//
//  ViewController.m
//  MessageForwarding
//
//  Created by penghe on 2018/7/27.
//  Copyright © 2018年 WondersGroup. All rights reserved.
//

#import "ViewController.h"
#import "TestOneClass.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    TestOneClass *testOneClass = [TestOneClass new];
    [testOneClass run];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
