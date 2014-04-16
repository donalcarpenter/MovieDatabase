//
//  MDBPopularMovies.m
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBPopularMovies.h"
#import "MDBMovie.h"

NSString * const MDBMovieCollectionDidFinishLoadingNotification = @"MDBMovieCollectionDidFinishLoadingNotification";

@interface MDBPopularMovies()

@property (nonatomic, strong) NSOperationQueue *movieLoadingQueue;

@end

@implementation MDBPopularMovies
- (void)load:(loadPopularMoviesSuccess)success handleError:(loadError)error{
 
    if(!self.movieLoadingQueue){
        self.movieLoadingQueue = [NSOperationQueue new];
        [self.movieLoadingQueue setMaxConcurrentOperationCount:5];
    }
    
    NSString* uritemplates = @"%@movie/popular?api_key=%@";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:uritemplates, BASE_URL, API_KEY]];
    
    self->_loading = YES;
    
    [MDBModel executeUrlRequest:[NSURLRequest requestWithURL:url] handleSuccessWith:^(NSDictionary *jsonData, NSUInteger statusCode) {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSArray *results = jsonData[@"results"];
            
            // load the json into movies
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[results count]];
            
            [results enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                NSUInteger movieId = [obj[@"id"] integerValue];
                
                NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                    MDBMovie *m = [[MDBMovie alloc] initWithId:movieId];
                    [array addObject:m];
                }];
                
                [self.movieLoadingQueue addOperation:op];
                
            }];
            
            // wait for all the items to download on this thread
            [self.movieLoadingQueue waitUntilAllOperationsAreFinished];
            
            self.movies = array;
            
            // now populate the dictionary
            
            self.moviesByGenre = [self mapByGenre:self.movies];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(self.movies, self.moviesByGenre);
            });
            
            self->_loading = NO;
        });
        
        
    } andErrorWith:^(NSString *errorDesc, NSUInteger errorCode) {
        
        error(errorDesc, errorCode);
        
    }];
    
}

- (NSDictionary *) mapByGenre: (NSArray*) movies{
    
    __block NSMutableDictionary *genres = [NSMutableDictionary dictionary];
    
    [movies enumerateObjectsUsingBlock:^(MDBMovie *movie, NSUInteger idx, BOOL *stop) {
        
        // quick hack - ensure all the data is loaded
        while(movie.loading)
            sleep(1);
        

        [movie.genres enumerateObjectsUsingBlock:^(NSString *genre, NSUInteger idx, BOOL *stop) {
            if(!genres[genre]){
                [genres setObject:[NSMutableArray arrayWithObject:movie] forKey:genre];
            }
            else{
                NSMutableArray *moviesForGenre = genres[genre];
                [moviesForGenre addObject:movie];
            }
        }];
        
    }];
    
    return genres;
}
@end
