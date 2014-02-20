//
//  PageController.m
//  SecondScrollView
//
//  Created by yrnunez on 6/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import "PageController.h"
#import "PageInformation.h"
#import "Constants.h"

@implementation PageController

- (id)initWithInformation:(PageInformation *)page
{
    self = [super init];
    if(self)
    {
        _pageInfo = page;
        self.largeView = [[UIView alloc] initWithFrame:CGRectMake(MAIN_ORIGIN_X, MAIN_ORIGIN_Y, MAIN_WIDTH, MAIN_HEIGHT)];
        self.largeView.userInteractionEnabled = YES;
        self.largeView.multipleTouchEnabled = YES;
        self.largeView.clipsToBounds = YES;
    }
    return self;
}

-(void)setImageForPage
{
    
    //setting info for small page
    self.smallImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.smallImageName] ];
    self.smallImage.backgroundColor = [UIColor whiteColor];

    //setting info for large page
    self.largeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.largeImageName] ];
    self.largeImage.backgroundColor = [UIColor whiteColor];
    self.largeImage.frame = self.largeView.frame;
    self.largeImage.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //largeview will manage the view when it belongs to the pageviewcontroller
    [self.largeView addSubview:self.largeImage];
}

- (UIImageView *)addPageToScrollWithFrame:(CGRect)frame withOffset:(NSInteger)xOffset delegate:(id <UIGestureRecognizerDelegate>) delegate
{
    self.largeImage.userInteractionEnabled = YES;
    self.largeImage.multipleTouchEnabled = YES;
    
    self.smallImage.userInteractionEnabled = YES;
    self.smallImage.multipleTouchEnabled = YES;
    self.smallImage.frame = CGRectMake(xOffset, 0, SECOND_IMAGE_WIDTH, frame.size.height);
    
    /**********************************************************/
    //small gestures
    /**********************************************************/
    
    //single tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    //rotate
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    //scale
    UIPinchGestureRecognizer *scale = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleScale:)];
    //pan
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    pan.minimumNumberOfTouches = 2;
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.delegate = delegate;
    rotate.delegate = delegate;
    scale.delegate = delegate;
    pan.delegate = delegate;
    
    [self.smallImage addGestureRecognizer:rotate];
    [self.smallImage addGestureRecognizer:tap];
    [self.smallImage addGestureRecognizer:scale];
    [self.smallImage addGestureRecognizer:pan];
    
    /**********************************************************/
    //large gestures
    /**********************************************************/
    UIRotationGestureRecognizer *lRotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleLRotation:)];
    
    UIPinchGestureRecognizer *lScale = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleLScale:)];
    //pan
    UIPanGestureRecognizer *lPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLPan:)];
    
    lPan.minimumNumberOfTouches = 2;
    lPan.maximumNumberOfTouches = 2;
    lPan.delegate = delegate;
    lScale.delegate = delegate;
    lRotate.delegate = delegate;
    
    [self.largeView addGestureRecognizer:lRotate];
    [self.largeView addGestureRecognizer:lScale];
    [self.largeImage addGestureRecognizer:lPan];
    
    /*************/
    self.initialFrame = self.smallImage.frame;
    self.initialBounds = self.smallImage.bounds;
    /*************/
    self.tap = NO;
    self.rotate = NO;
    self.scale = NO;
    self.pan = NO;
    self.isBig = NO;
    /*************/
    return self.smallImage;
}

#pragma mark - handleSmallGestures

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    self.tap = YES;
    if([self.gesturesDelegate beginGestures:self])
    {
        [self.gesturesDelegate manageTap:self];
        self.tap = NO;
    }
    else self.tap = NO;
}

- (void) handleRotation:(UIRotationGestureRecognizer *)rotationRecognizer
{
    if (rotationRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.rotate = YES;
        [self.gesturesDelegate beginGestures:self];
    }
    else if(rotationRecognizer.state == UIGestureRecognizerStateEnded || rotationRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        self.rotate = NO;
        [self touchesEnd:@"rota"];
    }
    else
    {
        
        CGFloat angle = rotationRecognizer.rotation;
        [self.gesturesDelegate manageRotationInView:self.smallImage angle:angle];
        rotationRecognizer.rotation = 0.0;

    }
}

- (void) handleScale:(UIPinchGestureRecognizer *)pinchRecognizer
{
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.scale = YES;
        [self.gesturesDelegate beginGestures:self];
    }
    else if(pinchRecognizer.state == UIGestureRecognizerStateEnded || pinchRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        self.scale = NO;
        [self touchesEnd:@"pinch"];
    }
    else
    {
        CGFloat scale = pinchRecognizer.scale;

        [self.gesturesDelegate manageScaleInView:self.smallImage scale:scale pinch:pinchRecognizer];
        pinchRecognizer.scale = 1.0;
    }
}

- (void) handlePan:(UIPanGestureRecognizer *)panRecognizer
{
    if (panRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.pan = YES;
        [self.gesturesDelegate beginGestures:self];
    }
    else if(panRecognizer.state == UIGestureRecognizerStateEnded || panRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        self.pan = NO;
        [self touchesEnd:@"pan"];
    }
    else
    {
        [self.gesturesDelegate managePanInView:self.smallImage panRecognizer:panRecognizer];

    }
}

#pragma mark - handleLargeGestures

- (void) handleLRotation:(UIRotationGestureRecognizer *)rotationRecognizer
{
    CGFloat angle = rotationRecognizer.rotation;
    [self.gesturesDelegate manageRotationInView:self.largeView angle:angle];
    rotationRecognizer.rotation = 0.0;
}

- (void) handleLScale:(UIPinchGestureRecognizer *)pinchRecognizer
{
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.gesturesDelegate beginLargeGestures:self];
    }
    else if(pinchRecognizer.state == UIGestureRecognizerStateEnded || pinchRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self largeTouchesEnd:@"LARGE pinch"];
    }
    else
    {
        CGFloat scale = pinchRecognizer.scale;
        [self.gesturesDelegate manageScaleInView:self.largeView scale:scale pinch:pinchRecognizer];
        pinchRecognizer.scale = 1.0;
    }
}

- (void) handleLPan:(UIPanGestureRecognizer *)panRecognizer
{
   [self.gesturesDelegate managePanInView:self.smallImage panRecognizer:panRecognizer];
}

#pragma mark - touchesFinished

- (void)touchesEnd:(NSString *) name
{
    [self.gesturesDelegate gesturesFinished:self name:name];
}

- (void)largeTouchesEnd: (NSString *)name
{
    [self.gesturesDelegate largeGesturesFinished:self name:name];
}

#pragma mark - restoreSmallImage

- (void)smallImageToPositionInScroll: (UIScrollView *)scroll withChapterOffset: (CGFloat)pagesStartX
{
    self.smallImage.bounds = self.initialBounds;
    CGRect tmp = self.initialFrame;
    tmp.origin.y = 0;
    self.smallImage.frame = tmp;
    self.isBig = NO;
    self.smallImage.hidden = NO;
}

@end
