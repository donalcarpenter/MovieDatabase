//
//  FMViewController.m
//  sandbox
//
//  Created by EzetopMacbook on 16/04/2014.
//  Copyright (c) 2014 donal. All rights reserved.
//

#import "MDBMovieByGenreCollectionViewController.h"
#import "MDBStackLayout.h"
#import "MDBCollectionViewCell.h"
#import "MDBCollectionViewSupplementaryCellView.h"
#import "MDBMoviesInGenreCollectionViewController.h"
#import "MDBPopularMovies.h"
#import "MDBMovie.h"
#import "MDBImageUrlBuilder.h"

static NSString * const CellIdentifier = @"Cell";
static NSString * const TitleIdentifier = @"Title";

@interface MDBMovieByGenreCollectionViewController ()

@property (nonatomic, weak) IBOutlet MDBStackLayout* stackLayout;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;

@end

@implementation MDBMovieByGenreCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    
    // register classes for displaying cells
    
    [self.collectionView registerClass:[MDBCollectionViewCell class]
            forCellWithReuseIdentifier:CellIdentifier];
    
    [self.collectionView registerClass:[MDBCollectionViewSupplementaryCellView class] forSupplementaryViewOfKind:StackLayoutSectionKind withReuseIdentifier:TitleIdentifier];
    
    // go get the data
    
    // TODO: show spinner
    
    MDBPopularMovies *popularMovies = [MDBPopularMovies new];
    [popularMovies load:^(NSArray *movies, NSDictionary *moviesByGenre) {
        self.moviesByGenre = moviesByGenre;
        self.genreByIndex = [moviesByGenre allKeys];
        [self.collectionView reloadData];
    } handleError:^(NSString *errorDesc, NSUInteger errorCode) {
        
        // TODO: show error notifications
        
    }];
    
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return [[self.moviesByGenre allKeys] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.moviesByGenre[self.genreByIndex[section]] count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MDBCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MDBMovie *film = self.moviesByGenre[self.genreByIndex[indexPath.section]][indexPath.row];
    
    // load photo images in the background
    __weak MDBMovieByGenreCollectionViewController *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        [[MDBImageUrlBuilder sharedBuilder] loadImagePath:film.posterPath ofSize:MDBImageSizeTiny andType:MDBImageTypePoster thenHandleBy:^(UIImage *image) {
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
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    MDBCollectionViewSupplementaryCellView *suppView = [collectionView dequeueReusableSupplementaryViewOfKind:StackLayoutSectionKind withReuseIdentifier:TitleIdentifier forIndexPath:indexPath];
    
    suppView.titleLabel.text = self.genreByIndex[indexPath.section];
    
    return suppView;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc] init];
    grid.itemSize = CGSizeMake(75.0, 75.0);
    grid.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    
    MDBMoviesInGenreCollectionViewController *next = [[MDBMoviesInGenreCollectionViewController alloc] initWithCollectionViewLayout:grid];
    NSArray *genreMovies = self.moviesByGenre[self.genreByIndex[indexPath.section]];
    
    next.movies = genreMovies;
    
    self->_selectedPath = indexPath;
    
    //next.useLayoutToLayoutNavigationTransitions = YES;
    
    [self.navigationController pushViewController:next animated:YES];
    
}

#pragma mark - View Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.stackLayout.numberOfColumns = 3;
        
        // handle insets for iPhone 4 or 5
        CGFloat sideInset = [UIScreen mainScreen].preferredMode.size.width == 1136.0f ?
        45.0f : 25.0f;
        
        self.stackLayout.itemInsets = UIEdgeInsetsMake(22.0f, sideInset, 13.0f, sideInset);
        
    } else {
        self.stackLayout.numberOfColumns = 2;
        self.stackLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    }
}

#pragma mark Transition Animation

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{

    MDBMovieByGenreCollectionViewController *a = (MDBMovieByGenreCollectionViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    MDBMoviesInGenreCollectionViewController *b = (MDBMoviesInGenreCollectionViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // this is the container for all stuff that gets animated
    UIView *container = [transitionContext containerView];
    CGPoint offset = b.collectionView.contentOffset;
    
    NSMutableArray *snapshots = [NSMutableArray array];
    NSMutableArray *transformations = [NSMutableArray array];
    
    [container addSubview:b.view];
    
    for (NSInteger i = 0; i < [b.movies count]; i++) {
        UICollectionViewLayoutAttributes *finalLayoutAttrs = [b.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        MDBCollectionViewCell *sourceCell = (MDBCollectionViewCell*)[a.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForRow:i inSection:self.selectedPath.section]];
        
        sourceCell.hidden = YES;
        
        UIView* snapshot = [sourceCell snapshotViewAfterScreenUpdates:NO];
        snapshot.frame = [container convertRect:sourceCell.frame fromView:sourceCell.superview];
        
        CGRect destFrame = CGRectMake(finalLayoutAttrs.frame.origin.x - offset.x, finalLayoutAttrs.frame.origin.y - offset.y, finalLayoutAttrs.frame.size.width, finalLayoutAttrs.frame.size.height);
        
        [container addSubview:snapshot];
        
        [snapshots addObject:snapshot];
        [transformations addObject:[NSValue valueWithCGRect:destFrame]];
    }
    
    
    
    
    CGRect secondFrame = [transitionContext finalFrameForViewController:b];
    
    // move the frame for b to the right
    b.view.frame = CGRectMake(secondFrame.origin.x + secondFrame.size.width, secondFrame.origin.y, secondFrame.size.width, secondFrame.size.height);
    
    
    
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        b.view.frame = secondFrame;
        b.view.alpha = 1.0;
        
        for (NSInteger i = [b.movies count] - 1; i >= 0 ; i--) {
            NSValue *frame = transformations[i];
            ((UIView*)snapshots[i]).frame = [frame CGRectValue];
        }
    } completion:^(BOOL finished) {
        //b.collectionView.hidden = NO;
        
        for (NSInteger i = 0; i < [b.movies count]; i++) {
            [((UIView*)snapshots[i]) removeFromSuperview];
            
            MDBCollectionViewCell *b_cell = (MDBCollectionViewCell*)[b.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForRow:i inSection:0]];
            b_cell.hidden = NO;
            
        }
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.4;
}

@end
