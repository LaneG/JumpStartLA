//
//  NetflixViewController.m
//  MoveIt
//
//  Created by Keith Merrill IV on 3/1/15.
//  Copyright (c) 2015 com.keithmerrill. All rights reserved.
//

#import "NetflixViewController.h"

@interface NetflixViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *netflix;

@end

@implementation NetflixViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"www.netflix.com"] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 999];
    [self.netflix loadRequest: request];
    [self.netflix loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://netflix.com/"]]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"www.netflix.com"] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 999];
    [self.netflix loadRequest: request];
     [self.netflix loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://netflix.com/"]]];
    
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
