//
//  PlaylistsCollectionViewController.m
//  iPodify
//
//  Created by Antonio Hung on 12/30/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#import "PlaylistsCollectionViewController.h"
#import "TracksCollectionViewController.h"
#import "PlaylistCollectionViewCell.h"
#import "PlaylistManager.h"
#import "PlayerManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PlaylistsCollectionViewController ()
{
    NSArray *starredTracks;
    NSMutableArray *images;
}
@end

@implementation PlaylistsCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]init];
    activityView.center = self.collectionView.center;
    _activityView = activityView;
    [self.view addSubview:activityView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionDataLoaded) name:@"successCallback" object:nil];
}

- (void)sessionDataLoaded
{
    if ([PlayerManager sharedInstance].session) {
        if (!self.playlists) {
            self.playlists = [NSMutableArray new];
        }
        [_activityView startAnimating];
        
        [[PlaylistManager sharedInstance]loadPlaylists:^(NSError *error, NSArray *playlists) {
            [self.playlists addObjectsFromArray:playlists];
            [_activityView stopAnimating];
            
            [self.collectionView reloadData];
        }];
    }
}

- (void)loadPlaylistsFromPlaylist: (SPTPartialPlaylist *)playlist
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showTracks"]) {
        TracksCollectionViewController *controller = segue.destinationViewController;

        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        if ([[self.playlists objectAtIndex:indexPath.row] isKindOfClass:[SPTPartialPlaylist class]]) {

            SPTPartialPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
            controller.playlist = playlist;
        } else {
            controller.savedTracks = [self.playlists objectAtIndex:indexPath.row];
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake((CGRectGetWidth(self.collectionView.bounds) / 2)-10.0, 150);
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.playlists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PlaylistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.coverImage.image = nil;
    cell.playlistName.text = nil;
    
    if ([[self.playlists objectAtIndex:indexPath.row] isKindOfClass:[SPTPartialPlaylist class]])
    {
        SPTPartialPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
        
        [cell.coverImage sd_setImageWithURL:[playlist.largestImage imageURL]];
        cell.playlistName.text = playlist.name;
    }
    else {
        cell.coverImage.image = nil;
        cell.playlistName.text = @"Saved Tracks";
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.playlistSelected) {
        SPTPartialPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
        self.playlistSelected(playlist);
        
    } else {
        [self performSegueWithIdentifier:@"showTracks" sender:nil];
    }
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
