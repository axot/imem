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
@property (nonatomic, readonly) int typeLength;

+ (AXMemoryCore*)sharedInstance;
- (void)setPid:(NSUInteger)aPid;
- (NSArray*)searchForValue:(int)val;
- (NSArray*)searchForIntValue:(int)val __attribute__((deprecated));

- (NSArray*)searchForString:(const char*)key;

- (BOOL)changeValueInAddressListToValue:(int)var;
- (BOOL)changeValueInAddressListToIntValue:(int)var __attribute__((deprecated));

- (BOOL)changeToValue:(int)var forAddress:(size_t)addr;
- (BOOL)changeToIntValue:(int)var forAddress:(size_t)addr __attribute__((deprecated));

- (void)resetAddressList;
- (BOOL)setAlias:(NSString*)name forAddresses:(NSArray*)addresses;
- (void)setTypeLength:(int)length;

- (int)valueForAddress:(size_t)addr;
- (int)intValueForAddress:(size_t)addr __attribute__((deprecated));

@end
