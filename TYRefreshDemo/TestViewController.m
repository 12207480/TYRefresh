//
//  TestViewController.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TestViewController.h"
#import "UIScrollView+TYRefresh.h"

@interface TestViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *testData;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    [self addTableView];
    
    if (_isAutoFooterRefresh) {
        [self configureAutoFooterRefesh];
    }else {
        [self configureNormalRefesh];
    }
    
    [self loadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)addTableView
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    _tableView = tableView;
}

#pragma mark - normalRefesh

- (TYGifAnimatorView *)gifAnimatorView
{
    TYGifAnimatorView *gifAnimatorView = [TYGifAnimatorView new];
    // 最好在 initialize 做成static 复用
    NSMutableArray *pullingImages = [NSMutableArray array];
    for (int i = 0; i< 60; ++i) {
        [pullingImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%d",i+1]]];
    }
    [gifAnimatorView setGifImages:[pullingImages copy] forState:TYRefreshStatePulling];
    
    // 最好在 initialize 做成static 复用
    NSMutableArray *loadingImages = [NSMutableArray array];
    for (int i = 0; i< 3; ++i) {
        [loadingImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%d",i+1]]];
    }
    
    [gifAnimatorView setGifImages:[loadingImages copy] forState:TYRefreshStateLoading];
    return gifAnimatorView;
}

- (void)configureNormalRefesh
{
    _tableView.contentInset = UIEdgeInsetsMake(20, 0, 40, 0);
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    
    __weak typeof(self) weakSelf = self;
    _tableView.ty_refreshHeader = [TYHeaderRefresh headerWithAnimator:_isGifRefresh ?[self gifAnimatorView] : [TYAnimatorView new]  handler:^{
        NSLog(@"下拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadData];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.ty_refreshFooter resetNormalState];
            [weakSelf.tableView.ty_refreshHeader endRefreshing];
        });
    }];
    
    _tableView.ty_refreshFooter = [TYFooterRefresh footerWithAnimator:_isGifRefresh ?[self gifAnimatorView] : [TYAnimatorView new] handler:^{
        NSLog(@"上拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadMoreData];
            [weakSelf.tableView reloadData];
            if (weakSelf.testData.count < 20) {
                 [weakSelf.tableView.ty_refreshFooter endRefreshing];
            }else {
                [weakSelf.tableView.ty_refreshFooter endRefreshingWithNoMoreData];
            }
        });
    }];

}

#pragma mark - auto footer refresh

- (TYAutoAnimatorView *)autoGifAnimatorView
{
    TYAutoAnimatorView *autoGifAnimatorView = [TYAutoAnimatorView new];
    // 最好在 initialize 做成static 复用
    NSMutableArray *loadingImages = [NSMutableArray array];
    for (int i = 0; i< 3; ++i) {
        [loadingImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%d",i+1]]];
    }
    [autoGifAnimatorView setLoadingImages:[loadingImages copy]];
    return autoGifAnimatorView;
}

- (void)configureAutoFooterRefesh
{
    _tableView.contentInset = UIEdgeInsetsMake(20, 0, 40, 0);
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    
    __weak typeof(self) weakSelf = self;
    _tableView.ty_refreshHeader = [TYHeaderRefresh headerWithAnimator:_isGifRefresh ?[self gifAnimatorView] : [TYAnimatorView new]  handler:^{
        NSLog(@"下拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadData];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.ty_refreshFooter resetNormalState];
            [weakSelf.tableView.ty_refreshHeader endRefreshing];
        });
    }];
    
    _tableView.ty_refreshFooter = [TYFooterAutoRefresh footerWithAnimator:_isGifRefresh ?[self autoGifAnimatorView] : [TYAutoAnimatorView new] handler:^{
        NSLog(@"上拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadMoreData];
            [weakSelf.tableView reloadData];
            if (weakSelf.testData.count < 20) {
                [weakSelf.tableView.ty_refreshFooter endRefreshing];
            }else {
                [weakSelf.tableView.ty_refreshFooter endRefreshingWithNoMoreData];
            }
        });
    }];
}

#pragma mark - load data

- (void)loadData
{
    _testData = [NSMutableArray array];
    for (int i = 0; i <= 10; ++i) {
        [_testData addObject:[NSString stringWithFormat:@"测试数据 row：%d",i]];
    }
}

- (void)loadMoreData
{
    int count = (int)_testData.count;
    for (int i = 0; i <= 6; ++i) {
        [_testData addObject:[NSString stringWithFormat:@"测试数据 row：%d",i+count]];
    }
}

#pragma mark - datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _testData.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"headerView";
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.textLabel.text = _testData[indexPath.row];
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
