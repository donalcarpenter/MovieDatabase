//
//  MDBMoviesInGenreCollectionViewController.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDBMoviesInGenreCollectionViewController : UICollectionViewController <UICollectionViewDataSource,
UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) NSArray *movies;
@end
