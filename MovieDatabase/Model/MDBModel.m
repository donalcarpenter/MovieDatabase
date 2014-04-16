//
//  MDBModel.m
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBModel.h"


@interface MDBModel()

@end



@implementation MDBModel

- (NSURL *)fullImageUrlForPath:(NSString *)path{
    
    
    
    if((id)path == [NSNull null] || ![path length]){
        return nil;
    }
    
    NSMutableString* uri = [[BASE_URL stringByAppendingPathComponent:path] mutableCopy];
    
    [uri appendFormat:@"?api_key=%@", API_KEY];
    
    return [NSURL URLWithString:uri];
}

+ (void)executeUrlRequest:(NSURLRequest *)request handleSuccessWith:(loadSuccess)success andErrorWith:(loadError)errorHandler{
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                    
                if(error){
                    // execute error handler
                    
                    errorHandler(error.domain, httpResponse.statusCode);
                    return;
                }
                
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    
                    success(json, httpResponse.statusCode);
                
            }] resume];
    
    
}
@end
