//
//  MDBMoviesInGenreCollectionViewController.m
//  MovieDatabase
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//


#import "MDBMoviesInGenreCollectionViewController.h"
#import "MDBCollectionViewCell.h"
#import "MDBMovie.h"
#import "MDBMovieByGenreCollectionViewController.h"
#import "MDBImageUrlBuilder.h"
#import "MDBMovieDetailsViewController.h"

@interface MDBMoviesInGenreCollectionViewController ()
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;
@property (nonatomic, strong) MDBMovie *selected;
@end

static NSString * const CellIdentifier = @"Cell";

@implementation MDBMoviesInGenreCollectionViewController

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
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
    [self.collectionView registerClass:[MDBCollectionViewCell class]
            forCellWithReuseIdentifier:CellIdentifier];
    
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    self.navigationController.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated{
    if(self.navigationController.delegate == self){
        self.navigationController.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.movies count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MDBCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MDBMovie *movie = self.movies[indexPath.row];
    
    // load photo images in the background
    __weak MDBMoviesInGenreCollectionViewController *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        [[MDBImageUrlBuilder sharedBuilder] loadImagePath:movie.posterPath ofSize:MDBImageSizeSmall andType:MDBImageTypePoster thenHandleBy:^(UIImage *image) {
            if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                MDBCollectionViewCell *c =
                (MDBCollectionViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                c.imageView.image = image;
            }
        }];

    }];
    
    //  increase priority for first image in stack
    operation.queuePriority = (indexPath.row == 0) ? NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
    
    [self.thumbnailQueue addOperation:operation];
    cell.hidden = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MDBMovieDetailsViewController *detailsVC = (MDBMovieDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"movieDetails"];
    detailsVC.movie = self.movies[indexPath.row];
    
    [self.navigationController pushViewController:detailsVC animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"movie"]){
        
        MDBMovieDetailsViewController *vc = (MDBMovieDetailsViewController*)segue.destinationViewController;
        vc.title = self.selected.title;
        vc.movie = self.selected;
        
    }
    
}


#pragma mark - Navigation

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if([toVC isKindOfClass:[MDBMovieByGenreCollectionViewController class]])
    {
        return self;
    }
    
    return nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    MDBMoviesInGenreCollectionViewController *a = (MDBMoviesInGenreCollectionViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    MDBMovieByGenreCollectionViewController *b = (MDBMovieByGenreCollectionViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *container = [transitionContext containerView];
    
    NSMutableArray *snapshots = [NSMutableArray array];
    NSMutableArray *transformations = [NSMutableArray array];
    
    [container addSubview:a.view];
    [container addSubview:b.view];
    
    
    
    
    NSArray *genreMovies =  b.moviesByGenre[b.genreByIndex[b.selectedPath.section]];
    
    
    for (NSInteger i = [genreMovies count] - 1; i >= 0; i--) {
        
        MDBCollectionViewCell *sourceCell = (MDBCollectionViewCell*)[a.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForRow:i inSection:0]];
        
        MDBCollectionViewCell *b_cell = (MDBCollectionViewCell*)[b.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForRow:i inSection:b.selectedPath.section]];
        
        sourceCell.hidden = YES;
        
        UIView* snapshot = [sourceCell snapshotViewAfterScreenUpdates:NO];
        
        if(!snapshot)
            continue;
        
        snapshot.frame = [container convertRect:sourceCell.frame fromView:sourceCell.superview];
        
        
        // CGRect destFrame = CGRectMake(finalLayoutAttrs.frame.origin.x - offset.x, finalLayoutAttrs.frame.origin.y - offset.y, finalLayoutAttrs.frame.size.width, finalLayoutAttrs.frame.size.height);
        
        CGRect destFrame = [container convertRect:b_cell.frame fromView:b_cell.superview];
        
        [container addSubview:snapshot];
        
        [snapshots addObject:snapshot];
        [transformations addObject:[NSValue valueWithCGRect:destFrame]];
    }
    
    
    
    
    //CGRect secondFrame = [transitionContext finalFrameForViewController:a];
    
    
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //a.view.frame = CGRectMake(a.view.frame.origin.x + a.view.frame.size.width, a.view.frame.origin.y, a.view.frame.size.width, a.view.frame.size.height);;
        b.view.alpha = 1.0;
        
        for (NSInteger i = [snapshots count] - 1; i >= 0 ; i--) {
            NSValue *frame = transformations[i];
            ((UIView*)snapshots[i]).frame = [frame CGRectValue];
        }
    } completion:^(BOOL finished) {
        //b.collectionView.hidden = NO;
        
        for (NSInteger i = 0; i < [genreMovies count]; i++) {
            
            // there may have been items that were off screen, so there
            // won't be a snapshot
            if(i < [snapshots count]){
                [((UIView*)snapshots[i]) removeFromSuperview];
            }
            
            MDBCollectionViewCell *b_cell = (MDBCollectionViewCell*)[b.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForRow:i inSection:b.selectedPath.section]];
            b_cell.hidden = NO;
            
        }
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}


@end