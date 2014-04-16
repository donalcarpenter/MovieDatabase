//
//  MDBActor.m
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBActor.h"

@implementation MDBActor

- (instancetype)initWithDictionary:(NSDictionary *)data{
    self = [super init];
    if(self){
        self->_character = data[@"character"];
        self->_actorName = data[@"name"];
        self->_actorId = [data[@"id"] integerValue];
        self->_pictureUrl = [self fullImageUrlForPath:data[@"profile_path"]];
    }
    
    return self;
}

@end
