//
//  MMScrapBezelMenuViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapView.h"

@protocol MMScrapSidebarContentViewDelegate <NSObject>

-(NSArray*) scraps;

-(void) didTapOnScrapFromMenu:(MMScrapView*)scrap;

-(BOOL) isVisible;

@end
