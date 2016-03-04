//
//  AWAudioMeterObserver.m
//  Pods
//
//  Created by AldaronWang on 16/2/18.
//
//

#import "AWAudioMeterObserver.h"
#import "AWAudioHelper.h"

#define kDefaultRefreshInterval 0.1 //默认0.1秒刷新一次

#define AW_RecallErrorAndReturn(error) \
    if (error) {\
        AW_RecallError(error);\
        return ;\
    }

#define AW_RecallError(error) [self recallErrorInfo:error]

@implementation AWLevelMeterState
@end

@interface AWAudioMeterObserver ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger channelCount;
@property (nonatomic, assign) NSTimeInterval refreshInterval; //刷新间隔,默认0.1

@end

@implementation AWAudioMeterObserver

- (instancetype)init{
    self = [super init];
    if (self) {
        //这里默认用_设置下吧。免得直接初始化了timer
        _refreshInterval = kDefaultRefreshInterval;
        self.channelCount = 1;
        //象征性的初始化一下
        _levelMeterStates = (AudioQueueLevelMeterState*)malloc(sizeof(AudioQueueLevelMeterState) * self.channelCount);
    }
    return self;
}

- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    
    free(_levelMeterStates);
    
    //DLOG(@"MLAudioMeterObserver dealloc");
}

#pragma mark - setter and getter
- (void)setRefreshInterval:(NSTimeInterval)refreshInterval{
    _refreshInterval = refreshInterval;
    
    //重置timer
    [self.timer invalidate];
    self.timer = [NSTimer
                  scheduledTimerWithTimeInterval:refreshInterval
                  target:self
                  selector:@selector(refresh)
                  userInfo:nil
                  repeats:YES
                  ];
}

- (void)setAudioQueue:(AudioQueueRef)audioQueue{
    NSError *error = nil;
    
    if ((_audioQueue!=NULL && audioQueue == _audioQueue) || (audioQueue==NULL)){
        //一样的就无需再处理
        return;
    }
    
    //处理关闭定时器
    [self.timer invalidate];
    self.timer = nil;
    
    _audioQueue = audioQueue;
    
    
    //检测这玩意是否支持光谱图
    UInt32 val = 1;
    [AWAudioHelper setProperty:audioQueue propertyID:kAudioQueueProperty_EnableLevelMetering dataSize:sizeof(UInt32) data:&val error:&error];
    AW_RecallErrorAndReturn(error);
    
    if (!val){
        //DLOG(@"不支持光谱图"); //需要发送错误
        return;
    }
    
    // now check the number of channels in the new queue, we will need to reallocate if this has changed
    AudioStreamBasicDescription queueFormat;
    UInt32 data_sz = sizeof(queueFormat);
    [AWAudioHelper getProperty:audioQueue propertyID:kAudioQueueProperty_StreamDescription dataSize:&data_sz data:&queueFormat error:&error];
    AW_RecallErrorAndReturn(error);
    
    self.channelCount = queueFormat.mChannelsPerFrame;
    
    //重新初始化大小
    _levelMeterStates = (AudioQueueLevelMeterState*)realloc(_levelMeterStates, self.channelCount * sizeof(AudioQueueLevelMeterState));
    
    //重新设置timer
    self.timer = [NSTimer
                  scheduledTimerWithTimeInterval:self.refreshInterval
                  target:self
                  selector:@selector(refresh)
                  userInfo:nil
                  repeats:YES
                  ];
}

/**
 *  回调函数
 *  每次回调的时候会通过获取AudioQueue的 kAudioQueueProperty_CurrentLevelMeterDB 参数，以获取当前录取录音的音量分贝值。
 *  在回调中可以获取AWLevelMeterState类型数据
 */
- (void)refresh{
    NSError *error = nil;
    UInt32 data_sz = (UInt32)(sizeof(AudioQueueLevelMeterState) * self.channelCount);
    
    [AWAudioHelper getProperty:_audioQueue propertyID:kAudioQueueProperty_CurrentLevelMeterDB dataSize:&data_sz data:_levelMeterStates error:&error];
    AW_RecallErrorAndReturn(error);
    
    //转化成LevelMeterState数组传递到block
    NSMutableArray *meters = [NSMutableArray arrayWithCapacity:self.channelCount];
    
    for (int i=0; i<self.channelCount; i++)
    {
        AWLevelMeterState *state = [[AWLevelMeterState alloc]init];
        state.mAveragePower = _levelMeterStates[i].mAveragePower;
        state.mPeakPower = _levelMeterStates[i].mPeakPower;
        [meters addObject:state];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(AWAudioMeterObserver:currentLevelMetterStates:)]) {
        [self.delegate AWAudioMeterObserver:self currentLevelMetterStates:meters];
    }
}

#pragma mark - Error
- (void)recallErrorInfo:(NSError *)error{
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AWAudioMeterObserver:error:)]) {
            [self.delegate AWAudioMeterObserver:self error:error];
        }
    }
}


@end
