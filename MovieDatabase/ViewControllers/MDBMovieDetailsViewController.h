//
//  MDBMovieDetailsViewController.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 17/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDBMovie.h"

@interface MDBMovieDetailsViewController : UITableViewController
@property (nonatomic, strong) MDBMovie *movie;
@end
