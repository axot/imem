//
//  AXCUIHandler.h
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import <Foundation/Foundation.h>

@interface AXCUIHandler : NSObject

+ (AXCUIHandler*)sharedManager;
- (void)handlerPID:(int)pid;

@end
