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

@property (nonatomic, readwrite) NSMutableArray* addressList;
@property (nonatomic, readwrite) NSMutableDictionary* aliasList;
@property (nonatomic, readwrite) int typeLength;
@property (nonatomic) task_t task;
@property (nonatomic) NSUInteger pid;
@property (nonatomic) NSUInteger lastSearchedRegionAddr;
@property (nonatomic) NSUInteger lastSearchedRegionSize;
@property (nonatomic) char* lastSearchedBuffer;

- (BOOL)searchRegionHasPrivilege:(vm_prot_t)pri
                       withBlock:(void (^)(vm_address_t offset, mach_msg_type_number_t size, char *buf))block;

@end

@implementation AXMemoryCore

+ (AXMemoryCore*)sharedInstance
{
    static AXMemoryCore* memCoreShared;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        memCoreShared = [[AXMemoryCore alloc] initShareInstance];
    });
    return memCoreShared;
}

- (void)setPid:(NSUInteger)aPid
{
    _pid = aPid;
    kern_return_t kr;
    mach_port_name_t tmpTask;
    kr = task_for_pid(mach_task_self(), _pid, &tmpTask);
    if (kr != KERN_SUCCESS)
    {
#ifdef DEBUG_INFO
        NSLog(@"task_for_pid failed, the pid:%d may not valid, kr:%d\n", _pid, kr);
#endif
        exit(-1);
    }
    _task = tmpTask;
#ifdef DEBUG_INFO
    NSLog(@"task: %d\n", _task);
#endif
}

- (id)init
{
    return nil;
}

- (id)initShareInstance
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
        _addressList = [[NSMutableArray alloc] init];
        _aliasList = [[NSMutableDictionary alloc] init];
        _lastChangedValue = INFINITY;
        _lastSearchedValue = INFINITY;
        _typeLength = sizeof(int);
    }
    return self;
}

