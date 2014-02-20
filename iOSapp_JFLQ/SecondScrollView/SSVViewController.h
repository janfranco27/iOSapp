//
//  SSVViewController.h
//  SecondScrollView
//
//  Created by yrnunez on 4/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChapterController;
@class UISecondScrollView;
@protocol UISecondScrollDelegate;
@protocol GesturesDelegate;

@interface SSVViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UISecondScrollDelegate, GesturesDelegate>
{
    BOOL chapterChanged;
    BOOL isScrolling;
    BOOL secondScrollIsLeftMost;
    BOOL secondScrollIsRightMost;
    BOOL chapterScrollIsLeftMost;
    BOOL chapterScrollIsRightMost;
    BOOL secondScrollIsScrolling;
    BOOL canBeginGestures;
    BOOL setOffsetForChange;
}


//arrat of chapter controller
@property (nonatomic, strong) NSMutableArray *chaptersController;
@property (nonatomic, strong) IBOutlet UISecondScrollView *secondScroll;
@property (nonatomic, strong) IBOutlet UIScrollView *chapterScroll;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) ChapterController *currentChapter;

@property (nonatomic, strong) UIPageViewController *pagesViewController;

@end
