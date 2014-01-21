//
//  AXProcessCenter.h
//  imem
//
//  Created by Zheng Shao on 1/15/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXCUIHandler.h"

@class AXMemoryCore;

@interface AXProcessCenter : NSObject <AXCUIHandlerDelegate>

@property (nonatomic) AXMemoryCore* memProcessor;
@property (nonatomic) int pid;

- (AXProcessCenter*)initWithPid:(int)pid;

@end
