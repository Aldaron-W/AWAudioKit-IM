//
//  AWAudioRecorder.h
//  Pods
//
//  Created by AldaronWang on 16/2/17.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class AWAudioRecorder;

@protocol AWAudioRecorderDelegate <NSObject>

@optional
//- (void)AudioRecorderDidStartRecording:(AWAudioRecorder *)audioRecorder;
- (void)AudioRecorderDidStoppedRecording:(AWAudioRecorder *)audioRecorder;

- (void)AudioRecorder:(AWAudioRecorder *)audioRecorder currentVolume:(float)volume;

@end

@interface AWAudioRecorder : NSObject

#pragma mark - Readonly Property
/**
 *  是否正在录音
 */
@property (atomic, assign, readonly) BOOL isRecording;

#pragma mark - Public Property

/**
 *  这俩是当前的采样率和缓冲区采集秒数，根据情况可以设置(对其设置必须在startRecording之前才有效)，随意设置可能有意外发生。
 *  这俩属性被标识为原子性的，读取写入是线程安全的。
 */
@property (atomic, assign) NSUInteger sampleRate;
@property (atomic, assign) double bufferDurationSeconds;

@property (nonatomic, weak) id<AWAudioRecorderDelegate> delegate;

#pragma mark - Public methods

- (void)startRecording;
- (void)stopRecording;

@end
