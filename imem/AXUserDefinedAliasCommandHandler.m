//
//  AXUserDefinedAliasCommandHandler.m
//  imem
//
//  Created by Zheng Shao on 1/23/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXUserDefinedAliasCommandHandler.h"

@implementation AXUserDefinedAliasCommandHandler

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp *)help
{
  if (command == nil)  command = @"";
  if (params == nil)  params = @[];
  
  if (params.count == 0)
  {
    id values = [AXMemoryCore sharedInstance].aliasList[command];
    
    if (values)
    {
      int i = 0;
      for (NSNumber* addr in values)
      {
        int value = [[AXMemoryCore sharedInstance] valueForAddress:addr.unsignedIntValue];
        printf("[%d] 0x%08x (%d)\n", i, addr.unsignedIntValue, value);
        ++i;
      }
    }
    else
    {
      return NO;
    }
  }
  
  else if (params.count == 1)
  {
    id values = [AXMemoryCore sharedInstance].aliasList[command];
    if (values)
    {
      for (NSNumber* addr in values)
      {
        printf("0x%08x", addr.unsignedIntValue);
        [[AXMemoryCore sharedInstance] changeToValue:[params[0] intValue] forAddress:addr.unsignedLongValue];
      }
    }
    else
    {
      return NO;
    }
  }
  
  return NO;
}

- (NSString*)handlerDescription
{
  return @"[user defined alias]\n"
          "\t\tshow address list for user defined alias\n\n"
          "[user defined alias] value\n"
          "\t\tchange all addresses in alias to value\n\n";
}

@end
