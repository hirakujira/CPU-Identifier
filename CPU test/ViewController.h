//
//  ViewController.h
//  CPU test
//
//  Created by Gary on 2015/9/28.
//  Copyright © 2015年 Gary. All rights reserved.
//

#import <UIKit/UIKit.h>


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

@interface ViewController : UIViewController <UIWebViewDelegate>
{
    int areaCode ,upperOffset;
    NSString *lang;
    NSString* region;
    NSString* imageName;
    UIScrollView *mainScrollView;
    UIWebView *webView;
    NSLayoutConstraint *heightConstraint;
    
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

