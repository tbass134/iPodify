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
@property (nonatomic, strong) NSMutableArray* expandedSections;
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;

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
    [self.collectionView addGestureRecognizer:self.tapGestureRecognizer];

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


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sortedTracks.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *keys = [sortedTracks allKeys];
    NSInteger numberOfItemsInSection =  [sortedTracks[keys[section]] count];

    return [self isExpandedSection:section] ? numberOfItemsInSection : 0;

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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    TrackCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    NSArray *keys = [sortedTracks allKeys];
    headerView.artistNameLabel.text = keys[indexPath.section];
    
    
    return headerView;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 50);
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
        
        SPTPartialTrack *track = [values objectAtIndex:indexPath.row];
        PlayerViewController *controller = segue.destinationViewController;
        controller.tracks = values;
        controller.current_track_index = indexPath.row;
        controller.current_track = track;
    }
}

#pragma mark Expand
- (NSMutableArray *)expandedSections {
    if (!_expandedSections) {
        _expandedSections = [NSMutableArray array];
        
        NSInteger maxI = [self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)] ? [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView] : 0;
        for (NSInteger i = 0; i < maxI; i++) {
            [_expandedSections addObject:@NO];
        }
    }
    return _expandedSections;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        _tapGestureRecognizer.delegate = self;
    }
    return _tapGestureRecognizer;
}

- (BOOL)isExpandedSection:(NSInteger)section {
    return [self.expandedSections[section] boolValue];
}

- (void)handleTapGesture:(UITapGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath* tappedCellPath = [NSIndexPath indexPathForItem:0 inSection:0];
        
        if (tappedCellPath) {
            NSInteger tappedSection = tappedCellPath.section;
            BOOL willOpen = ![self.expandedSections[tappedSection] boolValue];
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (int i = )
            for (NSInteger i = 0, maxI = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:tappedSection]; i < maxI; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:tappedSection]];
            }
            [self.collectionView performBatchUpdates:^{
                if (willOpen) {
                    [self.collectionView insertItemsAtIndexPaths:indexPaths];
                } else {
                    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
                }
                self.expandedSections[tappedSection] = @(willOpen);
            } completion:nil];
            
            if (willOpen) {
                NSIndexPath* lastItemIndexPath = [NSIndexPath indexPathForItem:[self.collectionView numberOfItemsInSection:tappedCellPath.section] - 1 inSection:tappedCellPath.section];
                UICollectionViewCell* firstItem = [self.collectionView cellForItemAtIndexPath:tappedCellPath];
                UICollectionViewCell* lastItem = [self.collectionView cellForItemAtIndexPath:lastItemIndexPath];
                CGFloat firstItemTop = firstItem.frame.origin.y;
                CGFloat lastItemBottom = lastItem.frame.origin.y + lastItem.frame.size.height;
                CGFloat height = self.collectionView.bounds.size.height;
                
                if (lastItemBottom - self.collectionView.contentOffset.y > height) {
                    if (lastItemBottom - firstItemTop > height) {
                        // using setContentOffset:animated: here because scrollToItemAtIndexPath:atScrollPosition:animated: is broken on iOS 6
                        [self.collectionView setContentOffset:CGPointMake(0., firstItemTop) animated:YES];
                    } else {
                        [self.collectionView setContentOffset:CGPointMake(0., lastItemBottom - height) animated:YES];
                    }
                }
                if ([self.delegate respondsToSelector:@selector(collectionView:didExpandItemAtIndexPath:)]) {
                    [self.delegate collectionView:self.collectionView didExpandItemAtIndexPath:tappedCellPath];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(collectionView:didCollapseItemAtIndexPath:)]) {
                    [self.delegate collectionView:self.collectionView didCollapseItemAtIndexPath:tappedCellPath];
                }
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if (gestureRecognizer == self.tapGestureRecognizer) {
//        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
//            CGPoint point = [touch locationInView:self.collectionView];
//            NSIndexPath* tappedCellPath = [self.collectionView indexPathForItemAtPoint:point];
//            return tappedCellPath && (tappedCellPath.item == 0);
//        }
//        return NO;
//    }
    return YES;
}


@end
