//
//  NSString+Stripped.m
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "NSString+Stripped.h"

@implementation NSString (Stripped)

- (NSString*)stringBetweenString:(NSString*)delimeter
{
  return [self stringBetweenString:delimeter andString:delimeter];
}

- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end
{
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
