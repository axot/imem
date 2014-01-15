//
//  main.m
//  imem
//
//  Created by Zheng Shao on 1/13/14.
//  Copyright (c) 2014 axot.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXCUIHandler.h"
#import "AXProcessCenter.h"

#pragma mark -- Main entry

int main(int argc, const char * argv[])
{
  @autoreleasepool
  {
    printf("imem v0.1 20140215 by Zheng SHAO @axot\n\n");

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
    
    AXProcessCenter* center = [[AXProcessCenter alloc] initWithPid:atol(argv[1])];
    AXCUIHandler* handler = [AXCUIHandler sharedManager];
    handler.delegate = center;
    [handler startHandler];
  }
  return 0;
}
