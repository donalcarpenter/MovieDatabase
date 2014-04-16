//
//  MovieDatabaseTests.m
//  MovieDatabaseTests
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDBPopularMovies.h"
#import "MDBMovie.h"
#import "MDBActor.h"
#import "MDBImageUrlBuilder.h"

@interface MovieDatabaseTests : XCTestCase

@end

@implementation MovieDatabaseTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testLoadPopularMovies{
    
    NSCondition *loading = [NSCondition new];
    [loading lock];
    MDBPopularMovies *pop = [MDBPopularMovies new];
    
    [pop load:^(NSArray *movies, NSDictionary *moviesByGenre) {
        XCTAssert([movies count]>0, @"no movies returned");
        [loading unlock];
    } handleError:^(NSString *errorDesc, NSUInteger errorCode) {
        XCTFail(@"Error: %@, %d", errorDesc, errorCode);
        [loading unlock];
    }];
    
    while(pop.loading)
        [loading wait];
    
    NSLog(@"dont hit me");
    
}

- (void) testFightClub{
    
    MDBMovie *m = [[MDBMovie alloc] initWithId:550];
    
    while (m.loading)
        sleep(2);
    
    XCTAssert([m.title isEqualToString:@"Fight Club"], @"title was '%@', not 'Fight Club'", m.title);
    XCTAssert([m.tagLine isEqualToString:@"How much can you know about yourself if you've never been in a fight?"], @"tagline was '%@'", m.tagLine);
    
    XCTAssert([m.genres count] == 3, @"incorrect number of genres found");
    
    XCTAssert([m.cast.actors count] == 27, @"incorrect number of actors found");
    
    MDBActor *a = m.cast.actors[0];
    XCTAssert([a.actorName isEqualToString: @"Edward Norton"], @"actor 0 has incorrect name of '%@'", a.actorName);
    
    
}

- (void) testImageUrlManagement{
    
    NSCondition *c = [NSCondition new];
    
    [c lock];
    MDBImageUrlBuilder *b = [MDBImageUrlBuilder sharedBuilder];
    
    [b tryParseImageName:@"123.jpg" ToUrl:^(NSURL *url) {
        [c unlock];
        
        XCTAssert([url.absoluteString isEqualToString:@"https://image.tmdb.org/t/p/w300/123.jpg"], "bad url '%@' returned", url.absoluteString);
        
    } ofSizeIndex:MDBImageSizeTiny andType:MDBImageTypeBackdrop];
 
    while (b.loading) {
        [c wait];
    }
}

@end
