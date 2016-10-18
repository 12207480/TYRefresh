//
//  TYFooterRefresh.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/14.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYFooterRefresh.h"
#import "TYRefreshView+TYPrivate.h"

@interface TYFooterRefresh ()

@property (nonatomic, assign) CGFloat beginRefreshOffset;

@end

@implementation TYFooterRefresh

- (instancetype)init
{
    if (self = [super init]) {
        _adjustOriginBottomContentInset = YES;
        _beginRefreshOffset = 0;
    }
    return self;
}

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
    CGFloat bottomContentInset = MAX(scrollView.contentSize.height+self.scrollViewOrignContenInset.bottom, contentOnScreenHeight) - (_adjustOriginBottomContentInset ? 0 : self.scrollViewOrignContenInset.bottom);
    self.frame = CGRectMake(originleftContentInset,
                                bottomContentInset,
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
        CGFloat willPullRefreshOffsetY = self.frame.origin.y - scrollView.frame.size.height + (_adjustOriginBottomContentInset ? 0 :  self.scrollViewOrignContenInset.bottom);
        _beginRefreshOffset =  willPullRefreshOffsetY > 0 ? willPullRefreshOffsetY : -self.scrollViewOrignContenInset.top;
        return;
    }
    
    if (!self.isPanGestureBegin) { // 没有拖拽
        return;
    }
    
    NSLog(@"beginRefreshOffset %.f contentInsetTop %.f",_beginRefreshOffset,scrollView.contentOffset.y);
    
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
