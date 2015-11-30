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

@end

@implementation VideoPlayerViewController

@synthesize videoURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initShowViews];
    [self initPlayer];
    
    [self.player play];
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
    pauseBtn.backgroundColor = [UIColor grayColor];
    
    UIProgressView* progressView = [[UIProgressView alloc] init];
    [self.view addSubview:progressView];
    _progressView = progressView;
    _progressView.backgroundColor = [UIColor greenColor];
    
    UILabel* timeLabel = [[UILabel alloc] init];
    [self.view addSubview:timeLabel];
    _timeLabel = timeLabel;
    timeLabel.backgroundColor = [UIColor blackColor];

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

- (void)setConvertTimePos:(UIButton*)sender
{
    
    
}

- (void)convertVideoToGif:(id)sender
{
    
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
    
    self.progressView.frame = CGRectMake(sideMargin + btnHeight, proYPos, self.videoShowView.frame.size.width - btnHeight, btnHeight / 2);
    self.timeLabel.frame = CGRectMake(sideMargin + btnHeight, proYPos + btnHeight / 2, btnWidth, btnHeight / 2);
}




- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setShowViewsFrame];
}

@end
