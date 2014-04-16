//
//  MDBCast.m
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBCast.h"
#import "MDBActor.h"

@implementation MDBCast

- (instancetype)initWithArray:(NSArray*) data{
    self = [super init];
    if(self){
        
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[data count]];
        
        [data enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL *stop) {
            
            MDBActor *actor = [[MDBActor alloc] initWithDictionary:obj];
            [tmp addObject:actor];
            
        }];
        
        self->_actors = tmp;
        
    }
    
    return self;
}

@end
