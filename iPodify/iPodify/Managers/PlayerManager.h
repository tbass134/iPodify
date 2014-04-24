//
//  PlayerManager.h
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPlaybackManager.h"
#import "CocoaLibSpotify.h"

@interface PlayerManager : NSObject<SPSessionDelegate,SPSessionPlaybackDelegate>
@property (nonatomic, strong) void (^trackComplete)();
@property (nonatomic, strong) void (^trackPaused)();
@property (nonatomic, strong) void (^trackError)(NSError *error);


@property (nonatomic, readwrite, strong) SPPlaybackManager *playbackManager;
//@property(nonatomic,strong)SPTrack *currentTrack;
-(void)initPlayer;
-(BOOL )playTrack:(SPTrack *)track with_block:(void (^)(BOOL isReady))block;
-(void)starTrack:(SPTrack *)track;

-(void)coverForAlbum:(SPAlbum *)album with_block:(void (^)(UIImage *image))block;
-(void)seekToPosition:(NSTimeInterval)offset;
+ (PlayerManager*)sharedInstance;

@end
