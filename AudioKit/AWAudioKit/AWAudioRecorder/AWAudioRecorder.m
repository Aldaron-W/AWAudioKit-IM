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

@interface AWAudioRecorder (){
    //音频输入队列
    AudioQueueRef				_audioQueue;
    //音频输入数据format
    AudioStreamBasicDescription	_recordFormat;
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
        [self recallErrorInfo:[self getErrorWithErrorCode:AWLAudioRecorderErrorCodeDoublePerformStopRecordingMethod]];
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
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
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
        case AWLAudioRecorderErrorCodeAboutQueue:
            description = @"关于音频输入队列的错误";
            break;
        case AWAudioRecorderErrorCodeAboutSession:
            description = @"关于audio session的错误";
            break;
        case AWLAudioRecorderErrorCodeDoublePerformStartRecordingMethod:
            description = @"重复调用StartRecording函数";
            break;
        case AWLAudioRecorderErrorCodeDoublePerformStopRecordingMethod:
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
