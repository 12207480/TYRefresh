//
//  ViewController.m
//  TYRefreshDemo
//
//  Created by tany on 16/10/8.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *collectionViewSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoBeginRefreshSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)normalRefreshAction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.isCollectionView = _collectionViewSwitch.on;
    testVC.isAutoBeginRefresh = _autoBeginRefreshSwitch.on;
    [self.navigationController pushViewController:testVC animated:YES];
}

- (IBAction)gifRefreshAction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.isCollectionView = _collectionViewSwitch.on;
    testVC.isAutoBeginRefresh = _autoBeginRefreshSwitch.on;
    testVC.isGifRefresh = YES;
    [self.navigationController pushViewController:testVC animated:YES];

}
- (IBAction)normalAutoRefrshAction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.isCollectionView = _collectionViewSwitch.on;
    testVC.isAutoBeginRefresh = _autoBeginRefreshSwitch.on;
    testVC.isAutoFooterRefresh = YES;
    [self.navigationController pushViewController:testVC animated:YES];
    
}
- (IBAction)gifAutoRefreshAction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.isCollectionView = _collectionViewSwitch.on;
    testVC.isAutoBeginRefresh = _autoBeginRefreshSwitch.on;
    testVC.isAutoFooterRefresh = YES;
    testVC.isGifRefresh = YES;
    [self.navigationController pushViewController:testVC animated:YES];
}

- (IBAction)normalRefreshNoMoreAndErrorAction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.isCollectionView = _collectionViewSwitch.on;
    testVC.isAutoBeginRefresh = _autoBeginRefreshSwitch.on;
    testVC.haveNoMoreAndErrorRefresh = YES;
    [self.navigationController pushViewController:testVC animated:YES];
}

- (IBAction)autoRefreshNoMoreAndErrorAction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.isCollectionView = _collectionViewSwitch.on;
    testVC.isAutoBeginRefresh = _autoBeginRefreshSwitch.on;
    testVC.isAutoFooterRefresh = YES;
    testVC.haveNoMoreAndErrorRefresh = YES;
    [self.navigationController pushViewController:testVC animated:YES];

}

- (IBAction)normalRefreshAdjustOrignContentInsetAction:(UIButton *)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.isCollectionView = _collectionViewSwitch.on;
    testVC.isAutoBeginRefresh = _autoBeginRefreshSwitch.on;
    testVC.setOrignContentInset = YES;
    testVC.adjustOrignContentInset = sender.tag;
    [self.navigationController pushViewController:testVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
