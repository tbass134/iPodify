//
//  ArtistViewController.h
//  Simple Player
//
//  Created by Antonio Hung on 1/7/14.
//  Copyright (c) 2014 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "DNSSwipeableCell.h"
@interface ArtistViewController : UIViewController<DNSSwipeableCellDelegate, DNSSwipeableCellDataSource>

@property(nonatomic,strong)SPArtist *artist;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSArray *albums;
@property (nonatomic, strong) NSMutableArray *cellsCurrentlyEditing;
@property (nonatomic, strong) NSMutableArray *itemTitles;

@end
