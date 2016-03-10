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
- (void)audioRecorder:(AWAudioKit *)audioRecorder currentRecordVolume:(float)volume{

}

- (void)audioRecorder:(AWAudioKit *)audioRecorder currentRecordTime:(float)time{
    NSLog(@"Audio Recording Time : %.1f", time);
}

- (void)audioRecorderRecordingDidFinish:(AWAudioKit *)audioRecorder andFilePath:(NSString *)filePath durtionOfAudioFile:(float)durtion error:(NSError *)error{
    NSLog(@"FilePath : %@ \n Durtion : %f \n ", filePath, durtion);
}

#pragma mark - Actions
- (IBAction)recordButtonTouched:(id)sender {
    
    if ([self.audioRecorder isRecording]) {
        NSLog(@"Stop Recording.......");
        [self.recordButton setTitle:@"录音" forState:UIControlStateNormal];
        [self.audioRecorder stopRecording];
    }
    else{
        NSLog(@"Begin Recording.......");
        [self.recordButton setTitle:@"停止录音" forState:UIControlStateNormal];
        [self.audioRecorder startRecording];
    }
}

#pragma mark - Getter
- (AWAudioKit *)audioRecorder{
    if (!_audioRecorder) {
        _audioRecorder = [[AWAudioKit alloc] init];
        [_audioRecorder setDelegate:self];
    }
    return _audioRecorder;
}

@end
