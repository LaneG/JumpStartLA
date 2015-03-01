//
//  ViewController.m
//  MoveIt
//
//  Created by Keith Merrill IV on 2/28/15.
//  Copyright (c) 2015 com.keithmerrill. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

bool allowNotif;
bool allowsSound;
bool allowsBadge;
bool allowsAlert;

- (IBAction)sendNotif:(id)sender
{
    [self setNotificationTypesAllowed];
    
    // New for iOS 8 - Register the notifications
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification)
    {
        if (allowNotif)
        {
            notification.timeZone = [NSTimeZone defaultTimeZone];        }
        if (allowsAlert)
        {
            notification.alertBody = @"Congratulations, you reached your goal!";
        }
        if (allowsBadge)
        {
            notification.applicationIconBadgeNumber = 1;
        }
        if (allowsSound)
        {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        // this will fire the notification right away, it will still also fire at the date we set
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNotificationTypesAllowed
{
    NSLog(@"%s:", __PRETTY_FUNCTION__);
    // get the current notification settings
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    allowNotif = (currentSettings.types != UIUserNotificationTypeNone);
    allowsSound = (currentSettings.types & UIUserNotificationTypeSound) != 0;
    allowsBadge = (currentSettings.types & UIUserNotificationTypeBadge) != 0;
    allowsAlert = (currentSettings.types & UIUserNotificationTypeAlert) != 0;
}

@end