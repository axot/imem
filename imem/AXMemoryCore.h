//
//  AXMemoryCore.h
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import <Foundation/Foundation.h>

@interface AXMemoryCore : NSObject

- (id)initWithPid:(int) aPid;
- (void)setPid:(int) aPid;
- (NSArray*)searchForIntValue:(int)val;
- (BOOL)changeValueInAddressListToIntValue:(int)var;
- (BOOL)changeToIntValue:(int)var forAddress:(int)addr;
- (void)resetAddressList;
- (NSArray*)getAddressList;
- (BOOL)setAlias:(NSString*)name forAddresses:(NSArray*)addresses;
- (NSDictionary*)getAliasList;
- (int)intValueForAddress:(int)addr;

@end
