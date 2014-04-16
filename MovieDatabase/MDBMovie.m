//
//  MDBMovie.m
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBMovie.h"

NSString * const MDBMovieDidFinishLoadingNotification = @"MDBMovieDidFinishLoadingNotification";

@implementation MDBMovie


// https://api.themoviedb.org/3/movie/550?api_key=8740b876624a251072f14e1c009a369f&append_to_response=trailers,credits,images

- (instancetype)initWithId:(NSUInteger)movieId{
    
    self = [super init];
    if(self){
        
        self->_loading = YES;
        
        NSString* uritmpl = @"%@movie/%d?api_key=%@&append_to_response=trailers,credits,images";
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:uritmpl, BASE_URL, movieId, API_KEY]];
        
        [MDBModel executeUrlRequest:[NSURLRequest requestWithURL:url] handleSuccessWith:^(NSDictionary *jsonData, NSUInteger statusCode) {
            
            self->_title = jsonData[@"title"];
            self->_tagLine = jsonData[@"tagline"];
            self->_overview = jsonData[@"overview"];
            self->_releaseYear = [[jsonData[@"release_date"] substringToIndex:4] integerValue];
            self->_averageRating = [jsonData[@"vote_average"] floatValue];
            self->_trailerId = [jsonData valueForKeyPath:@"trailers.youtube.source"];
            
            NSArray *genres = jsonData[@"genres"];
            
            NSMutableArray *tmp_g = [NSMutableArray arrayWithCapacity: [genres count]];
            
            [genres enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                [tmp_g addObject:obj[@"name"]];
            }];
            
            self->_genres = tmp_g;
            
            self->_cast = [[MDBCast alloc] initWithArray:[jsonData valueForKeyPath:@"credits.cast"]];
            
            self->_loading = NO;
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            
            [center postNotificationName:MDBMovieDidFinishLoadingNotification object:self userInfo:nil];
            
        } andErrorWith:^(NSString *errorDesc, NSUInteger errorCode) {
            
            // crap... could not load

            self->_loading = NO;
        }];
        
    }
    
    return self;
}

@end
