//
//  AWAudioRecorder.m
//  Pods
//
//  Created by mafengwo on 16/2/16.
//
//

#import "AWAudioRecorder.h"

@implementation AWAudioRecorder

- (instancetype)init{
    self = [super init];
    if (self) {
        [self prepareRecording];
    }
    
    return self;
}

- (void)prepareRecording{
    
    AmrRecordWriter *amrWriter = [[AmrRecordWriter alloc] init];
    amrWriter.filePath = [self getAudioFilePath];
    amrWriter.maxSecondCount = 60;
    amrWriter.maxFileSize = 1024*256;
    self.amrWriter = amrWriter;
    
    MLAudioMeterObserver *meterObserver = [[MLAudioMeterObserver alloc]init];
    __weak __block typeof(self) wself = self;
    meterObserver.actionBlock = ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
        NSLog(@"volume:%f",[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]);
        float volume = [MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates];
        volume *= 5;
        
        volume = 25 + (40 * volume);
        
    };
    meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
        //        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    self.meterObserver = meterObserver;
    
    MLAudioRecorder *recorder = [[MLAudioRecorder alloc]init];
    recorder.receiveStoppedBlock = ^{
        
            wself.meterObserver.audioQueue = nil;
            
            if (wself.amrWriter.recordedSecondCount < 1.0f) {
//                [HintView hintViewWithText:@"录音时间过短，请重试" inView:wself.view];
                return;
            }
    };
    recorder.receiveErrorBlock = ^(NSError *error){
        //        [weakSelf.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        wself.meterObserver.audioQueue = nil;
        
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    
    recorder.fileWriterDelegate = amrWriter;
    recorder.bufferDurationSeconds = 0.25;
    self.filePath = amrWriter.filePath;
    
    self.recorder = recorder;
    
    MLAudioPlayer *player = [[MLAudioPlayer alloc]init];
    AmrPlayerReader *amrReader = [[AmrPlayerReader alloc]init];
    
    player.fileReaderDelegate = amrReader;
    player.receiveErrorBlock = ^(NSError *error){
        
        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    player.receiveStoppedBlock = ^{
        
    };
}

- (NSString *)getAudioFilePath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",fileName]];
    return path;
}

- (void)recordingButtonAction:(id)item
{
    if (self.recorder.isRecording) {
        //取消录音
        [self.recorder stopRecording];
    }else{
        //开始录音
        [self.recorder startRecording];
        self.meterObserver.audioQueue = self.recorder->_audioQueue;
    }
}

@end
