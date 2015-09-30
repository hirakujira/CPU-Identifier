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
#import "AFNetworking.h"

@import AdSupport;
#if __cplusplus
extern "C" {
#endif
    CFPropertyListRef MGCopyAnswer(CFStringRef property);
#if __cplusplus
}
#endif


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

    int adH ,upperOffset = 70;
    if(IS_IPHONE_6P ){
        adH = 66;
    }else if(IS_IPHONE_6){
        adH = 60;
    }else{
        adH = 52;
    }
    
    mainScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:mainScrollView];
    [mainScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mainScrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mainScrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mainScrollView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mainScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-adH]];
    
    CFStringRef val = (CFStringRef)MGCopyAnswer(CFSTR("HardwarePlatform"));
    NSString* chipIdentifier =(__bridge NSString * _Nullable)(val);
    
    CFStringRef boardID = MGCopyAnswer(kMGHardwarePlatform);
    UILabel* boardIDLabel = [[UILabel alloc] init];
    UILabel* addition = [[UILabel alloc] init];
    
    boardIDLabel.text = (__bridge NSString *)boardID;
    BOOL isA9 = NO;
    addition.text = @"";
    if ([(__bridge NSString *)boardID isEqualToString:@"s8000"]) {
        addition.text = @"Samsung";
        isA9 = YES;
        imageName = @"A9";
    }
    if ([(__bridge NSString *)boardID isEqualToString:@"s8003"]) {
        addition.text = @"TSMC";
        isA9 = YES;
        imageName = @"A9";
    }

    
    NSString* str2Cmp = [(__bridge NSString *)boardID lowercaseString];
    if ([str2Cmp hasPrefix:@"s5l8960"] || [str2Cmp hasPrefix:@"s5l8965"]){
        imageName = @"A7";
    }else if ([str2Cmp hasPrefix:@"t7000"]){
        imageName = @"A8";
    }else if ([str2Cmp hasPrefix:@"t7001"]){
        imageName = @"A8X";
    }else if ([str2Cmp hasPrefix:@"s5l8950"]){
        imageName = @"A6";
    }else if ([str2Cmp hasPrefix:@"S5L8955"]){
        imageName = @"A6X";
    }else if ([str2Cmp hasPrefix:@"s5l8940"] || [str2Cmp hasPrefix:@"s5l8942"] ){
        imageName = @"A5";
    }else if ([str2Cmp hasPrefix:@"s5l8945"]){
        imageName = @"A5X";
    }else if ([str2Cmp hasPrefix:@"s5l8930"]){
        imageName = @"A4";
    }
    
    //    [mainScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [boardIDLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addition setTranslatesAutoresizingMaskIntoConstraints:NO];
    [boardIDLabel setFont:[UIFont systemFontOfSize:36]];
    //    [boardIDLabel.text]
    [mainScrollView addSubview:boardIDLabel];
    [mainScrollView addSubview:addition];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:boardIDLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:boardIDLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-upperOffset]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:addition attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:addition attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:50-upperOffset]];
    
    //Add chip icon
    UIImageView *imgView = [[UIImageView alloc] init];
    if(imageName)
        imgView.image = [UIImage imageNamed:imageName];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [mainScrollView addSubview: imgView];
    [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainScrollView  attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:mainScrollView  attribute:NSLayoutAttributeWidth multiplier:0.4 constant:0]];
    [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imgView  attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:boardIDLabel  attribute:NSLayoutAttributeTop multiplier:1.0 constant:-24]];

    UIWebView *webView = [[UIWebView alloc]init];
    NSString *urlString = @"http://demo.hiraku.tw/CPUIdentifier/chart.php";
    NSURL *url_demo = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url_demo];
    webView.backgroundColor = [UIColor grayColor];
    
    [webView loadRequest:urlRequest];
    [mainScrollView addSubview:webView];
    webView.userInteractionEnabled = NO;
    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:addition attribute:NSLayoutAttributeBottom multiplier:1.0 constant:100-upperOffset]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:1300]];
    
    mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, SCREEN_HEIGHT + 952 -upperOffset*2);
    

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

