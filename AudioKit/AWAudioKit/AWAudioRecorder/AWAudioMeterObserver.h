//
//  AWAudioMeterObserver.h
//  Pods
//
//  Created by AldaronWang on 16/2/18.
//
//

/*
    AWAudioMeterObserver
    AWAudioMeterObserver类的主要功能是观察指定 AudioQueueRef 中获取当前录音的音量分贝数
    并通过 - (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer currentLevelMetterStates:(NSArray *)levelMeterStates 函数返回给 degegate
 
    若获取的过程当中出现异常的话则会通过 - (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer error:(NSError *)error 函数返回给 degeagte
 */

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class AWAudioMeterObserver;

@protocol AWAudioMeterObserverDelegate <NSObject>

- (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer currentLevelMetterStates:(NSArray *)levelMeterStates;
- (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer error:(NSError *)error;

@end

/**
 *  AudioQueueLevelMeterState 结构体的OC替代类
 *  Specifies the current level metering information for one channel of an audio queue.
 *
 *  @param mAveragePower The audio channel's average RMS power.
 *
 *  @param mPeakPower The audio channel's peak RMS power
 *
 *  @see AudioQueueLevelMeterState
 */
@interface AWLevelMeterState : NSObject
@property (nonatomic, assign) Float32 mAveragePower;
@property (nonatomic, assign) Float32 mPeakPower;
@end

@interface AWAudioMeterObserver : NSObject
{
    AudioQueueLevelMeterState	*_levelMeterStates;
}

@property (nonatomic, assign, readonly) NSTimeInterval refreshInterval; //刷新间隔,默认0.1
@property (nonatomic, assign) AudioQueueRef audioQueue;
@property (nonatomic, weak) id<AWAudioMeterObserverDelegate> delegate;

@end