- (BOOL)changeValueInAddressListToValue:(int)var
{
    kern_return_t kr = KERN_FAILURE;
    
    for ( NSNumber* addr in self.addressList )
    {
        if (self.typeLength == sizeof(int))
        {
            kr = vm_write(self.task, addr.intValue, (vm_offset_t)&var, sizeof(int));
        }
        else if (self.typeLength == sizeof(short))
        {
            short sVar = (short)var;
            kr = vm_write(self.task, addr.intValue, (vm_offset_t)&sVar, sizeof(short));
        }
        
        if (kr != KERN_SUCCESS)
        {
            printf("0x%x write error.\n", addr.intValue);
            continue;
        }
        printf("0x%x write ok.\n", addr.intValue);
    }
    return YES;
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

- (BOOL)changeToValue:(int)var forAddress:(size_t)addr
{
    kern_return_t kr = KERN_FAILURE;
    
    if (self.typeLength == sizeof(int))
    {
        kr = vm_write(self.task, addr, (vm_offset_t)&var, sizeof(int));
    }
    else if (self.typeLength == sizeof(short))
    {
        short sVar = (short)var;
        kr = vm_write(self.task, addr, (vm_offset_t)&sVar, sizeof(short));
    }
    
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

- (BOOL)changeToIntValue:(int)var forAddress:(size_t)addr
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

- (void)setTypeLength:(int)length
{
    if (length >= 0)
    {
        _typeLength = length;
    }
}

- (NSArray*)searchForValue:(int)tVar
{
#ifdef DEBUG_INFO
    NSLog(@"searchForValue: %d", tVar);
#endif
    if (self.addressList.count)
    {
        NSMutableArray* objectsNeedBeRemove = [NSMutableArray array];
        for (NSNumber* addr in self.addressList)
        {
            if (self.typeLength == sizeof(int))
            {
                int curVal = [self valueForAddress:addr.unsignedLongValue];
                if (curVal != tVar)
                {
#ifdef DEBUG_INFO
                    NSLog(@"addr %08lx, current value: %d", addr.unsignedLongValue, [self valueForAddress:addr.unsignedLongValue]);
#endif
                    [objectsNeedBeRemove addObject:addr];
                }
            }
            else if (self.typeLength == sizeof(short))
            {
                short curVal = [self valueForAddress:addr.unsignedLongValue];
                if (curVal != tVar)
                {
#ifdef DEBUG_INFO
                    NSLog(@"addr %08lx, current value: %d", addr.unsignedLongValue, [self valueForAddress:addr.unsignedLongValue]);
#endif
                    [objectsNeedBeRemove addObject:addr];
                }

            }
            else
            {
                printf("length not support: %d, [avariable: %lu %lu]\n",
                       self.typeLength, sizeof(int), sizeof(short));
            }
        }
#ifdef DEBUG_INFO
        NSLog(@"%d were removed", objectsNeedBeRemove.count);
#endif
        [(NSMutableArray *)self.addressList removeObjectsInArray:objectsNeedBeRemove];
    }
    else
    {
        if (self.typeLength == sizeof(int))
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
        else if (self.typeLength == sizeof(short))
        {
            [self searchRegionHasPrivilege:VM_PROT_READ | VM_PROT_WRITE
                                 withBlock:^(vm_address_t offset, mach_msg_type_number_t size, char *buf) {
                                     for (size_t i = 0; i < size; i += sizeof(short))
                                     {
                                         short val = *(short*)((vm_address_t)buf+i);
                                         if(val == tVar)
                                         {
                                             [(NSMutableArray *)self.addressList addObject:@(offset+i)];
                                         }
                                     }
                                 }];
        }
        else
        {
            printf("length not support: %d, [avariable: %lu %lu]\n",
                   self.typeLength, sizeof(int), sizeof(short));
        }
    }
    return [NSArray arrayWithArray:self.addressList];
}

- (NSArray*)searchForIntValue:(int)tVar
{
#ifdef DEBUG_INFO
    NSLog(@"searchForIntValue: %d", tVar);
#endif
    if (self.addressList.count)
    {
        NSMutableArray* objectsNeedBeRemove = [NSMutableArray array];
        for (NSNumber* addr in self.addressList)
        {
            int curVal = [self intValueForAddress:addr.unsignedLongValue];
            if (curVal != tVar)
            {
#ifdef DEBUG_INFO
                NSLog(@"addr %08lx, current value: %d", addr.unsignedLongValue, [self intValueForAddress:addr.unsignedLongValue]);
#endif
                [objectsNeedBeRemove addObject:addr];
            }
        }
#ifdef DEBUG_INFO
        NSLog(@"%d were removed", objectsNeedBeRemove.count);
#endif
        [(NSMutableArray *)self.addressList removeObjectsInArray:objectsNeedBeRemove];
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
                             NSLog(@"search region: %08ux", offset);
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
    
    /* must set to >= VM_REGION_BASIC_INFO_COUNT
     * or will cause KERN_INVALID_ARGUMENT
     * ref vm_map_region function from: http://www.opensource.apple.com/source/xnu/xnu-792.13.8/osfmk/vm/vm_map.c
     */
    mach_msg_type_number_t infoCnt = VM_REGION_BASIC_INFO_COUNT;
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
            fprintf(stderr, "vm_region failed for address: 0x%x err: %d task: %d\n", region_addr, kr, self.task);
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
            fprintf(stderr, "vm_read_overwrite failed for address: 0x%x err: %d task: %d\n", region_addr, kr, self.task);
#endif
            free(region_buf);
            return NO;
        }
        
        block(region_addr, region_size, region_buf);
        free(region_buf);
    }
    
    return YES;
}

- (int)valueForAddress:(size_t)addr
{
    if (addr >= self.lastSearchedRegionAddr &&
        addr <= self.lastSearchedRegionAddr + self.lastSearchedRegionSize)
    {
        int val = INFINITY;
        size_t bufAddr = (size_t)self.lastSearchedBuffer+(size_t)addr-self.lastSearchedRegionAddr;
        
        if (self.typeLength == sizeof(int))
        {
            val = *(int*)(bufAddr);
        }
        else if (self.typeLength == sizeof(short))
        {
            val = *(short*)(bufAddr);
        }
        return val;
    }
    
    kern_return_t kr;
    
    mach_msg_type_number_t region_size = 0;
    vm_region_basic_info_data_t info;
    
    /* must set to >= VM_REGION_BASIC_INFO_COUNT
     * or will cause KERN_INVALID_ARGUMENT
     * ref vm_map_region function from: http://www.opensource.apple.com/source/xnu/xnu-792.13.8/osfmk/vm/vm_map.c
     */
    mach_msg_type_number_t infoCnt = VM_REGION_BASIC_INFO_COUNT;
    mach_port_t objname;
    
    vm_address_t region_addr = addr;
    
    kr = vm_region(self.task,
                   &region_addr,
                   &region_size,
                   VM_REGION_BASIC_INFO,
                   (vm_region_info_t)&info,
                   &infoCnt,
                   &objname);
    
    if (kr == KERN_SUCCESS)
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
            if(region_addr != self.lastSearchedRegionAddr)
            {
                if(self.lastSearchedBuffer) free(self.lastSearchedBuffer);
                self.lastSearchedBuffer = (char*)malloc(region_size);
                memcpy(self.lastSearchedBuffer, ragion_buf, region_size);
                self.lastSearchedRegionAddr = region_addr;
                self.lastSearchedRegionSize = region_size;
            }
            
            int val = INFINITY;
            
            if (self.typeLength == sizeof(int))
            {
                val = *(int*)((size_t)ragion_buf+(size_t)addr-region_addr);
            }
            else if (self.typeLength == sizeof(short))
            {
                val = *(short*)((size_t)ragion_buf+(size_t)addr-region_addr);
            }

            free(ragion_buf);
            return val;
        }
#ifdef DEBUG_INFO
        printf("vm_read_overwrite addr: 0x%08x err: %d task:%d\n", region_addr, kr, self.task);
#endif
        
        free(ragion_buf);
    }
    
