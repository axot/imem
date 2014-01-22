//
//  NSString+Stripped.h
//  imem
//
//  Created by Zheng Shao on 1/22/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Stripped)

- (NSString*)stringBetweenString:(NSString*)delimeter;
- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end;

@end
