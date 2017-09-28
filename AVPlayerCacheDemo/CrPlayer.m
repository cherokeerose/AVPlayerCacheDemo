//
//  CrPlayer.m
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "CrPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AVPlayerCache.h"

@interface CrPlayer()

@property (nonatomic, strong) AVPlayer      *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id            timeObserver;

@property (nonatomic, strong) CrResourceLoader  *resourceLoader;

@property (nonatomic, assign) MPlayerStatus     status;
@property (nonatomic, assign) NSTimeInterval    totalDuration;
@property (nonatomic, assign) NSTimeInterval    cacheDuration;
@property (nonatomic, assign) NSTimeInterval    playingSeconds;

@property (nonatomic, copy  ) NSString          *url;

@end

@implementation CrPlayer

#pragma mark - init and dealloc
- (instancetype)init {
    self = [super init];
    if (self) {
        self.autoPlay = YES;
        [self addNotificaton];
        [self playback];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [[UIApplication sharedApplication] becomeFirstResponder];
        [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    if (self.status != MPlayerStatusStop) {
        [self removeKVO:self.player.currentItem];
        [self removeTimerObserver];
        self.status = MPlayerStatusStop;
    }
    [self removeNotificaton];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[UIApplication sharedApplication] resignFirstResponder];
    [self removeObserver:self forKeyPath:@"status"];
}

- (void)playMediaWithUrl:(NSString *)url {
    self.url = url;
    AVPlayerItem *playerItem = [self createPlayerItemWithUrl:url];
    [self playerWithPlayerItem:playerItem];
}

#pragma mark - setup and setdown
- (AVPlayerItem *)createPlayerItemWithUrl:(NSString *)url {
    //创建playeritem
    AVPlayerItem *playerItem = nil;
    if ([NSString httpURL:url]) {
        NSString *fileUrl = [CrFileHandle file:[NSString fileNameFromURL:url] existsAtCahcesFolder:self.resourceLoader.cachesFolder];
        if (fileUrl != nil) {   //有缓存
            playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:fileUrl]];
        } else {                //无缓存
            NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:url] resolvingAgainstBaseURL:NO];
            self.resourceLoader.scheme = components.scheme;
            components.scheme = @"streaming";
            AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:components.URL options:nil];
            [urlAsset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_queue_create("ResourceLoaderQueue", DISPATCH_QUEUE_SERIAL)];
            playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
        }
    } else {
        playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:url]];
    }
    return playerItem;
}

- (void)playerWithPlayerItem:(AVPlayerItem *)playerItem {
    //移除原有观察
    if (self.status != MPlayerStatusStop) {
        [self removeKVO:self.player.currentItem];
        [self removeTimerObserver];
    }
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    //添加观察
    [self addKVO:playerItem];
    [self addTimerObserver];
    
    self.status = MPlayerStatusPause;
}

#pragma mark - 播放器相关设置
- (void)playback {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark - addObserver
- (void)addKVO:(AVPlayerItem *)item {
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil]; // 观察status属性
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeKVO:(AVPlayerItem *)item {
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}

- (void)addNotificaton {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumped:) name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
}
- (void)removeNotificaton {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - 观察属性变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"] && [object isKindOfClass:[AVPlayerItem class]]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        if (status == AVPlayerStatusReadyToPlay) {
            CMTime duration = playerItem.duration;
            self.totalDuration = CMTimeGetSeconds(duration);    // 获取视频长度
            if (self.autoPlay) {
                [self play];                                    //开始播放
            }
        } else if (status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        } else {
            NSLog(@"AVPlayerStatusUnknown");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"] && [object isKindOfClass:[AVPlayerItem class]]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        NSArray<NSValue *> *loadedTimeRanges = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = loadedTimeRanges.firstObject.CMTimeRangeValue; //本次缓冲的时间范围
        self.cacheDuration = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        if (self.cacheDuration/self.totalDuration == 1) {
            NSLog(@"cache finish");
            NSString *filename = [NSString fileNameFromURL:self.url];
            [CrFileHandle copyTempFile:self.resourceLoader.tmpfile toCachesFolder:@"MV" withName:filename];
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"] && [object isKindOfClass:[AVPlayerItem class]]) {
        NSLog(@"playbackBufferEmpty");
    } else if ([keyPath isEqualToString:@"status"] && [object isKindOfClass:[CrPlayer class]]) {
        //NSLog(@"status");
    }
}

// 观察播放进度
- (void)addTimerObserver {
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        weakSelf.playingSeconds = CMTimeGetSeconds(time);
        //NSLog(@"playing time:%f",weakSelf.playingSeconds);
    }];
}

- (void)removeTimerObserver {
    [self.player removeTimeObserver:self.timeObserver];
}

#pragma mark - 远程控制
- (void)remoteControlReceivedEvent:(NSNotification *)notification {
    UIEvent *event = notification.object;
    if (event.type == UIEventTypeRemoteControl) {  //判断是否为远程控制
        switch (event.subtype) {
                case  UIEventSubtypeRemoteControlPlay:{
                    [self play];
                    break;
                }
                case UIEventSubtypeRemoteControlPause:{
                    [self pause];
                    break;
                }
                case UIEventSubtypeRemoteControlNextTrack:{
                    break;
                }
                case UIEventSubtypeRemoteControlPreviousTrack:{
                    break;
                }
            default:
                break;
        }
    }
}


#pragma mark - Notification
- (void)didPlayToEndTime:(NSNotification *)notification {
    [self removeTimerObserver];
    [self removeKVO:self.player.currentItem];
    self.status = MPlayerStatusStop;
    NSLog(@"didPlayToEndTime");
}

- (void)jumped:(NSNotification *)notification {
    NSLog(@"jumped");
}

- (void)playbackStalled:(NSNotification *)notification {
    NSLog(@"playbackStalled");
}

- (void)interruption:(NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    NSInteger interruption = [[dictionary objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (interruption == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"Audio:AVAudioSessionInterruptionTypeBegan");
    } else if (interruption == AVAudioSessionInterruptionOptionShouldResume) {
        NSLog(@"AVAudioSessionInterruptionOptionShouldResume");
    } else {
        NSLog(@"interruption");
    }
}

#pragma mark - control
- (void)play {
    [self.player play];
    self.status = MPlayerStatusPlay;
}

- (void)pause {
    [self.player pause];
    self.status = MPlayerStatusPause;
}

- (void)stop {
    if (self.status != MPlayerStatusStop) {
        [self removeKVO:self.player.currentItem];
        [self removeTimerObserver];
    }
    self.status = MPlayerStatusStop;
}

- (void)seekToTime:(CGFloat)time {
    CMTime seekTime = CMTimeMake(time, 1);
    [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
        
    }];
}

#pragma mark - getter
- (AVPlayer *)player {
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer {
    if (_playerLayer == nil) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    }
    return _playerLayer;
}

- (CrResourceLoader *)resourceLoader {
    if (_resourceLoader == nil) {
        _resourceLoader = [[CrResourceLoader alloc] init];
        _resourceLoader.cachesFolder = @"MV";
    }
    return _resourceLoader;
}

@end
