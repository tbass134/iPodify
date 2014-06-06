//
//  TracksViewController.h
//  Simple Player
//
//  Created by Antonio Hung on 1/10/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "DNSSwipeableCell.h"

@interface TracksViewController : UIViewController<DNSSwipeableCellDelegate, DNSSwipeableCellDataSource>
{
    NSMutableArray *tracksInPlayist;
    NSMutableArray *albumTracks;
}
@property (nonatomic, assign) BOOL sortTracksByArtist;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) SPArtist *artist;
@property (nonatomic, strong) SPAlbum *album;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic,strong) SPPlaylist *playlist;

@property (nonatomic, strong) NSMutableArray *cellsCurrentlyEditing;
@property (nonatomic, strong) NSMutableArray *itemTitles;
@end
