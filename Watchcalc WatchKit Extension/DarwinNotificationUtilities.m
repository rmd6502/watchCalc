//
//  DarwinNotificationUtilities.m
//  WatchSciCalc
//
//  Created by Diamond, Robert on 4/10/15.
//

#import "DarwinNotificationUtilities.h"

@interface DarwinNotificationCenter ()

@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSObject *observer;
@property (nonatomic) CFNotificationCenterRef notificationCenter;
@property (nonatomic) NSString *name;
@property (nonatomic) SEL aSelector;
- (void)handleNotification:(NSString *)name;

@end

void notificationCallback( CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo )
{
    DarwinNotificationCenter *nsObserver = (__bridge DarwinNotificationCenter *)observer;
    [nsObserver handleNotification:(__bridge NSString *)(name)];
}

@implementation DarwinNotificationCenter

- (instancetype)init
{
    if (self = [super init]) {
        self.notificationCenter = CFNotificationCenterGetDarwinNotifyCenter();
    }
    return self;
}

- (void)dealloc
{
    CFNotificationCenterRemoveObserver(self.notificationCenter, (__bridge const void *)(self), nil, nil);
}

- (id)addObserver:(NSObject *)observer selector:(SEL)aSelector name:(NSString *)aName userInfo:(NSDictionary *)userInfo
{
    CFNotificationCenterAddObserver(self.notificationCenter, (__bridge const void *)(self), notificationCallback, (CFStringRef)aName, nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    self.observer = observer;
    self.aSelector = aSelector;
    self.userInfo = userInfo;
    self.name = aName;
    return aName;
}

- (void)removeObserver:(id)observer
{
    CFNotificationCenterRemoveObserver(self.notificationCenter, (__bridge const void *)(self), (CFStringRef)self.name, nil);
}

- (void)handleNotification:(NSString *)name
{
    IMP imp = [self.observer methodForSelector:self.aSelector];
    ((void (*)(id, SEL, NSDictionary *))imp)(self.observer, self.aSelector, self.userInfo);
}

@end
