//
//  TYRefreshView+Extension.h
//  TYRefreshDemo
//
//  Created by tany on 16/10/18.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYRefreshView.h"

// 主线程执行
NS_INLINE void dispatch_main_async_safe_ty_refresh(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@interface TYRefreshView ()

@property (nonatomic, assign) TYRefreshState state;

@property (nonatomic, assign) TYRefreshType type;

@property (nonatomic, copy) TYRefresHandler handler;

@property (nonatomic, strong) UIView<TYRefreshAnimator> *animator;

@property (nonatomic, assign) CGFloat refreshHeight;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isEndRefreshAnimating;

@property (nonatomic, assign) BOOL isPanGestureBegin;

@property (nonatomic, assign) UIEdgeInsets scrollViewOrignContenInset;

@end
