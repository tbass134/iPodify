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
   	self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
	[[SPSession sharedSession] setDelegate:self];
	[self performSelector:@selector(showLogin) withObject:nil afterDelay:0.0];


    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)showLogin {
    
    NSString *username = [[NSUserDefaults standardUserDefaults]valueForKey:@"userName"];
    NSString *credential = [[NSUserDefaults standardUserDefaults]valueForKey:@"credential"];
    
    if(username && credential)
        [[SPSession sharedSession] attemptLoginWithUserName:username existingCredential:credential];
    else
    {
        SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
        controller.allowsCancel = NO;
        
        [self presentModalViewController:controller
                                animated:NO];
        
        
    }
}

-(void)loadPlaylists
{
    self.songs = [[NSMutableArray alloc]init];
    [SPAsyncLoading waitUntilLoaded:[SPSession sharedSession] timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedession, NSArray *notLoadedSession)
    {
        // The session is logged in and loaded — now wait for the userPlaylists to load.
        
        [[PlaylistManager sharedInstance]loadPlaylists:^(NSArray *playlists) {
            for(SPPlaylist *playlist in playlists)
            {
                for(SPTrack *track in playlist.items)
                {

                    if(track)
                        [self.songs addObject:track];
                }
            }
            
            [self sortSongsByAritst];

        }];
        
    }];
}

-(void)sortSongsByAritst
{
    NSMutableSet *temp_a =[[NSMutableSet alloc]init];
    for(SPPlaylistItem *item in self.songs)
    {
        if (item.itemClass == [SPTrack class])
        {
            SPTrack *track = item.item;
            if(track.artists.count>0)
            [temp_a addObject:[track.artists firstObject]];
        }
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];

    self.artists = [[NSMutableArray alloc]initWithArray:[temp_a sortedArrayUsingDescriptors:@[sort]]];
    [self.table_view reloadData];

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
    
    SPArtist *arist = [self.artists objectAtIndex:indexPath.row];
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
        SPArtist *artist = [self.artists objectAtIndex:path.row];
        
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


#pragma mark -
#pragma mark SPSessionDelegate Methods

-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return self;
}

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
	// Invoked by SPSession after a successful login.
    //[self playTrack];
    
    //NSLog(@"songs %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"songs"]);
    [self loadPlaylists];
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
	// Invoked by SPSession after a failed login.
}
-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName
{
    [[NSUserDefaults standardUserDefaults]setValue:credential forKey:@"credential"];
    [[NSUserDefaults standardUserDefaults]setValue:userName forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)sessionDidLogOut:(SPSession *)aSession {
	
	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	
	if (self.presentedViewController != nil) return;
	
	controller.allowsCancel = NO;
	
	[self presentModalViewController:controller
											   animated:YES];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	//return;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}


- (void)dealloc {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
