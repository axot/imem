//
//  AXSearchCommandHandlerBase.m
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXSearchCommandHandlerBase.h"
#import "NSString+Stripped.h"

@implementation AXSearchCommandHandlerBase

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp *)help
{
  if (command == nil)  command = @"";
  if (params == nil)  params = @[];

  if ([command isEqualToString:@"s"] ||
      [command isEqualToString:@"search"])
  {
    NSArray* resultList = nil;
    
    // search the same value as last time using address list
    if (params.count == 0)
    {
      if ([AXMemoryCore sharedInstance].lastSearchedValue == INFINITY)
      {
        fprintf(stderr, "search a value first\n");
      }
      else
      {
        printf("searching for %d\n", [AXMemoryCore sharedInstance].lastSearchedValue);
        resultList = [[AXMemoryCore sharedInstance] searchForValue:[AXMemoryCore sharedInstance].lastSearchedValue];
      }

    }
    // search a value
    else if (params.count == 1)
    {
      if ([params[0] hasPrefix:@"\""])
      {
        NSString* key = [params[0] stringBetweenString:@"\""];
        printf("searching for string: %s\n", key.UTF8String);
        resultList = [[AXMemoryCore sharedInstance] searchForString:key.UTF8String];
      }
      else
      {
        resultList = [[AXMemoryCore sharedInstance] searchForValue:[params[0] intValue]];
        [AXMemoryCore sharedInstance].lastSearchedValue = [params[0] intValue];
      }
    }
    
    else
    {
      printf("%s\n", self.handlerDescription.UTF8String);
      return YES;
    }
    
    if(resultList != nil)
    {
      int i = 0;
      for (NSNumber* addr in resultList)
      {
        printf("[%d] 0x%08lx (%d)\n", i, addr.unsignedLongValue, [AXMemoryCore sharedInstance].lastSearchedValue);
        ++i;
      }
    }
    
    return YES;
  }
  return NO;
}

- (NSString*)handlerDescription
{
  return @"[s | search]\n"
          "\t\tsearch the same value as last time using address list\n\n"
          "[s | search] value\n"
          "\t\tsearch for a value, if current address list is empty,\n"
          "\t\tsearch in whole address space\n\n";
}

@end
