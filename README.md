# TYRefresh
a simple way to use pull-to-refresh ,easy way to customize loading animation.<br>
简单，强大的上下拉刷新，支持自动上拉加载，支持自定义加载动画。

更详细的使用请看demo 和 [LovePlayNews](https://github.com/12207480/LovePlayNews)项目

## Requirements
* Xcode 7 or higher
* iOS 7.0 or higher
* ARC

### ScreenShot

* 普通上下拉刷新
<br>![image](https://github.com/12207480/TYRefresh/blob/master/ScreenShot/TYRefresh.gif)

* 自动上下拉刷新
<br>![image](https://github.com/12207480/TYRefresh/blob/master/ScreenShot/TYRefresh1.gif)

* 上下拉刷新没有更多数据和失败状态
<br>![image](https://github.com/12207480/TYRefresh/blob/master/ScreenShot/TYRefresh2.gif)

* 上下拉刷新自适应设置contentInset
<br>![image](https://github.com/12207480/TYRefresh/blob/master/ScreenShot/TYRefresh3.gif)

## Usage

```objc

@interface UIScrollView (TYRefresh)

@property (nonatomic, strong) TYRefreshView *ty_refreshHeader;

@property (nonatomic, strong) TYRefreshView *ty_refreshFooter;

@end

@interface TYHeaderRefresh : TYRefreshView

+ (instancetype)headerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler;

+ (instancetype)headerWithAnimator:(UIView<TYRefreshAnimator> *)animator target:(id)target action:(SEL)action;

@interface TYFooterRefresh : TYRefreshView

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler;

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator target:(id)target action:(SEL)action;

// 自动刷新footer
@interface TYFooterAutoRefresh : TYRefreshView

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator handler:(TYRefresHandler)handler;

+ (instancetype)footerWithAnimator:(UIView<TYRefreshAnimator> *)animator target:(id)target action:(SEL)action;

```


### Contact
如果你发现bug，please pull reqeust me <br>
如果你有更好的改进，please pull reqeust me <br>

