//
//  MMTutorialView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialView.h"
#import "MMVideoLoopView.h"
#import "AVHexColor.h"

@implementation MMTutorialView{
    UIPageControl* pageControl;
    UIView* fadedBackground;
    UIScrollView* scrollView;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        // 10% buffer
        CGFloat boxSize = 600;
        UIBezierPath* box = [self boxPathForWidth:boxSize];
        
        //
        // faded background
        
        fadedBackground = [[UIView alloc] initWithFrame:self.bounds];
        
        CAShapeLayer* shapeLayer = [CAShapeLayer layer];
        shapeLayer.bounds = self.bounds;
        shapeLayer.position = self.center;
        shapeLayer.path = box.CGPath;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.fillColor = [UIColor blackColor].CGColor;

        CALayer* greyBackground = [CALayer layer];
        greyBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
        greyBackground.bounds = self.bounds;
        greyBackground.position = self.center;
        greyBackground.mask = shapeLayer;
        [fadedBackground.layer addSublayer:greyBackground];
        [self addSubview:fadedBackground];
        
        //
        // scrollview
        
        CGPoint boxOrigin = [self topLeftCornerForBoxSize:boxSize];
        UIView* maskedScrollContainer = [[UIView alloc] initWithFrame:CGRectMake(boxOrigin.x, boxOrigin.y, boxSize, boxSize)];
        
        CAShapeLayer* scrollMaskLayer = [CAShapeLayer layer];
        scrollMaskLayer.backgroundColor = [UIColor clearColor].CGColor;
        scrollMaskLayer.fillColor = [UIColor whiteColor].CGColor;
        scrollMaskLayer.path = [self roundedRectPathForBoxSize:boxSize withOrigin:CGPointZero].CGPath;
        maskedScrollContainer.layer.mask = scrollMaskLayer;

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, boxSize, boxSize)];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.backgroundColor = [UIColor redColor];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = NO;
        
        [maskedScrollContainer addSubview:scrollView];
        [self addSubview:maskedScrollContainer];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(boxOrigin.x, boxOrigin.y + boxSize-40, boxSize, 40)];
        pageControl.pageIndicatorTintColor = [[UIColor blackColor] colorWithAlphaComponent:.4];
        pageControl.currentPageIndicatorTintColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        [self addSubview:pageControl];

        
        
        [self loadTutorials];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)_scrollView{
    CGFloat currX = scrollView.contentOffset.x + scrollView.bounds.size.width/2;
    NSInteger idx = (NSInteger) floorf(currX / scrollView.bounds.size.width);
    pageControl.currentPage = MAX(0, MIN(idx, pageControl.numberOfPages-1));
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)_scrollView{
    [scrollView.subviews makeObjectsPerformSelector:@selector(stopAnimating)];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)_scrollView{
    NSInteger idx = scrollView.contentOffset.x / scrollView.bounds.size.width;
    MMVideoLoopView* visible = [scrollView.subviews objectAtIndex:idx];
    [visible startAnimating];
}


#pragma mark - Tutorial Loading

-(void) loadTutorials{
    NSArray* tutorials = @[@"ruler-circle.mov",@"ruler-circle.mov",@"ruler-circle.mov"];
    
    [tutorials enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSURL* tutorialMov = [[NSBundle mainBundle] URLForResource:obj withExtension:nil];
        MMVideoLoopView* tutorial = [[MMVideoLoopView alloc] initForVideo:tutorialMov];
        tutorial.backgroundColor = [AVHexColor randomColor];
        [scrollView addSubview:tutorial];

        CGRect fr = scrollView.bounds;
        fr.origin.x = idx * fr.size.width;
        tutorial.frame = fr;
        [tutorial stopAnimating];
    }];
    
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * [tutorials count], scrollView.bounds.size.height);
    [(MMVideoLoopView*)scrollView.subviews.firstObject startAnimating];

    pageControl.numberOfPages = [tutorials count];
    pageControl.currentPage = 0;
}



#pragma mark - Private Helpers

-(CGPoint) topLeftCornerForBoxSize:(CGFloat)width{
    return CGPointMake((self.bounds.size.width - width) / 2, (self.bounds.size.height - width) / 2);
}

-(UIBezierPath*) roundedRectPathForBoxSize:(CGFloat)width withOrigin:(CGPoint)boxOrigin{
    return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(boxOrigin.x, boxOrigin.y, width, width)
                          byRoundingCorners:UIRectCornerAllCorners
                                cornerRadii:CGSizeMake(width/10, width/10)];
}

-(UIBezierPath*) boxPathForWidth:(CGFloat)width{
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:self.bounds];
    CGPoint boxOrigin = [self topLeftCornerForBoxSize:width];
    [path appendPath:[self roundedRectPathForBoxSize:width withOrigin:boxOrigin]];
    path.usesEvenOddFillRule = YES;
    return path;
}

@end