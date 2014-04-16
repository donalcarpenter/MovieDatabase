//
//  MDBModel.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_KEY @"8740b876624a251072f14e1c009a369f"
#define BASE_URL @"http://api.themoviedb.org/3/"

typedef void (^loadError)(NSString* errorDesc, NSUInteger errorCode);

typedef void (^loadSuccess)(NSDictionary* jsonData, NSUInteger statusCode);

@interface MDBModel : NSObject

+ (void) executeUrlRequest: (NSURLRequest*) request handleSuccessWith: (loadSuccess) success andErrorWith: (loadError) errorHandler;



- (NSURL*) fullImageUrlForPath: (NSString *) path;
@end
