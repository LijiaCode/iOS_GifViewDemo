//
//  VideoPlayerViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/11/28.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

static const CGFloat topMargin = 50.f;
static const CGFloat btmMargin = 40.f;
static const CGFloat sideMargin = 40.f;

static const CGFloat btnHeight = 40.f;
static const CGFloat btnWidth = 80.f;
static const CGFloat btnMargin = 20.f;


@interface VideoPlayerViewController ()

@property(nonatomic, strong)AVPlayer* player;
@property(nonatomic, weak)AVPlayerLayer* playLayer;
@property(nonatomic, weak)UIView* videoShowView;
@property(nonatomic, weak)UIButton* pauseBtn;
@property(nonatomic, weak)UIProgressView* progressView;
@property(nonatomic, weak)UILabel* timeLabel;

@property(nonatomic, weak)UIButton* startTimeBtn;
@property(nonatomic, weak)UIButton* endTimeBtn;
@property(nonatomic, weak)UIButton* convertBtn;

@property(nonatomic, copy)NSString* totalTimeStr;
@end

@implementation VideoPlayerViewController

@synthesize videoURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.totalTimeStr = nil;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initShowViews];
    [self initPlayer];
    
    [self.player play];
    
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:self.videoURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    int totalTimeTmp = ceil(audioDurationSeconds);
    int hour = totalTimeTmp / 3600;
    int min = (totalTimeTmp % 3600) / 60;
    int sec = ((totalTimeTmp % 3600) % 60) % 60;
    
    self.totalTimeStr = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
    [self addProgressObserver];
    [self addNotification];
}

- (void)initPlayer
{
    self.player = [AVPlayer playerWithURL:self.videoURL];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.videoShowView.bounds;
    [self.videoShowView.layer addSublayer:playerLayer];
    self.playLayer = playerLayer;
}

- (void)initShowViews
{
    UIView* showView = [[UIView alloc] init];
    showView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:showView];
    _videoShowView = showView;
    showView.backgroundColor = [UIColor redColor];
    
    UIButton* pauseBtn = [[UIButton alloc] init];
    [self.view addSubview:pauseBtn];
    _pauseBtn = pauseBtn;
    [_pauseBtn addTarget:self action:@selector(pauseVideoTarget:) forControlEvents:UIControlEventTouchUpInside];
    pauseBtn.backgroundColor = [UIColor grayColor];
    
    UIProgressView* progressView = [[UIProgressView alloc] init];
    [self.view addSubview:progressView];
    _progressView = progressView;
    _progressView.backgroundColor = [UIColor whiteColor];
    _progressView.trackTintColor = [UIColor colorWithRed:192.f / 255  green: 192.f / 255 blue:192.f / 255 alpha:0.7];
    _progressView.tintColor = [UIColor blueColor];
    
    UILabel* timeLabel = [[UILabel alloc] init];
    [self.view addSubview:timeLabel];
    _timeLabel = timeLabel;
    timeLabel.backgroundColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.adjustsFontSizeToFitWidth = YES;

    UIButton* startTimeBtn = [UIButton buttonWithType: UIButtonTypeRoundedRect];;
    startTimeBtn.backgroundColor = [UIColor yellowColor];
    [startTimeBtn setTitle:@"起始位置" forState:UIControlStateNormal];
    [self.view addSubview:startTimeBtn];
    [startTimeBtn addTarget:self action:@selector(setConvertTimePos:) forControlEvents:UIControlEventTouchUpInside];
    startTimeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    startTimeBtn.tag = 0;
    _startTimeBtn = startTimeBtn;
    
    UIButton* endTimeBtn = [UIButton buttonWithType: UIButtonTypeRoundedRect];;
    endTimeBtn.backgroundColor = [UIColor yellowColor];
    [endTimeBtn setTitle:@"结束位置" forState:UIControlStateNormal];
    [self.view addSubview:endTimeBtn];
    [endTimeBtn addTarget:self action:@selector(setConvertTimePos:) forControlEvents:UIControlEventTouchUpInside];
    endTimeBtn.tag = 1;
    endTimeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _endTimeBtn = endTimeBtn;
    
    UIButton* convertBtn = [UIButton buttonWithType: UIButtonTypeRoundedRect];;
    convertBtn.backgroundColor = [UIColor yellowColor];
    [convertBtn setTitle:@"转为GIF" forState:UIControlStateNormal];
    [self.view addSubview:convertBtn];
    [convertBtn addTarget:self action:@selector(convertVideoToGif:) forControlEvents:UIControlEventTouchUpInside];
    _convertBtn = convertBtn;
    _convertBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self setShowViewsFrame];
}

- (void)addNotification
{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playbackFinished:(id)sender
{
    //todo
}

- (void)setConvertTimePos:(UIButton*)sender
{
    
}

- (void)convertVideoToGif:(id)sender
{
    
}

- (void)updateTimeLabelText: (NSString*)timeStr
{
    self.timeLabel.text = timeStr;
}

- (void)pauseVideoTarget:(id)sender
{
    if(self.player.rate == 0)
        [self.player play];
    else if(self.player.rate == 1)
        [self.player pause];
}

-(void)addProgressObserver
{
    AVPlayerItem *playerItem = self.player.currentItem;
    UIProgressView *progress = self.progressView;
    //这里设置每秒执行一次
    __block VideoPlayerViewController* weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
    {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([playerItem duration]);
        if (current)
        {
            int curTimeTmp = ceil(current);
            int hour = curTimeTmp / 3600;
            int min = (curTimeTmp % 3600) / 60;
            int sec = ((curTimeTmp % 3600) % 60) % 60;
            NSString* timeLabelShowStr = [NSString stringWithFormat:@"%02d:%02d:%02d/%@", hour, min, sec, weakSelf.totalTimeStr];
            [weakSelf updateTimeLabelText:timeLabelShowStr];
            
            [progress setProgress:(current / total) animated:NO];
        }
    }];
}


- (void)setShowViewsFrame
{
    CGFloat margin = (self.view.frame.size.width - btnWidth * 3 - 2 * sideMargin) / 2;
    
    self.startTimeBtn.frame = CGRectMake(sideMargin, topMargin, btnWidth, btnHeight);
    self.endTimeBtn.frame = CGRectMake(sideMargin + btnWidth + margin, topMargin, btnWidth
                                       , btnHeight);
    self.convertBtn.frame = CGRectMake(self.endTimeBtn.frame.origin.x + self.endTimeBtn.frame.size.width + margin, topMargin, btnWidth, btnHeight);

    
    CGFloat showViewHeight = self.view.frame.size.height - topMargin - btmMargin - btnMargin - btnHeight * 2;
    self.videoShowView.frame = CGRectMake(sideMargin, topMargin + btnMargin + btnHeight, self.view.frame.size.width - 2 * sideMargin, showViewHeight);
     self.playLayer.frame = self.videoShowView.bounds;
    
    CGFloat proYPos = self.videoShowView.frame.origin.y + self.videoShowView.frame.size.height;
    self.pauseBtn.frame = CGRectMake(sideMargin, proYPos, btnHeight, btnHeight);
    
    self.progressView.frame = CGRectMake(sideMargin + btnHeight, proYPos + btnHeight / 4, self.videoShowView.frame.size.width - btnHeight, btnHeight);
    self.timeLabel.frame = CGRectMake(sideMargin + btnHeight, proYPos + btnHeight / 4 + 2, btnWidth, btnHeight * 3 / 4 - 2); //tine height
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setShowViewsFrame];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setShowViewsFrame];
}

- (void)dealloc
{
    [self removeNotification];
}

@end
