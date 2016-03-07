//
//  AWAudioRecorder.h
//  Pods
//
//  Created by AldaronWang on 16/2/16.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//#import "AmrRecordWriter.h"
//#import "MLAudioMeterObserver.h"
//#import "MLAudioPlayer.h"
//#import "AmrPlayerReader.h"


typedef enum : NSUInteger {
    kAWAudioFormat_None,
    kAWAudioFormat_MP3,
} AWAudioFormat;

@class AWAudioKit;

@protocol AWAudioKitDelegate <NSObject>

#pragma mark Beginning
/**
 *  录音即将开始
 *
 *  @param audioRecorder AWAudioKit对象
 */
- (void)audioRecorderRecordingWillBegin:(AWAudioKit *)audioRecorder;

#pragma mark Finishing
/**
 *  录音即将结束
 *
 *  @param audioRecorder AWAudioKit对象
 */
- (void)audioRecorderRecordingWillFinish:(AWAudioKit *)audioRecorder;

/**
 *  录音结束
 *
 *  @param audioRecorder AWAudioKit对象
 *  @param filePath      录音文件的路径
 *  @param durtion       录音的时长
 *  @param error         相关的异常信息（TODO：提示无存储空间等）
 */
- (void)audioRecorderRecordingDidFinish:(AWAudioKit *)audioRecorder andFilePath:(NSString *)filePath durtionOfAudioFile:(float)durtion error:(NSError *)error;

#pragma mark Recroding Prooerty
/**
 *  在录音当中反馈录音的分贝数
 *
 *  @param audioRecorder AWAudioKit对象
 *  @param volume        录音的分贝数（一般在50-80之间）
 */
- (void)audioRecorder:(AWAudioKit *)audioRecorder currentRecordVolume:(float)volume;


#pragma mark Recording Error
/**
 *  在录音准备、开始、结束过程当中会返回每一步的异常信息，若返回异常信息的话，则会自动终止录音过程，并会自动调用以上的相关回调函数
 *
 *  @param audioRecorder AWAudioKit对象
 *  @param error         异常信息
 */
- (void)audioRecorder:(AWAudioKit *)audioRecorder recordingError:(NSError *)error;

@end

@interface AWAudioKit : NSObject

//AWAudioKitDelegate
@property (nonatomic, weak) id<AWAudioKitDelegate> delegate;

//Private property
@property (nonatomic, assign, readonly) AWAudioFormat audioFileType;

@property (nonatomic, assign, readonly) BOOL isRecording;

#pragma mark - Public method
- (void)prepareRecordingWithRecordingType:(AWAudioFormat)recordingType;

- (void)startRecording;

- (void)stopRecording;

@end
