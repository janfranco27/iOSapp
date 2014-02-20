//
//  ChapterController.h
//  SecondScrollView
//
//  Created by yrnunez on 6/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChapterController : NSObject

//array of page controller
@property (nonatomic, strong) NSMutableArray *pagesController;
@property (nonatomic, strong) UIImageView *chapterImage;
@property (nonatomic) NSInteger pagesStartX;
@property (nonatomic) NSInteger pagesFinishX;
@property (nonatomic) NSInteger indexInBook;
@property (nonatomic) NSInteger numberOfPages;

- (id) initWithPages: (NSMutableArray *) pages withImage: (UIImage *) image withChapterIndex: (NSInteger) chapterIndex;

- (UIView *) addChapterWithFrame:(CGRect) frame withOffset: (NSInteger) xOffset;

@end
