//
//  TYFooterRefresh.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/14.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYFooterRefresh.h"

@interface TYRefreshView ()

@property (nonatomic, assign) TYRefreshState state;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isEndRefreshAnimating;

@property (nonatomic, assign) BOOL isPanGestureBegin;

@property (nonatomic, assign) UIEdgeInsets scrollViewOrignContenInset;

@end

@interface TYFooterRefresh ()

@property (nonatomic, assign) CGFloat beginRefreshOffset;

@end

@implementation TYFooterRefresh

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler
{
    return [[self alloc]initWithType:TYRefreshTypeFooter animator:animator handler:handler];
}

#pragma mark - configure scrollView

- (void)configureScrollView:(UIScrollView *)scrollView
{
    [super configureScrollView:scrollView];
    
    [self adjsutFrameToScrollView:scrollView];
}

- (void)adjsutFrameToScrollView:(UIScrollView *)scrollView
{
    CGFloat originleftContentInset = self.adjustOriginleftContentInset ? -self.scrollViewOrignContenInset.left : 0;

    CGFloat contentOnScreenHeight = CGRectGetHeight(scrollView.frame) - self.scrollViewOrignContenInset.top;
    self.frame = CGRectMake(originleftContentInset,
                                MAX(scrollView.contentSize.height+self.scrollViewOrignContenInset.bottom, contentOnScreenHeight),
                                CGRectGetWidth(scrollView.bounds),
                                self.refreshHeight);
}

#pragma mark - begin refresh

// 进入刷新状态
- (void)beginRefreshing
{
    UIScrollView *scrollView = [self superScrollView];
    if (!scrollView || self.isRefreshing) {
        return;
    }
    
    self.isRefreshing = YES;
    if (self.hidden) {
        self.hidden = NO;
    }
    
    dispatch_main_async_safe_ty_refresh(^{
        [self beginRefreshingAnimationOnScrollView:scrollView];
    });
}

- (void)beginRefreshingAnimationOnScrollView:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:self.beginAnimateDuring animations:^{
        // 内容高度 是否大于scrollView的高度
        CGFloat beginRefreshOffset = scrollView.contentSize.height - (scrollView.bounds.size.height - self.scrollViewOrignContenInset.top - self.scrollViewOrignContenInset.bottom);
        CGFloat normalRefreshBottom = self.scrollViewOrignContenInset.bottom + CGRectGetHeight(self.frame);
        UIEdgeInsets contentInset = scrollView.contentInset;
        contentInset.bottom = beginRefreshOffset >= 0 ? normalRefreshBottom : normalRefreshBottom-beginRefreshOffset;
        scrollView.contentInset = contentInset;
        
    } completion:^(BOOL finished) {
        self.isPanGestureBegin = NO;
        self.state = TYRefreshStateLoading;
        if ([self.animator respondsToSelector:@selector(refreshViewDidBeginRefresh:)]) {
            [self.animator refreshViewDidBeginRefresh:self];
        }
        if (self.handler) {
            self.handler();
        }
    }];
}

// 结束刷新状态
- (void)endRefreshing
{
    UIScrollView *scrollView = [self superScrollView];
    if (!scrollView || !self.isRefreshing || self.isEndRefreshAnimating) {
        return;
    }
    
    self.isRefreshing = NO;
    self.isEndRefreshAnimating = YES;
    
    dispatch_main_async_safe_ty_refresh(^{
        [self endRefreshingAnimationOnScrollView:scrollView];
    });
}

- (void)endRefreshingAnimationOnScrollView:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:self.endAnimateDuring animations:^{
        UIEdgeInsets contentInset = scrollView.contentInset;
        contentInset.bottom = self.scrollViewOrignContenInset.bottom;
        scrollView.contentInset = contentInset;
    } completion:^(BOOL finished) {
        self.isEndRefreshAnimating = NO;
        
        if ([self.animator respondsToSelector:@selector(refreshViewDidEndRefresh:)]) {
            [self.animator refreshViewDidEndRefresh:self];
        }
        self.state = TYRefreshStateNormal;
    }];
}

#pragma mark - observe scrollView

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
    [self scrollViewContentOffsetDidChangeFooter];
}

- (void)scrollViewContentOffsetDidChangeFooter
{
    UIScrollView *scrollView = [self superScrollView];
    
    if (self.isRefreshing) {
        return;
    }
    
    self.scrollViewOrignContenInset = scrollView.contentInset;
    
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.isPanGestureBegin = YES;
        // 刷新临界点 需要判断内容高度是否大于scrollView的高度
        CGFloat willShowRefreshOffset = self.frame.origin.y - scrollView.frame.size.height;
        _beginRefreshOffset =  willShowRefreshOffset > 0 ? willShowRefreshOffset : -self.scrollViewOrignContenInset.top;
        return;
    }
    
    if (!self.isPanGestureBegin) { // 没有拖拽
        return;
    }
    
    if (scrollView.contentOffset.y < _beginRefreshOffset) {
        // 还没到刷新点
        return;
    }
    
    CGFloat progress = (scrollView.contentOffset.y - _beginRefreshOffset) / CGRectGetHeight(self.frame);
    
    [self refreshViewDidChangeProgress:progress];
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    UIScrollView *scrollView = [self superScrollView];
    if (!scrollView) {
        return;
    }

    [self adjsutFrameToScrollView:scrollView];
}

@end
