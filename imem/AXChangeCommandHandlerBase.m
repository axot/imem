//
//  AXChangeCommandHandlerBase.m
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXChangeCommandHandlerBase.h"

@implementation AXChangeCommandHandlerBase

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp *)help
{
  if (command == nil)  command = @"";
  if (params == nil)  params = @[];

  if ([command isEqualToString:@"c"] ||
      [command isEqualToString:@"change"])
  {
    if(params.count == 3 && [params[0] isEqualToString:@"addr"])
    {
      unsigned int addr;
      if ([params[1] hasPrefix:@"0x"])
      {
        NSScanner* scanner = [NSScanner scannerWithString:params[1]];
        [scanner scanHexInt:&addr];
      }
      else addr = (unsigned int)[params[1] longLongValue];

      printf("change 0x%x to %d", addr, [params[2] intValue]);
      [[AXMemoryCore sharedInstance] changeToValue:[params[2] intValue]
                                           forAddress:addr];
    }
    
    else if(params.count == 4 && [params[0] isEqualToString:@"range"])
    {
      printf("change index from %d:%d to %d\n", [params[1] intValue], [params[2] intValue], [params[3] intValue]);
      
      for(int i=[params[1] intValue]; i<=[params[2] intValue]; ++i)
      {
        size_t addr = [[[AXMemoryCore sharedInstance] addressList][i] unsignedLongValue];
        printf("[%d] 0x%08lx", i, addr);
        [[AXMemoryCore sharedInstance] changeToValue:[params[3] intValue]
                                             forAddress:addr];
      }
    }
    
    else if(params.count == 0)
    {
      if([AXMemoryCore sharedInstance].lastChangedValue != INFINITY)
        [[AXMemoryCore sharedInstance] changeValueInAddressListToValue:[AXMemoryCore sharedInstance].lastChangedValue];
      else
        fprintf(stderr, "no address was be registered\n");
    }
    
    else if(params.count == 1)
    {
      if (![AXMemoryCore sharedInstance].addressList.count)
      {
        fprintf(stderr, "no address was be registered\n");
      }
      else
      {
        [AXMemoryCore sharedInstance].lastChangedValue = [params[0] intValue];
        [[AXMemoryCore sharedInstance] changeValueInAddressListToValue:[AXMemoryCore sharedInstance].lastChangedValue];
      }
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
  return @"[c | change]\n"
          "\t\tchange addrees using the last changed value\n\n"
          "[c | change] value\n"
          "\t\tchange addrees using value\n\n"
          "[c | change] [addr] value\n"
          "\t\tchange a specific addrees to value\n\n"
          "[c | change] [range] start end value\n"
          "\t\tchange addrees list from start index to end index using value\n\n";
}

@end
