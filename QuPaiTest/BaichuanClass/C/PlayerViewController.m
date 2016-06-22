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
    
    __weak IBOutlet UIView *_toolBarView;
    
    __weak IBOutlet UIView *_navBarView;
    
    __weak IBOutlet UIProgressView *_progressView;
    
    __weak IBOutlet UISlider *_silderView;
    
    __weak IBOutlet UILabel *_currentTimeLabel;
    
    __weak IBOutlet UILabel *_totalTimeLabel;
    
    __weak IBOutlet UIButton *_playBtn;
    
    __weak IBOutlet UIButton *_fullScreenBtn;
    
    __weak IBOutlet NSLayoutConstraint *_navBarTopConstraint;
    
    __weak IBOutlet NSLayoutConstraint *_playViewHeightConstraint;
    
    __weak IBOutlet NSLayoutConstraint *_toolBarTopConstraint;
    
    AVPlayerLayer *_playLayer;
    
    BOOL _isRotation;
    
    BOOL _isPlaying;
    
    BOOL _isPlayFinish;
    
    BOOL _isNavHide;
}
@end

@implementation PlayerViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _playLayer.frame = _playView.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    _toolBarView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _navBarView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    [_silderView addTarget:self action:@selector(sliderValueWillChange) forControlEvents:UIControlEventTouchDown];
    [_silderView addTarget:self action:@selector(sliderValueDidChange) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self initAvPlayer];
    [self addAvPlayerObserver];
    [self addGestureToPlayView];
    
}

- (void)initAvPlayer{
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:self.urlString]];
    
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playLayer.frame = _playView.bounds;
    [_playView.layer addSublayer:playLayer];
    _playLayer = playLayer;
}

- (void)addAvPlayerObserver{
    [_playLayer.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [_playLayer.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    __strong UIButton *tempBtn = _playBtn;
    __strong UIProgressView *tempProgressView = _progressView;
    __weak typeof(self)weakSelf = self;
    // 添加播放进度的监听
    [_playLayer.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf updateProgress ];
        if (CMTimeGetSeconds(_playLayer.player.currentItem.currentTime) == CMTimeGetSeconds(_playLayer.player.currentItem.duration)) {
            [tempBtn setTitle:@"播放" forState:UIControlStateNormal];
            tempProgressView.progress = 0;
            _isPlaying = NO;
            _isPlayFinish = YES;
        }
    }];
}

- (void)addGestureToPlayView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    tap.numberOfTapsRequired = 1;
    [_playView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [_playView addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan)];
    [_playView addGestureRecognizer:pan];
}


- (IBAction)play:(UIButton *)sender {
    if (_isPlaying) {
        [_playLayer.player pause];
        [sender setTitle:@"播放" forState:UIControlStateNormal];
        _isPlaying = NO;
    }else{
        if (_isPlayFinish) { // 播放完成则回到起点
               [_playLayer.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
        }
     
        [_playLayer.player play];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        _isPlaying = YES;
    }
}

- (IBAction)fullScreen:(UIButton *)sender {
    [self doubleTap];
}

- (void)tap{
    if (_isRotation) {
        if (_isNavHide) {
            [UIView animateWithDuration:0.25 animations:^{
                _navBarTopConstraint.constant = 0;
                _toolBarTopConstraint.constant = -30;
                [self.view layoutSubviews];
            } completion:^(BOOL finished) {
                _isNavHide = NO;
            }];
        }else{
            [UIView animateWithDuration:0.25 animations:^{
                _navBarTopConstraint.constant = -64;
                _toolBarTopConstraint.constant = 0;
                [self.view layoutSubviews];
            } completion:^(BOOL finished) {
                _isNavHide = YES;
                
            }];
        }
       
    }else{
        if (_isNavHide) {
            [UIView animateWithDuration:0.25 animations:^{
                _navBarTopConstraint.constant = 0;
                [self.view layoutSubviews];
            } completion:^(BOOL finished) {
                _isNavHide = NO;
            }];
        }else{
            [UIView animateWithDuration:0.25 animations:^{
                _navBarTopConstraint.constant = -64;
                [self.view layoutSubviews];
            } completion:^(BOOL finished) {
                _isNavHide = YES;
            }];
        }
    }
}

- (void)doubleTap{
    
    //  通过旋转self.view 来旋转屏幕,再调节相应的subview的frame 即可
    if (_isRotation) {
        [UIView animateWithDuration:0.25 animations:^{
            
            self.view.transform = CGAffineTransformMakeRotation(0);
            
            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
            _playViewHeightConstraint.constant = 200;
            
            _toolBarTopConstraint.constant = 0;
            
        }];
        _isRotation = NO;
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            
            self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
            
            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
            _playViewHeightConstraint.constant = [UIScreen mainScreen].bounds.size.width;
            
            _toolBarTopConstraint.constant = -30;
            
        }];
        _isRotation = YES;
    }
}

- (void)pan{
    
}

- (void)updateProgress{
    _currentTimeLabel.text = [self getTimeStrWithTimeInterval:CMTimeGetSeconds(_playLayer.player.currentItem.currentTime)];
    _totalTimeLabel.text = [self getTimeStrWithTimeInterval:CMTimeGetSeconds(_playLayer.player.currentItem.duration)];
    _silderView.value = CMTimeGetSeconds(_playLayer.player.currentItem.currentTime)/CMTimeGetSeconds(_playLayer.player.currentItem.duration);
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


#pragma mark - 监听 status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey]  isEqual: @1]) {
            [self updateProgress];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            _progressView.progress = CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration))/CMTimeGetSeconds(_playLayer.player.currentItem.duration);
        }
    }
}

#pragma mark - sliderValueChange
- (void)sliderValueWillChange{
    [_playLayer.player pause];
    _isPlaying = NO;
}

- (void)sliderValueDidChange{
    [_playLayer.player seekToTime:CMTimeMakeWithSeconds(_silderView.value * CMTimeGetSeconds(_playLayer.player.currentItem.duration), NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        [_playLayer.player play];
        _isPlaying = YES;
    }];
}

- (IBAction)back:(UIButton *)sender {
    if (_isRotation) {
        [self doubleTap];
        _isRotation = NO;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}
@end
