//
//  AXCUIHandler.m
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import "AXCUIHandler.h"
#include <readline/readline.h>
#include <readline/history.h>

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

@end

@implementation AXCUIHandler

+ (AXCUIHandler*)sharedManager
{
  static AXCUIHandler* sharedSingleton;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedSingleton = [[AXCUIHandler alloc] initSharedInstance];
  });
  
  return sharedSingleton;
}

- (id)initSharedInstance
{
  self = [super init];
  if (self)
  {
    // custom
  }
  return self;
}

- (id)init
{
  return nil;
}

#pragma mark -- public methods

- (void)startHandler
{
  char *buf = NULL;
  char *line;
  
  while (YES)
  {
    buf = readline("imem> ");
    
    // ctrl-d
    if(!buf)
    {
      printf("\n");
      continue;
    }
    
    line = stripwhite(buf);
    if (*line)
    {
      add_history(line);
      NSArray *items = [[NSString stringWithUTF8String:line] componentsSeparatedByString:@" "];
      id charset = [NSCharacterSet whitespaceAndNewlineCharacterSet];
      
      NSString* trimed = [items[0] stringByTrimmingCharactersInSet:charset];
      
      if ([trimed isEqualToString:@"c"] || [trimed isEqualToString:@"change"])
      {
        if (items.count == 1)
        {
          if ([self.delegate respondsToSelector:@selector(changeCommandNotification:Parameters:Handler:)])
          {
            NSArray* params = @[];
            [self.delegate changeCommandNotification:@"Change" Parameters:params Handler:self];
          }
        }
        else if (items.count == 2)
        {
          if ([self.delegate respondsToSelector:@selector(changeCommandNotification:Parameters:Handler:)])
          {
            NSArray* params = @[items[1]];
            [self.delegate changeCommandNotification:@"Change" Parameters:params Handler:self];
          }
        }
        // change a to b in all results
        else if (items.count == 3)
        {
          if ([self.delegate respondsToSelector:@selector(changeCommandNotification:Parameters:Handler:)])
          {
            NSArray* params = @[items[1], items[2]];
            [self.delegate changeCommandNotification:@"Change" Parameters:params Handler:self];
          }
        }
        
      }
      else if ([trimed isEqualToString:@"cs"] || [trimed isEqualToString:@"changeSearch"])
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
          if ([self.delegate respondsToSelector:@selector(searchCommandNotification:Parameters:Handler:)])
          {
            NSArray* params = @[];
            [self.delegate searchCommandNotification:@"Search" Parameters:params Handler:self];
          }
        }
        // search a value
        if (items.count == 2)
        {
          if ([self.delegate respondsToSelector:@selector(searchCommandNotification:Parameters:Handler:)])
          {
            NSArray* params = @[items[1]];
            [self.delegate searchCommandNotification:@"Search" Parameters:params Handler:self];
          }
        }
      }
      else if ([trimed isEqualToString:@"a"] || [trimed isEqualToString:@"alias"])
      {
        // show all alias
        if (items.count == 1)
        {
          if ([self.delegate respondsToSelector:@selector(aliasCommandNotification:Parameters:Handler:)])
          {
            NSArray* params = @[];
            [self.delegate aliasCommandNotification:@"Alias" Parameters:params Handler:self];
          }
        }
        // set a alias
        else if (items.count == 2)
        {
          if ([self.delegate respondsToSelector:@selector(aliasCommandNotification:Parameters:Handler:)])
          {
            NSArray* params = @[items[1]];
            [self.delegate aliasCommandNotification:@"Alias" Parameters:params Handler:self];
          }
        }
        
        // not implement
        else if (items.count > 2)
        {
          
        }
      }
      else if ([trimed isEqualToString:@"l"] ||
               [trimed isEqualToString:@"ls"] ||
               [trimed isEqualToString:@"list"])
      {
        // show current address list
        if (items.count == 1)
        {
          if ([self.delegate respondsToSelector:@selector(listCommandNotification:Parameters:Handler:)])
          {
            [self.delegate listCommandNotification:@"List" Parameters:@[] Handler:self];
          }
        }
      }
      else if ([trimed isEqualToString:@"r"] || [trimed isEqualToString:@"reset"])
      {
        // reset last address list
        if (items.count == 1)
        {
          if ([self.delegate respondsToSelector:@selector(resetCommandNotification:Parameters:Handler:)])
          {
            [self.delegate resetCommandNotification:@"Reset" Parameters:@[] Handler:self];
          }
        }
      }
      else if ([trimed isEqualToString:@"help"])
      {
        // TODO
        fprintf(stderr, "command description");
      }
      else if ([trimed isEqualToString:@"q"] ||
               [trimed isEqualToString:@"quit"])
      {
        exit(EXIT_SUCCESS);
      }
      else
      {
        if ([self.delegate respondsToSelector:@selector(userCommandNotification:Parameters:Handler:)])
        {
          NSArray* params =
            [items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, items.count-1)]];
          
          [self.delegate userCommandNotification:trimed Parameters:params Handler:self];
        }
      }
    }
    free(buf);
  }
}

- (NSString*)askUserAnwserWithString:(NSString*)line
{
  char *buf = readline([line UTF8String]);
  
  // ctrl-d
  if(!buf)
  {
    printf("\n");
  }
  
  char* stripedLine = stripwhite(buf);
  if (*stripedLine)
  {
    NSString* ans = [NSString stringWithUTF8String:stripedLine];
    free(stripedLine);
    return ans;
  }
  return @"";
}

@end
