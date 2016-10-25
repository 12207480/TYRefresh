//
//  TYAutoAnimatorView.h
//  TYRefreshDemo
//
//  Created by tany on 16/10/25.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYRefreshView.h"

@interface TYAutoAnimatorView : UIView<TYRefreshAnimator>

@property (nonatomic, weak, readonly) UILabel *titleLabel;

@property (nonatomic, weak, readonly) UIActivityIndicatorView *indicatorView;

- (instancetype)initWithHeight:(CGFloat)height;

- (void)setTitle:(NSString *)title forState:(TYRefreshState)state;

@end
