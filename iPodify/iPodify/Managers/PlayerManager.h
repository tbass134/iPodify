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
@property (nonatomic, strong) void (^trackChanged)(NSDictionary *metaData);



//@property (nonatomic, readwrite, strong) SPPlaybackManager *playbackManager;
//@property(nonatomic,strong)SPTrack *currentTrack;
-(void)initPlayer;
- (void)loginWithSession:(SPTSession *)session usingCallback:(void (^)(BOOL success))block;
-(void)playTrack:(SPTPartialTrack *)track with_block:(void (^)(SPTTrack *track))block;
-(void)starTrack:(SPTPartialTrack *)track;

-(void)coverForAlbum:(SPTPartialAlbum *)album with_block:(void (^)(UIImage *image))block;
-(void)seekToPosition:(NSTimeInterval)offset;
+ (PlayerManager*)sharedInstance;

@end
