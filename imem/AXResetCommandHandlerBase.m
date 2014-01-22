//
//  AXRestCommandHandlerBase.m
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXResetCommandHandlerBase.h"

@implementation AXResetCommandHandlerBase

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp *)help
{
  if (command == nil)  command = @"";
  if (params == nil)  params = @[];

  if ([command isEqualToString:@"r"] ||
      [command isEqualToString:@"reset"])
  {
    // reset latest address list
    if (params.count == 0)
    {
      printf("latest address list was reset\n");
      [[AXMemoryCore sharedInstance] resetAddressList];
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
  return @"[r | reset]\n"
          "\t\treset address list\n\n";
}

@end
