//
//  AWRecordWriterHelper.h
//  Pods
//
//  Created by AldaronWang on 16/3/11.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kAWSampleRate_Low = 8000,
    kAWSampleRate_Medium = 22050,
    kAWSampleRate_High = 44100,
    kAWSampleRate_VeryHigh = 47250,
} kAWSampleRate;

@interface AWRecordWriterHelper : NSObject

+ (Float64)getDefultSampleRate;

@end
