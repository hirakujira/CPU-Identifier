//
//  TodayViewController.h
//  CPUIdentifierToday
//
//  Created by Hiraku on 2015/11/15.
//  Copyright © 2015年 Gary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *barview;
@property (weak, nonatomic) IBOutlet UIProgressView *barviewSpace;
@property (weak, nonatomic) IBOutlet UILabel *diskFreeSpace;
@property (weak, nonatomic) IBOutlet UILabel *freeSpace;
@end
