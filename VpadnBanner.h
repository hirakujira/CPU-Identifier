/**
 * @note Copyright (C) 2012~, Vpon Incorporated. All Rights Reserved.
 *       This program is an unpublished copyrighted work which is proprietary to
 *       Vpon Incorporated and contains confidential information that is
 *       not to be reproduced or disclosed to any other person or entity without
 *       prior written consent from Vpon, Inc. in each and every instance.
 *
 * @warning Unauthorized reproduction of this program as well as unauthorized
 *          preparation of derivative works based upon the program or distribution of
 *          copies by sale, rental, lease or lending are violations of federal
 *          copyright laws and state trade secret laws, punishable by civil and
 *          criminal penalties.
 *
 * @file    VpadnBanner.h
 *
 * @brief   support publisher to use Vpadn ad
 *
 * @author  Alan(alan.tseng@vopn.com)
 *
 *
 * @date    2014/2/14
 *
 * @version 4.2.0
 *
 * @remark
 *
 **/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
	male, female
} UserInfoGender;

#pragma mark VpadnAdType
typedef enum {
	BANNER,
    RECTANGLE,
    PAD_BANNER,
    LEADERBOARD,
    SMART,
    STANDARD_PORTRAIT,
    SMART_PORTRAIT,
    INTERSTITIAL,
    SPLASH,
    MEDIUM_RECTANGLE,
    SMART_LANDSCAPE,
    VIDEO_INTERSTITIAL
} SizeTypeEnum;

#pragma mark VpadnAdSize
typedef struct  VpadnAdSize {
    CGSize size;
    int    adType;
}VpadnAdSize;

extern VpadnAdSize const VpadnAdSizeBanner;               // use for 320 * 50
extern VpadnAdSize const VpadnAdSizeFullBanner;           // use for 468 * 60   for iPad
extern VpadnAdSize const VpadnAdSizeLeaderboard;          // use for 728 * 90   for iPad
extern VpadnAdSize const VpadnAdSizeMediumRectangle;      // use for 300 * 250  for iPad
extern VpadnAdSize const VpadnAdSizeSmartBannerLandscape; // use for landscape smart banner
extern VpadnAdSize const VpadnAdSizeSmartBannerPortrait;  // use for portrait smart banner

CGSize CGSizeFromVpadnAdSize(VpadnAdSize size);   // get banner size


#pragma mark VpadnBannerDelegate
@protocol VpadnBannerDelegate <NSObject>
@optional
#pragma mark 通知有廣告可供拉取
- (void)onVpadnGetAd:(UIView *)bannerView;
#pragma mark 通知拉取廣告成功pre-fetch完成
- (void)onVpadnAdReceived:(UIView *)bannerView;
#pragma mark 通知拉取廣告失敗
- (void)onVpadnAdFailed:(UIView *)bannerView didFailToReceiveAdWithError:(NSError *)error;
#pragma mark 通知開啟vpadn廣告頁面
- (void)onVpadnPresent:(UIView *)bannerView;
#pragma mark 通知關閉vpadn廣告頁面
- (void)onVpadnDismiss:(UIView *)bannerView;
#pragma mark 通知離開publisher application
- (void)onVpadnLeaveApplication:(UIView *)bannerView;
#pragma mark View size change publisher can not to use
- (void)onVpadnViewSizeChange:(CGRect)ViewSize;
#pragma mark View size change publisher can not to use
- (void)onVpadnViewColorChange:(UIColor*)bgColor;
#pragma mark Ad auto refresh notify
-(void)onVpadnRefreshAd;

@end
#pragma mark VpadnBanner
@interface VpadnBanner : NSObject<VpadnBannerDelegate>  {
}
@property (nonatomic, copy) NSString *strBannerId;
@property (nonatomic, retain) UIViewController *rootViewController;
@property (nonatomic, assign) NSObject<VpadnBannerDelegate> *delegate;
@property (nonatomic, retain) NSString* platform;
@property (nonatomic, copy) NSArray* arrayTestIdentifiers;

#pragma mark 回傳Vpadn SDK版本
+ (NSString *)getVersionVpadn;
- (void)dealloc;
#pragma mark 取得VpadnBanner物件
- (id)initWithAdSize:(VpadnAdSize)adSize origin:(CGPoint)origin;
#pragma mark 取得VpadnBanner物件 位置預設為(0,0)
- (id)initWithAdSize:(VpadnAdSize)adSize;

#pragma mark 設定廣告是否自動更新. (Default NO)
- (void)setAdAutoRefresh:(BOOL)bSetAutoRefresh;
#pragma mark 開始取得廣告
- (void)startGetAd:(NSArray *)arrayTestIdentifiers;
#pragma mark 取得廣告View
- (UIView *)getVpadnAdView;
- (void)bannerPositionChange;

#pragma mark - UserInfomation
#pragma mark 設定使用者資訊-年齡
- (void)setUserInfoAge:(NSInteger)age;
#pragma mark 設定使用者資訊-生日
- (void)setUserInfoBirthdayWithYear:(NSInteger)year Month:(NSInteger)month andDay:(NSInteger)day;
#pragma mark 設定使用者資訊-性別
- (void)setUserInfoGender:(UserInfoGender)gender;
#pragma mark 設定使用者資訊-關鍵字
- (void)setUserInfoKeyword:(NSString *)keyword;

#pragma mark 設定Location開關
- (void)setLocationOnOff:(BOOL)isOn;
#pragma mark  回傳Location狀態
- (BOOL)isUseLocation;
- (void)destroyBanner;
@end
