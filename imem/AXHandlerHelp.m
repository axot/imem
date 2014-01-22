//
//  AXHandlderHelp.m
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXHandlerHelp.h"

@interface AXHandlerHelp()

@property (nonatomic) NSMutableArray* handlers;

@end

@implementation AXHandlerHelp

- (NSMutableArray*)handlers
{
  if(!_handlers)
  {
    _handlers = [NSMutableArray array];
  }
  return _handlers;
}

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params
{
  BOOL result = NO;

  for (id handlerHelp in self.handlers)
  {
    if ([[handlerHelp class] conformsToProtocol:@protocol(AXHandlerProtocol)])
    {
      result = [handlerHelp handlerCommand:command withParameters:params withSuperHelper:self] ? YES : result;
    }
  }
  
  return result;
}

- (BOOL)setHandler:(AXHandlerHelp*)handler
{
  [self.handlers addObject:handler];
  return YES;
}

- (NSString*)handlerDescription
{
  NSMutableString* descr = [NSMutableString string];

  for (id handlerHelp in self.handlers)
  {
    if ([handlerHelp isKindOfClass:[AXHandlerHelp class]])
    {
      [descr appendString:[handlerHelp handlerDescription]];
    }
  }
  return descr;
}

@end
