//
//  TracksViewController.h
//  Simple Player
//
//  Created by Antonio Hung on 1/10/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TracksViewController : UIViewController
{
    NSMutableArray *tracksInPlayist;
    NSMutableArray *albumTracks;
}
@property (nonatomic, assign) BOOL sortTracksByArtist;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) SPTArtist *artist;
@property (nonatomic, strong) SPTAlbum *album;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic,strong) SPTPlaylistList *playlist;
@end
