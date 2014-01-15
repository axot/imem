//
//  AXCUIHandler.h
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import <Foundation/Foundation.h>

@protocol AXCUIHandlerDelegate <NSObject>

@optional
- (void)changeCommandNotification:(NSString*)command Parameters:(NSArray*)params;
- (void)searchCommandNotification:(NSString*)command Parameters:(NSArray*)params;
- (void)changesearchCommandNotification:(NSString*)command Parameters:(NSArray*)params;
- (void)aliasCommandNotification:(NSString*)command Parameters:(NSArray*)params;
- (void)listCommandNotification:(NSString*)command Parameters:(NSArray*)params;
- (void)resetCommandNotification:(NSString*)command Parameters:(NSArray*)params;

@end

@interface AXCUIHandler : NSObject

@property (assign, nonatomic) id <AXCUIHandlerDelegate> delegate;

+ (AXCUIHandler*)sharedManager;
- (void)startHandler;

@end
