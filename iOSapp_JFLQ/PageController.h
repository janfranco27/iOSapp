//
//  PageController.h
//  SecondScrollView
//
//  Created by yrnunez on 6/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageInformation;
@protocol GesturesDelegate;


@interface PageController : UIView

@property (nonatomic, strong) NSString *smallImageName;
@property (nonatomic, strong) NSString *largeImageName;
@property (nonatomic, strong) UIImageView *smallImage;
@property (nonatomic, strong) UIImageView *largeImage;
@property (nonatomic, strong) UIView *largeView;
@property (nonatomic, strong) PageInformation *pageInfo;
@property (nonatomic, strong) id <GesturesDelegate> gesturesDelegate;
@property (nonatomic) CGRect initialFrame;
@property (nonatomic) CGRect initialBounds;
@property (nonatomic) BOOL tap;
@property (nonatomic) BOOL pan;
@property (nonatomic) BOOL rotate;
@property (nonatomic) BOOL scale;
@property (nonatomic) BOOL isBig;

- (id)initWithInformation: (PageInformation *) page;
- (void) setImageForPage;
- (UIImageView *) addPageToScrollWithFrame: (CGRect) frame withOffset: (NSInteger) xOffset delegate:(id<UIGestureRecognizerDelegate>) delegate;
- (void)smallImageToPositionInScroll: (UIScrollView *)scroll withChapterOffset:(CGFloat)pagesStartX;
@end


@protocol GesturesDelegate <NSObject>

- (void)manageTap:(PageController *)page;
- (void)manageRotationInView:(UIView *)view angle:(CGFloat)angle;
- (void)managePanInView:(UIView *)view panRecognizer:(UIPanGestureRecognizer *)panRecognizer;
- (void)manageScaleInView:(UIView *)view scale:(CGFloat)scale pinch:(UIPinchGestureRecognizer *)pinch;
- (void)gesturesFinished:(PageController *)page name:(NSString *)name;
- (void)largeGesturesFinished:(PageController *)page name:(NSString *)name;
- (void)beginLargeGestures:(PageController *)page;
- (BOOL)beginGestures:(PageController *)page;

@end