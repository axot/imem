//
//  AXMemoryCore.m
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

//#define DEBUG_INFO_MEMORYCORE

#import "AXMemoryCore.h"
#include <stdlib.h>
#include <stdio.h>
#include <mach/mach.h>
#include <unistd.h>

//#define DEBUG_INFO

@interface AXMemoryCore()

@property (nonatomic, readwrite) NSMutableArray* addressList;
@property (nonatomic, readwrite) NSMutableDictionary* aliasList;
@property (nonatomic) task_t task;
@property (nonatomic) pid_t pid;

- (task_t)getTaskForPid:(pid_t)aPid;
- (BOOL)searchRegionHasPrivilege:(vm_prot_t)pri
                       withBlock:(void (^)(vm_address_t offset, mach_msg_type_number_t size, char *buf))block;

@end

@implementation AXMemoryCore

//@synthesize addressList = _addressList;
//@synthesize aliasList = _aliasList;

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
    _addressList = [[NSMutableArray alloc] init];
    _aliasList = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (task_t)getTaskForPid:(pid_t)aPid
{
  kern_return_t kr;
  
  kr = task_for_pid(mach_task_self(), aPid, &_task);
  if (kr != KERN_SUCCESS)
  {
    NSLog(@"task_for_pid failed, the pid may not valid\n");
    exit(-1);
  }
  
  return _task;
}

- (BOOL)changeValueInAddressListToIntValue:(int)var
{
  kern_return_t kr;
  
  for ( NSNumber* addr in self.addressList )
  {
    kr = vm_write(self.task, addr.intValue, (vm_offset_t)&var, sizeof(int));
    
    if (kr != KERN_SUCCESS)
    {
      printf("0x%x write error.\n", addr.intValue);
      continue;
    }
    printf("0x%x write ok.\n", addr.intValue);
  }
  return YES;
}

- (BOOL)changeToIntValue:(int)var forAddress:(int)addr
{
  kern_return_t kr;
  
  kr = vm_write(self.task, addr, (vm_offset_t)&var, sizeof(int));
  
  if (kr != KERN_SUCCESS)
  {
    printf(" write error.\n");
    return NO;
  }
  
  if ([self.addressList indexOfObject:@(addr)] == NSNotFound )
  {
    [(NSMutableArray *)self.addressList addObject:@(addr)];
  }
  printf(" write ok.\n");
  return YES;
}

- (BOOL)setAlias:(NSString*)name forAddresses:(NSArray*)addresses
{
  [(NSMutableDictionary *)self.aliasList setObject:[NSArray arrayWithArray:addresses]
                                            forKey:name];
  return YES;
}

- (NSArray*)searchForIntValue:(int)tVar
{
  if (self.addressList.count)
  {
    for ( NSNumber* addr in [self.addressList reverseObjectEnumerator] )
    {
      if ([self intValueForAddress:addr.intValue] != tVar)
      {
        [(NSMutableArray *)self.addressList removeObject:addr];
      }
    }
  }
  else
  {
    [self searchRegionHasPrivilege:VM_PROT_READ | VM_PROT_WRITE
                         withBlock:^(vm_address_t offset, mach_msg_type_number_t size, char *buf) {
                           for (size_t i = 0; i < size; i += sizeof(int))
                           {
                             int val = *(int*)((vm_address_t)buf+i);
                             if(val == tVar)
                             {
                               [(NSMutableArray *)self.addressList addObject:@(offset+i)];
                             }
                           }
                         }];
  }
  return [NSArray arrayWithArray:self.addressList];
}

- (NSArray*)searchForString:(const char*)key
{
  [self searchRegionHasPrivilege:VM_PROT_READ | VM_PROT_WRITE
                       withBlock:^(vm_address_t offset, mach_msg_type_number_t size, char *buf) {
#ifdef DEBUG_INFO
                         NSLog(@"search region: %x", offset);
#endif
                         int len = strlen(key);
                         for (size_t i = 0; i < size-len+1; i++)
                         {
                           
                           char* addr = (char*)((vm_address_t)buf+i);
                           if(strncmp(key, addr, len) == 0)
                           {
#ifdef DEBUG_INFO
                             NSLog(@"found: %x", (vm_address_t)addr);
#endif
                             [(NSMutableArray *)self.addressList addObject:@(offset+i)];
                           }
                         }
                       }];
  return [NSArray arrayWithArray:self.addressList];
}

- (void)resetAddressList
{
  [(NSMutableArray *)self.addressList removeAllObjects];
}

- (BOOL)searchRegionHasPrivilege:(vm_prot_t)pri
                       withBlock:(void (^)(vm_address_t offset, mach_msg_type_number_t size, char *buf))block
{
  kern_return_t kr;
  
  mach_msg_type_number_t region_size = 0;
  vm_region_basic_info_data_t info;
  mach_msg_type_number_t infoCnt;
  mach_port_t objname;
  
  vm_address_t region_addr = 1;
  while((size_t)region_addr != 0)
  {
    region_addr += region_size;
    
    kr = vm_region(self.task,
                   &region_addr,
                   &region_size,
                   VM_REGION_BASIC_INFO,
                   (vm_region_info_t)&info,
                   &infoCnt,
                   &objname);
    
    if (kr != KERN_SUCCESS)
    {
#ifdef DEBUG_INFO
      fprintf(stderr, "vm_region failed for address: 0x%x err: %d\n", region_addr, kr);
#endif
      return NO;
    }
    
    if(info.protection != pri)
      continue;
    
    char *region_buf = (char*)malloc(region_size);
    
    vm_size_t count;
    
    kr = vm_read_overwrite(self.task,
                           region_addr,
                           region_size,
                           (vm_offset_t)region_buf,
                           &count);
    
    if (kr != KERN_SUCCESS)
    {
#ifdef DEBUG_INFO
      fprintf(stderr, "vm_read_overwrite failed for address: 0x%x err: %d\n", region_addr, kr);
#endif
      free(region_buf);
      return NO;
    }
    
    block(region_addr, region_size, region_buf);
    free(region_buf);
  }
  
  return YES;
}

- (int)intValueForAddress:(int)addr
{
  kern_return_t kr;
  
  mach_msg_type_number_t region_size = 0;
  vm_region_basic_info_data_t info;
  mach_msg_type_number_t infoCnt;
  mach_port_t objname;
  
  vm_address_t region_addr = addr;
  
  kr = vm_region(self.task,
                 &region_addr,
                 &region_size,
                 VM_REGION_BASIC_INFO,
                 (vm_region_info_t)&info,
                 &infoCnt,
                 &objname);
  
  if(kr == KERN_SUCCESS && info.protection & VM_PROT_READ)
  {
    char *ragion_buf = (char*)malloc(region_size);
    vm_size_t count;
    
    kr = vm_read_overwrite(self.task,
                            region_addr,
                            region_size,
                            (vm_offset_t)ragion_buf,
                            &count);
    
    if (kr == KERN_SUCCESS)
    {
      int val = *(int*)(ragion_buf+addr-region_addr);
      free(ragion_buf);
      return val;
    }
    free(ragion_buf);
  }
  return INFINITY;
}
@end
