//
//  AWAudioRecorderHelper.h
//  Pods
//
//  Created by AldaronWang on 16/3/4.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AWAudioHelper : NSObject

#pragma mark - Audio Set & Get Property and Parameter
+ (BOOL)setProperty:(AudioQueueRef)audioQueue propertyID:(AudioQueuePropertyID)propertyID dataSize:(UInt32)dataSize data:(const void *)data error:(NSError *__autoreleasing *)outError;

+ (BOOL)getProperty:(AudioQueueRef)audioQueue propertyID:(AudioQueuePropertyID)propertyID dataSize:(UInt32 *)dataSize data:(void *)data error:(NSError *__autoreleasing *)outError;

+ (BOOL)setParameter:(AudioQueueRef)audioQueue propertyID:(AudioQueueParameterID)parameterId value:(AudioQueueParameterValue)value error:(NSError *__autoreleasing *)outError;

+ (BOOL)getParameter:(AudioQueueRef)audioQueue propertyID:(AudioQueueParameterID)parameterId value:(AudioQueueParameterValue *)value error:(NSError *__autoreleasing *)outError;

@end
