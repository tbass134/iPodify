//
//  PlayerViewController.m
//  Simple Player
//
//  Created by Antonio Hung on 1/23/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlaylistsCollectionViewController.h"
#import "PlayerManager.h"
#import <MediaPlayer/MPVolumeView.h>
@interface PlayerViewController () <UIActionSheetDelegate>

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: self.volumeView.bounds];
    self.volumeView.backgroundColor = [UIColor clearColor];
    [self.volumeView addSubview: myVolumeView];
    [self.duration_slider addTarget:self action:@selector(sliderTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];

    SPTPartialTrack *track =self.tracks[self.current_track_index];
    [self playTheTrack:track];
    
    
    [[PlayerManager sharedInstance]setTrackChanged:^(NSDictionary *metaDict) {
        [self updateUI];
        
        if ([PlayerManager sharedInstance].player.currentTrackMetadata == nil) {
            NSLog(@"track is over");
            trackLoaded = NO;
            [self.timer invalidate];
            [self playNextTrack:nil];
        }
        
    }];

    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set itself as the first responder
    [self becomeFirstResponder];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.timer invalidate];
}

- (void)updateTime:(NSTimer *)timer {
    
    if(is_seeking)
        return;
    
    NSTimeInterval currentTime =[PlayerManager sharedInstance].player.currentPlaybackPosition;
    NSNumber *totalTime = [[PlayerManager sharedInstance].player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataTrackDuration];

    self.current_time_txt.text = [self formattedStringForDuration:currentTime];
    self.duration_slider.value = (currentTime / [totalTime doubleValue]);
}

-(void)updateUI {
    
    if ([PlayerManager sharedInstance].player.currentTrackMetadata == nil) {
        self.song_txt.text = @"Nothing Playing";
        self.album_txt.text = @"";
        self.artist_name_txt.text = @"";
    } else {
        self.song_txt.text = [[PlayerManager sharedInstance].player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataTrackName];
        self.album_txt.text = [[PlayerManager sharedInstance].player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataAlbumName];
        self.artist_name_txt.text = [[PlayerManager sharedInstance].player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataArtistName];
    }
    
    //update the states of the ff / rr buttons
    self.prev_btn.enabled = (self.current_track_index > 1);
    self.fwd_btn.enabled =  (self.current_track_index < self.tracks.count - 1);

    if(![PlayerManager sharedInstance].player.isPlaying)
    {
        [self.play_btn setImage:[UIImage imageNamed:@"pause_icon"] forState:UIControlStateNormal];
    }
    else
    {
        [self.play_btn setImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];

    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playTrack:nil];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playPreviousTrack:nil];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNextTrack:nil];
                break;
            default:
                break;
        }
    }
}

-(void)playTheTrack:(SPTPartialTrack *)track
{
    [[PlayerManager sharedInstance]playTrack:track with_block:^(SPTTrack *track) {
        
        [[PlayerManager sharedInstance]coverForAlbum:track.album with_block:^(UIImage *image) {
            self.coverImage.image = image;
        }];
        [self.timer invalidate];

        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTime:)
                                                    userInfo:nil
                                                     repeats:YES];
        self.duration_slider.value = 0;
        self.duration_time_txt.text =[self formattedStringForDuration:track.duration];
        [self updateUI];
        
    }];
    
 }

- (IBAction)scrubberChanged:(id)sender {
    
    is_seeking = YES;
    NSTimeInterval currentTime =[PlayerManager sharedInstance].player.currentPlaybackPosition;
    self.current_time_txt.text = [self formattedStringForDuration:currentTime];
}

-(void)sliderTouchUpInsideAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;

    NSNumber *totalTime = [[PlayerManager sharedInstance].player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataTrackDuration];
    NSTimeInterval totalDutation = [totalTime doubleValue]*(slider.value);
    
    [[PlayerManager sharedInstance]seekToPosition:round(totalDutation)];
    is_seeking = NO;

}

