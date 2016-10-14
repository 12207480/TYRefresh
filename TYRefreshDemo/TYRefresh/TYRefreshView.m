//
//  TYRefreshView.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/10.
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

// scrollView KVO
static NSString *const kTYRefreshContentOffsetKey = @"contentOffset";
static NSString *const kTYRefreshContentSizeKey = @"contentSize";
static char kTYRefreshContentKey;

#define kRefreshViewHeight 60

@interface TYRefreshView ()

@property (nonatomic, assign) TYRefreshState state;

@property (nonatomic, assign) TYRefreshType type;

@property (nonatomic, copy) TYRefresHandler handler;

@property (nonatomic, strong) UIView<TYRefreshAnimator> *animator;

@property (nonatomic, assign) CGFloat refreshHeight;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isEndRefreshAnimating;

@property (nonatomic, assign) BOOL isPanGestureBegin;

@property (nonatomic, assign) CGFloat beginRefreshOffset;

@property (nonatomic, assign) UIEdgeInsets scrollViewOrignContenInset;

@end

@implementation TYRefreshView

- (instancetype)init
{
    if (self = [super init]) {
        _beginAnimateDuring = 0.25;
        _endAnimateDuring = 0.25;
        _adjustOriginTopContentInset = YES;
        _adjustOriginleftContentInset = NO;
    }
    return self;
}

- (instancetype)initWithHeight:(CGFloat)height type:(TYRefreshType)type animator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler
{
    if (self = [self init]) {
        _refreshHeight = height;
        _type = type;
        _animator = animator;
        _handler = handler;
        
        [self addAnimatorView];
    }
    return self;
}

- (instancetype)initWithType:(TYRefreshType)type animator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler
{
    return [self initWithHeight:CGRectGetHeight(animator.frame) > 0 ? CGRectGetHeight(animator.frame) : kRefreshViewHeight type:type animator:animator handler:handler];
}

+ (instancetype)headerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler
{
    return [[self alloc]initWithType:TYRefreshTypeHeader animator:animator handler:handler];
}

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler
{
    return [[self alloc]initWithType:TYRefreshTypeFooter animator:animator handler:handler];
}

#pragma mark - getter

- (UIScrollView *)superScrollView
{
    if (self.superview && [self.superview isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)self.superview;
    }
    return nil;
}

#pragma mark - setter

- (void)setState:(TYRefreshState)state
{
    if (state == TYRefreshStateNormal) {
        self.hidden = _isAutomaticHidden;
    }
    
    if (_state != state) {
        TYRefreshState oldState = _state;
        _state = state;
        if ([_animator respondsToSelector:@selector(refreshView:didChangeFromState:toState:)]) {
            [_animator refreshView:self didChangeFromState:oldState toState:state];
        }
    }
}

#pragma mark - add subview

- (void)addAnimatorView
{
    NSAssert(_animator != nil, @"animator can't nil!");
    NSAssert([_animator isKindOfClass:[UIView class]], @"animator must is UIView subClass!");

    [self addSubview:_animator];
    
    [self addConstraintWithView:_animator edgeInset:UIEdgeInsetsZero];
    
    if ([_animator respondsToSelector:@selector(refreshViewDidPrepareRefresh:)]) {
        [_animator refreshViewDidPrepareRefresh:self];
    }
}

- (void)addConstraintWithView:(UIView *)view edgeInset:(UIEdgeInsets)edgeInset
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:edgeInset.top]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:edgeInset.left]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:edgeInset.right]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:edgeInset.bottom]];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    UIScrollView *scrollView = [self superScrollView];
    if (scrollView) {
        [self removeObserverScrollView:scrollView];
    }
    
    if (newSuperview && [newSuperview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)newSuperview;
        
        [self addObserverScrollView:scrollView];
        
        [self configureScrollView:scrollView];
    }
}

- (void)configureScrollView:(UIScrollView *)scrollView
{
    scrollView.alwaysBounceVertical = YES;
    _scrollViewOrignContenInset = scrollView.contentInset;
    
    [self adjsutFrameToScrollView:scrollView];
}

