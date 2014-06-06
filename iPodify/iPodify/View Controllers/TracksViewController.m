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
#import "TrackCell.h"
#import "PlayerManager.h"
#import "PlaylistsTableViewController.h"
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
    //Register the custom subclass
    [self.tableView registerClass:[TrackCell class] forCellReuseIdentifier:@"Cell"];

    
    self.cellsCurrentlyEditing = [NSMutableArray array];

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
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    
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

    cell.exampleLabel.text = track.name;
    cell.exampleImageView.image = nil;
    [[PlayerManager sharedInstance]coverForAlbum:track.album with_block:^(UIImage *image) {
        cell.exampleImageView.image = image;

    }];
   
    
    //if the track is starrted, show a star on the left hand side
    if(track.starred)
    {
        NSLog(@"current track %@ is starred",track.name);
    }
    
    //Set up the buttons
    cell.indexPath = indexPath;
    cell.dataSource = self;
    cell.delegate = self;
    
    [cell setNeedsUpdateConstraints];
    
    //Reopen the cell if it was already editing
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
        [cell openCell:NO];
    }

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PlayTrack" sender:self];
    
}
#pragma mark Required Methods
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //This needs to return NO or you'll only get the stock delete button.
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Deletes the object from the array
        [_itemTitles removeObjectAtIndex:indexPath.row];
        
        //Deletes the row from the tableView.
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        //This is something that hasn't been set up yet - add a log to determine
        //what sort of editing style you also need to handle.
        NSLog(@"Unhandled editing style! %d", editingStyle);
    }
    
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

#pragma mark - DNSSwipeableCellDataSource

#pragma mark Required Methods
- (NSInteger)numberOfButtonsInSwipeableCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 3;
    
}

- (NSString *)titleForButtonAtIndex:(NSInteger)index inCellAtIndexPath:(NSIndexPath *)indexPath
{
    switch (index) {
        case 0:
            return NSLocalizedString(@"Star", @"Star");
            break;
        case 1:
            return NSLocalizedString(@"Add", @"Add");
            break;
        case 2:
            return NSLocalizedString(@"Save", @"Save");
            break;
        default:
            break;
    }
    
    return nil;
}

- (UIColor *)backgroundColorForButtonAtIndex:(NSInteger)index inCellAtIndexPath:(NSIndexPath *)indexPath
{
    switch (index) {
        case 0:
            return [UIColor yellowColor];
            break;
        case 1:
            return [UIColor greenColor];
            break;
        case 2:
            return [UIColor whiteColor];
            break;
    }
    return NULL;
}

- (UIColor *)textColorForButtonAtIndex:(NSInteger)index inCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIColor blackColor];
}
#pragma mark - DNSSwipeableCellDelegate

- (void)swipeableCell:(DNSSwipeableCell *)cell didSelectButtonAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SPTrack *currentTrack = [self.tracks objectAtIndex:indexPath.row];

    if(index ==0)
    {
        //Star Track
        [[PlayerManager sharedInstance]starTrack:currentTrack];
        [[[UIAlertView alloc]initWithTitle:@"Track Saved" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil]show];
    }
    else if (index ==1)
    {
        __weak PlaylistsTableViewController *playlists = [self.storyboard instantiateViewControllerWithIdentifier:@"Playlists"];
        
        [playlists setAddToPlaylist:^(SPPlaylist *playlist) {
            
//            if(playlist)
//            {
//                [playlist addItem:currentTrack atIndex:0 callback:^(NSError *error) {
//                    if(!error)
//                    {
//                        printf("track added!");
//                           [[[UIAlertView alloc]initWithTitle:@"Track Added" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil]show];
//                    }
//                    else
//                    {
//                        NSLog(@"error %@",error);
//                    }
//                    
//                }];
//            }
            [playlists dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:playlists];
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    [cell closeCell:YES];
}
 
- (void)swipeableCellDidOpen:(DNSSwipeableCell *)cell
{
    [self.cellsCurrentlyEditing addObject:cell.indexPath];
}

- (void)swipeableCellDidClose:(DNSSwipeableCell *)cell
{
    [self.cellsCurrentlyEditing removeObject:cell.indexPath];
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
