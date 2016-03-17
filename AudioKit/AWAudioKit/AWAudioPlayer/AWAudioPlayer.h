//
//  AWAudioPlayer.h
//  Pods
//
//  Created by Work on 16/3/17.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class AWAudioPlayer;

typedef void (^AWAudioPlayerReceiveStoppedBlock)();
typedef void (^AWAudioPlayerReceiveErrorBlock)(NSError *error);

/**
 *  错误标识
 */
typedef NS_OPTIONS(NSUInteger, AWAudioPlayerErrorCode) {
    AWAudioPlayerErrorCodeAboutFile = 0, //关于文件操作的错误
    AWAudioPlayerErrorCodeAboutQueue, //关于音频输入队列的错误
    AWAudioPlayerErrorCodeAboutSession, //关于audio session的错误
    AWAudioPlayerErrorCodeAboutOther, //关于其他的错误
};

@protocol FileReaderForMLAudioPlayer <NSObject>

@required
- (BOOL)openFileWithPlayer:(AWAudioPlayer*)player;
- (AudioStreamBasicDescription)customAudioFormatAfterOpenFile;
- (NSData*)readDataFromFileWithPlayer:(AWAudioPlayer*)player andBufferSize:(NSUInteger)bufferSize error:(NSError**)error;
- (BOOL)completeReadWithPlayer:(AWAudioPlayer*)player withIsError:(BOOL)isError;

@end

@interface AWAudioPlayer : NSObject
{
@public
    //音频输入队列
    AudioQueueRef				_audioQueue;
    //音频输入数据format
    AudioStreamBasicDescription	_audioFormat;
}


@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, weak) id<FileReaderForMLAudioPlayer> fileReaderDelegate;

@property (nonatomic, copy) AWAudioPlayerReceiveErrorBlock receiveErrorBlock;
@property (nonatomic, copy) AWAudioPlayerReceiveStoppedBlock receiveStoppedBlock;

- (void)startPlaying;
- (void)stopPlaying;

@end
