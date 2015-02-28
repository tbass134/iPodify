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
#import "PlaylistManager.h"

@interface TracksCollectionViewController () <UIGestureRecognizerDelegate>
{
    NSMutableDictionary *sortedTracks;
    SPTPlaylistSnapshot *_playlistSnapshot;
}
@property(nonatomic,strong) NSMutableArray *allTracks;

@end

@implementation TracksCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    
    sortedTracks = [NSMutableDictionary new];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]init];
    activityView.center = self.collectionView.center;
    _activityView = activityView;
    [self.view addSubview:activityView];

    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 44.);
    layout.minimumLineSpacing = 4.;
    layout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
    
    if (self.savedTracks) {
        _allTracks = [NSMutableArray arrayWithArray:self.savedTracks];
        [self sortTracksByArtist];
        [self.collectionView reloadData];
    } else {
        
        [_activityView startAnimating];
        [[PlaylistManager sharedInstance]loadTracksForPlaylist:self.playlist completion:^(NSError *error, NSArray *tracks) {
            _allTracks = [NSMutableArray arrayWithArray:tracks];
            //NSLog(@"sorted %@",[_allTracks sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"artists[0].name" ascending:YES]]]);
            
            //NSLog(@"_allTracks %i",_allTracks.count);
            
            [self sortTracksByArtist];
            [self.collectionView reloadData];
            [_activityView stopAnimating];
        }];
        
    }
    [super viewDidLoad];
}

- (void)sortTracksByArtist
{
    NSArray* ids = [_allTracks valueForKeyPath:@"artists.name"];
    NSSet* uniqueIDs = [NSSet setWithArray:ids];
    for (NSArray* anIDs in [uniqueIDs allObjects])
    {
        NSString *anID =[anIDs firstObject];
        NSLog(@"anID %@",anID);
        [sortedTracks setObject:[self tracksForArtistID:anID] forKey:anID];
        //[sortedTracks setObject:[self tracksForArtistID:anID] forKey:anID];
    }

    
    NSLog(@"result %@",sortedTracks);
}
- (NSArray *)tracksForArtistID:(NSString *)artistID
{
    return [[_allTracks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"artists.name contains[cd] %@",artistID]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"album.releaseDate" ascending:YES]]];
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
    NSArray *keys = [[sortedTracks allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *values = sortedTracks[keys[indexPath.section]];
    
    if (indexPath.item == 0) {
        NSArray *keys = [[sortedTracks allKeys]sortedArrayUsingSelector:@selector(compare:)];
         cell.trackName.text = keys[indexPath.section];
            cell.indentView.hidden = YES;
        cell.trackArtist.text = nil;
        

    }
    else {
        SPTPlaylistTrack *track = [values objectAtIndex:indexPath.row - 1];
        cell.trackName.text = track.name;
        SPTPartialArtist *artist = [track.artists firstObject];
        cell.trackArtist.text = nil;//artist.name;
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
        NSArray *values = sortedTracks[keys[indexPath.section]];
        
        PlayerViewController *controller = segue.destinationViewController;
        controller.tracks = values;
        controller.current_track_index = indexPath.row - 1;
        //controller.current_track = track;
    }
}

@end
