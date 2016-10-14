//
//  TYAnimatorView.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYAnimatorView.h"

#define kImageViewCenterOffsetX 20
#define kTitleLabelLeftEdging 10

typedef NS_ENUM(NSUInteger, TYArrowDirection) {
    TYArrowDirectionUp,
    TYArrowDirectionDown,
};

@interface TYAnimatorView ()

// UI
@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;

// Data
@property (nonatomic, strong) NSMutableDictionary *titleDic;

@end

@implementation TYAnimatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addTitleLabel];
        
        [self addImageView];
        
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

- (void)addImageView
{
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"refresh_arrow_down"];
    [self addSubview:imageView];
    _imageView = imageView;
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

- (void)rotateArrowDirection:(TYArrowDirection)direction animated:(BOOL)animated
{
    CGFloat animateDuring = animated ? 0.2:0.0;
    [UIView animateWithDuration:animateDuring animations:^{
        _imageView.transform = direction== TYArrowDirectionDown ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
    }];
}

- (void)configureRefreshTitleWithType:(TYRefreshType)type
{
    // 默认
    [self setTitle:type==TYRefreshTypeHeader ? @"下拉刷新" : @"上拉刷新" forState:TYRefreshStatePulling];
    [self setTitle:@"加载中..." forState:TYRefreshStateLoading];
    [self setTitle: @"松开刷新" forState:TYRefreshStateRelease];
    [self setTitle: @"加载失败" forState:TYRefreshStateError];
    [self setTitle: @"没有更多了" forState:TYRefreshStateNoMore];
}

#pragma mark - TYRefreshAnimator

- (void)refreshViewDidPrepareRefresh:(TYRefreshView *)refreshView
{
    [self rotateArrowDirection:refreshView.type==TYRefreshTypeHeader ? TYArrowDirectionDown:TYArrowDirectionUp animated:NO];
    
    if (_titleDic.count == 0) {
        [self configureRefreshTitleWithType:refreshView.type];
    }
}

- (void)refreshView:(TYRefreshView *)refreshView didChangeFromState:(TYRefreshState)fromState toState:(TYRefreshState)toState
{
    _imageView.hidden = toState == TYRefreshStateLoading;
    _titleLabel.text = [self titleForState:toState];
    switch (toState) {
        case TYRefreshStateNormal:
            [self rotateArrowDirection:refreshView.type==TYRefreshTypeHeader ? TYArrowDirectionDown:TYArrowDirectionUp animated:NO];
            break;
        case TYRefreshStateLoading:
            
            break;
        case TYRefreshStatePulling:
            if (fromState == TYRefreshStateRelease) {
                [self rotateArrowDirection:refreshView.type==TYRefreshTypeHeader ? TYArrowDirectionDown:TYArrowDirectionUp animated:YES];
            }
        case TYRefreshStateRelease:
            if (fromState == TYRefreshStatePulling) {
                [self rotateArrowDirection:refreshView.type==TYRefreshTypeHeader ? TYArrowDirectionUp:TYArrowDirectionDown animated:YES];
            }
        default:
            break;
    }
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
    _imageView.frame = CGRectMake(0, 0, _imageView.image.size.width, _imageView.image.size.height);
    CGFloat imageWidth = MAX(MAX(CGRectGetWidth(_imageView.frame)/2, CGRectGetWidth(_indicatorView.frame)/2), 20);
    _indicatorView.center = CGPointMake(CGRectGetWidth(self.frame)/2 - kImageViewCenterOffsetX - imageWidth , CGRectGetHeight(self.frame)/2);
    _imageView.center = _indicatorView.center;
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_indicatorView.frame)+kTitleLabelLeftEdging, 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(_indicatorView.frame) - kTitleLabelLeftEdging , CGRectGetHeight(self.frame));
}

@end
