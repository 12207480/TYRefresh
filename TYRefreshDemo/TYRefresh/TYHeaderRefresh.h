//
//  TYHeaderRefresh.h
//  TYRefreshDemo
//
//  Created by tany on 16/10/14.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYRefreshView.h"

@interface TYHeaderRefresh : TYRefreshView

+ (instancetype)headerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler;

@end
