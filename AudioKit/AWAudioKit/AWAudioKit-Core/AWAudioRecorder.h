//
//  AWAudioRecorder.h
//  Pods
//
//  Created by mafengwo on 16/2/16.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "AmrRecordWriter.h"
#import "MLAudioMeterObserver.h"
#import "MLAudioPlayer.h"
#import "AmrPlayerReader.h"

@class AWAudioRecorder;

@protocol AWAudioRecorderDelegate <NSObject>

- (void)audioRecorder:(AWAudioRecorder *)audioRecorder currentRecordVolume:(float)volume;

@end

@interface AWAudioRecorder : NSObject

//Delegate
@property (nonatomic, weak) id<AWAudioRecorderDelegate> delegate;

//Recording...
@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) AmrRecordWriter *amrWriter;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;

- (void)prepareRecording;

- (void)recordingButtonAction:(id)item;

@end
