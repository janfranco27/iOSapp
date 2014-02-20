//
//  SSVViewController.m
//  SecondScrollView
//
//  Created by yrnunez on 4/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import "SSVViewController.h"
#import "Constants.h"
#import "PageController.h"
#import "PageInformation.h"
#import "ChapterController.h"
#import "UISecondScrollView.h"
#import "QuartzCore/QuartzCore.h"
#import "ChapterViewController.h"

@implementation SSVViewController


- (void)loadPropertiesFile
{
    NSArray *allContent = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"]];
    
    self.chaptersController = [[NSMutableArray alloc] init];
    
    int chapterIndex = 0;
    int numberOfPage = 0;
    for (NSDictionary *chapterContent in allContent)
    {
        
        NSString *chapterImageName = [chapterContent objectForKey:@"ChapterImage"];
        
        //pagesName is array of strings
        NSMutableArray* pagesName =  [NSMutableArray arrayWithArray:[chapterContent objectForKey:@"Pages"] ];
        
        [pagesName insertObject:chapterImageName atIndex:0];
        
        UIImage *chapterImage = [UIImage imageNamed:chapterImageName];
        
        
        NSMutableArray *pagesController = [[NSMutableArray alloc] init];
        
        
        for (int page = 0; page < [pagesName count]; page++)
        {
            //creating object with pageInfo
            PageInformation *pi = [[PageInformation alloc] init];
            pi.indexInChapter = page;
            pi.indexInBook = numberOfPage;
            
            //setting extra information in pageController
            PageController *tmpPage = [[PageController alloc] initWithInformation:pi];
            tmpPage.smallImageName = [pagesName objectAtIndex:page];
            tmpPage.largeImageName = [pagesName objectAtIndex:page];
                        
            /***************/
            tmpPage.gesturesDelegate = self;
            numberOfPage++;
            /***************/
            
            //updating array of PagesController for this chapter
            [pagesController addObject:tmpPage];
        }
        
        ChapterController *tmpChapter = [[ChapterController alloc] initWithPages:pagesController withImage:chapterImage withChapterIndex:chapterIndex];
        
        chapterIndex++;
        
        [self.chaptersController addObject:tmpChapter];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self loadPropertiesFile];
    chapterChanged = NO;
    setOffsetForChange = NO;
    secondScrollIsScrolling = NO;
    canBeginGestures = YES;
    
    //initial frames
    self.chapterScroll.frame = CGRectMake(MAIN_ORIGIN_X, MAIN_ORIGIN_Y, MAIN_WIDTH, MAIN_HEIGHT);
    
    self.secondScroll.frame = CGRectMake(SECOND_ORIGIN_X, SECOND_ORIGIN_Y, SECOND_WIDTH, SECOND_HEIGHT);
    
    //initializing instance variables
    self.pageControl.numberOfPages = [self.chaptersController count];
    self.currentPage = 0;
    self.pageControl.currentPage = self.currentPage;
    self.currentChapter = [self.chaptersController objectAtIndex:self.currentPage];
    
    //setting initial properties for second scroll
    self.secondScroll.currentChapter = self.currentPage;

    
    
    NSMutableArray *pagesController = [[NSMutableArray alloc] init];
    
    for(ChapterController *tmp in self.chaptersController)
    {
        for (PageController *page in tmp.pagesController)
        {
            [pagesController addObject:page];
        }
    }
    
    self.secondScroll.pagesController = pagesController;
    self.secondScroll.totalPages = pagesController.count;
    
    /**********************************/
    //pageviewcontroller
    /**********************************/
    self.pagesViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl                                                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pagesViewController.dataSource = self;
    self.pagesViewController.delegate = self;


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //mainScroll offset
    NSInteger xOffset = 0;
    
    for(ChapterController *chapter in self.chaptersController)
    {
        
        self.chapterScroll.contentSize = CGSizeMake(self.chapterScroll.frame.size.width + xOffset, self.chapterScroll.frame.size.height);
        
        //call to draw mainScroll
        //chapterScroll has as many subviews as chapters in the book
        [self.chapterScroll addSubview:[chapter addChapterWithFrame: self.chapterScroll.frame withOffset:xOffset] ];
        
        xOffset += self.chapterScroll.frame.size.width;
    }
    
    //load second scroll. Inside this method secondScroll should be drawn
    
    self.secondScroll.secondScrollDelegate = self;
    
    UIView * tmp = [self.secondScroll loadViewWithFrame:self.secondScroll.frame delegate:self];
    [self.secondScroll addSubview:tmp];
    
    //once second scroll has been loaded, we can update the x positions for each chapter
    [self updateChaptersControllerXPositions];
    
    [self.secondScroll setCurrentChapterController: self.currentChapter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewController

//pageViewController to manage Large's Page's View
- (void) initPagesViewController:(PageController *)page
{
    ChapterViewController *contentViewController = [[ChapterViewController alloc] initWithPage:page];

    NSArray *viewControllers = [NSArray arrayWithObject:contentViewController];
    [self.pagesViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pagesViewController];
    [self.view addSubview:self.pagesViewController.view];
    [self.pagesViewController didMoveToParentViewController:self];
    
    CGRect pageViewRect = self.view.bounds;
    self.pagesViewController.view.frame = pageViewRect;
    
    self.pagesViewController.view.userInteractionEnabled = YES;
    self.chapterScroll.scrollEnabled = NO;
    self.chapterScroll.userInteractionEnabled = NO;
    self.secondScroll.userInteractionEnabled = NO;
    self.secondScroll.scrollEnabled = NO;
    
    //secondScrollIsScrolling is set to YES because when repainting secondScroll position, scrollViewDidScroll should not be called
    secondScrollIsScrolling = YES;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = ((ChapterViewController *)viewController).page.pageInfo.indexInBook;
    
    if(currentIndex == 0)
    {
        return nil;
    }
    ChapterViewController *contentViewController = [[ChapterViewController alloc] initWithPage:[self.secondScroll.pagesController objectAtIndex:(currentIndex - 1)]];
  
    return contentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
     NSUInteger currentIndex = ((ChapterViewController *)viewController).page.pageInfo.indexInBook;
    if(currentIndex == self.secondScroll.pagesController.count - 1)
    {
        return nil;
    }
    ChapterViewController *contentViewController = [[ChapterViewController alloc] initWithPage:[self.secondScroll.pagesController objectAtIndex:(currentIndex + 1)]];
    return contentViewController;
}

-(void)enableUserInteraction
{
    [self.pagesViewController.view setUserInteractionEnabled:YES];
}
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self.pagesViewController.view setUserInteractionEnabled:NO];
    [self performSelector:@selector(enableUserInteraction) withObject:nil afterDelay:DELAY_IN_LARGE_VIEW];
    
    if(finished)
    {

    if(completed)
    {
        for (ChapterViewController *c in previousViewControllers)
        {
            [self.secondScroll.myView addSubview:c.page.smallImage];
            [c.page smallImageToPositionInScroll: self.secondScroll withChapterOffset:self.currentChapter.pagesStartX];
            
            //hide current small image
            ChapterViewController* currentViewController = [pageViewController.viewControllers lastObject];
            currentViewController.page.smallImage.hidden = YES;
            
            if(currentViewController.page.pageInfo.chapter != c.page.pageInfo.chapter)
            {
                //chapter changed
                NSInteger chapter = currentViewController.page.pageInfo.chapter;
                self.currentPage = chapter;
                self.currentChapter = [self.chaptersController objectAtIndex:chapter];
                [self drawCurrentChapter];
            }
                [self fixSecondScrollPosition:currentViewController.page];

        }
        NSLog(@"finish transition");

    }
    }
}
#pragma mark - MyMethods

