//
//  AWAudioRecorder.m
//  Pods
//
//  Created by AldaronWang on 16/2/16.
//
//

#import "AWAudioKit.h"

#import "AWAudioRecorderHeader.h"

@interface AWAudioKit () <AWAudioRecorderDelegate, AWAudioMeterObserverDelegate>

@property (nonatomic, strong) AWAudioRecorder *recorder;
@property (nonatomic, strong) AWAudioMeterObserver *meterObserver;
@property (nonatomic, strong) id<AWFileWriterForAWAudioRecorder> fileWriter;

//Private property
@property (nonatomic, assign) AWAudioFormat audioFileType;

@property (nonatomic, assign) BOOL isRecordingPrepare;

@end

@implementation AWAudioKit

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)prepareRecordingWithRecordingType:(AWAudioFormat)recordingType{
    switch (recordingType) {
        case kAWAudioFormat_MP3:{
            self.fileWriter = [MP3RecordWriter new];
            break;
        }
        default:{
            //若为无法识别类型的则无法初始化录音对象
            return;
            break;
        }
    }
    
    self.recorder.fileWriterDelegate = self.fileWriter;
}

#pragma mark - Private
- (NSString *)getAudioFilePath{
    NSString *path = @"";
    if (self.isRecordingPrepare) {
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName, [self getAudioFilePostfix]]];
    }
    
    return path;
}

- (NSString *)getAudioFilePostfix{
    switch (self.audioFileType) {
        case kAWAudioFormat_MP3:
            return @"mp3";
            break;
            
        default:
            return @"error";
            break;
    }
}

#pragma mark - Delegate
#pragma mark AWAudioRecorderDelegate
- (void)awAudioRecorderDidStartRecording:(AWAudioRecorder *)audioRecorder{
    
}
- (void)awAudioRecorderDidStoppedRecording:(AWAudioRecorder *)audioRecorder{
    
}
- (void)awAudioRecorderRecordingError:(AWAudioRecorder *)audioRecorder error:(NSError *)error{
    
}

- (void)awAudioRecorder:(AWAudioRecorder *)audioRecorder currentVolume:(float)volume{
    
}

#pragma mark AWAudioMeterObserverDelegate
- (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer currentLevelMetterStates:(NSArray *)levelMeterStates{
    
}

- (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer error:(NSError *)error{
    
}

#pragma mark - Getter
- (AWAudioRecorder *)recorder{
    if (!_recorder) {
        _recorder = [AWAudioRecorder new];
        _recorder.delegate = self;
    }
    return _recorder;
}

- (AWAudioMeterObserver *)meterObserver{
    if (!_meterObserver) {
        _meterObserver = [AWAudioMeterObserver new];
        _meterObserver.delegate = self;
    }
    return _meterObserver;
}

@end
