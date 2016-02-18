//
//  AWAudioRecorder.m
//  Pods
//
//  Created by AldaronWang on 16/2/17.
//
//

#import "AWAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

/**
 *  缓存区的个数，3个一般不用改
 */
#define kAW_NumberAudioQueueBuffers 3

/**
 *  每次的音频输入队列缓存区所保存的是多少秒的数据
 */
#define kAW_DefaultBufferDurationSeconds 0.5
/**
 *  采样率，要转码为amr的话必须为8000
 */
#define kAW_DefaultSampleRate 8000

#define kAWAudioRecorderErrorDomain @"AWAudioRecorderErrorDomain"

#define AW_RecallErrorAndReturn(error) \
    if (error) {\
        AW_RecallError(error);\
        return ;\
    }

#define AW_RecallErrorWithErrorCode(errorCode) AW_RecallError([self getErrorWithErrorCode:errorCode])

#define AW_RecallError(error) [self recallErrorInfo:error]

@interface AWAudioRecorder (){
    //音频输入队列
    AudioQueueRef				_audioQueue;
    //音频输入数据format
    AudioStreamBasicDescription	_recordFormat;
    //音频输入缓冲区
    AudioQueueBufferRef	_audioBuffers[kAW_NumberAudioQueueBuffers];
}

/**
 *  是否正在录音
 */
@property (atomic, assign) BOOL isRecording;
/**
 *  录音的采样率。默认：8000
 */
@property (atomic, assign, getter=getSampleRate) NSUInteger sampleRate;
/**
 *  缓冲区采集的秒数。默认：0.5秒
 */
@property (atomic, assign, getter=getBufferDurationSeconds) double bufferDurationSeconds;

@property (nonatomic, strong) NSLock *propertyLock;

@end

@implementation AWAudioRecorder

#pragma mark - Object life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        //建立写入文件线程队列,串行，和一个信号量标识
//        self.writeFileQueue = dispatch_queue_create("cn.aldaron.AWAudioRecorder.writeFileQueue", NULL);
        
        self.sampleRate = kAW_DefaultSampleRate;
        self.bufferDurationSeconds = kAW_DefaultBufferDurationSeconds;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruption:)
                                                     name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

#pragma mark - Public methods
- (void)startRecording{
    
}

- (void)stopRecording{
    if (self.isRecording) {
        self.isRecording = NO;
        
        //Recall
        if (self.delegate && [self.delegate respondsToSelector:@selector(awAudioRecorderDidStoppedRecording:)]) {
            [self.delegate awAudioRecorderDidStoppedRecording:self];
        }
    }
    else{
        AW_RecallErrorWithErrorCode(AWAudioRecorderErrorCodeDoublePerformStopRecordingMethod);
    }
}

- (void)prepareRecordingWithSampleRate:(NSUInteger)sampleRate andBufferDurationSeconds:(double)bufferDurationSeconds error:(NSError **)error{
    NSParameterAssert(sampleRate > 0);
    NSParameterAssert(bufferDurationSeconds > 0);
    
    [self setSampleRate:sampleRate];
    [self setBufferDurationSeconds:bufferDurationSeconds];
}

#pragma mark - Private methods
#pragma mark Prepare recording environment
/**
 *  初始化录音环境
 */
- (void)prepareRecordingEnvironment{
    
}

