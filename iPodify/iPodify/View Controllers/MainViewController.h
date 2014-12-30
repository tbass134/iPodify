//
//  MainViewController.h
//  Simple Player
//
//  Created by Antonio Hung on 11/12/13.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *playlists;
@property (nonatomic, strong) NSMutableArray *songs;
@property (nonatomic, strong) NSMutableArray *artists;

@property (nonatomic, strong) IBOutlet UITableView *table_view;

- (void)sessionDataLoaded;

@end
