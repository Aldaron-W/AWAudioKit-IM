//
//  MP3RecordWriter.m
//  Pods
//
//  Created by AldaronWang on 16/3/4.
//
//

#import "MP3RecordWriter.h"
#import <lame.h>

@interface MP3RecordWriter (){
    FILE *_file;
    lame_t _lame;
}

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) unsigned long maxFileSize;
@property (nonatomic, assign) double maxSecondCount;
@property (nonatomic, assign) double recordedSecondCount;
@property (nonatomic, assign) unsigned long recordedFileSize;

@end

@implementation MP3RecordWriter

- (void)initLame{
    // mp3压缩参数
    _lame = lame_init();
    lame_set_num_channels(_lame, 1);
    lame_set_in_samplerate(_lame, 8000);
    lame_set_out_samplerate(_lame, 8000);
    lame_set_brate(_lame, 128);
    lame_set_mode(_lame, 1);
    lame_set_quality(_lame, 2);
    lame_init_params(_lame);
}

/**
 *  在录音开始时候建立文件和写入文件头信息等操作
 *
 */
- (BOOL)createFileWithRecorder:(AWAudioRecorder*)recoder;
{
    [self initLame];
    
    //建立mp3文件
    _file = fopen((const char *)[self.filePath UTF8String], "wb+");
    if (_file==0) {
        //DLOG(@"建立文件失败:%s",__FUNCTION__);
        return NO;
    }
    
    self.recordedFileSize = 0;
    self.recordedSecondCount = 0;
    
    return YES;
}

/**
 *  写入音频输入数据，内部处理转码等其他逻辑
 *  能传递过来的都传递了。以方便多能扩展使用
 */
- (BOOL)writeIntoFileWithData:(NSData*)data
                 withRecorder:(AWAudioRecorder*)recoder
                         inAQ:(AudioQueueRef)inAQ
                  inStartTime:(const AudioTimeStamp *)inStartTime
                 inNumPackets:(UInt32)inNumPackets
                 inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc{
    if (self.maxSecondCount>0){
        if (self.recordedSecondCount + recoder.bufferDurationSeconds > self.maxSecondCount){
            //            //DLOG(@"录音超时");
            dispatch_async(dispatch_get_main_queue(), ^{
                [recoder stopRecording];
            });
            return YES;
        }
        self.recordedSecondCount += recoder.bufferDurationSeconds;
    }
    
    //编码
    short *recordingData = (short*)data.bytes;
    int pcmLen = data.length;
    
    if (pcmLen<2){
        return YES;
    }
    
    int nsamples = pcmLen / 2;
    
    unsigned char buffer[pcmLen];
    // mp3 encode
    int recvLen = lame_encode_buffer(_lame, recordingData, recordingData, nsamples, buffer, pcmLen);
    // add NSMutable
    if (recvLen>0) {
        if (self.maxFileSize>0){
            if(self.recordedFileSize+recvLen>self.maxFileSize){
                //                    //DLOG(@"录音文件过大");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [recoder stopRecording];
                });
                return YES;//超过了最大文件大小就直接返回
            }
        }
        
        if(fwrite(buffer,1,recvLen,_file)==0){
            return NO;
        }
        self.recordedFileSize += recvLen;
    }
    
    return YES;
}

/**
 *  文件写入完成之后的操作，例如文件句柄关闭等,isError表示是否是因为错误才调用的
 *
 */
- (BOOL)completeWriteWithRecorder:(AWAudioRecorder*)recoder withIsError:(BOOL)isError{
    //关闭就关闭吧。管他关闭成功与否
    if(_file){
        fclose(_file);
        _file = 0;
    }
    
    if(_lame){
        lame_close(_lame);
        _lame = 0;
    }
    
    return YES;
}

- (void)dealloc{
    if(_file){
        fclose(_file);
        _file = 0;
    }
    
    if(_lame){
        lame_close(_lame);
        _lame = 0;
    }
}

@end