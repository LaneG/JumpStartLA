//
//  ViewController.m
//  MoveIt
//
//  Created by Keith Merrill IV on 2/28/15.
//  Copyright (c) 2015 com.keithmerrill. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>

#import "ViewController.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"

@interface ViewController ()

@end

@implementation ViewController

bool allowNotif;
bool allowsSound;
bool allowsBadge;
bool allowsAlert;
static NSString * const BaseURLString = @"http://54229587.ngrok.com/";

- (IBAction)testPOSTBtnPressed:(id)sender
{
    // 1
    NSString *string = [NSString stringWithFormat:@"%@?key=hello", BaseURLString];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 3
        NSDictionary *response = (NSDictionary *)responseObject;
        NSLog(@"response %@", response);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];
}

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
    
    CGRect frame = self.view.bounds;
    frame.size.height = frame.size.height / 3;
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height)];
    view2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:view2];
    
    // self.view.backgroundColor = [UIColor whiteColor];
    
    int x = self.view.center.x;
    int y = 20;
    
    //	Example 6 ========================================================================
    CGRect labelFrame = CGRectMake(x, y, frame.size.width, 40);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = @"Start from slice 3, custom label color with no shadow: ";
    [view2 addSubview:label];
    
    frame = CGRectMake(x, y, 100, 100);
    MDRadialProgressView *radialView5 = [self progressViewWithFrame:frame];
    
    radialView5.progressTotal = 20; // total number of segments to break wheel into
    radialView5.progressCounter = 14; // will a) highlight this many segments && 2) display (this) * (100/#segments)  as center value
    radialView5.startingSlice = 1;
    radialView5.theme.sliceDividerHidden = NO;
    radialView5.theme.sliceDividerThickness = 1;
    
    // theme update works both changing the theme or the theme attributes
    radialView5.theme.labelColor = [UIColor blueColor];
    radialView5.theme.labelShadowColor = [UIColor clearColor];
    
    /* Whole theme
     MDRadialProgressTheme *t = [MDRadialProgressTheme standardTheme];
     t.labelColor = [UIColor blueColor];
     t.labelShadowColor = [UIColor clearColor];
     radialView5.theme = t;
     */
    
    [view2 addSubview:radialView5];
    //	Example 6 ========================================================================
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


#pragma mark - Radial Progress View


- (MDRadialProgressView *)progressViewWithFrame:(CGRect)frame
{
    MDRadialProgressView *view = [[MDRadialProgressView alloc] initWithFrame:frame];
    
    // Only required in this demo to align vertically the progress views.
    view.center = CGPointMake(self.view.center.x + 80, view.center.y);
    
    return view;
}

- (UILabel *)labelAtY:(CGFloat)y andText:(NSString *)text
{
    CGRect frame = CGRectMake(5, y, 180, 50);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [label.font fontWithSize:14];
    
    return label;
}

@end