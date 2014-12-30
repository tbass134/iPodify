//
//  MainViewController.m
//  Simple Player
//
//  Created by Antonio Hung on 11/12/13.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import "MainViewController.h"
#import "ArtistViewController.h"
#import "PlaylistManager.h"
#import "PlayerManager.h"
@interface MainViewController ()

@end

@implementation MainViewController

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
    self.songs = [[NSMutableArray alloc]init];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


-(void)sortSongsByAritst
{
    NSMutableSet *temp_a =[[NSMutableSet alloc]init];
//    for(SPTPlaylistList *item in self.songs)
//    {
//        if (item.itemClass == [SPTTrack class])
//        {
//            SPTrack *track = item.item;
//            if(track.artists.count>0)
//            [temp_a addObject:[track.artists firstObject]];
//        }
//    }
//    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
//
//    self.artists = [[NSMutableArray alloc]initWithArray:[temp_a sortedArrayUsingDescriptors:@[sort]]];
//    [self.table_view reloadData];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.artists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SPTArtist *arist = [self.artists objectAtIndex:indexPath.row];
    cell.textLabel.text =arist.name;
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"Artist_Detail" sender:nil];

}

 #pragma mark - Navigation
 
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Artist_Detail"])
    {
        NSIndexPath *path = [self.table_view indexPathForSelectedRow];
        SPTArtist *artist = [self.artists objectAtIndex:path.row];
        
        ArtistViewController *controller;
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navController =
            (UINavigationController *)segue.destinationViewController;
            
            controller = [navController.viewControllers objectAtIndex:0];
            
        } else {
            
            controller = segue.destinationViewController;
        }
    
        controller.artist = artist;


    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
