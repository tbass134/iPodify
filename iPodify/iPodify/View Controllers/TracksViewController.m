//
//  TracksViewController.m
//  Simple Player
//
//  Created by Antonio Hung on 1/10/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "TracksViewController.h"
#import "PlayerViewController.h"
#import "PlaylistManager.h"
@interface TracksViewController ()

@end

@implementation TracksViewController

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
    if(self.album) //comming from arist view
    {
        [SPAsyncLoading waitUntilLoaded:[SPAlbumBrowse browseAlbum:self.album inSession:[SPSession sharedSession]] timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
            SPArtistBrowse *ab = loadedItems[0];
            //NSLog(@"tracks %@",ab.tracks);
            self.tracks = ab.tracks;
            
            albumTracks = [NSMutableArray arrayWithArray:self.tracks];
            
            NSMutableArray *tempTracks = [[NSMutableArray alloc]init];
            NSLog(@"self.tracks %@",self.tracks);
            for(SPTrack *track in self.tracks)
            {
                if([[PlaylistManager sharedInstance]isTrackInPlaylist:track])
                {
                    [tempTracks addObject:track];
                }
            }
            tracksInPlayist = tempTracks;
            
            [self.tableView reloadData];

        }];
    }
    else if(self.playlist)
    {
        NSMutableArray *tracks = [[NSMutableArray alloc]init];
        
        for (SPPlaylistItem *item in self.playlist.items) {
            if (item.itemClass == [SPTrack class])
                [tracks addObject:item.item];
        }
        self.tracks = tracks;
        [self.tableView reloadData];
    }
       [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.playlist)
        return 1;
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.playlist)
        return self.tracks.count;
    
    if(section ==0)
        return albumTracks.count;
    return tracksInPlayist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//    SPDispatchAsync(^{
//        SPArtistBrowse *ab = [SPArtistBrowse browseArtist:self.artist inSession:[SPSession sharedSession] type:SP_ARTISTBROWSE_NO_TRACKS];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSLog(@"ab %@",ab.biography);
//        });
//    });
    SPTrack *track;
    if(self.playlist)
        track = self.tracks[indexPath.row];
    else
    {
        if(indexPath.section ==0 )
            track = albumTracks[indexPath.row];
        else
            track = tracksInPlayist[indexPath.row];
    }

    cell.textLabel.text = track.name;
    
    cell.imageView.image = nil;
    
    
    SPTrack *currentTrack = [self.tracks objectAtIndex:indexPath.row];
    cell.textLabel.text =currentTrack.name;
    
    //if the track is starrted, show a star on the left hand side
    if(currentTrack.starred)
    {
        NSLog(@"current track %@ is starred",currentTrack.name);
    }
    
    //This is a placeholder to test adding tracks to playlist until we get the swipe animation on the cell
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(addToPlaylist:)];
    [cell addGestureRecognizer:longPress];

    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PlayTrack" sender:self];
    
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PlayTrack"])
    {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        PlayerViewController *player = segue.destinationViewController;
        player.arist = self.artist;
        player.album = self.album;
        player.current_track_index = path.row;
        player.tracks = self.tracks;
        
    }
    //    DetailObject *detail = [self detailForIndexPath:path];
    //    [segue.destinationViewController setDetail:detail];
}
-(void)addToPlaylist:(UILongPressGestureRecognizer *)guesture
{
    SPTrack *currentTrack = [self.tracks objectAtIndex:0];
    
    //show modal of playlists, then add the track to the playlist
    //for now, just add the track to a playlist
    SPPlaylist *firstPlaylist = [PlaylistManager sharedInstance].playlists[1];
    NSString *playlistName = firstPlaylist.name;
    [firstPlaylist addItem:currentTrack atIndex:0 callback:^(NSError *error) {
        NSLog(@"track %@ added to playlist %@",currentTrack.name,playlistName);
    }];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
