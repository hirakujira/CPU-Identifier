//
//  ViewController.h
//  CPU test
//
//  Created by Gary on 2015/9/28.
//  Copyright © 2015年 Gary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GADInterstitial.h>
#import "VpadnBanner.h"
#import "VpadnInterstitial.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define FOOTER_HEIGHT 44

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define HeightDevide_FOR_GoogleAD 12

#define AdmobIDBtn @"ca-app-pub-1596827822280753/2928738031"
#define AdmobIDAll @"ca-app-pub-1596827822280753/3986668835"
#define vponIDBanner @"8a8081824ff371e00150144e8f4d14df"
#define vponIDBannerJ @"8a808182442a711e0144347d7c4509f7"
#define vponIDAll @"8a8081824ff371e00150144f202614e0"

#define testiPhoneID1 @"037de1273f4e3317e9328d7e4594b2cf"  // Gary's iPhone 5s
#define testiPhoneID2 @"c95365b957f7ce41b737b489eb3b538ax"  // Hiraku's iPhone 6+
#define testiPhoneID3 @"464caf0bee75ad7989d2403994944d81"  // Gary's iPhone 4
#define testiPhoneVID1 @"B1E3906D-2482-4CA6-A6FD-E259A570592D"  // Gary's iPhone 5s for Vpad
#define testiPhoneVID2 @"5499571D-4A59-418A-A5FF-CCD1FD757EFC"  // Gary's iPhone 4 for Vpad
@import GoogleMobileAds;

@interface ViewController : UIViewController <VpadnBannerDelegate, VpadnInterstitialDelegate ,UIWebViewDelegate>
{
    VpadnBanner*    vpadnAd; // 宣告使用VpadnBanner廣告
    VpadnInterstitial*    vpadnInterstitial; // 宣告使用Vpadn插屏廣告
    GADInterstitial *interstitial;
    GADBannerView *gADBannerView;
    int areaCode ,upperOffset;
    NSString *lang;
    NSString* region;
    NSString* imageName;
    UIScrollView *mainScrollView;
    UIWebView *webView;
    NSLayoutConstraint *heightConstraint;
    
    GADRequest *grequest;
    GADRequest *grequest2;
    
    vm_size_t pagesize;
    
    UILabel* totalMem,*totalMemTitle;
    UILabel* activeMem,*activeMemTitle;
    UILabel* wireMem,*wireMemTitle;
    UILabel* inactiveMem,*inactiveMemTitle;
    UILabel* freeMem,*freeMemTitle;
}

@property (nonatomic, strong) NSTimer           *ramUsageTimer;
- (void)ramUsageTimerCB:(NSNotification*)notification;

@end