//when pageviewcontroller is present, secondscroll should be located in the correct place when manageScale is called
- (void) fixSecondScrollPosition:(PageController *)page
{
    CGPoint offset = self.secondScroll.contentOffset;

    if(page.smallImage.frame.origin.x + SECOND_IMAGE_WIDTH > self.currentChapter.pagesStartX + self.secondScroll.contentOffset.x + self.secondScroll.frame.size.width)
    {
        offset.x += (page.smallImage.frame.origin.x + SECOND_IMAGE_WIDTH - self.currentChapter.pagesStartX - self.secondScroll.contentOffset.x - self.secondScroll.frame.size.width);
        self.secondScroll.contentOffset = offset;
    }
    else if (page.smallImage.frame.origin.x < offset.x + self.currentChapter.pagesStartX)
    {
        offset.x = page.smallImage.frame.origin.x - self.currentChapter.pagesStartX;
        self.secondScroll.contentOffset = offset;
    }
}

//set pagesStartX and pagesFinishX in every chapter

- (void) updateChaptersControllerXPositions
{
    ChapterController *prev = [self.chaptersController objectAtIndex:0];
    
    prev.pagesStartX = 0;
    prev.pagesFinishX = SECOND_IMAGE_WIDTH * [prev.pagesController count];
    
    for(int i = 1; i < [self.chaptersController count]; i++)
    {
        ChapterController *tmp = [self.chaptersController objectAtIndex:i];
        tmp.pagesStartX = prev.pagesFinishX;
        tmp.pagesFinishX = tmp.pagesStartX + (SECOND_IMAGE_WIDTH * [tmp.pagesController count]);
        prev = tmp;
    }
}

