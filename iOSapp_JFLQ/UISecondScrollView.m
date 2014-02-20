//
//  UISecondScrollView.m
//  SecondScrollView
//
//  Created by yrnunez on 6/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import "UISecondScrollView.h"
#import "Constants.h"
#import "ChapterController.h"
#import "PageController.h"
#import "PageInformation.h"


@implementation UISecondScrollView


- (void)commonInit
{
    //setting important features
    self.delegate = self;
    self.clipsToBounds = YES;
    self.myView.clipsToBounds = YES;
    self.exclusiveTouch = YES;
    self.multipleTouchEnabled = NO;
    self.myView.multipleTouchEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    currentPageScrollIsLeftMost = YES;
    currentPageScrollIsRightMost = NO;
    pagesAreScrolling = NO;
    chapterIsScrolling = NO;
    self.moveToLeft = NO;
    self.moveToRight = NO;
    
    self.currentChapter = 0;
    
}

- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (UIView *)loadViewWithFrame:(CGRect)frame delegate:(id<UIGestureRecognizerDelegate> ) delegate;
{
    //drawing view

    self.myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SECOND_IMAGE_WIDTH *self.totalPages, self.frame.size.height)];
    NSInteger xOffset = 0;
    
    
    for (PageController *tmp in self.pagesController)
    {
        [tmp setImageForPage];
        
        tmp.smallImage.bounds = CGRectMake(0, 0, SECOND_IMAGE_WIDTH, frame.size.height);
        
        self.contentSize = CGSizeMake(tmp.smallImage.frame.size.width + xOffset, tmp.smallImage.frame.size.height);
        
        //adding pages to second Scroll, one next to the other
        [self.myView addSubview:[tmp addPageToScrollWithFrame:frame withOffset:xOffset delegate:delegate] ];
        
        xOffset += tmp.smallImage.frame.size.width;
    }
    return self.myView;
    
}

#pragma mark - MyMethods

-(void)setOffset:(CGPoint)offset
{
    chapterIsScrolling = YES;
    [self setContentOffset:offset];
}
- (void)moveToChapter:(ChapterController *)chapter
{
    [self setCurrentChapterController: chapter];
    CGRect f = self.myView.frame;
    f.origin.x = -chapter.pagesStartX;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState |
     UIViewAnimationOptionCurveEaseOut animations:^{
         self.myView.frame = f;
         [self setContentOffset:CGPointMake(0, 0)];

     } completion:nil];
    

}

- (void) setCurrentChapterController:(ChapterController *)currentChapterController
{
    _currentChapterController = currentChapterController;
    _currentChapter = currentChapterController.indexInBook;
    
    CGSize contentSize = self.contentSize;
    contentSize.width = self.currentChapterController.pagesFinishX - self.currentChapterController.pagesStartX;
    self.contentSize = contentSize;
    
}
- (void) evaluateChapterBounds:(UIScrollView *) scrollView
{
    if(scrollView.contentOffset.x <= -LIMIT_TO_CHANGE_CHAPTER)
        self.moveToLeft = YES;
    else self.moveToLeft = NO;
    
    if(scrollView.contentOffset.x + self.frame.size.width >= self.contentSize.width + LIMIT_TO_CHANGE_CHAPTER)
        self.moveToRight = YES;
    else self.moveToRight = NO;
}

- (void) checkLeftOrRightMost: (UIScrollView *)scrollView
{
    currentPageScrollIsLeftMost = (scrollView.contentOffset.x <= 0 && self.currentChapter == 0) ? YES : NO;
    
    NSInteger lastChapter = ((PageController *)self.pagesController.lastObject).pageInfo.chapter;
    
    currentPageScrollIsRightMost = (scrollView.contentOffset.x + scrollView.frame.size.width > self.currentChapterController.pagesFinishX - self.currentChapterController.pagesStartX && self.currentChapter == lastChapter) ? YES : NO;
}

- (void) pagesAreScrolling:(BOOL) p
{
    pagesAreScrolling = p;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!chapterIsScrolling)
    {
        if (pagesAreScrolling)
        {
            [self checkLeftOrRightMost:scrollView];
            if(currentPageScrollIsLeftMost || currentPageScrollIsRightMost)
               [self.secondScrollDelegate secondScrollDidScroll:(UISecondScrollView *) scrollView];
            
            [self evaluateChapterBounds: scrollView];
            if(!scrollView.isTracking)
            
            {
                if(self.moveToRight || self.moveToLeft)
                {
                    [self.secondScrollDelegate updateChapterScroll:(UISecondScrollView *) scrollView];
                }
            }
        }
     }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    chapterIsScrolling = NO;
    pagesAreScrolling = YES;
    [self checkLeftOrRightMost:scrollView];
    
    [self.secondScrollDelegate secondScrollWillBeginDragging: (UISecondScrollView* )scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.secondScrollDelegate respondsToSelector:@selector(secondScrollDidEndDragging:)])
        [self.secondScrollDelegate secondScrollDidEndDragging:(UISecondScrollView *)scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pagesAreScrolling = NO;
    [self.secondScrollDelegate secondScrollDidEndDragging:(UISecondScrollView *)scrollView];
}

@end
