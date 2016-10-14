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
    
    [self configureTableView];
    
    [self loadData];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
//    _tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
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

- (void)configureTableView
{
    _tableView.contentInset = UIEdgeInsetsMake(20, 0, 60, 0);
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    
    __weak typeof(self) weakSelf = self;
    _tableView.ty_refreshHeader = [TYRefreshView headerWithAnimator:_isGifRefresh ?[TYGifAnimatorView new] : [TYAnimatorView new]  handler:^{
        NSLog(@"上拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadData];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.ty_refreshHeader endRefreshing];
        });
    }];
    
    _tableView.ty_refreshFooter = [TYRefreshView footerWithAnimator:_isGifRefresh ?[TYGifAnimatorView new] : [TYAnimatorView new] handler:^{
        NSLog(@"下拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadMoreData];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.ty_refreshFooter endRefreshing];
        });
    }];

}

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
