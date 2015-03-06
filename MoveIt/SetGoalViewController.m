//
//  SetGoalViewController.m
//  MoveIt
//
//  Created by Keith Merrill IV on 3/1/15.
//  Copyright (c) 2015 com.keithmerrill. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>

#import "SetGoalViewController.h"

@interface SetGoalViewController ()

@end

@implementation SetGoalViewController

static NSString * const BaseURLString = @"http://54229587.ngrok.com/";

- (IBAction)steps100BtnPressed:(id)sender
{
//    [self killNetflix];
}

- (IBAction)steps1000BtnPressed:(id)sender
{
//    [self killNetflix];
}

- (IBAction)steps10000BtnPressed:(id)sender
{
//    [self killNetflix];
}

- (void)killNetflix
{
    // 1
    NSString *string = [NSString stringWithFormat:@"%@?key=hello", BaseURLString];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