//did the chapter change?
- (BOOL) updateCurrentChapter
{
    NSInteger chapter = round(self.chapterScroll.contentOffset.x / self.chapterScroll.frame.size.width);
    
    if (chapter >= [self.chaptersController count] || chapter < 0)
    {
        chapterChanged = NO;
        return chapterChanged;
    }
    
    if (chapter != self.currentPage)
    {
        self.currentPage = chapter;
        
        //
        self.currentChapter = [self.chaptersController objectAtIndex:self.currentPage];
        
        self.pageControl.currentPage = self.currentPage;
        
        //chapter in second scroll
        self.secondScroll.currentChapter = self.currentPage;
        
        secondScrollIsScrolling = NO;
        
        chapterChanged = YES;
    }
    else
        chapterChanged = NO;
    
    return chapterChanged;
}

//move offset when chapter change
- (void) drawCurrentChapter
{

    CGPoint moveChapterOffset = CGPointMake(self.currentPage * self.chapterScroll.frame.size.width, self.chapterScroll.contentOffset.y);
    
    [self.chapterScroll setContentOffset:moveChapterOffset animated:YES];
    [self.secondScroll moveToChapter: self.currentChapter];
    [self killScroll];
    
}
- (void) killScroll
{
    CGPoint offset = self.secondScroll.contentOffset;
    [self.secondScroll setContentOffset:offset animated:NO];
}

//evaluate and update limits for the secondScroll when the mainScroll is left-most or right-most
- (void) evaluateBounds:(UIScrollView *) scrollView
{
    if(scrollView.contentOffset.x <= 0 && secondScrollIsLeftMost)
    {
        [self.secondScroll setContentOffset:scrollView.contentOffset];
        NSLog(@"left");
    }
    if(scrollView.contentOffset.x >= (self.chapterScroll.contentSize.width - self.chapterScroll.frame.size.width) && secondScrollIsRightMost)
    {
        CGPoint offSet = CGPointMake(self.secondScroll.contentSize.width, self.secondScroll.contentOffset.y);
        
        offSet.x += (scrollView.contentOffset.x - self.chapterScroll.contentSize.width);
        [self.secondScroll setContentOffset:offSet];
    }
}

