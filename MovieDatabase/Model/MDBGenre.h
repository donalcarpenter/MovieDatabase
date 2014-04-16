//
//  MDBGenre.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBModel.h"

@interface MDBGenre : MDBModel

typedef void (^genreLoadSuccess)(NSArray *genres);

@property (nonatomic, readonly) NSUInteger id;
@property (nonatomic, readonly, copy) NSString* name;

+ (void) load: (genreLoadSuccess) succes withError: (loadError) error;
@end
