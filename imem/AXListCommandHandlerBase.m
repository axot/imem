//
//  AXListCommandHandlerBase.m
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXListCommandHandlerBase.h"

@implementation AXListCommandHandlerBase

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp *)help
{
  if (command == nil)  command = @"";
  if (params == nil)  params = @[];

  if ([command isEqualToString:@"l"] ||
      [command isEqualToString:@"ls"] ||
      [command isEqualToString:@"list"])
  {
    // show current address list
    if (params.count == 0)
    {
      printf("current address list\n");
      
      NSArray* addrs = [[AXMemoryCore sharedInstance] addressList];
      int i = 0;
      for (NSNumber* addr in addrs)
      {
        int value = [[AXMemoryCore sharedInstance] valueForAddress:addr.unsignedIntValue];
        printf("[%d] 0x%08x (%d)\n", i, addr.unsignedIntValue, value);
        ++i;
      }
      
      if (i == 0)
      {
        printf("an empty list!\n");
      }
      return YES;
    }
    else
    {
      printf("%s\n", self.handlerDescription.UTF8String);
      return YES;
    }
  }
  return NO;
}

- (NSString*)handlerDescription
{
  return @"[l | ls | list]\n"
          "\t\tshow current address list\n\n";
}

@end
