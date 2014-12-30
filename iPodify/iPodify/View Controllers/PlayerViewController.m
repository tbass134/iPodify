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
	// Do any additional setup after loading the view.
}
- (void)updateTime:(NSTimer *)timer {
    
    if(is_seeking)
        return;
    
//    //NSLog(@"current_track %@",self.current_track);
//    NSTimeInterval currentTime =[[PlayerManager sharedInstance].playbackManager trackPosition] ;
//    NSTimeInterval totalTime = self.current_track.duration;
//    //NSLog(@"currentTime %f totalTime %f",currentTime,totalTime);
//    
//    self.current_time_txt.text = [self formattedStringForDuration:currentTime];
//    
//    self.duration_slider.value = (currentTime /totalTime);
//    
//    NSLog(@"[PlayerManager sharedInstance].currentTrack %@",[PlayerManager sharedInstance].playbackManager.currentTrack );
//    if([PlayerManager sharedInstance].playbackManager.currentTrack == nil)
//    {
//        NSLog(@"track is over");
//        trackLoaded = NO;
//        [timer invalidate];
//        [self playNextTrack:nil];
//    }
    //NSLog(@"slide %f",self.duration_slider.value);
    
}

-(void)viewDidAppear:(BOOL)animated
{
    //[PlayerManager sharedInstance].currentTrack = nil;

    
    //start a timer to update the time label display
    
    self.current_track =self.tracks[self.current_track_index];
    [self playTheTrack:self.current_track];
    
    [[PlayerManager sharedInstance]setTrackPaused:^{
        
        [self.play_btn setTitle:@"Play" forState:UIControlStateNormal];

    }];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.timer invalidate];
}
-(void)playTheTrack:(SPTTrack *)track
{
//    [PlayerManager sharedInstance].playbackManager.isPlaying = NO;
//
//    [[PlayerManager sharedInstance]playTrack:track with_block:^(BOOL isReady) {
//        if(isReady)
//        {
//            trackLoaded = YES;
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                          target:self
//                                                        selector:@selector(updateTime:)
//                                                        userInfo:nil
//                                                         repeats:YES];
//            
//            self.duration_slider.value = 0;
//
//            
//            self.current_track = track;
//            [self.play_btn setTitle:@"Pause" forState:UIControlStateNormal];
//            
//            
//            self.duration_time_txt.text =[self formattedStringForDuration:track.duration];
//            self.artist_name_txt.text = track.album.artist.name;
//            self.song_txt.text = track.name;
//            
//            self.album_txt.text = track.album.name;
//            [[PlayerManager sharedInstance]coverForAlbum:track.album with_block:^(UIImage *image) {
//                if(image)
//                    self.coverImage.image = image;
//            }];
//        }
//    }];
 }

- (IBAction)scrubberChanged:(id)sender {
    
    is_seeking = YES;    
    //self.current_time_txt.text = [self formattedStringForDuration:[[PlayerManager sharedInstance].playbackManager trackPosition]];
    
}
-(void)sliderTouchUpInsideAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;

    NSLog(@"seconds %ld slider.value %f",(long)self.current_track.duration,slider.value);
    
    NSTimeInterval totalDutation = self.current_track.duration *(slider.value);
    
    [[PlayerManager sharedInstance]seekToPosition:round(totalDutation)];
    
    //self.current_time_txt.text = [self formattedStringForDuration:[[PlayerManager sharedInstance].playbackManager trackPosition]];
    
    is_seeking = NO;

}

- (IBAction)playTrack:(id)sender
{
//    [PlayerManager sharedInstance].playbackManager.isPlaying = ![PlayerManager sharedInstance].playbackManager.isPlaying;
//
//    if(![PlayerManager sharedInstance].playbackManager.isPlaying)
//    {
//        [self.play_btn setTitle:@"Play" forState:UIControlStateNormal];
//    }
//    else
//    {
//        [self.play_btn setTitle:@"Pause" forState:UIControlStateNormal];
//    }

}

- (IBAction)playNextTrack:(id)sender
{
    if(self.current_track_index <self.tracks.count)
    {
        [self.timer invalidate];
        self.current_track_index++;
        self.current_track =self.tracks[self.current_track_index];
        [self playTheTrack:self.current_track];
    }

}
- (IBAction)playPreviousTrack:(id)sender
{
    
    if(self.current_track_index >=1)
    {
        [self.timer invalidate];
        self.current_track_index--;
        self.current_track =self.tracks[self.current_track_index];
        [self playTheTrack:self.current_track];
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
    self.current_track =self.tracks[self.current_track_index];
    [self playTheTrack:self.current_track];
    
}

- (IBAction)repeatTrack:(id)sender {
    
    if(self.current_track)
     [self playTheTrack:self.current_track];
}

- (IBAction)starTrack:(id)sender;
{
    if(self.current_track)
        [[PlayerManager sharedInstance]starTrack:self.current_track];

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
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
