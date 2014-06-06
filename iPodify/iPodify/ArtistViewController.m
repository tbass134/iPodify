//
//  ArtistViewController.m
//  Simple Player
//
//  Created by Antonio Hung on 1/7/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "ArtistViewController.h"
#import "TracksViewController.h"
#import "TrackCell.h"
#import "PlayerManager.h"
#import "PlaylistsTableViewController.h"

@interface ArtistViewController ()

@end

@implementation ArtistViewController

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
    [self.tableView registerClass:[TrackCell class] forCellReuseIdentifier:@"Cell"];
    
    
    self.cellsCurrentlyEditing = [NSMutableArray array];


    [SPAsyncLoading waitUntilLoaded:[SPArtistBrowse browseArtist:self.artist inSession:[SPSession sharedSession] type:SP_ARTISTBROWSE_NO_TRACKS] timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
        
        if(loadedItems.count>0)
        {
            SPArtistBrowse *artistBrowse =loadedItems[0];
            NSMutableArray *available_albums = [[NSMutableArray alloc]init];
            for(SPAlbum *album in artistBrowse.albums)
            {
                if(album.available)
                    [available_albums addObject:album];
            }
            self.albums = available_albums;
            [self.tableView reloadData];
        }
    }];
    
    //self.albums = [NSArray alloc]initWithArray:self.artist.
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    SPAlbum *album = [self.albums objectAtIndex:indexPath.row];
    
    cell.exampleLabel.text = album.name;
    cell.exampleImageView.image = nil;
    [[PlayerManager sharedInstance]coverForAlbum:album with_block:^(UIImage *image) {
        cell.exampleImageView.image = image;
        
    }];

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
    [self performSegueWithIdentifier:@"Album_Tracks" sender:nil];
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
    SPAlbum *album = [self.albums objectAtIndex:indexPath.row];
   
    if(index ==0)
    {
        [[PlayerManager sharedInstance]getTracksForAlbum:album with_block:^(NSArray *tracks) {
            for(SPTrack *track in tracks)
            {
                [[PlayerManager sharedInstance]starTrack:track];
                
            }
            [[[UIAlertView alloc]initWithTitle:@"Tracks Saved" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil]show];

        }];
        
    }
    else if (index ==1)
    {
        __weak PlaylistsTableViewController *playlists = [self.storyboard instantiateViewControllerWithIdentifier:@"Playlists"];
        
        [playlists setAddToPlaylist:^(SPPlaylist *playlist) {
            
            if(playlist)
            {
                
                [[PlayerManager sharedInstance]getTracksForAlbum:album with_block:^(NSArray *tracks) {
                    [playlist addItems:tracks atIndex:0 callback:^(NSError *error) {
                        if(!error)
                        {
                            [[[UIAlertView alloc]initWithTitle:@"Tracks Added" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil]show];
                        }
                        else
                        {
                            [[[UIAlertView alloc]initWithTitle:@"Error!" message:error.description delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil]show];
                        }
                        
                    }];
                    
                }];
            }
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
    if([segue.identifier isEqualToString:@"Album_Tracks"])
    {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        SPAlbum *album = [self.albums objectAtIndex:path.row];
        TracksViewController *tracks = segue.destinationViewController;
        tracks.album = album;
        tracks.artist = self.artist;
        
    }
    //    DetailObject *detail = [self detailForIndexPath:path];
    //    [segue.destinationViewController setDetail:detail];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