-(void) updateSecondScroll
{
    CGFloat offsetX = self.chapterScroll.contentOffset.x - self.currentChapter.chapterImage.frame.origin.x;
    if (secondScrollIsLeftMost)
    {
        if (offsetX <= 0)
        {
            [self.secondScroll setOffset:CGPointMake(offsetX, 0)];
        }
    }
    else if (secondScrollIsRightMost)
    {
        if (offsetX >= 0)
        {
            offsetX += self.secondScroll.contentSize.width - self.secondScroll.frame.size.width;
            [self.secondScroll setOffset:CGPointMake(offsetX, 0)];
        }
    }
    else return;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (!secondScrollIsScrolling)
    {
        if (scrollView.tracking)
        {
            [self updateSecondScroll];
        }
        else
        {
            if ([self updateCurrentChapter])
            {
                setOffsetForChange = YES;
                [self.secondScroll moveToChapter:self.currentChapter];
                [self.secondScroll setContentOffset:CGPointMake(0, 0)];

            }
            else
            {
                if(setOffsetForChange)
                    [self.secondScroll setContentOffset:CGPointMake(0, 0)];
                    else
                [self updateSecondScroll];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.secondScroll.userInteractionEnabled = NO;
    isScrolling = YES;
    secondScrollIsLeftMost = (self.secondScroll.contentOffset.x == 0) ? YES : NO;
    secondScrollIsRightMost = (self.secondScroll.contentOffset.x == (self.secondScroll.contentSize.width - self.secondScroll.frame.size.width) ) ? YES : NO;
    secondScrollIsScrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate) {
        isScrolling = NO;
    }
    self.secondScroll.userInteractionEnabled = YES;
    if(chapterChanged)
    {
        [self.secondScroll setContentOffset:CGPointMake(0, 0)];
    }    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.secondScroll.userInteractionEnabled = YES;
    
    //if current chapter changes, the second one should be located at the begining of the current chapter
    if(setOffsetForChange)
    {
        [self.secondScroll setContentOffset:CGPointMake(0, 0)];
        setOffsetForChange = NO;
    }
}


#pragma mark - UISecondScrollDelegate

- (void)secondScrollWillBeginDragging:(UISecondScrollView *)scrollView
{
    secondScrollIsScrolling = YES;
    self.chapterScroll.userInteractionEnabled = NO;
}

- (void)secondScrollDidScroll:(UISecondScrollView *)scrollView
{
    if(scrollView->currentPageScrollIsLeftMost && scrollView.contentOffset.x < 0)
    {
        CGPoint offset = self.chapterScroll.contentOffset;
        offset.x = scrollView.contentOffset.x;
        self.chapterScroll.contentOffset = offset;
    }
    else if(scrollView->currentPageScrollIsRightMost && scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width)
    {
        
        CGFloat diff = scrollView.contentOffset.x - scrollView.contentSize.width;
        CGPoint offset = self.chapterScroll.contentOffset;
        offset.x = (self.currentPage + 1) * MAIN_WIDTH + diff;
        self.chapterScroll.contentOffset = offset;
    }
}

- (void)secondScrollDidEndDragging:(UISecondScrollView *) scrollView
{
    self.chapterScroll.userInteractionEnabled = YES;
    [self.secondScroll evaluateChapterBounds:scrollView];
}

- (void)updateChapterScroll:(UISecondScrollView *)scrollView
{
    if(scrollView.moveToLeft)
    {
        if(self.currentPage == 0)
            return;
        else
        {
            self.currentPage--;
            self.pageControl.currentPage = self.currentPage;
            self.currentChapter = [self.chaptersController objectAtIndex:self.currentPage];
            [self drawCurrentChapter];
            scrollView.moveToLeft = NO;
        }
    }
    else if(scrollView.moveToRight)
    {
        if(self.currentPage == self.chaptersController.count - 1)
            return;
        else
        {
            self.currentPage++;
            self.pageControl.currentPage = self.currentPage;
            self.currentChapter = [self.chaptersController objectAtIndex:self.currentPage];
            [self drawCurrentChapter];
            scrollView.moveToRight = NO;
        }
        
    }

}

#pragma mark - GesturesDelegate
- (void)restorePropertiesWhenGesturesFinish
{
    self.secondScroll.userInteractionEnabled = YES;
    self.secondScroll.scrollEnabled = YES;
    self.chapterScroll.userInteractionEnabled = YES;
    self.chapterScroll.scrollEnabled = YES;
    [self.secondScroll pagesAreScrolling:NO];
    canBeginGestures = YES;
    secondScrollIsScrolling = NO;
}

- (void)loadLargeViewWithPage:(PageController *)page
{
    page.largeView.frame = CGRectMake(MAIN_ORIGIN_X, MAIN_ORIGIN_Y, MAIN_WIDTH, MAIN_HEIGHT);
    UIView *largeView = page.largeView;
    [self.view addSubview:largeView];
    [self.view bringSubviewToFront:largeView];
    page.largeView.hidden = NO;
    page.smallImage.hidden = YES;
    
    [self initPagesViewController:page];

    
}
- (void)manageTap:(PageController *)page
{
    if(!page.isBig)
    {
        UIView *pageView = page.smallImage;
    
        CGRect modifiedFrame = pageView.frame;
        modifiedFrame.origin.x = modifiedFrame.origin.x - self.secondScroll.contentOffset.x - self.currentChapter.pagesStartX;
        modifiedFrame.origin.y = SECOND_ORIGIN_Y;
        pageView.frame = modifiedFrame;
    
        CGRect newFrame = CGRectMake(MAIN_ORIGIN_X, MAIN_ORIGIN_Y, MAIN_WIDTH, MAIN_HEIGHT);


        [UIView animateWithDuration:ANIMATION_DURATION
            animations:^{
                pageView.frame = newFrame;
            } completion:^(BOOL finished) {
               
                if(finished)
                    [self loadLargeViewWithPage:page];
            }];
        
        
        page.isBig = YES;
    }
}

//manage rotation for both: small and large view
-(void)manageRotationInView:(UIView *)view angle:(CGFloat)angle
{
    view.transform = CGAffineTransformRotate(view.transform, angle);
}

-(void)managePanInView:(UIView *)view panRecognizer:(UIPanGestureRecognizer *)panRecognizer
{
    CGPoint translation = [panRecognizer translationInView:self.view];
    CGPoint imageViewPosition = view.center;
    imageViewPosition.x += translation.x;
    imageViewPosition.y += translation.y;
    
    view.center = imageViewPosition;
    [panRecognizer setTranslation:CGPointZero inView:self.view];

}

-(void)manageScaleInView:(UIView *)view scale:(CGFloat)scale pinch:(UIPinchGestureRecognizer *)pinch
{
    CGPoint midPoint = [pinch locationInView:self.view];
    view.transform = CGAffineTransformScale(view.transform, scale, scale);
    view.center = midPoint;
}

- (void)beginLargeGestures:(PageController *)page
{
    if(self.pagesViewController)
    {
        self.pagesViewController.view.userInteractionEnabled = NO;
    }
}

- (BOOL)beginGestures:(PageController *) page
{
    if(canBeginGestures)
    {
        self.secondScroll.scrollEnabled = NO;
        self.chapterScroll.scrollEnabled = NO;
        self.chapterScroll.userInteractionEnabled = NO;
        self.secondScroll.userInteractionEnabled = NO;

        //locating the view as sibling of second scroll and chapter scroll
        [self.view addSubview:page.smallImage];
        CGRect tmp = page.smallImage.frame;
        tmp.origin.y = SECOND_ORIGIN_Y;
        
        if(!page.tap)
            tmp.origin.x -= self.secondScroll.contentOffset.x;
        
        page.smallImage.frame = tmp;
        canBeginGestures = NO;
        return YES;
    }
    return canBeginGestures;
    
}
- (void)gesturesFinished:(PageController *)page name:(NSString *)name
{

    if(!page.scale && !page.rotate && !page.pan)
    {
    if(page.smallImage.frame.size.width > REQUIRED_WIDTH && page.smallImage.frame.size.height > REQUIRED_HEIGHT)
    {
        //view should grow up
        CGRect newFrame = page.smallImage.frame;
        newFrame.origin.x = MAIN_ORIGIN_X;
        newFrame.origin.y = MAIN_ORIGIN_Y;
        newFrame.size.width = MAIN_WIDTH;
        newFrame.size.height = MAIN_HEIGHT;
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^()
        {
            page.smallImage.transform = CGAffineTransformIdentity;
            page.smallImage.frame = newFrame;
            page.isBig = YES;
        }
        completion:^(BOOL finished)
        {
            if(finished)
                [self loadLargeViewWithPage:page];
        }];
    }
    
    else
    {
        //view should return to initial position
        [UIView animateWithDuration:ANIMATION_DURATION animations:^()
        {
            page.smallImage.transform = CGAffineTransformIdentity;
            page.smallImage.bounds = page.initialBounds;
            CGRect tmp = page.initialFrame;
            
            // es + por el cambio de signo
            tmp.origin.x -= self.secondScroll.contentOffset.x + self.currentChapter.pagesStartX;
            
            tmp.origin.y = SECOND_ORIGIN_Y;
            page.smallImage.frame = tmp;
            
        }
        completion:^(BOOL finished)
        {
            if(finished)
            {
                [self.secondScroll.myView addSubview:page.smallImage];
                CGRect tmp2 = page.smallImage.frame;
                tmp2.origin.x += self.secondScroll.contentOffset.x + self.currentChapter.pagesStartX;
                tmp2.origin.y = 0;
                page.smallImage.frame = tmp2;

                page.isBig = NO;
                [self restorePropertiesWhenGesturesFinish];
            }
        }];
    }
    }
}

- (void)largeGesturesFinished:(PageController *)page name:(NSString *)name
{
    if(page.largeView.frame.size.width > REQUIRED_WIDTH && page.largeView.frame.size.height > REQUIRED_HEIGHT)
    {
        //large view should stay present
        CGRect newFrame = page.largeView.frame;
        
        newFrame.origin.x = MAIN_ORIGIN_X;
        newFrame.origin.y = MAIN_ORIGIN_Y;
        newFrame.size.width = MAIN_WIDTH;
        newFrame.size.height = MAIN_HEIGHT;
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^()
        {

            page.largeView.transform = CGAffineTransformIdentity;
            page.largeView.frame = newFrame;
            page.isBig = YES;
            self.pagesViewController.view.userInteractionEnabled = YES;
            
        }];
    }
    else
    {
        //view should return to initial position
        [UIView animateWithDuration:ANIMATION_DURATION animations:^()
        {
            page.largeView.transform = CGAffineTransformIdentity;
            page.largeView.bounds = page.initialBounds;
            
            CGRect tmp = page.initialFrame;
            // es + por el cambio de signo
            tmp.origin.x -= self.secondScroll.contentOffset.x + self.currentChapter.pagesStartX;
            tmp.origin.y = SECOND_ORIGIN_Y;
            page.largeView.frame = tmp;
  
        }
        completion:^(BOOL finished)
        {
            if(finished)
            {
                [self.secondScroll.myView addSubview:page.smallImage];
                [page smallImageToPositionInScroll: self.secondScroll withChapterOffset:self.currentChapter.pagesStartX];
                page.largeView.hidden = YES;
                [page.largeView removeFromSuperview];
               
                [self restorePropertiesWhenGesturesFinish];
                
                //delete pageviewcontroller
                [self.pagesViewController.view removeFromSuperview];
                [self.pagesViewController removeFromParentViewController];
            }
        }];

    }


}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
