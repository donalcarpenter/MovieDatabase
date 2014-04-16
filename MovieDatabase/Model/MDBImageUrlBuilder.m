//
//  MDBImageUrlBuilder.m
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBImageUrlBuilder.h"

@interface MDBImageUrlBuilder()

@property (nonatomic, strong) NSArray* backdropImageSizes;
@property (nonatomic, strong) NSArray* logoImageSizes;
@property (nonatomic, strong) NSArray* posterImageSizes;
@property (nonatomic, strong) NSArray* profileImageSizes;
@property (nonatomic, strong) NSArray* stillImageSizes;

@end

@implementation MDBImageUrlBuilder{
    NSCondition *lockUntilSharedInstanceIsLoaded;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->lockUntilSharedInstanceIsLoaded = [NSCondition new];
    }
    return self;
}

+ (instancetype)sharedBuilder{
    static dispatch_once_t onceToken;
    static MDBImageUrlBuilder *sharedBuilderInner;
    dispatch_once(&onceToken, ^{
        sharedBuilderInner = [self new];
        
        // now load the configuration
        sharedBuilderInner->_loading = YES;
        [sharedBuilderInner->lockUntilSharedInstanceIsLoaded lock];
        
        NSString* uritmpl = @"%@configuration?api_key=%@";
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:uritmpl, BASE_URL, API_KEY]];
        
        [MDBModel executeUrlRequest:[NSURLRequest requestWithURL:url] handleSuccessWith:^(NSDictionary *jsonData, NSUInteger statusCode) {
            
            NSDictionary *imageConfig = jsonData[@"images"];
            
            sharedBuilderInner->_baseImageUrl = imageConfig[@"secure_base_url"];
            
            sharedBuilderInner->_backdropImageSizes = imageConfig[@"backdrop_sizes"];
            sharedBuilderInner->_logoImageSizes = imageConfig[@"logo_sizes"];
            sharedBuilderInner->_posterImageSizes = imageConfig[@"poster_sizes"];
            sharedBuilderInner->_profileImageSizes = imageConfig[@"profile_sizes"];
            sharedBuilderInner->_stillImageSizes = imageConfig[@"still_sizes"];
            
            sharedBuilderInner->_loading = NO;
            [sharedBuilderInner->lockUntilSharedInstanceIsLoaded unlock];
            [sharedBuilderInner->lockUntilSharedInstanceIsLoaded broadcast];
            
        } andErrorWith:^(NSString *errorDesc, NSUInteger errorCode) {
            // noop
            
            sharedBuilderInner->_loading = NO;
            [sharedBuilderInner->lockUntilSharedInstanceIsLoaded unlock];
            [sharedBuilderInner->lockUntilSharedInstanceIsLoaded broadcast];
        }];
        
    });
    
    
    return sharedBuilderInner;
}

- (void)tryParseImageName:(NSString *)image
                    ToUrl:(completedUrlHandler)completedHandler
              ofSizeIndex:(MDBImageSize)size
                  andType:(MDBImageType) type{
    
    
    while (self.loading) {
        [self->lockUntilSharedInstanceIsLoaded wait];
    }
    
    NSArray* sizes;
    
    switch (type) {
        case MDBImageTypeBackdrop:
            sizes = self.backdropImageSizes;
            break;
        case MDBImageTypeLogo:
            sizes = self.logoImageSizes;
            break;
        case MDBImageTypePoster:
            sizes = self.posterImageSizes;
            break;
        case MDBImageTypeProfile:
            sizes = self.profileImageSizes;
            break;
        case MDBImageTypeStill:
            sizes = self.stillImageSizes;
            break;
    }
    
    
    NSString *dbmImageSize;
    if(size == MDBImageSizeOriginal)
    {
        dbmImageSize = [sizes lastObject];
    }
    else
    {
        // quick transform to make sure we are covering all the possible
        // sizes
        NSInteger s = ((((float) [sizes count]) / 4.0) * size);
        
        dbmImageSize = sizes[s];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@/%@", self.baseImageUrl, dbmImageSize, image];
    
    completedHandler([NSURL URLWithString:url]);
}

@end