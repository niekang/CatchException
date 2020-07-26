//
//  ViewController.m
//  CatchException
//
//  Created by 聂康 on 2020/7/25.
//  Copyright © 2020 com.nk. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property(nonatomic, assign)UILabel *label;
@property(nonatomic, strong)UILabel *nameLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel = [[UILabel alloc] init];
    self.label = self.nameLabel;
    self.nameLabel = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // signal 模拟
    // [self.label setText:@"ssssssa"];
    static BOOL isFirst = true;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@"1",@"2"]];
    if (isFirst){
        NSString *str = arr[2];
        isFirst = NO;
    }
    NSLog(@"%@",arr);
    [arr addObject:@"2"];
}


@end
