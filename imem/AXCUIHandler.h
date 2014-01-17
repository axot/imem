//
//  AXCUIHandler.h
//  
//
//  Created by Zheng Shao on 1/14/14.
//
//

#import <Foundation/Foundation.h>

@class AXCUIHandler;
@protocol AXCUIHandlerDelegate <NSObject>

@optional
- (void)changeCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler;
- (void)searchCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler;
- (void)changesearchCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler;
- (void)aliasCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler;
- (void)listCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler;
- (void)resetCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler;
- (void)userCommandNotification:(NSString*)command Parameters:(NSArray*)params Handler:(AXCUIHandler*)handler;

@end

@interface AXCUIHandler : NSObject

@property (assign, nonatomic) id <AXCUIHandlerDelegate> delegate;

+ (AXCUIHandler*)sharedManager;
- (void)startHandler;
- (NSString*)askUserAnwserWithString:(NSString*)line;

@end
