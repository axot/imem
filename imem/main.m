//
//  main.m
//  memhack
//
//  Created by Zheng Shao on 1/13/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#include <Foundation/Foundation.h>
#include "AXCUIHandler.h"
#include "AXMemoryCore.h"

#pragma mark -- Main entry

int main(int argc, const char * argv[])
{
  @autoreleasepool
  {
    if(argc != 2)
    {
      fprintf(stderr, "usage: \n%s pid\n", argv[0]);
      exit(-1);
    }
    
    char buf[256];
    NSString* line;
    AXCUIHandler* handler = [AXCUIHandler sharedManager];
    AXMemoryCore* mem = [[AXMemoryCore alloc] initWithPid:atol(argv[1])];
    
    while (fgets(buf, 256, stdin))
    {
      line = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
      NSArray *items = [line componentsSeparatedByString:@" "];
      id charset = [NSCharacterSet whitespaceAndNewlineCharacterSet];
      
      NSString* trimed = [items[0] stringByTrimmingCharactersInSet:charset];
      
      if ([trimed isEqualToString:@"c"] || [trimed isEqualToString:@"change"])
      {
        // change a to b in all results
        if (items.count == 3)
        {
          NSLog(@"Alter %@ to %@", items[1], items[2]);
          [mem changeValue:[items[2] intValue] forTargetValue:[items[1] intValue]];
        }
      }
      if ([trimed isEqualToString:@"cs"] || [trimed isEqualToString:@"changeSearch"])
      {
        // change all value in address list to b
        if (items.count == 2)
        {
          
        }
        
        /* change all values between 2 addresses
         * ex: cs 8888 0x10000 0x20000
         */
        else if (items.count == 4)
        {
          
        }
      }
      else if ([trimed isEqualToString:@"s"] || [trimed isEqualToString:@"search"])
      {
        // search the same value as last time using address list
        if (items.count == 1)
        {
          
        }
        // search a value
        if (items.count == 2)
        {
          NSLog(@"search for %@", items[2]);
          
        }
      }
      else if ([trimed isEqualToString:@"a"] || [trimed isEqualToString:@"alias"])
      {
        // show all alias
        if (items.count == 1)
        {
          
          
        }
        // show a alias
        else if (items.count == 1)
        {
          
        }
        // set a alias
        else if (items.count > 1)
        {
          
        }
      }
      else if ([trimed isEqualToString:@"ls"] || [trimed isEqualToString:@"list"])
      {
        // show current address list
        if (items.count == 1)
        {
          
        }
      }
      else if ([trimed isEqualToString:@"r"] || [trimed isEqualToString:@"reset"])
      {
        // reset last address list
        if (items.count == 1)
        {
          
        }
      }
      else
        NSLog(@"unknown command");
    }
  }
  return 0;
}
