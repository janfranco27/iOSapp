//
//  ChapterController.m
//  SecondScrollView
//
//  Created by yrnunez on 6/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import "ChapterController.h"
#import "PageController.h"
#import "PageInformation.h"

@implementation ChapterController

- (id)initWithPages:(NSMutableArray *)pages withImage:(UIImage *)image withChapterIndex:(NSInteger)chapterIndex
{
    self = [super init];
    if (self)
    {
        _pagesController = pages;
        _chapterImage = [[UIImageView alloc] initWithImage:image];
        _indexInBook = chapterIndex;
        _numberOfPages = pages.count;
        for (PageController *p in _pagesController)
        {
            p.pageInfo.chapter = chapterIndex;
        }
    }
    return self;
}

- (UIView *)addChapterWithFrame:(CGRect)frame withOffset:(NSInteger)xOffset
{
    self.chapterImage.userInteractionEnabled = YES;
    
    self.chapterImage.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.chapterImage.frame = CGRectMake(xOffset, 0, frame.size.width, frame.size.height);
    return self.chapterImage;
}



@end
