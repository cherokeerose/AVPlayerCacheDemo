//
//  CrPlayer.h
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    MPlayerStatusStop,
    MPlayerStatusPause,
    MPlayerStatusPlay,
} MPlayerStatus;

@interface CrPlayer : NSObject

@property (nonatomic, strong, readonly) AVPlayer        *player;
@property (nonatomic, strong, readonly) AVPlayerLayer   *playerLayer;

@property (nonatomic, assign, readonly) MPlayerStatus   status;

@property (nonatomic, assign) BOOL      autoPlay;

- (void)playMediaWithUrl:(NSString *)url;

- (void)play;
- (void)pause;
- (void)stop;

@end
