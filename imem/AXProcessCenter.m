//
//  AXProcessCenter.m
//  imem
//
//  Created by Zheng Shao on 1/15/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXProcessCenter.h"
#import "AXMemoryCore.h"

@implementation AXProcessCenter

- (AXMemoryCore*)memProcessor
{
  if (!_memProcessor)
  {
    _memProcessor = [[AXMemoryCore alloc] initWithPid:self.pid];
  }
  return _memProcessor;
}

- (void)setPid:(int)pid
{
  if (!_pid)
  {
    _pid = pid;
  }
}

- (AXProcessCenter*)initWithPid:(int)pid
{
  self = [super init];
  if (self)
  {
    if (pid <= 0)
      return nil;
    
    else
      self.pid = pid;
  }
  return self;
}

- (id)init
{
  return nil;
}

#pragma mark -- AXCUIHandlerDelegate
- (void)changeCommandNotification:(NSString*)command Parameters:(NSArray*)params
{
  printf("%s command", [command UTF8String]);
  if(params.count == 2)
  {
    printf(",changing %d to %d", [params[0] intValue], [params[1] intValue]);
    [self.memProcessor changeValue:[params[1] intValue] forTargetValue:[params[0] intValue]];
  }
  printf("\n");
}

- (void)searchCommandNotification:(NSString*)command Parameters:(NSArray*)params
{
  
}

- (void)changesearchCommandNotification:(NSString*)command Parameters:(NSArray*)params
{
  
}

- (void)aliasCommandNotification:(NSString*)command Parameters:(NSArray*)params
{
  
}

- (void)listCommandNotification:(NSString*)command Parameters:(NSArray*)params
{
  
}

- (void)resetCommandNotification:(NSString*)command Parameters:(NSArray*)params
{
  
}

@end
