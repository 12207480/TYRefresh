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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)normalRefreshAction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    [self.navigationController pushViewController:testVC animated:YES];
}

- (IBAction)gifRefreshAction:(id)sender {
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.isGifRefresh = YES;
    [self.navigationController pushViewController:testVC animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
