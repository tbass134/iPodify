//
//  TrackCell.m
//  iPodify
//
//  Created by Antonio Hung on 4/25/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#import "TrackCell.h"
//Public constants
CGFloat const kExampleCellHeight = 80.0f;

//Private constants
static CGFloat const kExampleCellLeftMargin = 15.0f;
static CGFloat const kExampleCellRightMargin = 20.0f;
static CGFloat const kBetweenViewsMargin = 8.0f;

@implementation TrackCell

- (void)commonInit
{
    [super commonInit];
    
    //Setup the pieces of this cell which will be reused
    CGFloat imageHeight = kExampleCellHeight - (kBetweenViewsMargin * 2);
    self.exampleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kExampleCellLeftMargin, kBetweenViewsMargin, imageHeight, imageHeight)];
    [self.myContentView addSubview:self.exampleImageView];
    
    CGFloat labelXOrigin = CGRectGetMaxX(self.exampleImageView.frame) + kBetweenViewsMargin;
    CGFloat labelWidth = CGRectGetWidth(self.frame) - labelXOrigin - kExampleCellRightMargin;
    self.exampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelXOrigin, 0, labelWidth, 50)];
    self.exampleLabel.numberOfLines = 0;
    [self.myContentView addSubview:self.exampleLabel];
}
@end
