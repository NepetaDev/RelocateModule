#import "RLCModuleViewController.h"
#import <Cephei/HBPreferences.h>

@implementation RLCModuleViewController

-(void)viewDidLayoutSubviews {
    if ([self isExpanded]) {
        [self setSelected:NO];
    } else {
        HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"me.nepeta.relocate"];
        [self setSelected:[([preferences objectForKey:@"Enabled"] ?: @(true)) boolValue]];
    }
    
    [super viewDidLayoutSubviews];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"me.nepeta.relocate"];
    [self setSelected:[([preferences objectForKey:@"Enabled"] ?: @(true)) boolValue]];
    
    [self removeAllActions];

    id obj = [preferences objectForKey:@"Favorites"];
    if (obj && [obj isKindOfClass:[NSArray class]]) {
        NSArray *favorites = obj;
        __weak id weakSelf = self;
        for (NSDictionary *favorite in favorites) {
            [self addActionWithTitle:favorite[@"Name"] glyph:nil handler:^() {
                [weakSelf setSelected:YES];
                [preferences setBool:YES forKey:@"Enabled"];

                NSMutableDictionary* globalLocation = [([preferences objectForKey:@"GlobalLocation"] ?: @{}) mutableCopy];
                globalLocation[@"Coordinate"] = @{
                    @"Latitude": favorite[@"Latitude"] ?: @(0),
                    @"Longitude": favorite[@"Longitude"] ?: @(0)
                };
                [preferences setObject:globalLocation forKey:@"GlobalLocation"];
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.nepeta.relocate/ReloadPrefs", nil, nil, true);
            }];
        }
    }
}

-(void)buttonTapped:(id)arg1 forEvent:(id)arg2 {
    BOOL newState = ![self isSelected];
    [self setSelected:newState];
    
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"me.nepeta.relocate"];
    [preferences setBool:newState forKey:@"Enabled"];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.nepeta.relocate/ReloadPrefs", nil, nil, true);
}

@end