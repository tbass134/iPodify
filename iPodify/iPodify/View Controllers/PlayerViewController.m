//
//  PlayerViewController.m
//  Simple Player
//
//  Created by Antonio Hung on 1/23/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerManager.h"
#import <MediaPlayer/MPVolumeView.h>
@interface PlayerViewController ()

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
    [[PlayerManager sharedInstance]initPlayer];
    
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: self.volumeView.bounds];
    self.volumeView.backgroundColor = [UIColor clearColor];
    [self.volumeView addSubview: myVolumeView];
    [self.duration_slider addTarget:self action:@selector(sliderTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];

    [super viewDidLoad];
}

- (void)updateTime:(NSTimer *)timer {
    
    if(is_seeking)
        return;
    
    NSTimeInterval currentTime =[PlayerManager sharedInstance].player.currentPlaybackPosition;
    NSNumber *totalTime = [[PlayerManager sharedInstance].player.currentTrackMetadata valueForKey:SPTAudioStreamingMetadataTrackDuration];

    self.current_time_txt.text = [self formattedStringForDuration:currentTime];
    self.duration_slider.value = (currentTime / [totalTime doubleValue]);
    //[self updateUI];
    
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
}

-(void)viewDidAppear:(BOOL)animated
{
    SPTPartialTrack *track =self.tracks[self.current_track_index];
    [self playTheTrack:track];
    
    [[PlayerManager sharedInstance]setTrackPaused:^{
        [self.play_btn setImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
    }];
    
    [[PlayerManager sharedInstance]setTrackChanged:^(NSDictionary *metaDict) {
        [self updateUI];
        
        if ([PlayerManager sharedInstance].player.currentTrackMetadata == nil) {
            NSLog(@"track is over");
            trackLoaded = NO;
            [self.timer invalidate];
            [self playNextTrack:nil];
        }
        
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.timer invalidate];
}

-(void)playTheTrack:(SPTPartialTrack *)track
{
    [[PlayerManager sharedInstance]playTrack:track with_block:^(SPTTrack *track) {
        
        [[PlayerManager sharedInstance]coverForAlbum:track.album with_block:^(UIImage *image) {
            self.coverImage.image = image;
        }];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTime:)
                                                    userInfo:nil
                                                     repeats:YES];
        self.duration_slider.value = 0;
        [self.play_btn setImage:[UIImage imageNamed:@"pause_icon"] forState:UIControlStateNormal];
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
        [self.play_btn setImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
        [[PlayerManager sharedInstance].player setIsPlaying:YES callback:nil];
    }
    else
    {
        [self.play_btn setImage:[UIImage imageNamed:@"pause_icon"] forState:UIControlStateNormal];
        [[PlayerManager sharedInstance].player setIsPlaying:NO callback:nil];

    }

}

- (IBAction)playNextTrack:(id)sender
{
    if(self.current_track_index <self.tracks.count)
    {
        [self.timer invalidate];
        self.current_track_index++;
        SPTPartialTrack *track =self.tracks[self.current_track_index];
        [self playTheTrack:track];
    }

}
- (IBAction)playPreviousTrack:(id)sender
{
    if(self.current_track_index >=1)
    {
        [self.timer invalidate];
        self.current_track_index--;
        SPTPartialTrack *track =self.tracks[self.current_track_index];
        [self playTheTrack:track];
    }
}

- (IBAction)shuffleTracks:(id)sender {
    
    NSMutableArray *tracks = [self.tracks mutableCopy ];
    NSUInteger count = [self.tracks count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
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

- (IBAction)starTrack:(id)sender;
{
    SPTPartialTrack *track =self.tracks[self.current_track_index];

    if(track) {
        [[PlayerManager sharedInstance]starTrack:track];
    }

}
- (IBAction)saveTrack:(id)sender {
    
}

- (IBAction)addToPlaylist:(id)sender {
    
//    __weak PlaylistsTableViewController *playlists = [self.storyboard instantiateViewControllerWithIdentifier:@"Playlists"];
//    
//    [playlists setAddToPlaylist:^(SPPlaylist *playlist) {
//        
//        [playlist addItem:self.current_track atIndex:0 callback:^(NSError *error) {
//            if(!error)
//            {
//                printf("track added!");
//            }
//            else
//            {
//                NSLog(@"error %@",error);
//            }
//            [playlists dismissViewControllerAnimated:YES completion:nil];
//
//        }];
//    }];
//    
//    [self.navigationController presentViewController:playlists animated:YES completion:nil];
    
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
