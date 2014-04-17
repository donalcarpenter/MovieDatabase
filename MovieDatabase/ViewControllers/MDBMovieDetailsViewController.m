//
//  MDBMovieDetailsViewController.m
//  MovieDatabase
//
//  Created by EzetopMacbook on 17/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBMovieDetailsViewController.h"
#import "MDBImageUrlBuilder.h"
#import <QuartzCore/QuartzCore.h>

@interface MDBMovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (weak, nonatomic) IBOutlet UITextView *overviewText;

@property (nonatomic, strong) UIImageView *standardImage;
@property (nonatomic, strong) UIImageView *blurImage;

@end

@implementation MDBMovieDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = self.movie.title;
    
    self.tagLineLabel.text = self.movie.tagLine;
    
    self.overviewText.text = self.movie.overview;
    
    self.tableView.scrollEnabled = NO;
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    
    [[MDBImageUrlBuilder sharedBuilder] loadImagePath:self.movie.posterPath ofSize:MDBImageSizeLarge andType:MDBImageTypePoster thenHandleBy:^(UIImage *image) {
       
        self->_standardImage =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 500)];

        self->_blurImage =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 500)];
        
        //create our blurred image
        CIContext *context = [CIContext contextWithOptions:nil];
        __block CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            
            CIFilter *filter1 = [CIFilter filterWithName:@"CIVignetteEffect"
                                          keysAndValues:kCIInputImageKey, inputImage, nil];
            
            [filter1 setDefaults];
            
            
            CIVector *vigVec = [CIVector vectorWithCGPoint:CGPointMake(self.standardImage.frame.size.width / 2,  self.standardImage.frame.size.height)];
            
            [filter1 setValue:vigVec forKey:@"inputCenter"];
            [filter1 setValue:@(1) forKey:@"inputIntensity"];
            
            [filter1 setValue:@(self.standardImage.frame.size.height * 0.8) forKey:@"inputRadius"];
            
            
            inputImage = [filter1 outputImage];

            
            //setting up Gaussian Blur (we could use one of many filters offered by Core Image)
            CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [filter setValue:inputImage forKey:kCIInputImageKey];
            [filter setValue:[NSNumber numberWithFloat:25.0f] forKey:@"inputRadius"];
            CIImage *result = [filter valueForKey:kCIOutputImageKey];
            
            //CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches up exactly to the bounds of our original image
            CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
            
            dispatch_async(dispatch_get_main_queue() , ^{
                
                self->_blurImage.image = [UIImage imageWithCGImage:cgImage];
                self->_standardImage.image = [UIImage imageWithCIImage:inputImage];
                self->_blurImage.contentMode = UIViewContentModeScaleAspectFit;
                self->_blurImage.clipsToBounds = YES;
                
                self.tableView.scrollEnabled = YES;
            });
            
        });
        
        [background addSubview:self->_blurImage];
        [background addSubview:self->_standardImage];
        
        self->_standardImage.opaque = NO;
        self->_standardImage.backgroundColor = [UIColor clearColor];
        //self->_standardImage.image = image;
        
        self->_standardImage.contentMode = UIViewContentModeScaleAspectFit;
        self->_standardImage.clipsToBounds = YES;
        
        [self.tableView addSubview:background];
        [self.tableView setBackgroundView:background];
        
    }];
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    if(scrollView.contentOffset.y >= 100){
        self->_standardImage.alpha = 0;
        return;
    }
    
    float alphaChannel = 1 - (scrollView.contentOffset.y / 100.0f);
    
    self->_standardImage.alpha = alphaChannel;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
