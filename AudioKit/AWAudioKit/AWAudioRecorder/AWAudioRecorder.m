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
#define kAW_DefaultBufferDurationSeconds 0.1
/**
 *  采样率，要转码为amr的话必须为8000
 */
#define kAW_DefaultSampleRate 8000

#define kAW_AudioRecorderErrorDomain @"AWAudioRecorderErrorDomain"

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

@property (nonatomic, strong) dispatch_queue_t writeFileQueue;
@property (nonatomic, strong) dispatch_semaphore_t semError; //一个信号量，用来保证队列中写文件错误事件处理只调用一次

@end

@implementation AWAudioRecorder

#pragma mark - Object life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        //建立写入文件线程队列,串行，和一个信号量标识
        self.writeFileQueue = dispatch_queue_create("cn.aldaron.AWAudioRecorder.writeFileQueue", NULL);
        
        self.sampleRate = kAW_DefaultSampleRate;
        self.bufferDurationSeconds = kAW_DefaultBufferDurationSeconds;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruption:)
                                                     name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public methods
- (void)startRecording{
    NSError *error = nil;
    
    [self prepareAudioSession:&error];
    AW_RecallErrorAndReturn(error)
    
    [self prepareRecordingDelegate:&error];
    AW_RecallErrorAndReturn(error)
    
    [self prepareRecordingEnvironment:&error];
    AW_RecallErrorAndReturn(error)
    
    //开始录音
    AudioQueueStart(_audioQueue, NULL);
//    if (errorCode != noErr) {
//        AW_RecallErrorWithErrorCode(AWAudioRecorderErrorCodeAboutQueue);
//        return;
//    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(awAudioRecorderDidStartRecording:)]) {
        [self.delegate awAudioRecorderDidStartRecording:self];
    }
    
    self.isRecording = YES;
}