- (IBAction)playTrack:(id)sender
{
    if(![PlayerManager sharedInstance].player.isPlaying)
    {
        [[PlayerManager sharedInstance].player setIsPlaying:YES callback:nil];
    }
    else
    {
        [[PlayerManager sharedInstance].player setIsPlaying:NO callback:nil];
    }
    [self updateUI];
}

- (IBAction)playNextTrack:(id)sender
{
    self.current_track_index++;

    if(self.current_track_index < self.tracks.count)
    {
        SPTPartialTrack *track =self.tracks[self.current_track_index];
        [self playTheTrack:track];
    }

}
- (IBAction)playPreviousTrack:(id)sender
{
    self.current_track_index--;
    if(self.current_track_index > 0)
    {
        SPTPartialTrack *track =self.tracks[self.current_track_index];
        [self playTheTrack:track];
    }
}

- (IBAction)shuffleTracks:(id)sender {
    
    NSMutableArray *tracks = [self.tracks mutableCopy ];
    NSUInteger count = [self.tracks count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [tracks exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    self.tracks = tracks;
    
    [self.timer invalidate];
    self.current_track_index = 0;
    SPTPartialTrack *track =self.tracks[self.current_track_index];
    [self playTheTrack:track];
    
}

- (IBAction)repeatTrack:(id)sender {
    
    SPTPartialTrack *track =self.tracks[self.current_track_index];
    if(track)
     [self playTheTrack:track];
}


- (IBAction)showMore:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to playlist",@"Save track",@"Star track", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self addToPlaylist];
            break;
        case 1:
            [self saveTrack];
            break;
        case  2:
            [self starTrack];
            break;
        default:
            break;
    }
}

- (void)starTrack
{
    //not working
    [SPTRequest starredListForUserInSession:[PlayerManager sharedInstance].session callback:^(NSError *error, id object) {
        SPTPlaylistSnapshot *playlistSnapshot = (SPTPlaylistSnapshot *)object;
        SPTPartialTrack *track =self.tracks[self.current_track_index];
        
        [playlistSnapshot addTracksToPlaylist:@[track] withSession:[PlayerManager sharedInstance].session callback:^(NSError *error) {
            
            NSLog(@"error %@",error);
            //TODO add alert / toast when track is added
            if (!error) {
                NSLog(@"track added");
            }
        }];
        
    }];
    
    SPTPartialTrack *track =self.tracks[self.current_track_index];
    
    if(track) {
        [[PlayerManager sharedInstance]starTrack:track];
    }
    
}
- (void)saveTrack
{
    SPTPartialTrack *track =self.tracks[self.current_track_index];
    [SPTRequest saveTracks:@[track] forUserInSession:[PlayerManager sharedInstance].session  callback:^(NSError *error, id object) {
        
        //if (!error) {
            NSLog(@"error %@",error);
        //}
    }];
}

- (void)addToPlaylist
{
    __weak PlaylistsCollectionViewController *playlists = [self.storyboard instantiateViewControllerWithIdentifier:@"Playlists"];

    [playlists setPlaylistSelected:^(SPTPartialPlaylist *playlist) {
        
        [SPTRequest requestItemFromPartialObject:playlist withSession:[PlayerManager sharedInstance].session callback:^(NSError *error, SPTPlaylistSnapshot *playlistSnapshot) {
            SPTPartialTrack *track =self.tracks[self.current_track_index];

            if (!error) {
                [playlistSnapshot addTracksToPlaylist:@[track] withSession:[PlayerManager sharedInstance].session callback:^(NSError *error) {
                    
                    //TODO add alert / toast when track is added
                    if (!error) {
                        NSLog(@"track added");
                    }
                }];
            } else {
                NSLog(@"requestItemFromPartialObject error: %@",error);
            }
        }];
        
        [playlists dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.navigationController presentViewController:playlists animated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"successCallback" object:nil];

    }];
    
}



- (NSString*)formattedStringForDuration:(NSTimeInterval)duration
{
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
