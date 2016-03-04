//
//  AWAudioMeterObserver.h
//  Pods
//
//  Created by AldaronWang on 16/2/18.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class AWAudioMeterObserver;

@protocol AWAudioMeterObserverDelegate <NSObject>

- (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer currentLevelMetterStates:(NSArray *)levelMeterStates;
- (void)AWAudioMeterObserver:(AWAudioMeterObserver *)observer error:(NSError *)error;

@end

/**
 *  AudioQueueLevelMeterState 结构体的OC替代类
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

@property (nonatomic, assign) AudioQueueRef audioQueue;
@property (nonatomic, weak) id<AWAudioMeterObserverDelegate> delegate;

@end
