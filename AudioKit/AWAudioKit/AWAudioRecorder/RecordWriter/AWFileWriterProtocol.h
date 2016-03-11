//
//  AWFileWriterProtocol.h
//  Pods
//
//  Created by AldaronWang on 16/3/4.
//
//

#import <AudioToolbox/AudioToolbox.h>
#import "AWRecordWriterHelper.h"

@class AWAudioRecorder;

#ifndef AWFileWriterProtocol_h
#define AWFileWriterProtocol_h

/**
 *  处理写文件操作的，实际是转码的操作在其中进行。算作可扩展自定义的转码器
 *  当然如果是实时语音的需求的话，就可以在此处理编码后发送语音数据到对方
 *  PS:这里的三个方法是在后台线程中处理的
 */
@protocol AWFileWriterForAWAudioRecorder <NSObject>

@optional
- (AudioStreamBasicDescription)customAudioFormatBeforeCreateFile;


/**
 *  在录音开始时候建立文件和写入文件头信息等操作
 *
 */
@required
- (BOOL)createFileWithRecorder:(AWAudioRecorder*)recoder;

/**
 *  写入音频输入数据，内部处理转码等其他逻辑
 *  能传递过来的都传递了。以方便多能扩展使用
 */
@required
- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(AWAudioRecorder*)recoder inAQ:(AudioQueueRef) inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc;

/**
 *  文件写入完成之后的操作，例如文件句柄关闭等,isError表示是否是因为错误才调用的
 *
 */
@required
- (BOOL)completeWriteWithRecorder:(AWAudioRecorder*)recoder withIsError:(BOOL)isError;

- (void)setFilePath:(NSString *)filePath;
- (NSString *)filePath;

- (void)setMaxFileSize:(double)fileSize;

- (void)setMaxSecondCount:(double)maxSecondCount;

- (double)recordedSecondCount;
/**
 *  获取录音文件的后缀
 *
 *  @return 文件的后缀
 */
- (NSString *)fileSuffix;

@end

#endif /* AWFileWriterProtocol_h */