- (void)stopRecording{
    if (self.isRecording) {
        self.isRecording = NO;
        
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
//        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        //Recall
        if (self.fileWriterDelegate && [self.fileWriterDelegate respondsToSelector:@selector(completeWriteWithRecorder:withIsError:)]) {
            [self.fileWriterDelegate completeWriteWithRecorder:self withIsError:NO];
        }
        
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

- (AudioQueueRef)getAudioQueue{
    return _audioQueue;
}

#pragma mark - Private methods
#pragma mark Prepare recording environment
/**
 *  初始化录音环境
 */
- (void)prepareRecordingEnvironment:(NSError **)error{
//    NSError *error = nil;
    OSStatus errorCode = noErr;
    
    //设定录音的回调函数
    errorCode = AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
    if (errorCode != noErr) {
        *error = [self getErrorWithErrorCode:errorCode];
        return;
    }
    
    //计算估算的缓存区大小
    int frames = (int)ceil(self.bufferDurationSeconds * _recordFormat.mSampleRate);
    int bufferByteSize = frames * _recordFormat.mBytesPerFrame;
    
    //创建缓冲器
    for (int i = 0; i < kAW_NumberAudioQueueBuffers; ++i){
        errorCode = AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
        if (errorCode != noErr) {
            *error = [self getErrorWithErrorCode:errorCode];
            return;
        }
        errorCode = AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
        if (errorCode != noErr) {
            *error = [self getErrorWithErrorCode:errorCode];
            return;
        }
    }
}

- (void)prepareAudioSession:(NSError **)error{
    OSStatus errorCode = noErr;
    
    //设置AVAudioSession的Category
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:error];
    AW_RecallErrorAndReturn(*error)
    
    //设置AVAudioSession的Active状态
    [[AVAudioSession sharedInstance] setActive:YES error:error];
    AW_RecallErrorAndReturn(*error)
    
    _recordFormat.mSampleRate = self.sampleRate;
}

- (void)prepareRecordingDelegate:(NSError **)error{
    if(!self.fileWriterDelegate ||
       ![self.fileWriterDelegate respondsToSelector:@selector(createFileWithRecorder:)] ||
       ![self.fileWriterDelegate respondsToSelector:@selector(writeIntoFileWithData:withRecorder:inAQ:inStartTime:inNumPackets:inPacketDesc:)] ||
       ![self.fileWriterDelegate respondsToSelector:@selector(completeWriteWithRecorder:withIsError:)]){
//        [self postAErrorWithErrorCode:MLAudioRecorderErrorCodeAboutOther andDescription:@"fileWriterDelegate的代理未设置或其代理方法不完整"];
        return;
    }
    
    //设置录音的format数据
    if (self.fileWriterDelegate&&[self.fileWriterDelegate respondsToSelector:@selector(customAudioFormatBeforeCreateFile)]) {
        dispatch_sync(self.writeFileQueue, ^{
            AudioStreamBasicDescription format = [self.fileWriterDelegate customAudioFormatBeforeCreateFile];
            memcpy(&_recordFormat, &format,sizeof(_recordFormat));
        });
    }else{
        [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:self.sampleRate];
    }
    _recordFormat.mSampleRate = self.sampleRate;
    
    
    //建立文件,顺便同步下串行队列，防止意外前面有没处理的
    __block BOOL isContinue = YES;;
    dispatch_sync(self.writeFileQueue, ^{
        if(self.fileWriterDelegate&&![self.fileWriterDelegate createFileWithRecorder:self]){
            dispatch_async(dispatch_get_main_queue(),^{
//                [self postAErrorWithErrorCode:MLAudioRecorderErrorCodeAboutFile andDescription:@"为音频输入建立文件失败"];
            });
            isContinue = NO;
        }
    });
    if(!isContinue){
        return;
    }
    
    self.semError = dispatch_semaphore_create(0); //重新初始化信号量标识
    dispatch_semaphore_signal(self.semError); //设置有一个信号
}

// 回调函数
void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    AWAudioRecorder *recorder = (__bridge AWAudioRecorder*)inUserData;
    
    if (inNumPackets > 0) {
        NSData *pcmData = [[NSData alloc]initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        if (pcmData&&pcmData.length>0) {
            //在后台串行队列中去处理文件写入
            dispatch_async(recorder.writeFileQueue, ^{
                if(recorder.fileWriterDelegate &&
                   ![recorder.fileWriterDelegate writeIntoFileWithData:pcmData withRecorder:recorder inAQ:inAQ inStartTime:inStartTime inNumPackets:inNumPackets inPacketDesc:inPacketDesc]){
                    //保证只处理了一次
                    if (dispatch_semaphore_wait(recorder.semError,DISPATCH_TIME_NOW)==0){
                        //回到主线程
                        dispatch_async(dispatch_get_main_queue(),^{
//                            [recorder postAErrorWithErrorCode:MLAudioRecorderErrorCodeAboutFile andDescription:@"写入文件失败"];
                        });
                    }
                }
            });
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

#pragma mark Audio Format
// 设置录音格式
- (void)setupAudioFormat:(UInt32) inFormatID SampleRate:(int)sampeleRate
{
    //重置下
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    
    //设置采样率，这里先获取系统默认的测试下 //TODO:
    //采样率的意思是每秒需要采集的帧数
    _recordFormat.mSampleRate = sampeleRate;//[[AVAudioSession sharedInstance] sampleRate];
    
    //设置通道数,这里先使用系统的测试下 //TODO:
    _recordFormat.mChannelsPerFrame = 1;//(UInt32)[[AVAudioSession sharedInstance] inputNumberOfChannels];
    
    //    //DLOG(@"sampleRate:%f,通道数:%d",_recordFormat.mSampleRate,_recordFormat.mChannelsPerFrame);
    
    //设置format，怎么称呼不知道。
    _recordFormat.mFormatID = inFormatID;
    
    if (inFormatID == kAudioFormatLinearPCM){
        //这个屌属性不知道干啥的。，
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        //每个通道里，一帧采集的bit数目
        _recordFormat.mBitsPerChannel = 16;
        //结果分析: 8bit为1byte，即为1个通道里1帧需要采集2byte数据，再*通道数，即为所有通道采集的byte数目。
        //所以这里结果赋值给每帧需要采集的byte数目，然后这里的packet也等于一帧的数据。
        //至于为什么要这样。。。不知道。。。
        _recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
        _recordFormat.mFramesPerPacket = 1;
    }
    else{
        //这个屌属性不知道干啥的。，
        _recordFormat.mFormatFlags = 0;
        //每个通道里，一帧采集的bit数目
        _recordFormat.mBitsPerChannel = 0;
        //结果分析: 8bit为1byte，即为1个通道里1帧需要采集2byte数据，再*通道数，即为所有通道采集的byte数目。
        //所以这里结果赋值给每帧需要采集的byte数目，然后这里的packet也等于一帧的数据。
        //至于为什么要这样。。。不知道。。。
        _recordFormat.mBytesPerPacket = 1024;
        _recordFormat.mFramesPerPacket = 0;
    }
}

#pragma mark - Tools
#pragma mark Recall Error
- (void)recallErrorInfoAndStopRecording:(NSError *)error{
    [self recallErrorInfo:error];
    
    if (self.isRecording) {
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
    
    error = [NSError errorWithDomain:kAW_AudioRecorderErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:description}];
    
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