- (void)adjsutFrameToScrollView:(UIScrollView *)scrollView
{
    CGFloat originleftContentInset = _adjustOriginleftContentInset ? -_scrollViewOrignContenInset.left : 0;
    if (_type == TYRefreshTypeHeader) {
        CGFloat adjustTopContentInset = _adjustOriginTopContentInset ? [self adjustsViewControllerScrollViewTopInset:scrollView] : 0;
        self.frame = CGRectMake(originleftContentInset,
                                -_refreshHeight-_scrollViewOrignContenInset.top+adjustTopContentInset,
                                CGRectGetWidth(scrollView.bounds),
                                _refreshHeight);
    }else {
        CGFloat contentOnScreenHeight = CGRectGetHeight(scrollView.frame) - _scrollViewOrignContenInset.top;
        NSLog(@"origin %@ Height %.f",NSStringFromUIEdgeInsets(_scrollViewOrignContenInset),contentOnScreenHeight);
        self.frame = CGRectMake(originleftContentInset,
                                MAX(scrollView.contentSize.height+_scrollViewOrignContenInset.bottom, contentOnScreenHeight),
                                CGRectGetWidth(scrollView.bounds),
                                _refreshHeight);
    }
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

#pragma mark - refresh

// 进入刷新状态
- (void)beginRefreshing
{
    UIScrollView *scrollView = [self superScrollView];
    if (!scrollView || _isRefreshing) {
        return;
    }
    
    _isRefreshing = YES;
    if (self.hidden) {
        self.hidden = NO;
    }
    
    [self beginRefreshingAnimationOnScrollView:scrollView];
}

- (void)beginRefreshingAnimationOnScrollView:(UIScrollView *)scrollView
{
    dispatch_main_async_safe_ty_refresh(^{
        [UIView animateWithDuration:_beginAnimateDuring animations:^{
            if (_type == TYRefreshTypeHeader) {
                UIEdgeInsets contentInset = scrollView.contentInset;
                contentInset.top = _scrollViewOrignContenInset.top + CGRectGetHeight(self.frame);
                scrollView.contentInset = contentInset;
            }else {
                // 内容高度 是否大于scrollView的高度
                CGFloat beginRefreshOffset = scrollView.contentSize.height - (scrollView.bounds.size.height - _scrollViewOrignContenInset.top - _scrollViewOrignContenInset.bottom);
                CGFloat normalRefreshBottom = _scrollViewOrignContenInset.bottom + CGRectGetHeight(self.frame);
                UIEdgeInsets contentInset = scrollView.contentInset;
                contentInset.bottom = beginRefreshOffset >= 0 ? normalRefreshBottom : normalRefreshBottom-beginRefreshOffset;
                scrollView.contentInset = contentInset;
            }
            
        } completion:^(BOOL finished) {
            _isPanGestureBegin = NO;
            self.state = TYRefreshStateLoading;
            if ([_animator respondsToSelector:@selector(refreshViewDidBeginRefresh:)]) {
                [_animator refreshViewDidBeginRefresh:self];
            }
            if (_handler) {
                _handler();
            }
        }];
    });

}

// 结束刷新状态
- (void)endRefreshing
{
    UIScrollView *scrollView = [self superScrollView];
    if (!scrollView || !_isRefreshing || _isEndRefreshAnimating) {
        return;
    }
    
    _isRefreshing = NO;
    _isEndRefreshAnimating = YES;
    
    [self endRefreshingAnimationOnScrollView:scrollView];
}

- (void)endRefreshingAnimationOnScrollView:(UIScrollView *)scrollView
{
     dispatch_main_async_safe_ty_refresh(^{
          [UIView animateWithDuration:_endAnimateDuring animations:^{
              UIEdgeInsets contentInset = scrollView.contentInset;
              if (_type == TYRefreshTypeHeader) {
                  contentInset.top = _scrollViewOrignContenInset.top;
              }else {
                  contentInset.bottom = _scrollViewOrignContenInset.bottom;
              }
              scrollView.contentInset = contentInset;
          } completion:^(BOOL finished) {
              _isEndRefreshAnimating = NO;
              
              if ([_animator respondsToSelector:@selector(refreshViewDidEndRefresh:)]) {
                  [_animator refreshViewDidEndRefresh:self];
              }
              self.state = TYRefreshStateNormal;
          }];
     });
}

#pragma mark - Observer scrollView

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context != &kTYRefreshContentKey) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:kTYRefreshContentOffsetKey]) {
        [self scrollViewContentOffsetDidChange:change];
    }else if ([keyPath isEqualToString:kTYRefreshContentSizeKey]) {
        [self scrollViewContentSizeDidChange:change];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    if (![self superScrollView] || self.hidden) {
        return;
    }
    
    if (_type == TYRefreshTypeHeader) {
        [self scrollViewContentOffsetDidChangeHeader];
    }else {
        [self scrollViewContentOffsetDidChangeFooter];
    }
}

