//
//  ViewController.m
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "ViewController.h"
#import "CrPlayer.h"

@interface ViewController ()

@property (nonatomic, strong) CrPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.player.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.player.playerLayer];
    
    [self.player playMediaWithUrl:@"http://hc.yinyuetai.com/uploads/videos/common/8063015A8F40658E463185BAAD29142D.mp4"];
}

- (CrPlayer *)player {
    if (_player == nil) {
        _player = [[CrPlayer alloc] init];
    }
    return _player;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
