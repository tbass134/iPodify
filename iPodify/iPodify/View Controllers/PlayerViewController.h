//
//  PlayerViewController.h
//  Simple Player
//
//  Created by Antonio Hung on 1/23/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController
{
    BOOL trackLoaded;
    BOOL is_playing;
    BOOL is_seeking;
}
@property(nonatomic,weak)NSTimer *timer;
@property(nonatomic,assign)BOOL scrubbing;
@property(nonatomic,strong)NSArray *tracks;
@property(nonatomic,assign)NSInteger current_track_index;
@property(nonatomic,strong)SPTArtist *arist;
@property(nonatomic,strong)SPTAlbum *album;
@property (weak, nonatomic) IBOutlet UIView *volumeView;


@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (strong, nonatomic) IBOutlet UILabel *artist_name_txt;
@property (weak, nonatomic) IBOutlet UILabel *song_txt;
@property (weak, nonatomic) IBOutlet UILabel *album_txt;

@property (weak, nonatomic) IBOutlet UIButton *play_btn;
@property (weak, nonatomic) IBOutlet UIButton *fwd_btn;
@property (weak, nonatomic) IBOutlet UIButton *prev_btn;
@property (weak, nonatomic) IBOutlet UISlider *duration_slider;
@property (weak, nonatomic) IBOutlet UILabel *current_time_txt;
@property (weak, nonatomic) IBOutlet UILabel *duration_time_txt;
- (IBAction)scrubberChanged:(id)sender;

- (IBAction)playTrack:(id)sender;
- (IBAction)playNextTrack:(id)sender;
- (IBAction)playPreviousTrack:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)shuffleTracks:(id)sender;
- (IBAction)repeatTrack:(id)sender;
- (IBAction)showMore:(id)sender;
@end
