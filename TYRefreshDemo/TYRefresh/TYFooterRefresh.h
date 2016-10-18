//
//  TYFooterRefresh.h
//  TYRefreshDemo
//
//  Created by tany on 16/10/14.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYRefreshView.h"

@interface TYFooterRefresh : TYRefreshView

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler;

@end
