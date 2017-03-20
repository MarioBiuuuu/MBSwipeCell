//
//  ViewController.m
//  SwipCellDemo
//
//  Created by ZhangXiaofei on 17/3/20.
//  Copyright © 2017年 Yuri. All rights reserved.
//

#import "ViewController.h"
#import "MBSwipTableViewCell.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource> {
    CGFloat _height;
    UITableView *_tableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _height = 60;
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
//    [tableView registerClass:[MBSwipTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
//    [tableView registerNib:[UINib nibWithNibName:@"MBSwipTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifier"];
}

- (void)btnClick {
    _height += 20;
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    MBSwipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    MBSwipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[MBSwipTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", @(indexPath.section), @(indexPath.row)];
    cell.textLabel.textColor = [UIColor blackColor];
    
    MBSwipCellMenuItem *item = [[MBSwipCellMenuItem alloc] init];
    item.normalImage = [UIImage imageNamed:@"1"];
    item.selectedImage = [UIImage imageNamed:@"2"];
    
    item.itemTitle = @"删除";
    item.titleColor = [UIColor redColor];
    
    item.titleFont = [UIFont systemFontOfSize:15.f];
    item.itemWidth = 60;
    item.itemBackgroundColor = [UIColor grayColor];
    
    item.style = MBSwipCellItemStyleOnlyTitle;
    [item clickItem:^(MBSwipCellMenuItem *item) {
        NSLog(@"click 0 %@", item);

    }];
    
    MBSwipCellMenuItem *item1 = [[MBSwipCellMenuItem alloc] init];
    item1.normalImage = [UIImage imageNamed:@"2"];
    item1.selectedImage = [UIImage imageNamed:@"1"];
    
    item1.itemTitle = @"修改";
    item1.titleColor = [UIColor blackColor];
    
    item1.titleFont = [UIFont systemFontOfSize:15.f];
    item1.itemWidth = 160;
    item1.itemBackgroundColor = [UIColor orangeColor];
    
    item1.style = MBSwipCellItemStyleOnlyImage;
    [item1 clickItem:^(MBSwipCellMenuItem *item) {
        NSLog(@"click 1 %@", item);
        
    }];
    
    MBSwipCellMenuItem *item2 = [[MBSwipCellMenuItem alloc] init];
    item2.normalImage = [UIImage imageNamed:@"2"];
    item2.selectedImage = [UIImage imageNamed:@"1"];
    
    item2.itemTitle = @"哈哈";
    item2.titleColor = [UIColor whiteColor];
    
    item2.titleFont = [UIFont systemFontOfSize:12.f];
    item2.itemWidth = 60;
    item2.itemBackgroundColor = [UIColor blackColor];
    
    item2.style = MBSwipCellItemStyleCenter;
    [item2 clickItem:^(MBSwipCellMenuItem *item) {
        NSLog(@"click 2 %@", item);
        
    }];
    
    [cell addMenuItems:@[item, item1, item2]];
    
    
    return cell;
}

- (BOOL)mb_menuCell:(MBSwipTableViewCell *)whcCell didPullCell:(NSInteger)index {
    NSLog(@"hehe  %@", @(index));
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
