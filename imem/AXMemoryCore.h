//
//  AXMemoryCore.h
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import <Foundation/Foundation.h>

@interface AXMemoryCore : NSObject

- (id)initWithPid:(int) aPid;
- (void)setPid:(int) aPid;
- (BOOL)changeValue:(int)aVar forTargetValue:(int)tVar;

@end
