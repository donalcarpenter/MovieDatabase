//
//  MDBActor.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBModel.h"

@interface MDBActor : MDBModel
@property (nonatomic, copy) NSString* character;
@property (nonatomic, copy) NSString* actorName;
@property (nonatomic, copy) NSString* pictureUrl;
@property (nonatomic, readonly) NSUInteger actorId;

- (instancetype) initWithDictionary: (NSDictionary *) data;
@end
