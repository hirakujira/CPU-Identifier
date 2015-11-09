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
    
    
    NSLog(@"=====>You are in %@ areacode : %d",lang,areaCode);
    [self getIPLocation];
    
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

    BOOL isA9 = NO;
    manufactory.text = @"";
    if ([(__bridge NSString *)boardID isEqualToString:@"s8000"]) {
        manufactory.text = @"Samsung";
        isA9 = YES;
        imageName = @"A9";
    }
    if ([(__bridge NSString *)boardID isEqualToString:@"s8003"]) {
        manufactory.text = @"TSMC";
        isA9 = YES;
        imageName = @"A9";
    }

    
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
    
    
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *url = @"http://demo.hiraku.tw/CPUIdentifier/stat.php";
    NSString *requestStr = [[NSString alloc] initWithFormat:@"%@?adid=%@&device_type=%@&model=%@&region=%@&chip=%@",url,adId,[self platformString], (__bridge NSString*)(CFStringRef)$MGCopyAnswer(kMGModelNumber), (__bridge NSString*)(CFStringRef)$MGCopyAnswer(kMGRegionCode),boardIDLabel.text];
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
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:manufactory attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:mainScrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:100-upperOffset]];
    
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
    
    if (showAds) {
        
        //Add google ads
        gADBannerView = [[GADBannerView alloc] init];// 調整廣告的位置
        [gADBannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        gADBannerView.backgroundColor = [UIColor blackColor];
        gADBannerView.adUnitID = AdmobIDBtn;
        
        grequest = [GADRequest request];
        grequest.testDevices = @[
                                 kGADSimulatorID,
                                 kDFPSimulatorID,
                                 ];
        gADBannerView.rootViewController = self;
        
        [self.view  addSubview:gADBannerView];
        [self.view  addConstraint:[NSLayoutConstraint constraintWithItem:gADBannerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self.view  addConstraint:[NSLayoutConstraint constraintWithItem:gADBannerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        [self.view  addConstraint:[NSLayoutConstraint constraintWithItem:gADBannerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [gADBannerView setHidden:YES];
        
        [self.view  addConstraint:[NSLayoutConstraint constraintWithItem:gADBannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:adH]];
        
        interstitial = [[GADInterstitial alloc] initWithAdUnitID:AdmobIDAll];
        
        grequest2 = [GADRequest request];
        // Requests test ads on test devices.
        grequest2.testDevices = @[
                                  testiPhoneID1,
                                  testiPhoneID2,
                                  kGADSimulatorID,
                                  kDFPSimulatorID,
                                  ];
        
        // 設定廣告位置
        CGPoint origin = CGPointMake(0.0,SCREEN_HEIGHT - CGSizeFromVpadnAdSize(VpadnAdSizeSmartBannerPortrait).height);
        vpadnAd = [[VpadnBanner alloc] initWithAdSize:VpadnAdSizeSmartBannerPortrait origin:origin];  // 初始化Banner物件
        vpadnAd.strBannerId = vponIDBanner;   // 填入您的BannerId
        vpadnAd.delegate = self;       // 設定delegate接收protocol回傳訊息
        // 台灣地區請填TW 大陸則填CN
        [vpadnAd setAdAutoRefresh:NO]; //如果為mediation則set NO
        [vpadnAd setRootViewController:self]; //請將window的rootViewController設定在此 以便廣告順利執行
    }
    
    
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
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:linkButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:manufactory attribute:NSLayoutAttributeBottom multiplier:1.0 constant:25]];
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
    [mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:manufactory attribute:NSLayoutAttributeBottom multiplier:1.0 constant:150-upperOffset]];
    heightConstraint = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:0.0f constant:10.0f];
    [mainScrollView addConstraint:heightConstraint];

    
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


#pragma mark VpadnAdDelegate method 接一般Banner廣告就需要新增
- (void)onVpadnAdReceived:(UIView *)bannerView{
    //NSLog(@"廣告抓取成功");
}

- (void)onVpadnAdFailed:(UIView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    //NSLog(@"廣告抓取失敗");
}

- (void)onVpadnPresent:(UIView *)bannerView{
    //NSLog(@"開啟vpadn廣告頁面 %@",bannerView);
}

- (void)onVpadnDismiss:(UIView *)bannerView{
    //NSLog(@"關閉vpadn廣告頁面 %@",bannerView);
}

- (void)onVpadnLeaveApplication:(UIView *)bannerView{
    //NSLog(@"離開publisher application");
}

#pragma mark VpadnInterstitial Delegate 有接Interstitial的廣告才需要新增
- (void)onVpadnInterstitialAdReceived:(UIView *)bannerView{
    //NSLog(@"插屏廣告抓取成功");
    // 顯示插屏廣告
    [vpadnInterstitial show];
}

- (void)onVpadnInterstitialAdFailed:(UIView *)bannerView{
    //NSLog(@"插屏廣告抓取失敗");
}

- (void)onVpadnInterstitialAdDismiss:(UIView *)bannerView{
    //NSLog(@"關閉插屏廣告頁面 %@",bannerView);
}

#pragma mark 通知關閉vpadn開屏廣告
- (void)onVpadnSplashAdDismiss{
    //NSLog(@"關閉vpadn開屏廣告頁面");
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated{
    
    
}

- (void)getIPLocation{
    NSMutableURLRequest *requestHTTP = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://ip-api.com/json"]
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    
    [requestHTTP setHTTPMethod:@"GET"];
    [requestHTTP setValue: @"text/json" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:requestHTTP];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"IP response: %@ ",responseObject);
        NSString *myIP = [responseObject valueForKey:@"query"];
        [self setLocation:(NSDictionary*)responseObject];
        //NSLog(@"IP: %@", myIP);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }];
    [op start];
}

- (void)setLocation:(NSDictionary*)respDict{
    /*
     as = "AS4812 China Telecom (Group)";
     city = Shanghai;
     country = China;
     countryCode = CN;
     isp = "shanghai science and technology network communicat";
     lat = "31.0456";
     lon = "121.3997";
     org = "shanghai science and technology network communicat";
     query = "210.14.66.179";
     region = 31;
     regionName = "Shanghai Shi";
     status = success;
     timezone = "Asia/Shanghai";
     zip = "";
     
     */
    //NSLog(@"IP from Area: %@",[respDict valueForKey:@"countryCode"]);
    region = [respDict valueForKey:@"countryCode"];
    vpadnAd.platform = region;
    if (showAds) {
        if(region) {
            //        NSLog(@"region is %@",region);
            if ([region isEqualToString:@"TW"]) {
                [self.view addSubview:[vpadnAd getVpadnAdView]]; // 將VpadnBanner的View加入此ViewController中
                [vpadnAd startGetAd:[self getTestIdentifiers]]; // 開始抓取Banner廣告
                // Show 全幅廣告
                [self addInterstitialAds:NO];
            }
            else {
                [interstitial loadRequest:grequest2];
                [gADBannerView loadRequest:grequest];
                [gADBannerView setHidden:NO];
                [self addInterstitialAds:YES];
            }
        }
        else {
            if (areaCode != 3) {
                [interstitial loadRequest:grequest2];
                [gADBannerView loadRequest:grequest];
                [gADBannerView setHidden:NO];
                [self addInterstitialAds:YES];
            }
            else {
                [self.view addSubview:[vpadnAd getVpadnAdView]]; // 將VpadnBanner的View加入此ViewController中
                [vpadnAd startGetAd:[self getTestIdentifiers]]; // 開始抓取Banner廣告
                [self addInterstitialAds:NO];
            }
        }
    }
}

- (void)addInterstitialAds:(bool)isGoogleAD{
    if(isGoogleAD == YES){
        [NSTimer
         scheduledTimerWithTimeInterval:20.0
         target:self
         selector:@selector(addGInterAd)
         userInfo:nil
         repeats:NO];
    
        [NSTimer
         scheduledTimerWithTimeInterval:60.0
         target:self
         selector:@selector(addGInterAd)
         userInfo:nil
         repeats:YES];
    }else{
        [NSTimer
         scheduledTimerWithTimeInterval:20.0
         target:self
         selector:@selector(addVInterAd)
         userInfo:nil
         repeats:NO];
        
        [NSTimer
         scheduledTimerWithTimeInterval:60.0
         target:self
         selector:@selector(addVInterAd)
         userInfo:nil
         repeats:YES];
    }

}


- (void)addVInterAd{
    vpadnInterstitial = [[VpadnInterstitial alloc] init];
    vpadnInterstitial.strBannerId = vponIDAll;   // 填入您的Interstitial BannerId
    vpadnInterstitial.platform = region;       // 台灣地區請填TW 大陸則填CN
    vpadnInterstitial.delegate = self;
    [vpadnInterstitial getInterstitial:[self getTestIdentifiers]];
}

- (void)addGInterAd{
    interstitial = [[GADInterstitial alloc] initWithAdUnitID:AdmobIDAll];
    
    GADRequest *request2 = [GADRequest request];
    // Requests test ads on test devices.
    request2.testDevices = @[
                             kGADSimulatorID,
                             kDFPSimulatorID,
                             ];
    [interstitial loadRequest:request2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([interstitial isReady]) {
            [interstitial presentFromRootViewController:self];
        }
        //NSLog(@"is ready %d", [interstitial isReady]);
    });
}

@end

