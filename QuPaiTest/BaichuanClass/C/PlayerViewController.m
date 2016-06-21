//
//  PlayerViewController.m
//  AVPlayerLayer
//
//  Created by 熊云桥 on 16/6/21.
//  Copyright © 2016年 熊云桥. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController ()
{
    __weak IBOutlet UIView *_playView;
    
    __weak IBOutlet UIProgressView *_progressView;
    
    __weak IBOutlet UILabel *_currentTimeLabel;
    
    __weak IBOutlet UILabel *_totalTimeLabel;
    
    __weak IBOutlet UIButton *_playBtn;
    __weak IBOutlet UIButton *_fullScreenBtn;
    AVPlayerLayer *_playLayer;
    
    BOOL _isRotation;
    
    BOOL _isPlaying;
    
    NSTimer *_timer;
}
@end

@implementation PlayerViewController

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    _playLayer.frame = _playView.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:self.urlString]];
    
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [_playView.layer addSublayer:playLayer];
    _playLayer = playLayer;
    
    [self updateProgress];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [_playView addGestureRecognizer:doubleTap];
    
    
}
- (IBAction)play:(UIButton *)sender {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];

    }
    
    if (_isPlaying) {
        [_playLayer.player pause];
        [sender setTitle:@"播放" forState:UIControlStateNormal];
        _isPlaying = NO;
    }else{
        [_playLayer.player play];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        _isPlaying = YES;
    }
}

- (IBAction)fullScreen:(UIButton *)sender {
    [self doubleTap];
}

- (void)doubleTap{
    
    if (_isRotation) {
        [UIView animateWithDuration:0.25 animations:^{
            
            _playView.transform = CGAffineTransformMakeRotation(0);
            
            _playView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 200);
            
            _playLayer.frame = _playView.bounds;
        }];
        _isRotation = NO;
        [self hideTool:NO];
    }else{
        
        [UIView animateWithDuration:0.25 animations:^{
            
            CGFloat ff = ([UIScreen mainScreen].bounds.size.height-[UIScreen mainScreen].bounds.size.width)/2;
            
            _playView.frame = CGRectMake(-ff, ff, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            
            _playView.transform = CGAffineTransformMakeRotation(M_PI/2);
            
            _playLayer.frame = _playView.bounds;
        }];
        _isRotation = YES;
        [self hideTool:YES];
    }
}

- (void)hideTool:(BOOL)hide{
    _playBtn.hidden = hide;
    _fullScreenBtn.hidden = hide;
    _progressView.hidden = hide;
    _currentTimeLabel.hidden = hide;
    _totalTimeLabel.hidden = hide;
}

- (void)updateProgress{
    if (_isRotation) {
        return;
    }
    _currentTimeLabel.text = [self getTimeStrWithTimeInterval:CMTimeGetSeconds(_playLayer.player.currentItem.currentTime)];
    _totalTimeLabel.text = [self getTimeStrWithTimeInterval:CMTimeGetSeconds(_playLayer.player.currentItem.duration)];
    _progressView.progress = CMTimeGetSeconds(_playLayer.player.currentItem.currentTime)/CMTimeGetSeconds(_playLayer.player.currentItem.duration);
}

- (NSString *)getTimeStrWithTimeInterval:(CGFloat)timeInterval{
    
    if (isnan(timeInterval)) {
        return @"00:00:00";
    }
    int h = timeInterval/3600;
    int m = (timeInterval-h*3600)/60;
    int s = timeInterval-h*3600-m*60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",h,m,s];
}

@end
