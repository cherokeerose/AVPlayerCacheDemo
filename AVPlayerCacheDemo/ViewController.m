//
//  ViewController.m
//  AVPlayerCacheDemo
//
//  Created by cherokee rose on 2020/7/10.
//  Copyright © 2020 刘天荣. All rights reserved.
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
    
    [self.player playMediaWithUrl:@"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4"];
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