#ifdef DEBUG_INFO
    printf("vm_region addr: 0x%08x err: %d task:%d\n", region_addr, kr, self.task);
#endif
    return INFINITY;
}

- (int)intValueForAddress:(size_t)addr
{
    if (addr >= self.lastSearchedRegionAddr &&
        addr <= self.lastSearchedRegionAddr + self.lastSearchedRegionSize)
    {
        int val = *(int*)((size_t)self.lastSearchedBuffer+(size_t)addr-self.lastSearchedRegionAddr);
        return val;
    }
    
    kern_return_t kr;
    
    mach_msg_type_number_t region_size = 0;
    vm_region_basic_info_data_t info;
    
    /* must set to >= VM_REGION_BASIC_INFO_COUNT
     * or will cause KERN_INVALID_ARGUMENT
     * ref vm_map_region function from: http://www.opensource.apple.com/source/xnu/xnu-792.13.8/osfmk/vm/vm_map.c
     */
    mach_msg_type_number_t infoCnt = VM_REGION_BASIC_INFO_COUNT;
    mach_port_t objname;
    
    vm_address_t region_addr = addr;
    
    kr = vm_region(self.task,
                   &region_addr,
                   &region_size,
                   VM_REGION_BASIC_INFO,
                   (vm_region_info_t)&info,
                   &infoCnt,
                   &objname);
    
    if (kr == KERN_SUCCESS)
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
            if(region_addr != self.lastSearchedRegionAddr)
            {
                if(self.lastSearchedBuffer) free(self.lastSearchedBuffer);
                self.lastSearchedBuffer = (char*)malloc(region_size);
                self.lastSearchedRegionAddr = region_addr;
                self.lastSearchedRegionSize = region_size;
            }
            int val = *(int*)((size_t)ragion_buf+(size_t)addr-region_addr);
            free(ragion_buf);
            return val;
        }
#ifdef DEBUG_INFO
        printf("vm_read_overwrite addr: 0x%08x err: %d task:%d\n", region_addr, kr, self.task);
#endif
        
        free(ragion_buf);
    }
    
#ifdef DEBUG_INFO
    printf("vm_region addr: 0x%08x err: %d task:%d\n", region_addr, kr, self.task);
#endif
    return INFINITY;
}
@end
