//
//  TYRefreshView.h
//  TYRefreshDemo
//
//  Created by tany on 16/10/10.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TYRefreshState) {
    // 正常
    TYRefreshStateNormal,
    // 下拉或上拉
    TYRefreshStatePulling,
    // 正在加载
    TYRefreshStateLoading,
    // 松开进入刷新
    TYRefreshStateRelease,
    // 加载失败
    TYRefreshStateError,
    // 没有更多数据
    TYRefreshStateNoMore
};

typedef NS_ENUM(NSUInteger, TYRefreshType) {
    TYRefreshTypeHeader,
    TYRefreshTypeFooter,
};

typedef void(^TYRefresHandler)(void);
@class TYRefreshView;

@protocol TYRefreshAnimator <NSObject>

@optional

- (void)refreshViewDidPrepareRefresh:(TYRefreshView *)refreshView;

- (void)refreshView:(TYRefreshView *)refreshView didChangeFromState:(TYRefreshState)fromState toState:(TYRefreshState)toState;

- (void)refreshView:(TYRefreshView *)refreshView didChangeProgress:(CGFloat)progress;

- (void)refreshViewDidBeginRefresh:(TYRefreshView *)refreshView;

- (void)refreshViewDidEndRefresh:(TYRefreshView *)refreshView;

@end

@interface TYRefreshView : UIView

@property (nonatomic, assign, readonly) TYRefreshState state;

@property (nonatomic, assign, readonly) TYRefreshType type;

@property (nonatomic, copy, readonly) TYRefresHandler handler;

@property (nonatomic, strong, readonly) UIView<TYRefreshAnimator> *animator;

@property (nonatomic, assign, readonly) CGFloat refreshHeight;

@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOrignContenInset;

@property (nonatomic, assign, readonly) BOOL isRefreshing;

@property (nonatomic, assign, readonly) BOOL isEndRefreshAnimating;

@property (nonatomic, assign, readonly) BOOL isPanGestureBegin;

@property (nonatomic, assign) CGFloat beginAnimateDuring;

@property (nonatomic, assign) CGFloat endAnimateDuring;

@property (nonatomic, assign) BOOL isAutomaticHidden; // default NO

@property (nonatomic, assign) BOOL adjustOriginleftContentInset; // default NO

#pragma mark - init

- (instancetype)initWithHeight:(CGFloat)height type:(TYRefreshType)type animator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler;

- (instancetype)initWithType:(TYRefreshType)type animator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler; // height = animator's height


#pragma mark - super scrollView

- (UIScrollView *)superScrollView;

#pragma mark - configure scrollView

- (void)configureScrollView:(UIScrollView *)scrollView;

#pragma mark - observe scrollView

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change;

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change;

- (void)refreshViewDidChangeProgress:(CGFloat)progress;

#pragma mark - refresh

- (void)beginRefreshing;

- (void)endRefreshing;

@end
