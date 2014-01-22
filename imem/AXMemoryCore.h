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
@property (nonatomic) int lastSearchedValue;
@property (nonatomic) int lastChangedValue;

+ (AXMemoryCore*)sharedInstance;
- (void)setPid:(NSUInteger)aPid;
- (NSArray*)searchForIntValue:(int)val;
- (NSArray*)searchForString:(const char*)key;
- (BOOL)changeValueInAddressListToIntValue:(int)var;
- (BOOL)changeToIntValue:(int)var forAddress:(size_t)addr;
- (void)resetAddressList;
- (BOOL)setAlias:(NSString*)name forAddresses:(NSArray*)addresses;
- (int)intValueForAddress:(size_t)addr;

@end
