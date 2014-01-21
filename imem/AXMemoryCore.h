//
//  AXMemoryCore.h
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import <Foundation/Foundation.h>

@interface AXMemoryCore : NSObject

@property (readonly) NSArray* addressList;
@property (readonly) NSDictionary* aliasList;

- (id)initWithPid:(int) aPid;
- (void)setPid:(int) aPid;
- (NSArray*)searchForIntValue:(int)val;
- (NSArray*)searchForString:(const char*)key;
- (BOOL)changeValueInAddressListToIntValue:(int)var;
- (BOOL)changeToIntValue:(int)var forAddress:(int)addr;
- (void)resetAddressList;
- (BOOL)setAlias:(NSString*)name forAddresses:(NSArray*)addresses;
- (int)intValueForAddress:(int)addr;

@end
