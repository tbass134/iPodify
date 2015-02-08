//
//  PlaylistsCollectionViewController.h
//  iPodify
//
//  Created by Antonio Hung on 12/30/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistsCollectionViewController : UICollectionViewController
@property(nonatomic,strong)NSMutableArray *playlists;
@property (nonatomic, strong) void (^playlistSelected)(SPTPartialPlaylist *playlist); //used to add a track to a playlist

@end
