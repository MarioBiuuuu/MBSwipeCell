//
//  MBSwipTableViewCell.h
//  SwipCellDemo
//
//  Created by ZhangXiaofei on 17/3/20.
//  Copyright © 2017年 Yuri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBSwipCellMenuItem.h"

@interface MBSwipTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL autoClose;

- (void)closeLeftSwipe; //关闭左滑

- (void)addMenuItems:(NSArray <MBSwipCellMenuItem *>*)items;

@end
