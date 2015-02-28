//
//  TracksCollectionViewController.h
//  iPodify
//
//  Created by Tony Hung on 12/30/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APLExpandableCollectionView.h"

@interface TracksCollectionViewController : UICollectionViewController <APLExpandableCollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong)SPTPartialPlaylist *playlist;
@property (nonatomic,strong)NSArray *savedTracks;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end
