//
//  PlayListTracksTableViewController.h
//  Simple Player
//
//  Created by Antonio Hung on 2/17/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface PlayListTracksTableViewController : UITableViewController

@property(nonatomic,strong)SPPlaylist *playlist;
@end
