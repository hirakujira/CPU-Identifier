//
//  ViewController.m
//  CPU test
//
//  Created by Gary on 2015/9/28.
//  Copyright © 2015年 Gary. All rights reserved.
//

#import "ViewController.h"

#include <sys/sysctl.h>
#include <sys/resource.h>
#include <sys/vm.h>
#include <dlfcn.h>
#import "MobileGestalt.h"
#import "AppDelegate.h"


@implementation ViewController

- (NSString *)platformString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = (char*)malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return sDeviceModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CFStringRef boardID = MGCopyAnswer(kMGHardwarePlatform);
    UILabel* boardIDLabel = [[UILabel alloc] init];
    UILabel* addition = [[UILabel alloc] init];
    
    boardIDLabel.text = (__bridge NSString *)boardID;
    BOOL isA9 = NO;
    addition.text = @"";
    if ([(__bridge NSString *)boardID isEqualToString:@"s8000"]) {
        addition.text = @"Samsung";
        isA9 = YES;
    }
    if ([(__bridge NSString *)boardID isEqualToString:@"s8003"]) {
        addition.text = @"TSMC";
        isA9 = YES;
    }
    
    [boardIDLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addition setTranslatesAutoresizingMaskIntoConstraints:NO];
    [boardIDLabel setFont:[UIFont systemFontOfSize:36]];
    //    [boardIDLabel.text]
    [self.view addSubview:boardIDLabel];
    [self.view addSubview:addition];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:boardIDLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:boardIDLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addition attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addition attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:50]];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

