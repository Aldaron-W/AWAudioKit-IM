//
//  MP3RecordWriter.h
//  Pods
//
//  Created by AldaronWang on 16/3/4.
//
//

#import <Foundation/Foundation.h>
#import "AWFileWriterProtocol.h"
#import "AWAudioRecorder.h"

@interface MP3RecordWriter : NSObject<AWFileWriterForAWAudioRecorder>

@end
