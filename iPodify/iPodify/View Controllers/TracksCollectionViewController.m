//
//  TracksCollectionViewController.m
//  iPodify
//
//  Created by Tony Hung on 12/30/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#import "TracksCollectionViewController.h"
#import "TrackCollectionViewCell.h"
#import "TrackCollectionReusableView.h"
#import "PlayerViewController.h"
#import "PlayerManager.h"

@interface TracksCollectionViewController () <UIGestureRecognizerDelegate>
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
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 44.);
    layout.minimumLineSpacing = 4.;
    layout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
    

    
    
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
        //[sortedTracks setObject:[self tracksForArtistID:anID] forKey:anID];
    }
    
    NSLog(@"result %@",sortedTracks);
}
- (NSArray *)tracksForArtistID:(NSString *)artistID
{
    return [allTracks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"artists.identifier contains[cd] %@",artistID]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sortedTracks.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *keys = [sortedTracks allKeys];
    NSInteger numberOfItemsInSection =  [sortedTracks[keys[section]] count] + 1;
    return numberOfItemsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TrackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSArray *keys = [sortedTracks allKeys];
    NSArray *values = [sortedTracks[keys[indexPath.section]]sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    if (indexPath.item == 0) {
        NSArray *keys = [sortedTracks allKeys];
         cell.trackName.text = keys[indexPath.section];
        cell.indentView.hidden = YES;

    }
    else {
        SPTPartialTrack *track = [values objectAtIndex:indexPath.row - 1];
        cell.trackName.text = track.name;
        SPTPartialArtist *artist = [track.artists firstObject];
        cell.trackArtist.text = artist.name;
        cell.indentView.hidden = NO;

    }
    
    return cell;
}

#pragma mark Segue

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{   
    [self performSegueWithIdentifier:@"playTrack" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"playTrack"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        NSArray *keys = [sortedTracks allKeys];
        NSArray *values = [sortedTracks[keys[indexPath.section]]sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        SPTPartialTrack *track = [values objectAtIndex:indexPath.row - 1];
        PlayerViewController *controller = segue.destinationViewController;
        controller.tracks = values;
        controller.current_track_index = indexPath.row;
        controller.current_track = track;
    }
}

@end
