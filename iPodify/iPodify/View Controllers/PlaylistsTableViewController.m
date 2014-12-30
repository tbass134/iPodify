//
//  PlaylistsTableViewController.m
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "PlaylistsTableViewController.h"
#import "PlaylistManager.h"
#import "TracksViewController.h"
@interface PlaylistsTableViewController ()

@end

@implementation PlaylistsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionDataLoaded) name:@"successCallback" object:nil];
}

- (void)sessionDataLoaded
{
    [[PlaylistManager sharedInstance]loadPlaylists:^(SPTPlaylistList *playlists) {
        NSLog(@"playlists %@",playlists);
        self.playlists = playlists;
        [self.tableView reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    // Return the number of rows in the section.
    return self.playlists.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveToOffline:)];
    
    // Configure the cell...
    SPTPartialPlaylist *playlist = [self.playlists.items objectAtIndex:indexPath.row];
    cell.textLabel.text = [playlist name];
    [cell setGestureRecognizers:@[longPress]];
    
    
    return cell;
}
-(void)saveToOffline:(id )guesture
{
    //get cell at guesture point
    //SPTPlaylistList *playlist = self.playlists[1];
    
//    if(![playlist isMarkedForOfflinePlayback])
//        [playlist setMarkedForOfflinePlayback:YES];
//
//    NSLog(@"offline %@",[playlist offlineStatusString]);
   
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.addToPlaylist)
    {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        SPTPlaylistList *playlist = self.playlists.items[path.row];
        self.addToPlaylist(playlist);
    }
    else
        [self performSegueWithIdentifier:@"Album_Tracks" sender:nil];

}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if([segue.identifier isEqualToString:@"view_tracks"])
//    {
//        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
//        SPPlaylist *playlist = self.playlists[path.row];
//        PlayListTracksTableViewController *playlistItems = segue.destinationViewController;
//        playlistItems.playlist = playlist;
//        
//    }
    
    if([segue.identifier isEqualToString:@"Album_Tracks"])
    {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        SPTPlaylistList *playlist = self.playlists.items[path.row];
        TracksViewController *tracks = segue.destinationViewController;
        tracks.album = nil;
        tracks.artist = nil;
        tracks.playlist = playlist;
        
        
    }
    //    DetailObject *detail = [self detailForIndexPath:path];
    //    [segue.destinationViewController setDetail:detail];
}

@end
