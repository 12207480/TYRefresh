//
//  TYAutoAnimatorView.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/25.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYAutoAnimatorView.h"

#define kImageViewCenterOffsetX 20
#define kTitleLabelLeftEdging 10

@interface TYAutoAnimatorView ()

// UI
@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;

// Data
@property (nonatomic, strong) NSMutableDictionary *titleDic;

@end

@implementation TYAutoAnimatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addTitleLabel];
        
        [self addIndicatorView];
    }
    return self;
}

- (instancetype)initWithHeight:(CGFloat)height
{
    return [self initWithFrame:CGRectMake(0, 0, 0, height)];
}

- (void)addTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
}

- (void)addIndicatorView
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.hidesWhenStopped = YES;
    [self addSubview:indicatorView];
    _indicatorView = indicatorView;
}

- (NSMutableDictionary *)titleDic
{
    if (!_titleDic) {
        _titleDic = [NSMutableDictionary dictionary];
    }
    return _titleDic;
}

#pragma mark - public

- (void)setTitle:(NSString *)title forState:(TYRefreshState)state
{
    [self.titleDic setObject:title ? title : @"" forKey:@(state)];
}

- (NSString *)titleForState:(TYRefreshState)state
{
    return [self.titleDic objectForKey:@(state)];
}

#pragma mark - private

- (void)configureRefreshTitleWithType:(TYRefreshType)type
{
    // 默认
    [self setTitle: type==TYRefreshTypeHeader ? @"下拉自动加载" : @"上拉自动加载" forState:TYRefreshStateNormal];
    [self setTitle: @"加载中..." forState:TYRefreshStatePulling];
    [self setTitle: @"加载中..." forState:TYRefreshStateLoading];
    [self setTitle: @"加载中..." forState:TYRefreshStateRelease];
    [self setTitle: @"加载失败" forState:TYRefreshStateError];
    [self setTitle: @"没有更多了" forState:TYRefreshStateNoMore];
}

#pragma mark - TYRefreshAnimator

- (void)refreshViewDidPrepareRefresh:(TYRefreshView *)refreshView
{
    if (_titleDic.count == 0) {
        [self configureRefreshTitleWithType:refreshView.type];
    }
}

- (void)refreshView:(TYRefreshView *)refreshView didChangeFromState:(TYRefreshState)fromState toState:(TYRefreshState)toState
{
    _titleLabel.text = [self titleForState:toState];
}

- (void)refreshViewDidBeginRefresh:(TYRefreshView *)refreshView
{
    [_indicatorView startAnimating];
}

- (void)refreshViewDidEndRefresh:(TYRefreshView *)refreshView
{
    [_indicatorView stopAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat imageWidth = MAX(CGRectGetWidth(_indicatorView.frame)/2, 20);
    _indicatorView.center = CGPointMake(CGRectGetWidth(self.frame)/2 - kImageViewCenterOffsetX - imageWidth , CGRectGetHeight(self.frame)/2);
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_indicatorView.frame)+kTitleLabelLeftEdging, 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(_indicatorView.frame) - kTitleLabelLeftEdging , CGRectGetHeight(self.frame));
}

@end
