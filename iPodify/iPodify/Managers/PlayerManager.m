//
//  PlayerManager.m
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "PlayerManager.h"
#import <AudioToolbox/AudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "Config.h"
#define kClientId "fd73406af85645d9a77ec207903b064f"

@implementation PlayerManager

-(void)initPlayer
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
- (void)loginWithSession:(SPTSession *)session usingCallback:(void (^)(BOOL success))block
{
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:@kClientId];
        self.player.playbackDelegate = self;
        self.session = session;
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            block(NO);
        }
        else {
            block(YES);
        }
    }];
    
}

+ (PlayerManager*)sharedInstance
{
    static PlayerManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PlayerManager alloc] init];
    });
    return _sharedInstance;
    
}

-(void)playTrack:(SPTPartialTrack *)track with_block:(void (^)(SPTTrack *track))block
{
    [SPTRequest requestItemAtURI:track.uri
                     withSession:self.session
                        callback:^(NSError *error, id object) {
                            
                            if (error != nil) {
                                NSLog(@"*** Album lookup got error %@", error);
                                return;
                            }
                            
                            [self.player playTrackProvider:(id <SPTTrackProvider>)object callback:nil];
                            
                            [SPTRequest requestItemFromPartialObject:track withSession:self.session callback:^(NSError *error, SPTTrack *track) {
                                if (error == nil) {
                                    [self updateLockScreen:nil];
                                    block(track);
                                }
                            }];
                            
                        }];
}

-(void)coverForAlbum:(SPTPartialAlbum *)album with_block:(void (^)(UIImage *image))block;
{
    [SPTAlbum albumWithURI:album.uri
                   session:self.session
                  callback:^(NSError *error, SPTAlbum *album) {
                      
                      NSURL *imageURL = album.largestCover.imageURL;
                      if (imageURL == nil) {
                          NSLog(@"Album %@ doesn't have any images!", album);
                          block(nil);
                          return;
                      }
                      
                      // Pop over to a background queue to load the image over the network.
                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                          NSError *error = nil;
                          UIImage *image = nil;
                          NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:0 error:&error];
                          
                          if (imageData != nil) {
                              image = [UIImage imageWithData:imageData];
                          }
                          
                          // …and back to the main queue to display the image.
                          dispatch_async(dispatch_get_main_queue(), ^{
                              block(image);
                              if (image == nil) {
                                  NSLog(@"Couldn't load cover image with error: %@", error);
                              }
                              else {
                                  [self updateLockScreen:image];
                              }
                          });
                      });
                  }];
}


-(void)seekToPosition:(NSTimeInterval)offset
{
    NSLog(@"offset %f",offset);
    [self.player seekToOffset:offset callback:nil];

}

#pragma mark Remote Controls
-(void)updateLockScreen:(UIImage *)albumArtImage
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataArtistName], MPMediaItemPropertyArtist,
                                  [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataTrackName], MPMediaItemPropertyTitle,
                                  [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataAlbumName], MPMediaItemPropertyAlbumTitle,
                                   [self.player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataTrackDuration], MPMediaItemPropertyPlaybackDuration,
                                  nil];
        if (albumArtImage) {
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:albumArtImage];
            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        }

        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];

    }
}

- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
                break;
            case UIEventSubtypeRemoteControlPause:
                break;
            case UIEventSubtypeRemoteControlStop:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
            default: break;
        }
    }
}

#pragma mark - 
#pragma mark Track Features
-(void)starTrack:(SPTPartialTrack *)track
{
//    if(!track.starred)
//        track.starred = YES;
//    else
//        track.starred = NO;
}

-(void)saveTrack:(SPTTrack *)track
{
}

#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    if (self.trackChanged) {
        self.trackChanged(trackMetadata);
    }
}



#pragma mark -
#pragma mark AVAudio

- (void)interruption:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSUInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan)
    {
        
    }
    else if (interuptionType == AVAudioSessionInterruptionTypeEnded)
    {
        
    }
}
- (void)routeChange:(NSNotification *)notification
{
    
    NSDictionary *routeChangeDict = notification.userInfo;
    NSUInteger routeChangeType = [[routeChangeDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if (routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
    } else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable)
    {
        
    }
    NSLog(@"routeChanged: %@", routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable ? @"New Device Available" : @"Old Device Unavailable");
}
-(void)dealloc
{
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

@end
