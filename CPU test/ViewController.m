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
//#import "MobileGestalt.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import <mach/mach.h>

@import AdSupport;
#if __cplusplus
extern "C" {
#endif
    CFPropertyListRef MGCopyAnswer(CFStringRef property);
#if __cplusplus
}
#endif


#define showAds 0
#define showFB 0
#define appstore 1



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

- (NSString *)platformString2 {
    size_t size;
    sysctlbyname("hw.model", NULL, &size, NULL, 0);
    char *model = (char*)malloc(size);
    sysctlbyname("hw.model", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return sDeviceModel;
}


static CFStringRef (*$MGCopyAnswer)(CFStringRef);
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"language %@",language);
    if([language isEqualToString:@"zh-Hans"]){
        areaCode = 2;
        lang = @"CN";
    }else if([language isEqualToString:@"zh-Hant"]){
        areaCode = 3;
        lang = @"TW";
    }else{
        areaCode = 1;
        lang = @"EN";
    }
    //areaCode = 1;
    
    int adH  = 70;
    if(IS_IPHONE_6P ){
        adH = 66;
    }else if(IS_IPHONE_6){
        adH = 60;
    }else{
        adH = 52;
    }
    
   
    
    
    _ramUsageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 1
                                                          target:self
                                                        selector:@selector(logMemUsage)
                                                        userInfo:nil
                                                         repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.ramUsageTimer forMode:NSDefaultRunLoopMode];
    [self.ramUsageTimer fire];
    
    
    void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY);
    $MGCopyAnswer = dlsym(gestalt, "MGCopyAnswer");