- (void)prepareAudioSession{
    NSError *error = nil;
    OSStatus errorCode = noErr;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    AW_RecallErrorAndReturn(error)
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    AW_RecallErrorAndReturn(error)
    
    _recordFormat.mSampleRate = self.sampleRate;
    
    errorCode = AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
    if (errorCode != noErr) {
        AW_RecallErrorWithErrorCode(AWAudioRecorderErrorCodeAboutQueue);
        return;
    }
    
    //计算估算的缓存区大小
    int frames = (int)ceil(self.bufferDurationSeconds * _recordFormat.mSampleRate);
    int bufferByteSize = frames * _recordFormat.mBytesPerFrame;
    
    //创建缓冲器
    for (int i = 0; i < kAW_NumberAudioQueueBuffers; ++i){
        errorCode = AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
        if (errorCode != noErr) {
            AW_RecallErrorWithErrorCode(AWAudioRecorderErrorCodeAboutQueue);
            return;
        }
        errorCode = AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
        if (errorCode != noErr) {
            AW_RecallErrorWithErrorCode(AWAudioRecorderErrorCodeAboutQueue);
            return;
        }
    }
    
    //开始录音
    AudioQueueStart(_audioQueue, NULL);
    if (errorCode != noErr) {
        AW_RecallErrorWithErrorCode(AWAudioRecorderErrorCodeAboutQueue);
        return;
    }
    
    self.isRecording = YES;
}

// 回调函数
void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    AWAudioRecorder *recorder = (__bridge AWAudioRecorder*)inUserData;
    
    if (inNumPackets > 0) {
        NSData *pcmData = [[NSData alloc]initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        if (pcmData&&pcmData.length>0) {
            //TODO: 写入文件
        }
    }
    if (recorder.isRecording) {
        if(AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL)!=noErr){
            recorder.isRecording = NO; //这里直接设置下，能防止队列中3个缓存，重复post error
            //回到主线程
            dispatch_async(dispatch_get_main_queue(),^{
                [recorder recallErrorInfo:[recorder getErrorWithErrorCode:AWAudioRecorderErrorCodeAboutQueue]];
            });
        }
    }
}

#pragma mark - Tools
#pragma mark Recall Error
- (void)recallErrorInfoAndStopRecording:(NSError *)error{
    [self recallErrorInfo:error];
    
    if (self.isRecording) {
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        [self stopRecording];
    }
}

- (void)recallErrorInfo:(NSError *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(awAudioRecorderRecordingError:error:)]) {
        [self.delegate awAudioRecorderRecordingError:self error:error];
    }
}

#pragma mark Error
- (NSError *)getErrorWithErrorCode:(AWAudioRecorderErrorCode)errorCode{
    NSError *error = nil;
    NSString *description = nil;
    
    switch (errorCode) {
        case AWAudioRecorderErrorCodeAboutFile:
            description = @"关于文件操作的错误";
            break;
        case AWAudioRecorderErrorCodeAboutQueue:
            description = @"关于音频输入队列的错误";
            break;
        case AWAudioRecorderErrorCodeAboutSession:
            description = @"关于audio session的错误";
            break;
        case AWAudioRecorderErrorCodeDoublePerformStartRecordingMethod:
            description = @"重复调用StartRecording函数";
            break;
        case AWAudioRecorderErrorCodeDoublePerformStopRecordingMethod:
            description = @"重复调用StopRecording函数";
            break;
        case AWAudioRecorderErrorCodeAboutOther:
        default:
            description = @"其他错误";
            break;
    }
    
    error = [NSError errorWithDomain:kAWAudioRecorderErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:description}];
    
    return error;
}

#pragma mark - notification
- (void)sessionInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType interruptionType = [[[notification userInfo]
                                                        objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (AVAudioSessionInterruptionTypeBegan == interruptionType)
    {
        //DLOG(@"begin interruption");
        //直接停止录音
        [self stopRecording];
    }
    else if (AVAudioSessionInterruptionTypeEnded == interruptionType)
    {
        //DLOG(@"end interruption");
    }
}

#pragma mark - Getters
- (NSLock *)propertyLock{
    if (_propertyLock) {
        _propertyLock = [[NSLock alloc] init];
    }
    return _propertyLock;
}

- (NSUInteger)getSampleRate{
    [self.propertyLock lock];
    if (_sampleRate <= 0) {
        return kAW_DefaultSampleRate;
    }
    [self.propertyLock unlock];
    return _sampleRate;
}

- (double)getBufferDurationSeconds{
    if (_bufferDurationSeconds <= 0.0f) {
        return kAW_DefaultBufferDurationSeconds;
    }
    return _bufferDurationSeconds;
}

@end
