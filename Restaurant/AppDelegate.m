//
//  AppDelegate.m
//  TestTemplate
//
//  Created by AppsFoundation on 1/18/15.
//  Copyright (c) 2015 AppsFoundation. All rights reserved.
//

#import "AppDelegate.h"

#import "Appirater.h"
#import "ConfigurationManager.h"
#import "MSSlidingPanelController.h"
#import "ThemeManager.h"
#import "Localytics.h"
#import <Taplytics/Taplytics.h>
#import "Mixpanel.h"

static NSInteger secondsInHour = 60;

typedef enum {
    RateAppDeclined = 0,
    RateAppConfirmed
}RateApp;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initAppiRater];
    [self initRateAppTimer];
    
    [ThemeManager applyNavigationBarTheme];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    
    [Localytics autoIntegrate:@"5a97d4a6eefb4d7050f7652-ddfe2de2-a520-11e5-127c-008b20abc1fa" launchOptions:launchOptions];
    [Taplytics startTaplyticsAPIKey:@"d9ba01a31e8d6d3d3de5a6b079c48107d396556c"];
    [Mixpanel sharedInstanceWithToken:@"fb25d24b0d4d0786d308f0c0498ba09f"];
    [Taplytics startTaplyticsAPIKey:@"578f6de6ae8383fd9713f65a9a65eba18ca8368f"];

    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Opened app" properties:@{
                                                @"Gender": @"Female",
                                                @"Plan": @"Premium"
                                                }];

    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)sourceApp annotation:(id)ann {
    return NO;
}


+ (AppDelegate *)sharedDelegate {
    return (AppDelegate *)([UIApplication sharedApplication]).delegate;
}


#pragma mark - Actions

- (void)openOurMenu {
    [self openControllerWithIndentifier:@"ourMenuNavController"];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel track:@"Opened Menu" properties:@{
                                @"Gender": @"Female",
                                @"Plan": @"Premium"
                            }];

    
    
}

- (void)openReservation {
    [self openControllerWithIndentifier:@"reservationNavController"];
}

- (void)openFindUs {
    [self openControllerWithIndentifier:@"findUsNavController"];
}

- (void)openFeedback{
    [self openControllerWithIndentifier:@"feedbackNavController"];
}

#pragma mark - Private methods

- (void)openControllerWithIndentifier:(NSString *)identifier {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    MSSlidingPanelController *rootController = (MSSlidingPanelController *)self.window.rootViewController;
    
    [rootController setCenterViewController:controller];
    [rootController closePanel];
}

- (void)initAppiRater {
    [Appirater appLaunched:YES];
    [Appirater setAppId:[[ConfigurationManager sharedManager] appId]];
    [Appirater setOpenInAppStore:YES];
}

- (void)initRateAppTimer {
    NSNumber *didShowAppRate = [[NSUserDefaults standardUserDefaults] valueForKey:@"showedAppRate"];
    if (!didShowAppRate.boolValue) {
        NSInteger showRateDelay = [[[ConfigurationManager sharedManager] rateAppDelay] integerValue] * secondsInHour;
        [NSTimer scheduledTimerWithTimeInterval:showRateDelay target:self
                                       selector:@selector(showAppRate)
                                       userInfo:nil repeats:NO];
    }
}

- (void)showAppRate {
    NSNumber *didShowAppRate = [[NSUserDefaults standardUserDefaults] valueForKey:@"showedAppRate"];
    if (![didShowAppRate boolValue]) {
        [self rateApp];
        [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"showedAppRate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)rateApp {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rate the App" message:@"Do you like app?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"No",@"Yes",nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Rate the App"]) {
        switch (buttonIndex) {
            case RateAppDeclined: {
                break;
            }
            case RateAppConfirmed:
                [Appirater rateApp];
                break;
            default:
                break;
        }
    }
}

@end