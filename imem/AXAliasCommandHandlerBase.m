//
//  AXAliasCommandHandlerBase.m
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXAliasCommandHandlerBase.h"

@implementation AXAliasCommandHandlerBase

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp *)help
{
  if (command == nil)  command = @"";
  if (params == nil)  params = @[];

  if ([command isEqualToString:@"a"] || [command isEqualToString:@"alias"])
  {
    // show all alias
    if (params.count == 0)
    {
      for(NSString* name in [AXMemoryCore sharedInstance].aliasList)
      {
        printf("%s\n", name.UTF8String);
      }
    }
    
    // set a alias
    else if (params.count == 1)
    {
      [[AXMemoryCore sharedInstance] setAlias:params[0] forAddresses:[AXMemoryCore sharedInstance].addressList];
    }
    
    else
    {
      printf("%s\n", self.handlerDescription.UTF8String);
      return YES;
    }
    return YES;
  }
  
  return NO;
}

- (NSString*)handlerDescription
{
  return @"[a | alias]\n"
          "\t\tshow all user defined aliases\n\n"
          "[a | alias] name\n"
          "\t\tset alias(name) using current address list\n\n";
}

@end