- (void)scrollViewContentOffsetDidChangeHeader
{
    UIScrollView *scrollView = [self superScrollView];
    if (_isRefreshing) {
        // 处理 section header
        CGFloat contentInsetTop = scrollView.contentOffset.y > -_scrollViewOrignContenInset.top ? _scrollViewOrignContenInset.top : -scrollView.contentOffset.y;
        UIEdgeInsets contentInset = scrollView.contentInset;
        contentInset.top = MIN(_scrollViewOrignContenInset.top + CGRectGetHeight(self.frame), contentInsetTop);
        scrollView.contentInset = contentInset;
        return;
    }
    
    if (_isEndRefreshAnimating) {
        // 结束动画
        return;
    }
    
    BOOL isChangeContentInsetTop = _scrollViewOrignContenInset.top != scrollView.contentInset.top;
    _scrollViewOrignContenInset = scrollView.contentInset;
    if (isChangeContentInsetTop) {
        [self adjsutFrameToScrollView:scrollView];
    }
    
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _isPanGestureBegin = YES;
        return;
    }
    
    if (!_isPanGestureBegin) { // 没有拖拽
        return;
    }
    
    if (scrollView.contentOffset.y > -_scrollViewOrignContenInset.top) { // 还没到临界点
        return;
    }
    
    CGFloat progress = (-_scrollViewOrignContenInset.top - scrollView.contentOffset.y) / CGRectGetHeight(self.frame);
    
    [self refreshViewDidChangeProgress:progress];
}

- (void)scrollViewContentOffsetDidChangeFooter
{
    UIScrollView *scrollView = [self superScrollView];
    
    if (_isRefreshing) {
        return;
    }
    
    _scrollViewOrignContenInset = scrollView.contentInset;
    
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _isPanGestureBegin = YES;
        // 刷新临界点 需要判断内容高度是否大于scrollView的高度
        CGFloat willShowRefreshOffset = self.frame.origin.y - scrollView.frame.size.height;
        _beginRefreshOffset =  willShowRefreshOffset > 0 ? willShowRefreshOffset : -_scrollViewOrignContenInset.top;
        return;
    }
    
    if (!_isPanGestureBegin) { // 没有拖拽
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
    if ([self superScrollView].isDragging) {
        
        if (progress >= 1.0) {
            self.state = TYRefreshStateRelease;
        }else if (progress <= 0.0) {
            self.state = TYRefreshStateNormal;
        }else {
            self.state = TYRefreshStatePulling;
        }
    }else if (self.state == TYRefreshStateRelease) {
        [self beginRefreshing];
    }else {
        if (progress <= 0.0) {
            self.state = TYRefreshStateNormal;
        }
    }
    
    if ([_animator respondsToSelector:@selector(refreshView:didChangeProgress:)]) {
        [_animator refreshView:self didChangeProgress:MAX(MIN(progress, 1.0), 0.0)];
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    CGSize oldContentSize = [[change valueForKey:NSKeyValueChangeOldKey] CGSizeValue];
    CGSize newContentSize = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];
    
    UIScrollView *scrollView = [self superScrollView];
    if ((CGSizeEqualToSize(oldContentSize, newContentSize) && _type != TYRefreshTypeFooter) || !scrollView) {
        return;
    }
    if (_type == TYRefreshTypeFooter) {
        [self adjsutFrameToScrollView:scrollView];
    }else if (oldContentSize.width != newContentSize.width) {
        CGRect frame = self.frame;
        frame.size.width = CGRectGetWidth(scrollView.bounds);
        self.frame = frame;
    }
}

- (void)removeObserverScrollView:(UIScrollView *)scrollView
{
    [scrollView removeObserver:self forKeyPath:kTYRefreshContentOffsetKey context:&kTYRefreshContentKey];
    [scrollView removeObserver:self forKeyPath:kTYRefreshContentSizeKey context:&kTYRefreshContentKey];
}

- (void)addObserverScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:kTYRefreshContentOffsetKey options:NSKeyValueObservingOptionInitial context:&kTYRefreshContentKey];
    [scrollView addObserver:self forKeyPath:kTYRefreshContentSizeKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&kTYRefreshContentKey];
}

- (void)dealloc
{
    UIScrollView *scrollView = [self superScrollView];
    if (scrollView) {
        [self removeObserverScrollView:scrollView];
    }
}

@end
