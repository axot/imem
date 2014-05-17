//
//  AXCUIHandler.m
//
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import "AXCUIHandler.h"
#import <readline/readline.h>
#import <readline/history.h>
#import "AXHandlerHelp.h"
#import "AXChangeCommandHandlerBase.h"
#import "AXSearchCommandHandlerBase.h"
#import "AXAliasCommandHandlerBase.h"
#import "AXUserDefinedAliasCommandHandler.h"
#import "AXListCommandHandlerBase.h"
#import "AXResetCommandHandlerBase.h"
#import "AXHelpCommandHandlerBase.h"
#import "AXQuitCommandHandlerBase.h"
#import "AXTypeCommandHandlerBase.h"
#import "AXPrintCommandHandlerBase.h"
#import "AXMemoryCore.h"

/* Strip whitespace from the start and end of STRING.  Return a pointer
 into STRING. */
char *stripwhite(char *string)
{
    register char *s, *t;
    
    for (s = string; whitespace (*s); s++)
        ;
    
    if (*s == 0)
        return (s);
    
    t = s + strlen (s) - 1;
    while (t > s && whitespace (*t))
        t--;
    *++t = '\0';
    
    return s;
}

@interface AXCUIHandler()

@property (nonatomic) AXHandlerHelp* handlerHelp;
@property (nonatomic) AXMemoryCore* memProcessor;

@end

@implementation AXCUIHandler

#pragma mark -- public methods

- (AXCUIHandler*)initWithPid:(NSUInteger)pid
{
    self = [super init];
    if (self)
    {
        _memProcessor = [AXMemoryCore sharedInstance];
        [_memProcessor setPid:pid];
        
        _handlerHelp = [[AXHandlerHelp alloc] init];
        
        id handler = [[AXChangeCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = [[AXSearchCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = [[AXAliasCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = [[AXUserDefinedAliasCommandHandler alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = [[AXListCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = [[AXResetCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = [[AXTypeCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];

        handler = [[AXHelpCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = [[AXQuitCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = [[AXPrintCommandHandlerBase alloc] init];
        [_handlerHelp setHandler:handler];
        
        handler = nil;
    }
    return self;
}

- (AXCUIHandler*)init
{
    return nil;
}

- (void)startHandler
{
    char *buf = NULL;
    char *line;
    
    while (YES)
    {
        buf = readline("imem> ");
        if(!buf)
        {
            exit(EXIT_SUCCESS);
        }
        
        line = stripwhite(buf);
        if (*line)
        {
            add_history(line);
            NSArray *items = [[NSString stringWithUTF8String:line] componentsSeparatedByString:@" "];
            id charset = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            
            NSString* command = [items[0] stringByTrimmingCharactersInSet:charset];
            NSArray* params =
            [items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, items.count-1)]];
            
            [self.handlerHelp handlerCommand:command withParameters:params];
        }
    }
}

@end
