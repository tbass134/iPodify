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

@interface PlaylistsCollectionViewController ()

@end

@implementation PlaylistsCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionDataLoaded) name:@"successCallback" object:nil];
}

- (void)sessionDataLoaded
{
    //[self loadPlaylistsFromPlaylist:nil];
    
    [[PlaylistManager sharedInstance]loadPlaylists:^(NSError *error, NSArray *playlists) {
        self.playlists = playlists;
        [self.collectionView reloadData];
    }];
    
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
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        SPTPartialPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
        TracksCollectionViewController *controller = segue.destinationViewController;
        controller.playlist = playlist;

    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((CGRectGetWidth(self.collectionView.bounds) / 2)-10.0, 150);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.playlists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PlaylistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    
    SPTPartialPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
    cell.playlistName.text = playlist.name;
    //cell.playlistCoverImage.image = playlist
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showTracks" sender:nil];
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
