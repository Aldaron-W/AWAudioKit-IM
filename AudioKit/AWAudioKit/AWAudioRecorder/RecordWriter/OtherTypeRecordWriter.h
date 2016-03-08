//
//  OtherTypeRecordWriter.h
//  Pods
//
//  Created by AldaronWang on 16/3/8.
//
//

#import <Foundation/Foundation.h>
#import "AWFileWriterProtocol.h"

@interface OtherTypeRecordWriter : NSObject<AWFileWriterForAWAudioRecorder>

@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) unsigned long maxFileSize;
@property (nonatomic, assign) double maxSecondCount;
@property (nonatomic, assign) double recordedSecondCount;
@property (nonatomic, assign) unsigned long recordedFileSize;

@end
