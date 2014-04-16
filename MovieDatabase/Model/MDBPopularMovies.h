//
//  MDBPopularMovies.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBModel.h"

typedef void (^loadPopularMoviesSuccess)(NSArray *movies, NSDictionary *moviesByGenre);

extern NSString * const MDBMovieCollectionDidFinishLoadingNotification;

@interface MDBPopularMovies : MDBModel
@property (atomic, readonly) BOOL loading;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSDictionary *moviesByGenre;

- (void) load: (loadPopularMoviesSuccess) success handleError: (loadError) error;
@end
