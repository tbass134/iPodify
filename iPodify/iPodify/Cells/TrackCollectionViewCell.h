//
//  TrackCollectionViewCell.h
//  iPodify
//
//  Created by Tony Hung on 12/30/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *trackName;
@property (weak, nonatomic) IBOutlet UILabel *trackArtist;

@end
