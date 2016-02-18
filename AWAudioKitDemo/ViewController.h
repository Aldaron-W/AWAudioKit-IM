//
//  ViewController.h
//  AWAudioKitDemo
//
//  Created by AldaronWang on 16/2/16.
//  Copyright © 2016年 Aldaron. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AWAudioKit/AWAudioKit-Core/AWAudioRecorder.h>

@interface ViewController : UIViewController <AWAudioRecorderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

#pragma mark Record
@property (nonatomic, strong) AWAudioRecorder *audioRecorder;

@end

