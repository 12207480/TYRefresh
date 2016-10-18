//
//  TYHeaderRefresh.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/14.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYHeaderRefresh.h"

@interface TYRefreshView ()

@property (nonatomic, assign) TYRefreshState state;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isPanGestureBegin;

@property (nonatomic, assign) BOOL isEndRefreshAnimating;

@property (nonatomic, assign) UIEdgeInsets scrollViewOrignContenInset;

@end

@interface TYHeaderRefresh ()

@end


@implementation TYHeaderRefresh

+ (instancetype)headerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler
{
    return [[self alloc]initWithType:TYRefreshTypeHeader animator:animator handler:handler];
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
    CGFloat adjustTopContentInset = self.adjustOriginTopContentInset ? [self adjustsViewControllerScrollViewTopInset:scrollView] : 0;
    self.frame = CGRectMake(originleftContentInset,
                                -self.refreshHeight-self.scrollViewOrignContenInset.top+adjustTopContentInset,
                                CGRectGetWidth(scrollView.bounds),
                                self.refreshHeight);

}

- (CGFloat)adjustsViewControllerScrollViewTopInset:(UIScrollView *)scrollView
{
    UIViewController *VC = nil;
    if (scrollView.superview) {
        UIResponder* nextResponder = [scrollView.superview nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]]) {
            VC = (UIViewController *)nextResponder;
        }
    }
    if (VC && VC.automaticallyAdjustsScrollViewInsets) {
        return VC.navigationController.navigationBarHidden || scrollView.contentInset.top < 64 ? 0 : 64;
    }
    return 0;
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
        UIEdgeInsets contentInset = scrollView.contentInset;
            contentInset.top = self.scrollViewOrignContenInset.top + CGRectGetHeight(self.frame);
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
        contentInset.top = self.scrollViewOrignContenInset.top;
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
    
    [self scrollViewContentOffsetDidChangeHeader];
}

- (void)scrollViewContentOffsetDidChangeHeader
{
    UIScrollView *scrollView = [self superScrollView];
    if (self.isRefreshing) {
        // 处理 section header
        CGFloat contentInsetTop = scrollView.contentOffset.y > -self.scrollViewOrignContenInset.top ? self.scrollViewOrignContenInset.top : -scrollView.contentOffset.y;
        UIEdgeInsets contentInset = scrollView.contentInset;
        contentInset.top = MIN(self.scrollViewOrignContenInset.top + CGRectGetHeight(self.frame), contentInsetTop);
        scrollView.contentInset = contentInset;
        return;
    }
    
    if (self.isEndRefreshAnimating) {
        // 结束动画
        return;
    }
    
    BOOL isChangeContentInsetTop = self.scrollViewOrignContenInset.top != scrollView.contentInset.top;
    self.scrollViewOrignContenInset = scrollView.contentInset;
    if (isChangeContentInsetTop) {
        [self adjsutFrameToScrollView:scrollView];
    }
    
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.isPanGestureBegin = YES;
        return;
    }
    
    if (!self.isPanGestureBegin) { // 没有拖拽
        return;
    }
    
    if (scrollView.contentOffset.y > -self.scrollViewOrignContenInset.top) { // 还没到临界点
        return;
    }
    
    CGFloat progress = (-self.scrollViewOrignContenInset.top - scrollView.contentOffset.y) / CGRectGetHeight(self.frame);
    
    [self refreshViewDidChangeProgress:progress];
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    CGSize oldContentSize = [[change valueForKey:NSKeyValueChangeOldKey] CGSizeValue];
    CGSize newContentSize = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];
    
    UIScrollView *scrollView = [self superScrollView];
    if (CGSizeEqualToSize(oldContentSize, newContentSize) || !scrollView) {
        return;
    }
    
    if (oldContentSize.width != newContentSize.width) {
        CGRect frame = self.frame;
        frame.size.width = CGRectGetWidth(scrollView.bounds);
        self.frame = frame;
    }
}

@end