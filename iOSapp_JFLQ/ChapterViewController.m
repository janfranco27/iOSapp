//
//  ChapterViewController.m
//  SecondScrollView
//
//  Created by yrnunez on 14/02/14.
//  Copyright (c) 2014 yrnunez. All rights reserved.
//

#import "ChapterViewController.h"
#import "PageController.h"
@interface ChapterViewController ()

@end

@implementation ChapterViewController

-(id)initWithPage:(PageController *)page
{
    self = [super init];
    if(self)
    {
        _page = page;
        _page.largeView.frame = CGRectMake(0, 0, 768, 1024);
        _page.largeView.hidden = NO;
        [self.view addSubview: _page.largeView];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
