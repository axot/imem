//
//  AXPrintCommandHandlerBase.m
//  imem
//
//  Created by Zheng Shao on 5/16/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import "AXPrintCommandHandlerBase.h"

@implementation AXPrintCommandHandlerBase

- (BOOL)handlerCommand:(NSString*)command withParameters:(NSArray*)params withSuperHelper:(AXHandlerHelp *)help
{
    if (command == nil)  command = @"";
    if (params == nil)  params = @[];
    
    if ([command isEqualToString:@"p"] || [command isEqualToString:@"print"])
    {
        // print 1 type of memory
        if (params.count == 1)
        {
            unsigned offset;
            
            if ([params[0] hasPrefix:@"0x"])
            {
                NSScanner* scanner = [NSScanner scannerWithString:params[0]];
                [scanner scanHexInt:&offset];
            }
            else offset = (unsigned int)[params[0] longLongValue];

            int value = [[AXMemoryCore sharedInstance] valueForAddress:offset];
            printf("0x%08x: %d\n", offset, value);
        }
        
        // print length type of memory
        else if (params.count == 2)
        {
            unsigned offset;
            int length = [params[1] intValue];
            
            if ([params[0] hasPrefix:@"0x"])
            {
                NSScanner* scanner = [NSScanner scannerWithString:params[0]];
                [scanner scanHexInt:&offset];
            }
            else offset = (unsigned int)[params[0] longLongValue];
            
            AXMemoryCore* memcore = [AXMemoryCore sharedInstance];
            for (int i = 0; i < length;)
            {
                printf("0x%08x: ", offset + i*memcore.typeLength);
                for (int j = 0; j < 4; ++j, ++i)
                {
                    int value = [memcore valueForAddress:offset + i*memcore.typeLength];
                    printf("%16d ", value);
                }
                printf("\n");
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
    return @"[p | print] offset\n"
    "\t\tprint memory as int value\n\n"
    "[p | print] offset length\n"
    "\t\tprint length type of memory as int value\n\n";
}

@end
