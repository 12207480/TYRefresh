//
//  TestViewController.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TestViewController.h"
#import "TYRefresh.h"

@interface TestViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *testData;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (_isCollectionView) {
        [self addCollectionView];
    }else {
        [self addTableView];
    }
    
    if (_isAutoFooterRefresh) {
        [self configureAutoFooterRefesh];
    }else {
        [self configureNormalRefesh];
    }
    
    if (!_isAutoBeginRefresh) {
        [self loadData];
    }else if (_isCollectionView) {
        [_collectionView.ty_refreshHeader beginRefreshing];
    }else {
        [_tableView.ty_refreshHeader beginRefreshing];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
    _collectionView.frame = self.view.bounds;
}

- (void)addTableView
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
}

- (void)addCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collectionCellId"];
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
    if (_setOrignContentInset) {
        if (_collectionView) {
            _collectionView.contentInset = UIEdgeInsetsMake(60, 0, 60, 0);
        }else {
            _tableView.contentInset = UIEdgeInsetsMake(60, 0, 60, 0);
        }
    }
    
    __weak typeof(self) weakSelf = self;
    TYHeaderRefresh *headerRefresh = [TYHeaderRefresh headerWithAnimator:_isGifRefresh ?[self gifAnimatorView] : [TYAnimatorView new]  handler:^{
        NSLog(@"下拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL errorState = weakSelf.haveNoMoreAndErrorRefresh && weakSelf.testData.count > 20;
            [weakSelf loadData];

            if (weakSelf.collectionView) {
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.ty_refreshFooter resetNormalState];
                if (errorState) {
                    [weakSelf.collectionView.ty_refreshHeader endRefreshingWithError];
                }else {
                    [weakSelf.collectionView.ty_refreshHeader endRefreshing];
                }                
            }else {
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.ty_refreshFooter resetNormalState];
                if (errorState) {
                    [weakSelf.tableView.ty_refreshHeader endRefreshingWithError];
                }else {
                    [weakSelf.tableView.ty_refreshHeader endRefreshing];
                }
            }
        });
    }];
    
    if (_isCollectionView) {
        _collectionView.ty_refreshHeader = headerRefresh;
    }else {
        _tableView.ty_refreshHeader = headerRefresh;
    }
    
    TYFooterRefresh *footerRefresh = [TYFooterRefresh footerWithAnimator:_isGifRefresh ?[self gifAnimatorView] : [TYAnimatorView new] handler:^{
        NSLog(@"上拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadMoreData];
            if (weakSelf.collectionView) {
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.ty_refreshHeader resetNormalState];
                if (weakSelf.testData.count > 30 && weakSelf.haveNoMoreAndErrorRefresh) {
                    [weakSelf.collectionView.ty_refreshFooter endRefreshingWithNoMoreData];
                }else {
                    [weakSelf.collectionView.ty_refreshFooter endRefreshing];
                }
            }else {
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.ty_refreshHeader resetNormalState];
                if (weakSelf.testData.count > 20 && weakSelf.haveNoMoreAndErrorRefresh) {
                    [weakSelf.tableView.ty_refreshFooter endRefreshingWithNoMoreData];
                }else {
                    [weakSelf.tableView.ty_refreshFooter endRefreshing];
                }
            }
        });
    }];
    
    if (_setOrignContentInset) {
        headerRefresh.adjustOriginTopContentInset = _adjustOrignContentInset;
        footerRefresh.adjustOriginBottomContentInset = _adjustOrignContentInset;
    }
    
    if (_isCollectionView) {
        _collectionView.ty_refreshFooter = footerRefresh;
    }else {
        _tableView.ty_refreshFooter = footerRefresh;
    }
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
    if (_setOrignContentInset) {
        if (_collectionView) {
            _collectionView.contentInset = UIEdgeInsetsMake(60, 0, 60, 0);
        }else {
            _tableView.contentInset = UIEdgeInsetsMake(60, 0, 60, 0);
        }
    }
    
    __weak typeof(self) weakSelf = self;
    TYHeaderRefresh *headerRefresh = [TYHeaderRefresh headerWithAnimator:_isGifRefresh ?[self gifAnimatorView] : [TYAnimatorView new]  handler:^{
        NSLog(@"下拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadData];
            
            if (weakSelf.isCollectionView) {
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.ty_refreshFooter resetNormalState];
                [weakSelf.collectionView.ty_refreshHeader endRefreshing];
            }else {
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.ty_refreshFooter resetNormalState];
                [weakSelf.tableView.ty_refreshHeader endRefreshing];
            }
        });
    }];
    
    if (_isCollectionView) {
        _collectionView.ty_refreshHeader = headerRefresh;
    }else {
        _tableView.ty_refreshHeader = headerRefresh;
    }
    
    TYFooterAutoRefresh *footerRefresh = [TYFooterAutoRefresh footerWithAnimator:_isGifRefresh ?[self autoGifAnimatorView] : [TYAutoAnimatorView new] handler:^{
        NSLog(@"上拉刷新");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadMoreData];
            if (weakSelf.isCollectionView) {
                [weakSelf.collectionView reloadData];
                if (weakSelf.testData.count > 30 && weakSelf.haveNoMoreAndErrorRefresh) {
                    [weakSelf.collectionView.ty_refreshFooter endRefreshingWithNoMoreData];
                }else {
                    [weakSelf.collectionView.ty_refreshFooter endRefreshing];
                    UIEdgeInsets contentInset = weakSelf.collectionView.contentInset;
                    //                contentInset.top += 40;
                    //                contentInset.bottom = 120;
                    weakSelf.collectionView.contentInset = contentInset;
                }
            }else {
                [weakSelf.tableView reloadData];
                if (weakSelf.testData.count > 20 && weakSelf.haveNoMoreAndErrorRefresh) {
                    [weakSelf.tableView.ty_refreshFooter endRefreshingWithNoMoreData];
                }else {
                    [weakSelf.tableView.ty_refreshFooter endRefreshing];
                    UIEdgeInsets contentInset = weakSelf.tableView.contentInset;
                    //                contentInset.top += 40;
                    //                contentInset.bottom = 120;
                    weakSelf.tableView.contentInset = contentInset;
                }
            }
        });
    }];
    
    if (_isCollectionView) {
        _collectionView.ty_refreshFooter = footerRefresh;
    }else {
        _tableView.ty_refreshFooter = footerRefresh;
    }
}

#pragma mark - load data

- (void)loadData
{
    _testData = [NSMutableArray array];
    NSInteger newDataCount = _isCollectionView ? 20 :10;
    for (int i = 0; i <= newDataCount; ++i) {
        [_testData addObject:[NSString stringWithFormat:@"测试数据 row：%d",i]];
    }
}

- (void)loadMoreData
{
    int count = (int)_testData.count;
    NSInteger newDataCount = _isCollectionView ? 12 :6;
    for (int i = 0; i <= newDataCount; ++i) {
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


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _testData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCellId" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
