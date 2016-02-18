//
//  ViewController.m
//  AWAudioKitDemo
//
//  Created by AldaronWang on 16/2/16.
//  Copyright © 2016年 Aldaron. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AWAudioRecorderDelegate
- (void)audioRecorder:(AWAudioRecorder *)audioRecorder currentRecordVolume:(float)volume{
    
}

#pragma mark - Actions
- (IBAction)recordButtonTouched:(id)sender {
    NSLog(@"Begin Recording.......");
}

#pragma mark - Getter
- (AWAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        _audioRecorder = [[AWAudioRecorder alloc] init];
        [_audioRecorder setDelegate:self];
    }
    return _audioRecorder;
}

@end
