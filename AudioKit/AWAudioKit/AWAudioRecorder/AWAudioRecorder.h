//
//  AWAudioRecorder.h
//  Pods
//
//  Created by AldaronWang on 16/2/17.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 *  错误标识
 */
typedef NS_ENUM(NSUInteger, AWAudioRecorderErrorCode) {
    //====================      File        ====================
    /**
     *  关于文件操作的错误
     */
    AWAudioRecorderErrorCodeAboutFile = 0,
    
    //====================      Queue       ====================
    /**
     *  关于音频输入队列的错误
     */
    AWAudioRecorderErrorCodeAboutQueue = 10,
    /**
     *  关于audio session的错误
     */
    AWAudioRecorderErrorCodeAboutSession = 20,
    //====================      Control     ====================
    /**
     *  重复调用StartRecording函数
     */
    AWAudioRecorderErrorCodeDoublePerformStartRecordingMethod = 30,
    /**
     *  重复调用StopRecording函数
     */
    AWAudioRecorderErrorCodeDoublePerformStopRecordingMethod,
    //====================      Others      ====================
    /**
     *  其他
     */
    AWAudioRecorderErrorCodeAboutOther,
};

@class AWAudioRecorder;

@protocol AWAudioRecorderDelegate <NSObject>

@optional
- (void)awAudioRecorderDidStartRecording:(AWAudioRecorder *)audioRecorder;
- (void)awAudioRecorderDidStoppedRecording:(AWAudioRecorder *)audioRecorder;
- (void)awAudioRecorderRecordingError:(AWAudioRecorder *)audioRecorder error:(NSError *)error;

- (void)awAudioRecorder:(AWAudioRecorder *)audioRecorder currentVolume:(float)volume;


@end

@interface AWAudioRecorder : NSObject

#pragma mark - Readonly Property
/**
 *  是否正在录音
 */
@property (atomic, assign, readonly) BOOL isRecording;
/**
 *  录音的采样率。默认：8000
 */
@property (atomic, assign, readonly) NSUInteger sampleRate;
/**
 *  缓冲区采集的秒数。默认：0.5秒
 */
@property (atomic, assign, readonly) double bufferDurationSeconds;

#pragma mark - Public Property
/**
 *  录音的相关回调
 */
@property (nonatomic, weak) id<AWAudioRecorderDelegate> delegate;

#pragma mark - Public methods

/**
 *  在录音之前做的准备工作，此函数会获取采样率和缓冲区的采集秒数，并通过这两个参数初始化录音环境。
 *  !注:本函数仅在录音未开始或录音结束后才可以进行调用。若录音时调用的话，这两个参数均不会生效，也不会重新初始化录音环境。
 *      不过这两个参数均有默认值，而且在调用 startRecording 函数的时候会自动调取初始化录音环境的函数。
 *      所以如果没有特殊需求的话，可以不调用此函数，直接调用 startRecording 函数即可开始录音。
 *
 *  @param sampleRate            采样率
 *  @param bufferDurationSeconds 缓冲区采集秒数
 *  @param error                 初始化异常信息
 */
- (void)prepareRecordingWithSampleRate:(NSUInteger)sampleRate andBufferDurationSeconds:(double)bufferDurationSeconds error:(NSError **)error;

/**
 *  开始录音
 *  开始录音后会初始化录音环境，之后通过回调函数 AudioRecorderDidStartRecording:(AWAudioRecorder *)audioRecorder 通知delegate开始录音
 *  若当前正处在录音的状态的话，则无法初始化录音环境，也不会调用任何回调函数
 *  
 *  @see AWAudioRecorderDelegate
 *  @see - (void)AudioRecorderDidStartRecording:(AWAudioRecorder *)audioRecorder
 */
- (void)startRecording;

/**
 *  结束录音
 *  若当前不处在录音状态的话，无法停止录音，也不会调用任何回调函数
 */
- (void)stopRecording;

@end
