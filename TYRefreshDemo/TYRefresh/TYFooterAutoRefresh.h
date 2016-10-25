//
//  TYFooterAutoRefresh.h
//  TYRefreshDemo
//
//  Created by tany on 16/10/18.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYRefreshView.h"

@interface TYFooterAutoRefresh : TYRefreshView

@property (nonatomic, assign) BOOL adjustOriginBottomContentInset; // default YES

@property (nonatomic,assign) CGFloat autoRefreshWhenScrollProgress;

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler;

@end
