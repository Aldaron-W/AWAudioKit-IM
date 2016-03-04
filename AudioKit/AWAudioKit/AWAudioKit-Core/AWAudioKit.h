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

@class AWAudioKit;

@protocol AWAudioKitDelegate <NSObject>

- (void)audioRecorder:(AWAudioKit *)audioRecorder currentRecordVolume:(float)volume;

@end

@interface AWAudioKit : NSObject

//Delegate
@property (nonatomic, weak) id<AWAudioKitDelegate> delegate;

//Recording...
//@property (nonatomic, strong) MLAudioRecorder *recorder;
//@property (nonatomic, strong) AmrRecordWriter *amrWriter;
//@property (nonatomic, copy) NSString *filePath;
//@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;

- (void)prepareRecording;

- (void)recordingButtonAction:(id)item;

@end
