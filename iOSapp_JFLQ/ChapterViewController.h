//
//  ChapterViewController.h
//  SecondScrollView
//
//  Created by yrnunez on 14/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PageController;

@interface ChapterViewController : UIViewController
@property (nonatomic, weak) PageController *page;

- (id)initWithPage:(PageController *)page;
@end
