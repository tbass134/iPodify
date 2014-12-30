//
//  PlayerManager.h
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerManager : NSObject <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>
@property (nonatomic,strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;

@property (nonatomic, strong) void (^trackComplete)();
@property (nonatomic, strong) void (^trackPaused)();
@property (nonatomic, strong) void (^trackError)(NSError *error);


//@property (nonatomic, readwrite, strong) SPPlaybackManager *playbackManager;
//@property(nonatomic,strong)SPTrack *currentTrack;
-(void)initPlayer;
- (void)loginWithSession:(SPTSession *)session usingCallback:(void (^)(BOOL success))block;
-(BOOL )playTrack:(SPTTrack *)track with_block:(void (^)(BOOL isReady))block;
-(void)starTrack:(SPTTrack *)track;

-(void)coverForAlbum:(SPTAlbum *)album with_block:(void (^)(UIImage *image))block;
-(void)seekToPosition:(NSTimeInterval)offset;
+ (PlayerManager*)sharedInstance;

@end
