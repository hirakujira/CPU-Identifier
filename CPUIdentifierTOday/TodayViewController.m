//
//  TodayViewController.m
//  CPUIdentifierToday
//
//  Created by Hiraku on 2015/11/15.
//  Copyright © 2015年 Gary. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#include <sys/sysctl.h>
#include <sys/resource.h>
#include <sys/vm.h>
#include <dlfcn.h>
#import <mach/mach.h>

@interface TodayViewController () <NCWidgetProviding>
{
     vm_size_t pagesize;
}
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_freeSpace setText:[NSString stringWithFormat:@"%.0lf MB",[self memoryBytesFree]/1000000]];
    [_diskFreeSpace setText:[NSString stringWithFormat:@"%.2lf GB",(float)[self freeSize]/1000/1000/1000]];
    _barview.progress = 1;
    _barview.tintColor = [UIColor colorWithRed:0.188 green:0.822 blue:0.517 alpha:1];
    _barviewSpace.tintColor = [UIColor colorWithRed:0.188 green:0.822 blue:0.517 alpha:1];
    _barviewSpace.progress = 1- (float)[self freeSize]/[self totalSize];
    NSTimer* updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [updateTimer fire];
    self.preferredContentSize = CGSizeMake(0, 80);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update {
    _barview.progress = 1-([self memoryBytesFree]/1000/1000)/([self memoryBytesTotal]/1000/1000);
    [_freeSpace setText:[NSString stringWithFormat:@"%.0lf MB",[self memoryBytesFree]/1000000]];
}

- (long long) freeSize{
    NSDictionary *dict = [[NSFileManager defaultManager]
                          attributesOfFileSystemForPath:NSHomeDirectory()
                          error:nil];
    long long freeSize       = [[dict valueForKey:NSFileSystemFreeSize]
                           unsignedLongLongValue];
    return freeSize;
}


- (long long) totalSize {
    NSDictionary *dict = [[NSFileManager defaultManager]
                          attributesOfFileSystemForPath:NSHomeDirectory()
                          error:nil];
    
    // Set the values
    long long fileSystemSize = [[dict valueForKey:NSFileSystemSize]
                                unsignedLongLongValue];
    return fileSystemSize;
}
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 10.0;
    return margins;
}

- (double)memoryBytesTotal{
    return (double)[self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
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

@end
