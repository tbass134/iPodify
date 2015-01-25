//
//  TrackCollectionReusableView.h
//  iPodify
//
//  Created by Tony Hung on 1/16/15.
//  Copyright (c) 2015 Tony Hung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;

@end
