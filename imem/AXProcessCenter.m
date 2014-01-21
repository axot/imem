//
//  AXProcessCenter.m
//  imem
//
//  Created by Zheng Shao on 1/15/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXProcessCenter.h"
#import "AXMemoryCore.h"

#define DEBUG_INFO

@interface NSString (NSAddition);
-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end;
@end

@implementation NSString (NSAddition)
-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end {
  NSScanner* scanner = [NSScanner scannerWithString:self];
  [scanner setCharactersToBeSkipped:nil];
  [scanner scanUpToString:start intoString:NULL];
  if ([scanner scanString:start intoString:NULL]) {
    NSString* result = nil;
    if ([scanner scanUpToString:end intoString:&result]) {
      return result;
    }
  }
  return nil;
}
@end

@interface AXProcessCenter()

@property (nonatomic) int lastSearchedValue;
@property (nonatomic) int lastChangedValue;

@end

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
    
    _lastSearchedValue = INFINITY;
    _lastChangedValue = INFINITY;
  }
  return self;
}

- (id)init
{
  return nil;
}

#pragma mark -- AXCUIHandlerDelegate
- (void)changeCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler
{
  printf("%s command", [command UTF8String]);
  if(params.count == 2)
  {
    // reset for search
    [self.memProcessor resetAddressList];
    printf(", changing %d to %d\n", [params[0] intValue], [params[1] intValue]);
    NSArray* addrs = [self.memProcessor searchForIntValue:[params[0] intValue]];
    
    // reset for change
    [self.memProcessor resetAddressList];

    self.lastSearchedValue = [params[0] intValue];
    self.lastChangedValue = [params[1] intValue];
    int i = 0;
    
    for (NSNumber* addr in addrs)
    {
      NSString *quest, *ans;
      printf("\n");
START:
      quest = [NSString stringWithFormat:@"[%d] 0x%08lx [y/n/a(bort)]: default no: ", i, addr.unsignedLongValue];
      ++i;

      ans = [handler askUserAnwserWithString:quest];

      if([ans isEqualToString:@"y"])
      {
        [self.memProcessor changeToIntValue:[params[1] intValue] forAddress:addr.unsignedLongValue];
        self.lastChangedValue = [params[1] intValue];
      }
      else if([ans isEqualToString:@"a"])
        return;
      else if([ans isEqualToString:@""] || [ans isEqualToString:@"n"])
        continue;
      else
        goto START;
    }
  }
  
  else if(params.count == 0)
  {
    printf("\n");
    if(self.lastChangedValue != INFINITY)
      [self.memProcessor changeValueInAddressListToIntValue:self.lastChangedValue];
    else
      fprintf(stderr, "no address was be registered\n");
  }
  
  else if(params.count == 1)
  {
    printf("\n");
    if (!self.memProcessor.addressList.count)
    {
      fprintf(stderr, "no address was be registered\n");
    }
    else
    {
      self.lastChangedValue = [params[0] intValue];
      [self.memProcessor changeValueInAddressListToIntValue:self.lastChangedValue];
    }
  }
  printf("\n");
}

- (void)searchCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler
{
  printf("%s command\n", [command UTF8String]);
  
  NSArray* resultList = nil;
  if(params.count == 0)
  {
    if (self.lastSearchedValue == INFINITY)
      fprintf(stderr, "you need search first\n");
    else
      resultList = [self.memProcessor searchForIntValue:self.lastSearchedValue];
  }
  else if(params.count == 1)
  {
    if ([params[0] hasPrefix:@"\""])
    {
#ifdef DEBUG_INFO
      NSLog(@"searching for string: %@", [params[0] stringBetweenString:@"\"" andString:@"\""]);
#endif
      resultList = [self.memProcessor searchForString:[params[0] stringBetweenString:@"\"" andString:@"\""].UTF8String];
    }
    else
    {
      resultList = [self.memProcessor searchForIntValue:[params[0] intValue]];
      self.lastSearchedValue = [params[0] intValue];
    }
  }
  
  if(resultList != nil)
  {
    int i = 0;
    for (NSNumber* addr in resultList)
    {
      printf("[%d] 0x%08lx\n", i, addr.unsignedLongValue);
      ++i;
    }
  }
  printf("\n");
}

- (void)changesearchCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler
{
  printf("%s command\n", [command UTF8String]);

}

- (void)aliasCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler
{
  if (params.count == 0)
  {
    for(NSString* name in self.memProcessor.aliasList)
    {
      printf("%s\n", name.UTF8String);
    }
  }
  else if(params.count == 1)
  {
    [self.memProcessor setAlias:params[0] forAddresses:self.memProcessor.addressList];
  }
  
  else if(params.count > 1)
  {
    NSLog(@"not implement yet");
  }
}

- (void)listCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler
{
  printf("%s command\n", [command UTF8String]);
  
  NSArray* addrs = [self.memProcessor addressList];
  int i = 0;
  for (NSNumber* addr in addrs)
  {
    printf("[%d] 0x%08x (%d)\n", i, addr.intValue, [self.memProcessor intValueForAddress:addr.unsignedLongValue]);
    ++i;
  }
}

- (void)resetCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler
{
  printf("%s command\n", [command UTF8String]);
  [self.memProcessor resetAddressList];
}

- (void)userCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler
{
  if (params.count == 0)
  {
    id values = self.memProcessor.aliasList[command];
    
    if (values)
    {
      int i = 0;
      for (NSNumber* addr in values)
      {
        printf("[%d] 0x%08x (%d)\n", i, addr.intValue, [self.memProcessor intValueForAddress:addr.intValue]);
        ++i;
      }
    }
    else
    {
      fprintf(stderr, "command not found\n");
    }
  }
  
  else if (params.count == 1)
  {
    id values = self.memProcessor.aliasList[command];
    if (values)
    {
      for (NSNumber* addr in values)
      {
        printf("0x%08x", addr.intValue);
        [self.memProcessor changeToIntValue:[params[0] intValue] forAddress:addr.unsignedLongValue];
      }
    }
    else
    {
      fprintf(stderr, "command not found\n");
    }
  }
  
  else
  {
    NSLog(@"not implement yet");
  }
}

@end
