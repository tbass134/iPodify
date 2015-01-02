//
//  ArtistViewController.m
//  Simple Player
//
//  Created by Antonio Hung on 1/7/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "ArtistViewController.h"

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

//    [SPAsyncLoading waitUntilLoaded:[SPArtistBrowse browseArtist:self.artist inSession:[SPSession sharedSession] type:SP_ARTISTBROWSE_NO_TRACKS] timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
//        
//        if(loadedItems.count>0)
//        {
//            SPArtistBrowse *artistBrowse =loadedItems[0];
//            NSMutableArray *available_albums = [[NSMutableArray alloc]init];
//            for(SPAlbum *album in artistBrowse.albums)
//            {
//                if(album.available)
//                    [available_albums addObject:album];
//            }
//            self.albums = available_albums;
//            [self.tableView reloadData];
//        }
//    }];
    
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.imageView.image = nil;

    
    SPTAlbum *album = [self.albums objectAtIndex:indexPath.row];
    SPTImage *coverImage = [album.covers firstObject];
    //cell.imageView.image = coverImage.imageURL;

    cell.textLabel.text =album.name;
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"Album_Tracks" sender:nil];
    
    
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Album_Tracks"])
    {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
               
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
