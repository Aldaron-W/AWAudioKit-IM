//
//  AWAudioRecorder.m
//  Pods
//
//  Created by AldaronWang on 16/2/16.
//
//

#import "AWAudioKit.h"

#import "AWAudioRecorderHeader.h"

@interface AWAudioKit () <AWAudioRecorderDelegate, AWAudioMeterObserverDelegate>{
    float _tempDurtion;//临时记录录音时间
}

@property (nonatomic, strong) AWAudioRecorder *recorder;
@property (nonatomic, strong) AWAudioMeterObserver *meterObserver;
@property (nonatomic, strong) id<AWFileWriterForAWAudioRecorder> fileWriter;

//Private property
@property (nonatomic, assign) AWAudioFormat audioFileType;
@property (nonatomic, assign) NSString *audioFilePath;

@property (nonatomic, assign) BOOL isRecordingPrepare;

@end

@implementation AWAudioKit

- (instancetype)init{
    self = [super init];
    if (self) {
        self.audioFileType = kAWAudioFormat_CAF;
    }
    
    return self;
}

- (void)startRecording{
    if (self.audioFileType != kAWAudioFormat_None) {
        [self prepareRecordingWithRecordingType:self.audioFileType];
        
        [self.recorder startRecording];
    }
}

- (void)stopRecording{
    [self.recorder stopRecording];
}

- (void)prepareRecordingWithRecordingType:(AWAudioFormat)recordingType{
    switch (recordingType) {
        case kAWAudioFormat_MP3:{
            self.fileWriter = [MP3RecordWriter new];
            break;
        }
        case kAWAudioFormat_CAF:{
            self.fileWriter = [OtherTypeRecordWriter new];
            break;
        }
        default:{
            //若为无法识别类型的则无法初始化录音对象
            return;
            break;
        }
    }
    
    self.recorder.fileWriterDelegate = self.fileWriter;
    
    [self prepareFileWriter];
}

- (void)prepareFileWriter{
    [self.fileWriter setFilePath:[self createAudioFilePath]];
    [self.fileWriter setMaxFileSize:1024*256];
    [self.fileWriter setMaxSecondCount:60];
}

#pragma mark - Private
- (NSString *)createAudioFilePath{
    NSString *path = @"";
    path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileName, [self getAudioFilePostfix]]];
    
    return path;
}

- (NSString *)getAudioFilePostfix{
    switch (self.audioFileType) {
        case kAWAudioFormat_MP3:
            return @"mp3";
            break;
        case kAWAudioFormat_CAF:{
            return @"caf";
        }
        default:
            return @"error";
            break;
    }
}

#pragma mark - Delegate
#pragma mark AWAudioRecorderDelegate
- (void)awAudioRecorderDidStartRecording:(AWAudioRecorder *)audioRecorder{
    self.meterObserver.audioQueue = [audioRecorder getAudioQueue];
    _tempDurtion = 0.0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorderRecordingWillBegin:)]) {
        [self.delegate audioRecorderRecordingWillBegin:self];
    }
}

- (void)awAudioRecorderDidStoppedRecording:(AWAudioRecorder *)audioRecorder{
    self.meterObserver.audioQueue = nil;
    _tempDurtion = 0.0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorderRecordingDidFinish:andFilePath:durtionOfAudioFile:error:)]) {
        [self.delegate audioRecorderRecordingDidFinish:self andFilePath:[self.fileWriter filePath] durtionOfAudioFile:[self.fileWriter recordedSecondCount] error:nil];
    }
}

- (void)awAudioRecorderRecordingError:(AWAudioRecorder *)audioRecorder error:(NSError *)error{
    self.meterObserver.audioQueue = nil;
    _tempDurtion = 0.0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:recordingError:)]) {
        [self.delegate audioRecorder:self recordingError:error];
    }
}

#pragma mark AWAudioMeterObserverDelegate
- (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer currentLevelMetterStates:(NSArray *)levelMeterStates{
    AWLevelMeterState *levelMeterState = [levelMeterStates firstObject];
    
    float volume = ([levelMeterState mAveragePower] * 10) / 0.5;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:currentRecordVolume:)]) {
        [self.delegate audioRecorder:self currentRecordVolume:volume];
    }
    
    _tempDurtion += observer.refreshInterval;
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:currentRecordTime:)]) {
        [self.delegate audioRecorder:self currentRecordTime:_tempDurtion];
    }
}

- (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer error:(NSError *)error{
    observer.audioQueue = nil;
    _tempDurtion = 0.0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:recordingError:)]) {
        [self.delegate audioRecorder:self recordingError:error];
    }
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

- (BOOL)isRecording{
    return [self.recorder isRecording];
}

@end
