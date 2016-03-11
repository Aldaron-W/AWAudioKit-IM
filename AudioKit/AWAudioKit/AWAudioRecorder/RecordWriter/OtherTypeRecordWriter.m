//
//  OtherTypeRecordWriter.m
//  Pods
//
//  Created by AldaronWang on 16/3/8.
//
//

#import "OtherTypeRecordWriter.h"
#import "AWAudioRecorder.h"

@interface OtherTypeRecordWriter (){
    AudioFileID _mFileID;
    SInt64 _mCurrentPacket;
}

@end

@implementation OtherTypeRecordWriter

- (AudioStreamBasicDescription)customAudioFormatBeforeCreateFile{
    AudioStreamBasicDescription basicDescription;
    memset(&basicDescription, 0, sizeof(basicDescription));
    
    basicDescription.mSampleRate = [AWRecordWriterHelper getDefultSampleRate];					// 采样率
    basicDescription.mChannelsPerFrame = 1;		// 声道数（单声道）
    basicDescription.mFramesPerPacket = 1;						// 一个数据包放一帧数据
    basicDescription.mBitsPerChannel = 8;						// 每个声道中的每个采样点用8bit数据量化
    basicDescription.mBytesPerFrame = (basicDescription.mBitsPerChannel / 8) * basicDescription.mChannelsPerFrame;	// 每帧的字节数(2个字节)
    basicDescription.mBytesPerPacket = basicDescription.mBytesPerFrame * basicDescription.mFramesPerPacket;
    basicDescription.mFormatID = kAudioFormatLinearPCM;
    basicDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
    self.basicDescription = basicDescription;
    return self.basicDescription;
}

/**
 *  在录音开始时候建立文件和写入文件头信息等操作
 *
 */
- (BOOL)createFileWithRecorder:(AWAudioRecorder*)recoder{
    self.fileData = [[NSMutableData alloc] init];
    
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)self.filePath, NULL);
    
    AudioStreamBasicDescription basicDescription = [self customAudioFormatBeforeCreateFile];
    
    AudioFileCreateWithURL(url, kAudioFileCAFType, &basicDescription, kAudioFileFlags_EraseFile, &_mFileID);
    
    CFRelease(url);
    
    return YES;
}

/**
 *  写入音频输入数据，内部处理转码等其他逻辑
 *  能传递过来的都传递了。以方便多能扩展使用
 */
- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(AWAudioRecorder*)recoder inAQ:(AudioQueueRef) inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc{
    [self.fileData appendData:data];
    self.recordedSecondCount += recoder.bufferDurationSeconds;
    
    AudioFileWritePackets(_mFileID, FALSE, (UInt32)data.length,
                          inPacketDesc, _mCurrentPacket, &inNumPackets, data.bytes);
    _mCurrentPacket += inNumPackets;
    
    return YES;
}

/**
 *  文件写入完成之后的操作，例如文件句柄关闭等,isError表示是否是因为错误才调用的
 *
 */
- (BOOL)completeWriteWithRecorder:(AWAudioRecorder*)recoder withIsError:(BOOL)isError{
    return YES;
}

/**
 *  获取录音文件的后缀
 *
 *  @return 文件的后缀
 */
- (NSString *)fileSuffix{
    return @"caf";
}

@end
