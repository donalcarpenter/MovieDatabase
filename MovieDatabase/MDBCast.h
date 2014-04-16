//
//  MDBCast.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBModel.h"

@interface MDBCast : MDBModel
@property (nonatomic, strong) NSArray* actors;
- (instancetype) initWithArray: (NSArray*) data;
@end
