//
//  AXHandlderHelp.h
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXMemoryCore.h"

#pragma mark -- AXHandlerProtocol

@class AXHandlerHelp;

@protocol AXHandlerProtocol <NSObject>

@required
- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp*)help;
- (NSString*)handlerDescription;

@end

#pragma mark -- AXHandlerHelp

@interface AXHandlerHelp : NSObject

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params;
- (BOOL)setHandler:(AXHandlerHelp*)handler;
- (NSString*)handlerDescription;

@end
