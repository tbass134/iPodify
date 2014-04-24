//
//  ArtistViewController.h
//  Simple Player
//
//  Created by Antonio Hung on 1/7/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
@interface ArtistViewController : UIViewController
@property(nonatomic,strong)SPArtist *artist;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSArray *albums;
@end
