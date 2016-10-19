//
//  TYFooterAutoRefresh.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/18.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYFooterAutoRefresh.h"
#import "TYRefreshView+Extension.h"

@implementation TYFooterAutoRefresh

- (instancetype)init
{
    if (self = [super init]) {
        _autoRefreshWhenScrollProgress = 1.0;
    }
    return self;
}

@end
