//
//  AWAudioRecorderHelper.m
//  Pods
//
//  Created by AldaronWang on 16/3/4.
//
//

#import "AWAudioHelper.h"

#define kAW_AudioRecorderErrorDomain @"AWAudioRecorderErrorDomain"

@implementation AWAudioHelper

#pragma mark - Audio Set & Get Property and Parameter
+ (BOOL)setProperty:(AudioQueueRef)audioQueue propertyID:(AudioQueuePropertyID)propertyID dataSize:(UInt32)dataSize data:(const void *)data error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioQueueSetProperty(audioQueue, propertyID, data, dataSize);
    [AWAudioHelper errorForOSStatus:status error:outError];
    return status == noErr;
}

+ (BOOL)getProperty:(AudioQueueRef)audioQueue propertyID:(AudioQueuePropertyID)propertyID dataSize:(UInt32 *)dataSize data:(void *)data error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioQueueGetProperty(audioQueue, propertyID, data, dataSize);
    [AWAudioHelper errorForOSStatus:status error:outError];
    return status == noErr;
}

+ (BOOL)setParameter:(AudioQueueRef)audioQueue propertyID:(AudioQueueParameterID)parameterId value:(AudioQueueParameterValue)value error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioQueueSetParameter(audioQueue, parameterId, value);
    [AWAudioHelper errorForOSStatus:status error:outError];
    return status == noErr;
}

+ (BOOL)getParameter:(AudioQueueRef)audioQueue propertyID:(AudioQueueParameterID)parameterId value:(AudioQueueParameterValue *)value error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioQueueGetParameter(audioQueue, parameterId, value);
    [AWAudioHelper errorForOSStatus:status error:outError];
    return status == noErr;
}

#pragma mark - error
+ (void)errorForOSStatus:(OSStatus)status error:(NSError *__autoreleasing *)outError
{
    if (status != noErr && outError != NULL)
    {
        *outError = [NSError errorWithDomain:kAW_AudioRecorderErrorDomain code:status userInfo:nil];
    }
}

@end
