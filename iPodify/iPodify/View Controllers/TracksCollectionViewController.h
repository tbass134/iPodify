//
//  TracksCollectionViewController.h
//  iPodify
//
//  Created by Tony Hung on 12/30/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APLExpandableSectionFlowLayout.h"

@protocol APLExpandableCollectionViewDelegate <UICollectionViewDelegateFlowLayout>

@optional

/** Tells the delegate that the item at the specified index path was expanded. */
- (void)collectionView:(UICollectionView *)collectionView didExpandItemAtIndexPath:(NSIndexPath *)indexPath;

/** Tells the delegate that the item at the specified index path was collapsed. */
- (void)collectionView:(UICollectionView *)collectionView didCollapseItemAtIndexPath:(NSIndexPath *)indexPath;

@end



@interface TracksCollectionViewController : UICollectionViewController
@property (nonatomic,strong)SPTPartialPlaylist *playlist;

/** The collection view’s delegate object. */
@property (nonatomic, assign) id <APLExpandableCollectionViewDelegate> delegate;

/** Returns YES if the specified section is expanded. */
- (BOOL)isExpandedSection:(NSInteger)section;


@end
