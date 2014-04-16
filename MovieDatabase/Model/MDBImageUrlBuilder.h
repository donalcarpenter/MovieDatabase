//
//  MDBImageUrlBuilder.h
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBModel.h"

// create enums for each image type

typedef void (^completedUrlHandler)(NSURL* url);

typedef enum {
    MDBImageSizeTiny,
    MDBImageSizeSmall,
    MDBImageSizeMedium,
    MDBImageSizeLarge,
    MDBImageSizeOriginal,
} MDBImageSize;

typedef enum {
    MDBImageTypeBackdrop,
    MDBImageTypeLogo,
    MDBImageTypePoster,
    MDBImageTypeProfile,
    MDBImageTypeStill,
} MDBImageType;

@interface MDBImageUrlBuilder : MDBModel


@property (nonatomic, copy) NSString* baseImageUrl;
@property (atomic, readonly) BOOL loading;

+ (instancetype) sharedBuilder;

- (void) tryParseImageName: (NSString*) image
                     ToUrl: (completedUrlHandler) completedHandler
               ofSizeIndex: (MDBImageSize) size
                   andType:(MDBImageType) type;

@end
