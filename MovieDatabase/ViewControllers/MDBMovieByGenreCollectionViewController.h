//
//  MDBMovieByGenreCollectionViewController.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MDBMovieByGenreCollectionViewController : UICollectionViewController <UICollectionViewDataSource,
UICollectionViewDelegate,
UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning>

@property (nonatomic, readonly) NSIndexPath* selectedPath;
@property (nonatomic, strong) NSDictionary *moviesByGenre;

@property (nonatomic, strong) NSArray *genreByIndex;

@end