//    NSLog(@"UDID %@",[self platformString2]);
    
    mainScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:mainScrollView];
    [mainScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mainScrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mainScrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mainScrollView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mainScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    mainScrollView.contentInset = UIEdgeInsetsMake(-100, 0, 0, 0);
    CFStringRef boardID = (CFStringRef)$MGCopyAnswer(CFSTR("HardwarePlatform"));
    CFStringRef HWModelStr = (CFStringRef)$MGCopyAnswer(CFSTR("HWModelStr"));
    UILabel* boardIDLabel = [[UILabel alloc] init];
    UILabel* manufactory = [[UILabel alloc] init];
    UILabel* HWModelStrLabel = [[UILabel alloc] init];
    UILabel* platformLabel = [[UILabel alloc] init];
    boardIDLabel.text = [NSString stringWithFormat:@"%@",(__bridge NSString *)boardID];
    HWModelStrLabel.text = [NSString stringWithFormat:@"%@",(__bridge NSString *)HWModelStr];
    platformLabel.text = [NSString stringWithFormat:@"%@",[self platformString]];
    
    
    //qwueoiqwueoiqwu
    totalMem = [[UILabel alloc] init];
    activeMem = [[UILabel alloc] init];
    wireMem = [[UILabel alloc] init];
    inactiveMem = [[UILabel alloc] init];
    freeMem  = [[UILabel alloc] init];
    [totalMem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [activeMem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [wireMem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [inactiveMem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [freeMem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mainScrollView addSubview:totalMem];
    [mainScrollView addSubview:activeMem];
    [mainScrollView addSubview:wireMem];
    [mainScrollView addSubview:inactiveMem];
    [mainScrollView addSubview:freeMem];
    
    
    totalMemTitle = [[UILabel alloc] init];
    activeMemTitle = [[UILabel alloc] init];
    wireMemTitle = [[UILabel alloc] init];
    inactiveMemTitle = [[UILabel alloc] init];
    freeMemTitle  = [[UILabel alloc] init];
    [totalMemTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [activeMemTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [wireMemTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [inactiveMemTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [freeMemTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mainScrollView addSubview:totalMemTitle];
    [mainScrollView addSubview:activeMemTitle];
    [mainScrollView addSubview:wireMemTitle];
    [mainScrollView addSubview:inactiveMemTitle];
    [mainScrollView addSubview:freeMemTitle];
    
    
    totalMem.text = @"0000.000";
    activeMem.text = @"0000.000";
    wireMem.text = @"0000.000";
    inactiveMem.text = @"0000.000";
    freeMem.text = @"0000.000";
    
    
    totalMemTitle.textAlignment = NSTextAlignmentRight;
    activeMemTitle.textAlignment = NSTextAlignmentRight;
    wireMemTitle.textAlignment = NSTextAlignmentRight;
    inactiveMemTitle.textAlignment = NSTextAlignmentRight;
    freeMemTitle.textAlignment = NSTextAlignmentRight;
    
    totalMemTitle.text = @"Total Mem:";
    activeMemTitle.text = @"Active Mem:";
    wireMemTitle.text = @"Wired Mem:";
    inactiveMemTitle.text = @"Inactive Mem:";
    freeMemTitle.text = @"Free Mem:";
    
    
    
    
    
    
    if (!appstore) {
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
    }
    else {
        imageName = @"CPU";
    }
    
    NSString *url = @"http://demo.hiraku.tw/CPUIdentifier/stat.php";
    NSString *requestStr = [[NSString alloc] initWithFormat:@"%@?adid=%@&device_type=%@&model=%@&region=%@&chip=%@",url,[[[UIDevice currentDevice] identifierForVendor] UUIDString],[self platformString], (__bridge NSString*)(CFStringRef)$MGCopyAnswer(CFSTR("ModelNumber")), (__bridge NSString*)(CFStringRef)$MGCopyAnswer(CFSTR("RegionCode")),boardIDLabel.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
     NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //    [mainScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [boardIDLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [manufactory setTranslatesAutoresizingMaskIntoConstraints:NO];
    [HWModelStrLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [platformLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [boardIDLabel setFont:[UIFont systemFontOfSize:18]];
    //    [boardIDLabel.text]
    
    UILabel* boardIDLabelPre = [[UILabel alloc] init];
    UILabel* platformLabelPre = [[UILabel alloc] init];
    UILabel* manuPre = [[UILabel alloc] init];
    UILabel* HWPre = [[UILabel alloc] init];
    UILabel* CPUTypePre = [[UILabel alloc] init];
    
    boardIDLabelPre.text = @"CPU Type:";
    boardIDLabelPre.textAlignment = NSTextAlignmentRight;
    boardIDLabelPre.translatesAutoresizingMaskIntoConstraints = NO;
    
    manuPre.text = @"Manufactory:";
    manuPre.textAlignment = NSTextAlignmentRight;
    manuPre.translatesAutoresizingMaskIntoConstraints = NO;
    
    platformLabelPre.text = @"Device:";
    platformLabelPre.textAlignment = NSTextAlignmentRight;
    platformLabelPre.translatesAutoresizingMaskIntoConstraints = NO;
    
    HWPre.text = @"Device Model:";
    HWPre.textAlignment = NSTextAlignmentRight;
    HWPre.translatesAutoresizingMaskIntoConstraints = NO;
    
    CPUTypePre.text = @"CPU Name:";
    CPUTypePre.textAlignment = NSTextAlignmentRight;
    CPUTypePre.translatesAutoresizingMaskIntoConstraints = NO;
    
    boardIDLabel.textAlignment = NSTextAlignmentLeft;
    manufactory.textAlignment = NSTextAlignmentLeft;
    platformLabel.textAlignment = NSTextAlignmentLeft;
    
    
    
    [mainScrollView addSubview:boardIDLabel];
    [mainScrollView addSubview:platformLabel];
    [mainScrollView addSubview:manufactory];
    [mainScrollView addSubview:HWModelStrLabel];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:boardIDLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:boardIDLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:manufactory attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:manufactory attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
    
    BOOL isA9 = NO;
    manufactory.text = @"";
    if ([(__bridge NSString *)boardID isEqualToString:@"s8000"]) {
        manufactory.text = @"Samsung";
        isA9 = YES;
//        imageName = @"A9";
    }
    else if ([(__bridge NSString *)boardID isEqualToString:@"s8003"]) {
        manufactory.text = @"TSMC";
        isA9 = YES;
//        imageName = @"A9";
    }
    else {
        manuPre.hidden = YES;
    }

    //Add chip icon
    
    UIImageView *imgView = [[UIImageView alloc] init];
    if(imageName)
        imgView.image = [UIImage imageNamed:imageName];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [mainScrollView addSubview: imgView];
    [imgView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainScrollView  attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:mainScrollView  attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0]];
    [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imgView  attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    if (1) {
       
//        [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:boardIDLabel  attribute:NSLayoutAttributeTop multiplier:1.0 constant:-24]];
    }

        NSString* str2Cmp = [(__bridge NSString *)boardID lowercaseString];
        NSString* typeName;
        if ([str2Cmp isEqualToString:@"s8000"]) {
            typeName = @"A9";
        }
        else if ([str2Cmp isEqualToString:@"s8003"]) {
            typeName = @"A9";
        }
        else if ([str2Cmp isEqualToString:@"s8001"]) {
            typeName = @"A9X";
        }
        else if ([str2Cmp hasPrefix:@"s5l8960"] || [str2Cmp hasPrefix:@"s5l8965"]){
            typeName = @"A7";
        }else if ([str2Cmp hasPrefix:@"t7000"]){
            typeName = @"A8";
        }else if ([str2Cmp hasPrefix:@"t7001"]){
            typeName = @"A8X";
        }else if ([str2Cmp hasPrefix:@"s5l8950"]){
            typeName = @"A6";
        }else if ([str2Cmp hasPrefix:@"S5L8955"]){
            typeName = @"A6X";
        }else if ([str2Cmp hasPrefix:@"s5l8940"] || [str2Cmp hasPrefix:@"s5l8942"] ){
            typeName = @"A5";
        }else if ([str2Cmp hasPrefix:@"s5l8945"]){
            typeName = @"A5X";
        }else if ([str2Cmp hasPrefix:@"s5l8930"]){
            typeName = @"A4";
        }

        UILabel *type = [[UILabel alloc] init];
        [mainScrollView addSubview: type];
        type.text  = [NSString stringWithFormat:@"%@",typeName];
//         type.textColor = [UIColor whiteColor];
//        type.font = [UIFont systemFontOfSize:18];
//        type.textAlignment = NSTextAlignmentRight;
        [type setTranslatesAutoresizingMaskIntoConstraints:NO];
        [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:type attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView  attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
//        [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:type attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:mainScrollView  attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
//        [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:type attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:type  attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        [mainScrollView  addConstraint:[NSLayoutConstraint constraintWithItem:type attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:boardIDLabel  attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];

        [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:HWModelStrLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
        [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:HWModelStrLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:type attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:platformLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
        [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:platformLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:HWModelStrLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:platformLabel  attribute:NSLayoutAttributeTop multiplier:1.0 constant:-20]];
    
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:totalMem attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:totalMem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:manufactory attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
    
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:activeMem attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:activeMem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:totalMem attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:wireMem attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:wireMem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:activeMem attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:inactiveMem attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:inactiveMem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:wireMem attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:freeMem attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:20]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:freeMem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:inactiveMem attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    
    //PreLabel
    
    [mainScrollView addSubview:boardIDLabelPre];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:boardIDLabelPre attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:boardIDLabelPre attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:boardIDLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [mainScrollView addSubview:manuPre];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:manuPre attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:manuPre attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:manufactory attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    

    [mainScrollView addSubview:platformLabelPre];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:platformLabelPre attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:platformLabelPre attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:platformLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [mainScrollView addSubview:HWPre];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:HWPre attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:HWPre attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:HWModelStrLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [mainScrollView addSubview:CPUTypePre];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:CPUTypePre attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:CPUTypePre attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:type attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [mainScrollView addSubview:totalMemTitle];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:totalMemTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:totalMemTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:totalMem attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [mainScrollView addSubview:activeMemTitle];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:activeMemTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:activeMemTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:activeMem attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [mainScrollView addSubview:wireMemTitle];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:wireMemTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:wireMemTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:wireMem attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [mainScrollView addSubview:inactiveMemTitle];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:inactiveMemTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:inactiveMemTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:inactiveMem attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [mainScrollView addSubview:freeMemTitle];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:freeMemTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:freeMemTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:freeMem attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:freeMem attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:150-upperOffset]];

//    if (showFB) {
//        FBSDKShareButton *button = [[FBSDKShareButton alloc] init];
//        NSString* content = isA9 ? [NSString stringWithFormat:@"The A9 chip of my iPhone 6s/6s plus is manufactured by %@. Check yours!", manufactory.text] : [NSString stringWithFormat:@"I'm using CPU Identifier to show the chip info of my iPhone. Check yours!"];
//        FBSDKShareLinkContent *fbcontent= [[FBSDKShareLinkContent alloc] init];
//        fbcontent.contentURL = [NSURL URLWithString:@"http://demo.hiraku.tw/CPUIdentifier/index.html"];
//        fbcontent.contentTitle = @"Check out the chip manufactory of your iPhone 6s/6s Plus!";
//        fbcontent.contentDescription = content;
//        button.shareContent = fbcontent;
//        [mainScrollView addSubview:button];
//        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
//        [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
//        [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:100-upperOffset]];
//    }
    
    UIButton* linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [linkButton setBackgroundColor:[UIColor colorWithRed:0.188 green:0.822 blue:0.517 alpha:1]];
    [linkButton.layer setCornerRadius:7];
    [linkButton setTitle:@"About" forState:UIControlStateNormal];
    [linkButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    linkButton.translatesAutoresizingMaskIntoConstraints = NO;
    [mainScrollView addSubview:linkButton];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:linkButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:linkButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:freeMem attribute:NSLayoutAttributeBottom multiplier:1.0 constant:25]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:linkButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200.0f]];
    [linkButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];

    NSString *urlString = @"http://demo.hiraku.tw/CPUIdentifier/chart-store.php";
    //urlString = @"http://demo.hiraku.tw/CPUIdentifier/region/TA.php";
    NSURL *url_demo = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url_demo];
    webView.backgroundColor = [UIColor grayColor];
    webView = [[UIWebView alloc] init];
    webView.delegate = self;
    [webView loadRequest:urlRequest];
    [mainScrollView addSubview:webView];
//    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
//    webView.userInteractionEnabled = NO;
    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:manufactory attribute:NSLayoutAttributeBottom multiplier:1.0 constant:250-upperOffset]];
    heightConstraint = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:0.0f constant:10.0f];
    [mainScrollView addConstraint:heightConstraint];
    manufactory.hidden = YES;
    manuPre.hidden = YES;
    
//    mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, SCREEN_HEIGHT + 1100 - upperOffset);
}


-(BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewin
{
    CGFloat height = [[webViewin stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    
    //NSLog(@"NEW HEIGHT %f", height);
    
    [mainScrollView removeConstraint:heightConstraint];
    heightConstraint = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:0.0f constant:height];
    [mainScrollView addConstraint:heightConstraint];
    [mainScrollView setContentSize:CGSizeMake(SCREEN_WIDTH,  SCREEN_HEIGHT/2 +240 + height)];
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    CGRect oldBounds = [webView bounds];
//    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
//    NSLog(@"NEW HEIGHT %f", height);
////    [webView setBounds:CGRectMake(oldBounds.origin.x, oldBounds.origin.y, oldBounds.size.width, height)];
//    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:height]];
////    mainScrollView.contentSize = webView.bounds.size;
//}

-(NSArray*)getTestIdentifiers
{
    return [NSArray arrayWithObjects:
            // add your test UUID
            @"c95365b957f7ce41b737b489eb3b538ax",
            nil];
}


- (void)buttonPressed {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://demo.hiraku.tw/CPUIdentifier/chart2-store.php"]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (double)memoryBytesFree
{
    mach_port_t           host_port = mach_host_self();
    mach_msg_type_number_t   host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
//    vm_size_t               pagesize;
    vm_statistics_data_t     vm_stat;
    host_page_size(host_port, &pagesize);
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) NSLog(@"Failed to fetch vm statistics");
    natural_t  mem_free = (double)vm_stat.free_count * (double)pagesize;
    return (double)mem_free;
}

- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (double)memoryBytesTotal{
    return (double)[self getSysInfo:HW_PHYSMEM];
}

- (double)memoryInactive{
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return -1;
    }
    else
    {
        return (double)vmstat.inactive_count *(double)pagesize;
    }
}

- (double)memoryActive{
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return -1;
    }
    else
    {
        return (double)vmstat.active_count  * (double)pagesize;
    }
}

- (double)memoryWire{
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return -1;
    }
    else
    {
        return (double)vmstat.wire_count  * (double)pagesize;
    }
}


-(void) logMemUsage {
//    NSLog(@"Memory total %7lu  active %7lu  wire %7lu  inactive %7lu free %7lu" , (unsigned long)[self memoryBytesTotal],(unsigned long)[self memoryActive],(unsigned long)[self memoryWire],(unsigned long)[self memoryInactive],(unsigned long)[self memoryBytesFree]);
    totalMem.text = [NSString stringWithFormat:@"%.3lf MB",([self memoryBytesTotal]/1000/1000)];
    activeMem.text = [NSString stringWithFormat:@"%.3lf MB",[self memoryActive]/1000/1000];
    wireMem.text = [NSString stringWithFormat:@"%.3lf MB",[self memoryWire]/1000/1000];
    inactiveMem.text = [NSString stringWithFormat:@"%.3lf MB",[self memoryInactive]/1000/1000];
    freeMem.text = [NSString stringWithFormat:@"%.3lf MB",[self memoryBytesFree]/1000/1000];
    

}


- (void)stopRAMUsageUpdates
{
    [self.ramUsageTimer invalidate];
    self.ramUsageTimer = nil;
}
@end

