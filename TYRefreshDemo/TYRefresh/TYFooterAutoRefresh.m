//
//  TYFooterAutoRefresh.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/18.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYFooterAutoRefresh.h"
#import "TYRefreshView+Extension.h"

@interface TYFooterAutoRefresh ()

@property (nonatomic, assign) CGFloat beginRefreshOffset;

@property (nonatomic, assign) UIEdgeInsets scrollViewAdjustContenInset;

@end

@implementation TYFooterAutoRefresh

- (instancetype)init
{
    if (self = [super init]) {
        _adjustOriginBottomContentInset = YES;
        _autoRefreshWhenScrollProgress = 0;
    }
    return self;
}

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler
{
    return [[self alloc]initWithType:TYRefreshTypeFooter animator:animator handler:handler];
}

- (void)configureScrollView:(UIScrollView *)scrollView
{
    [super configureScrollView:scrollView];
    
    [self configureAdjustScrollViewContentInset:scrollView];
    
    
}

- (void)configureAdjustScrollViewContentInset:(UIScrollView *)scrollView
{
    UIEdgeInsets  scrollViewAdjustContenInset = self.scrollViewOrignContenInset;
    scrollViewAdjustContenInset.bottom += self.refreshHeight;
    _scrollViewAdjustContenInset = scrollViewAdjustContenInset;
    scrollView.contentInset = _scrollViewAdjustContenInset;
}

- (void)adjsutFrameToScrollView:(UIScrollView *)scrollView
{
    CGFloat originleftContentInset = self.adjustOriginleftContentInset ? -self.scrollViewOrignContenInset.left : 0;
    
    CGFloat contentOnScreenHeight = CGRectGetHeight(scrollView.frame) - self.scrollViewOrignContenInset.top;
    CGFloat bottomContentInset = MAX(scrollView.contentSize.height+self.scrollViewOrignContenInset.bottom, contentOnScreenHeight-self.refreshHeight) - (_adjustOriginBottomContentInset ? 0 : self.scrollViewOrignContenInset.bottom);
    self.frame = CGRectMake(originleftContentInset,
                            bottomContentInset,
                            CGRectGetWidth(scrollView.bounds),
                            self.refreshHeight);
}

- (void)setScrollViewAdjustContenInset:(UIEdgeInsets)scrollViewAdjustContenInset
{
    _scrollViewAdjustContenInset = scrollViewAdjustContenInset;
    scrollViewAdjustContenInset.bottom -= self.refreshHeight;
    self.scrollViewOrignContenInset = scrollViewAdjustContenInset;
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
    
    self.isPanGestureBegin = NO;
    self.state = TYRefreshStateLoading;
    if ([self.animator respondsToSelector:@selector(refreshViewDidBeginRefresh:)]) {
        [self.animator refreshViewDidBeginRefresh:self];
    }
    if (self.handler) {
        self.handler();
    }
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
    self.isEndRefreshAnimating = NO;
    
    if ([self.animator respondsToSelector:@selector(refreshViewDidEndRefresh:)]) {
        [self.animator refreshViewDidEndRefresh:self];
    }
    self.state = TYRefreshStateNormal;
}

#pragma mark - observe scrollView

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    if (![self superScrollView] || self.hidden) {
        return;
    }
    
    [self scrollViewContentOffsetDidChangeFooter];
}

- (void)scrollViewContentOffsetDidChangeFooter
{
    UIScrollView *scrollView = [self superScrollView];
    
    if (self.isRefreshing) {
        return;
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(_scrollViewAdjustContenInset, scrollView.contentInset)) {
        self.scrollViewAdjustContenInset = scrollView.contentInset;
    }
    
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
    
    if (scrollView.contentOffset.y < _beginRefreshOffset) {
        // 还没到刷新点
        return;
    }
    
    CGFloat progress = (scrollView.contentOffset.y - _beginRefreshOffset) / CGRectGetHeight(self.frame);
    
    [self refreshViewDidChangeProgress:progress];
}

- (void)refreshViewDidChangeProgress:(CGFloat)progress
{
    if ([self superScrollView].isDragging && self.state == TYRefreshStateNormal) {
        if (progress >= _autoRefreshWhenScrollProgress) {
            [self beginRefreshing];
        }
    }
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
