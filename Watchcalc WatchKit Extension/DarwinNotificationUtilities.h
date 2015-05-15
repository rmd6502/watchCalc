//
//  DarwinNotificationUtilities.h
//  WatchSciCalc
//
//  Created by Diamond, Robert on 4/10/15.
//

#import <Foundation/Foundation.h>

@interface DarwinNotificationCenter : NSObject

- (id)addObserver:(NSObject *)observer selector:(SEL)aSelector name:(NSString *)aName userInfo:(NSDictionary *)userInfo;
- (void)removeObserver:(id)observer;

@end
