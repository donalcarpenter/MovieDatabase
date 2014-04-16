//
//  MDBMovie.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBModel.h"
#import "MDBCast.h"

extern NSString * const MDBMovieDidFinishLoadingNotification;

@interface MDBMovie : MDBModel

@property (atomic, readonly) BOOL loading;
@property (nonatomic, strong) NSArray* genres;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* tagLine;
@property (nonatomic, copy) NSString* overview;
@property (nonatomic, copy) NSURL* posterPath;
@property (nonatomic, readwrite) NSUInteger releaseYear;
@property (nonatomic, readwrite) CGFloat averageRating;
@property (nonatomic, strong) MDBCast* cast;
@property (nonatomic, strong) NSDictionary* images;
@property (nonatomic, copy) NSString *trailerId;

- (instancetype) initWithId: (NSUInteger) movieId;

@end
