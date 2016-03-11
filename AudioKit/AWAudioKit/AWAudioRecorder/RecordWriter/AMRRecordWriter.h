//
//  AMRRecordWriter.h
//  Pods
//
//  Created by AldaronWang on 16/3/11.
//
//

#import <Foundation/Foundation.h>
#import "AWFileWriterProtocol.h"
#import "AWAudioRecorder.h"

@interface AMRRecordWriter : NSObject<AWFileWriterForAWAudioRecorder>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) unsigned long maxFileSize;
@property (nonatomic, assign) double maxSecondCount;
@property (nonatomic, assign) double recordedSecondCount;
@property (nonatomic, assign) unsigned long recordedFileSize;

@end
