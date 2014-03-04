//
//  main.m
//  imem
//
//  Created by Zheng Shao on 1/13/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXCUIHandler.h"

#pragma mark -- Main entry

#define __VER__ "v0.3"

int main(int argc, const char * argv[])
{
  @autoreleasepool
  {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    /*
      G       時代(AD等)
      yy      年（下２桁）
      yyyy    年（４桁）
      MM      月（１〜１２）
      MMM     月（Jan）
      MMMM    月（Janualy）
      dd      日（２桁）
      H       時（ゼロ埋めなし）
      HH      時（２桁、ゼロ埋めあり）
      m       時（ゼロ埋めなし）
      mm      時（２桁、ゼロ埋めあり）
      s       時（ゼロ埋めなし）
      ss      時（２桁、ゼロ埋めあり）
      z       タイムゾーン
     */
    
    // __DATE__ Jan 18 2014
    // __TIME__ 15:38:05
    [df setDateFormat:@"MM dd yyyy HH:mm:ss"];
    NSDate* now = [df dateFromString:[NSString stringWithFormat:@"%s %s", __DATE__, __TIME__]];
    
    [df setDateFormat:@"yyyy/MM/dd HH:mm:ss z"];
    printf("imem %s by Zheng SHAO(@axot) at %s\n", __VER__, [df stringFromDate:now].UTF8String);

    if(argc != 2)
    {
      fprintf(stderr, "usage: \n%s pid\n", argv[0]);
      exit(-1);
    }
    
    int pid = atol(argv[1]);
    
    if (pid <= 0)
    {
      fprintf(stderr, "wrong pid number\n");
      exit(-2);
    }
    
    printf("Attaching Process ID: %d\n\n", pid);
    AXCUIHandler* handler = [[AXCUIHandler alloc] initWithPid:pid];
    [handler startHandler];
  }
  return 0;
}
