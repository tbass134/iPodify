//
//  PlayListTracksTableViewController.m
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import "PlayListTracksTableViewController.h"
#import "PlayerViewController.h"
#import "PlaylistManager.h"

@interface PlayListTracksTableViewController ()

@end

@implementation PlayListTracksTableViewController

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
    
    //show tracks that are in users playlist fol
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
{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    

    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PlayTrack" sender:nil];
    
    
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PlayTrack"])
    {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        PlayerViewController *player = segue.destinationViewController;
        player.arist = nil;
        player.album = nil;
        player.current_track_index = path.row;
        //player.tracks = self.playlist.items;
        
    }

    //    DetailObject *detail = [self detailForIndexPath:path];
    //    [segue.destinationViewController setDetail:detail];
}

@end
