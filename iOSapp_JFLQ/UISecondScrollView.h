//
//  UISecondScrollView.h
//  SecondScrollView
//
//  Created by yrnunez on 6/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChapterController;
@protocol UISecondScrollDelegate;

@interface UISecondScrollView : UIScrollView <UIScrollViewDelegate>
{
    @public
    BOOL currentPageScrollIsLeftMost;
    BOOL currentPageScrollIsRightMost;
    BOOL pagesAreScrolling;
    BOOL chapterIsScrolling;
}


@property (nonatomic, strong) NSMutableArray *pagesController;
@property (nonatomic, weak) ChapterController *currentChapterController;
@property (nonatomic) NSInteger currentChapter;
@property (nonatomic, strong) UIView* myView;
@property (nonatomic, weak) id <UISecondScrollDelegate> secondScrollDelegate;
@property (nonatomic) BOOL moveToLeft;
@property (nonatomic) BOOL moveToRight;
@property (nonatomic) NSInteger totalPages;

- (UIView *) loadViewWithFrame:(CGRect) frame delegate:(id<UIGestureRecognizerDelegate>) delegate;
- (void) pagesAreScrolling:(BOOL) p;
- (void) moveToChapter:(ChapterController *)chapter;
- (void) setOffset:(CGPoint) offset;
- (void) evaluateChapterBounds:(UIScrollView *) scrollView;
@end


@protocol UISecondScrollDelegate <NSObject>

- (void)secondScrollWillBeginDragging:(UISecondScrollView *)scrollView;
- (void)secondScrollDidScroll:(UISecondScrollView *)scrollView;
- (void)secondScrollDidEndDragging:(UISecondScrollView *)scrollView;
- (void)updateChapterScroll:(UISecondScrollView *) scrollView;

@end