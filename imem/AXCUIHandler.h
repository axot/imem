//
//  AXCUIHandler.h
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import <Foundation/Foundation.h>

@interface AXCUIHandler : NSObject

- (AXCUIHandler*)initWithPid:(NSUInteger)pid;
- (void)startHandler;

@end
