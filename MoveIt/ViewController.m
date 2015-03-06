//
//  ViewController.m
//  MoveIt
//
//  Created by Keith Merrill IV on 2/28/15.
//  Copyright (c) 2015 com.keithmerrill. All rights reserved.
//

#import "ViewController.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "HKHealthStore+AAPLExtensions.h"

@interface ViewController ()

@property (nonatomic, strong) NSTimer *pollingTimer;

@property (nonatomic, strong) MDRadialProgressView *radialView5;

@property (weak, nonatomic) IBOutlet UILabel *stepCountGoal;
@property (weak, nonatomic) IBOutlet UILabel *stepCountProgress;
@property (weak, nonatomic) IBOutlet UILabel *stepCountRemaining;

@end

@implementation ViewController

bool allowNotif;
bool allowsSound;
bool allowsBadge;
bool allowsAlert;
static NSString * const BaseURLString = @"http://54229587.ngrok.com/";

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.pollingTimer invalidate];
    self.pollingTimer = nil;
}

- (UIColor*)colorWithHex:(NSString*)hex
{
    unsigned int c;
    if ([hex characterAtIndex:0] == '#') {
        [[NSScanner scannerWithString:[hex substringFromIndex:1]] scanHexInt:&c];
    } else {
        [[NSScanner scannerWithString:hex] scanHexInt:&c];
    }
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0 green:((c & 0xff00) >> 8)/255.0 blue:(c & 0xff)/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated
     ];
    // Do any additional setup after loading the view, typically from a nib.

    self.stepCountGoal.text = [NSString stringWithFormat:@"%ld", (long)self.stepCount];
    
    CGRect frame = self.view.bounds;
    frame.size.height = frame.size.height / 3;
    
    //	Example 6 ========================================================================
    UIView *thisView = (UIView*)[self.view viewWithTag:99];
    
    CGRect frame2 = CGRectMake(0, 0, 220, 220);
    self.radialView5 = [self progressViewWithFrame:frame2];
    
    self.radialView5.progressTotal = self.stepCount; // total number of segments to break wheel into
    self.radialView5.progressCounter = 0; // will a) highlight this many segments && 2) display (this) * (100/#segments)  as center value
    self.radialView5.startingSlice = 1;
    self.radialView5.theme.thickness = 25;
    self.radialView5.theme.sliceDividerHidden = YES;
    self.radialView5.label.hidden = YES;
    self.radialView5.theme.sliceDividerThickness = 1;
    
    // theme update works both changing the theme or the theme attributes
    self.radialView5.theme.labelColor = [self colorWithHex:@"#4c4c4c"];
    self.radialView5.theme.labelShadowColor = [UIColor clearColor];
    self.radialView5.theme.completedColor = [self colorWithHex:@"#73BE00"];
    /*
     115 190 0
    73BE00
     */
    
    /* Whole theme
     MDRadialProgressTheme *t = [MDRadialProgressTheme standardTheme];
     t.labelColor = [UIColor blueColor];
     t.labelShadowColor = [UIColor clearColor];
     radialView5.theme = t;
     */
    
//    [thisView addSubview:self.radialView5];
    //	Example 6 ========================================================================
    
    self.healthStore = [[HKHealthStore alloc] init];
    // Set up an HKHealthStore, asking the user for read/write permissions. The profile view controller is the
    // first view controller that's shown to the user, so we'll ask for all of the desired HealthKit permissions now.
    // In your own app, you should consider requesting permissions the first time a user wants to interact with
    // HealthKit data.
    [HKHealthStore isHealthDataAvailable];
    
    self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateProgressView:) userInfo:nil repeats:YES];
}

- (void)updateProgressView:(NSInteger)steps
{
    if (self.pollingTimer) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];

        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the user interface based on the current user's health information.
                [self updateUsersStepCountProgress];
            });
        }];
    }
}

#pragma mark - HealthKit Permissions

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite
{
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    return [NSSet setWithObjects:stepCountType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead
{
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    return [NSSet setWithObjects:stepCountType, nil];
}

- (void)updateUsersStepCountProgress
{
    [self.healthStore appl_getStepCountForPast24HoursWithCompletion:^(NSArray *mostRecentStatistic, NSError *error) {
        if (!mostRecentStatistic) {
            NSLog(@"Either an error occured fetching the user's step count information or none has been stored yet. In your app, try to handle this gracefully.");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"meh");
            });
        } else {
            // Determine the height in the required unit.
            
            double usersSteps = 0;
            for (HKStatistics *stat in mostRecentStatistic) {
                HKQuantity *mostRecentQuantity = [stat sumQuantity];
                HKUnit *stdUnit = [HKUnit countUnit];
                usersSteps += [mostRecentQuantity doubleValueForUnit:stdUnit];
            }

            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.radialView5.progressCounter = usersSteps;
                self.stepCountProgress.text = [NSString stringWithFormat:@"%f", usersSteps];
                self.stepCountRemaining.text = [NSString stringWithFormat:@"%f", (self.stepCount - usersSteps)];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning
{
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