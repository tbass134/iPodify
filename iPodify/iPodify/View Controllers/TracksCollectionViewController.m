//
//  TracksCollectionViewController.m
//  iPodify
//
//  Created by Tony Hung on 12/30/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#import "TracksCollectionViewController.h"
#import "TrackCollectionViewCell.h"
#import "PlayerViewController.h"
#import "PlayerManager.h"

@interface TracksCollectionViewController ()
{
    NSMutableArray *allTracks;
    NSMutableDictionary *sortedTracks;
    SPTPlaylistSnapshot *_playlistSnapshot;
}
@end

@implementation TracksCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    
    allTracks = [NSMutableArray new];
    sortedTracks = [NSMutableDictionary new];
    
    [SPTRequest requestItemFromPartialObject:self.playlist withSession:[PlayerManager sharedInstance].session callback:^(NSError *error, SPTPlaylistSnapshot *playlistSnapshot) {
        _playlistSnapshot = playlistSnapshot;
        SPTListPage *page = _playlistSnapshot.firstTrackPage;
        [self loadTracksForPage:page];
    }];
    [super viewDidLoad];
}
- (void)loadTracksForPage:(SPTListPage *)page
{
    NSLog(@"page.tracksForPlayback.count %lu page.totalListLength %lu", (unsigned long)page.tracksForPlayback.count,(unsigned long)page.totalListLength);
    if (allTracks.count < page.totalListLength) {
        [allTracks addObjectsFromArray:page.tracksForPlayback];
        [_playlistSnapshot.firstTrackPage requestNextPageWithSession:[PlayerManager sharedInstance].session  callback:^(NSError *error, SPTListPage *page) {
                [self loadTracksForPage:page];
        }];
    } else
    {
        //NSLog(@"done loading tracks %@",allTracks);
        //sort tracks by arist, then song
        [self sortTracksByArtist];
        [self.collectionView reloadData];
    }
}

- (void)sortTracksByArtist
{
    NSArray* ids = [allTracks valueForKeyPath:@"artists.identifier"];
    NSSet* uniqueIDs = [NSSet setWithArray:ids];
    for (NSArray* anIDs in [uniqueIDs allObjects])
    {
        NSString *anID =[anIDs firstObject];
        [sortedTracks setObject:[self tracksForArtistID:anID] forKey:anID];
    }
    
    NSLog(@"result %@",sortedTracks);
}
- (NSArray *)tracksForArtistID:(NSString *)artistID
{
    NSMutableArray *tracks = [NSMutableArray new];
    
    for (SPTPlaylistTrack *track in allTracks) {
        SPTPartialArtist *artist = [track.artists firstObject];
        if ([artist.identifier isEqualToString:artistID]) {
            [tracks addObject:track];
        }
    }
    return tracks;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"playTrack"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        NSArray *keys = [sortedTracks allKeys];
        NSArray *values = [sortedTracks[keys[indexPath.section]]sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        SPTPartialTrack *track = [values objectAtIndex:indexPath.row];
        PlayerViewController *controller = segue.destinationViewController;
        controller.tracks = values;
        controller.current_track_index = indexPath.row;
        controller.current_track = track;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sortedTracks.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *keys = [sortedTracks allKeys];
    return [sortedTracks[keys[section]] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TrackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSArray *keys = [sortedTracks allKeys];
    NSArray *values = [sortedTracks[keys[indexPath.section]]sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    SPTPartialTrack *track = [values objectAtIndex:indexPath.row];
    cell.trackName.text = track.name;
    SPTPartialArtist *artist = [track.artists firstObject];
    cell.trackArtist.text = artist.name;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"playTrack" sender:nil];
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
