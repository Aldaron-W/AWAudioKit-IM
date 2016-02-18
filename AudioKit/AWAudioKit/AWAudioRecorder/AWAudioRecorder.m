//
//  AWAudioRecorder.m
//  Pods
//
//  Created by AldaronWang on 16/2/17.
//
//

#import "AWAudioRecorder.h"

@interface AWAudioRecorder (){
    //音频输入队列
    AudioQueueRef				_audioQueue;
    //音频输入数据format
    AudioStreamBasicDescription	_recordFormat;
}

/**
 *  是否正在录音
 */
@property (atomic, assign) BOOL isRecording;

@end

@implementation AWAudioRecorder

@end
