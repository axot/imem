//
//  AXMemoryCore.m
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import "AXMemoryCore.h"
#include <stdlib.h>
#include <stdio.h>
#include <mach/mach.h>
#include <unistd.h>

@interface AXMemoryCore()

@property (strong, nonatomic) NSMutableArray* addressList;
@property (strong, nonatomic) NSMutableDictionary* aliasList;
@property (assign, nonatomic) task_t task;
@property (assign, nonatomic) pid_t pid;

- (task_t)getTaskForPid:(pid_t)aPid;
- (BOOL)setAlias:(NSString*)name forAddresses:(NSArray*)addresses;

@end

@implementation AXMemoryCore

- (NSMutableArray*)addressList
{
  if(!_addressList)
  {
    _addressList = [NSMutableArray arrayWithCapacity:64];
  }
  return _addressList;
}

- (NSMutableDictionary*)aliasList
{
  if(_aliasList)
  {
    _aliasList = [NSMutableDictionary dictionaryWithCapacity:64];
  }
  return _aliasList;
}

- (void)setPid:(int)aPid
{
  _pid = aPid >= 0 ? aPid : -1;
}

- (id)initWithPid:(int)aPid
{
  // Make sure we're root
  if(getuid() && geteuid())
  {
    fprintf(stderr, "error: requires root.");
    return self;
  }
  
  self = [super init];
  if(self)
  {
    self.pid = aPid;
    self.task = [self getTaskForPid:self.pid];
  }
  return self;
}

- (task_t)getTaskForPid:(pid_t)aPid
{
  kern_return_t kr;
  
  kr = task_for_pid(mach_task_self(), aPid, &_task);
  if (kr != KERN_SUCCESS)
  {
    NSLog(@"task_for_pid failed\n");
    exit(-1);
  }
  
  return _task;
}

- (BOOL)changeValue:(int)aVar forTargetValue:(int)tVar
{
  kern_return_t kr;
  
  mach_msg_type_number_t region_size = sizeof(int);
  int _basic[VM_REGION_BASIC_INFO_COUNT];
  vm_region_basic_info_t basic = (vm_region_basic_info_t)_basic;
  mach_msg_type_number_t infocnt;
  infocnt = VM_REGION_BASIC_INFO_COUNT;
  mach_port_t objname;
  
  vm_address_t region_addr = 0x10000 - region_size;
  while(region_addr < 0x40000000 - region_size)
  {
    region_addr += region_size;
    
    kr = vm_region(self.task,
                   &region_addr,
                   &region_size,
                   VM_REGION_BASIC_INFO,
                   (vm_region_info_t)basic,
                   &infocnt,
                   &objname);
    
    if (kr != KERN_SUCCESS)
    {
      fprintf(stderr, "vm_region failed for address: 0x%x err: %d\n", region_addr, kr);
      continue;
    }
    
    if(basic->protection != (VM_PROT_READ | VM_PROT_WRITE))
      continue;
    
    char *ragion_buf = (char*)malloc(region_size);
    
    vm_size_t count;

    kr = vm_read_overwrite(self.task,
                           region_addr,
                           region_size,
                           (vm_offset_t)ragion_buf,
                           &count);

    if (kr != KERN_SUCCESS)
    {
      fprintf(stderr, "vm_read_overwrite failed for address: 0x%x err: %d\n", region_addr, kr);
      continue;
    }
    
    for (size_t i = 0; i < region_size; i += sizeof(int))
    {
      int val = *(int*)((size_t)ragion_buf+i);
      if(val == tVar)
      {
        printf("addr:0x%lx old:%i new: %i", region_addr+i, tVar, aVar);
        kr = vm_write(self.task, region_addr+i, (vm_offset_t)&aVar, sizeof(int));
        
        if (kr != KERN_SUCCESS)
        {
          printf(" write error.\n");
          continue;
        }
        printf(" write ok.\n");
      }
    }
    free(ragion_buf);
  }
  return NO;
}

- (BOOL)setAlias:(NSString*)name forAddresses:(NSArray*)addresses
{
  [self.aliasList setObject:addresses forKey:name];
  return NO;
}

@end
