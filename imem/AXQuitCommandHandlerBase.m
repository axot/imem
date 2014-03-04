//
//  AXQuitCommandHandlerBase.m
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXQuitCommandHandlerBase.h"

@implementation AXQuitCommandHandlerBase

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp *)help
{
  if (command == nil)  command = @"";
  if (params == nil)  params = @[];

  if ([command isEqualToString:@"q"] ||
      [command isEqualToString:@"quit"])
  {
    if (params.count == 0)
    {
      exit(EXIT_SUCCESS);
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
  return @"[q | quit]\n"
          "\t\tquit program\n\n";
}

@end
