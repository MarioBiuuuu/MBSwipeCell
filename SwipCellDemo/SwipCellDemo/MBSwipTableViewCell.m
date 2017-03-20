//
//  MBSwipTableViewCell.m
//  SwipCellDemo
//
//  Created by ZhangXiaofei on 17/3/20.
//  Copyright © 2017年 Yuri. All rights reserved.
//

#import "MBSwipTableViewCell.h"
#import "UIButton+SwipMenuItem.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define kMENUBUTTON_TAG 1000

@interface MBSwipTableViewCell () {
    CGFloat _menuWidth;
    CGPoint _beginPoint;
    CGPoint _lastMovePoint;
    BOOL _isMoveToLeft;
    BOOL _lockMoveRight;
}

@property (nonatomic, weak) UIView *containerView; //容器view

@property (nonatomic, assign) BOOL isOpenLeft; //是否已经打开左滑动

@property (nonatomic, weak) UISwipeGestureRecognizer *rightSwipe; //向右清扫手势

@property (nonatomic, strong) NSMutableArray<MBSwipCellMenuItem *> *menuArrM;

@property (nonatomic, strong) NSMutableArray<UIButton *> *menuButtons;

@end

@implementation MBSwipTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    CGFloat itemX = self.contentView.frame.size.width;
    CGFloat itemX = 0;
    if (self.menuArrM.count > 0) {
//        for (NSInteger i = (self.menuArrM.count - 1); i>=0; i--) {
//            
//            MBSwipCellMenuItem *item = self.menuArrM[i];
//            UIButton *btn = self.menuButtons[i];
//            itemX = itemX - item.itemWidth;
//
//            btn.frame = CGRectMake(itemX, 0, item.itemWidth, self.contentView.frame.size.height);
//            _menuWidth += item.itemWidth;
//        }
        
        for (int i = 0; i < self.menuArrM.count; i++) {
            MBSwipCellMenuItem *item = self.menuArrM[i];
            UIButton *btn = self.menuButtons[i];
            
            btn.frame = CGRectMake(itemX, 0, item.itemWidth, self.contentView.frame.size.height);
            _menuWidth += item.itemWidth;
            itemX = itemX + item.itemWidth;

        }
    }
    
    
    self.containerView.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds), 0, _menuWidth, CGRectGetHeight(self.contentView.bounds));
//    self.showLbl.frame = CGRectMake(0, 0, SCREENWIDTH, CELLHEIGHT - 1);
}

#pragma mark - 事件操作

// 关闭左滑，恢复原状
- (void)closeLeftSwipe {
    if (!self.isOpenLeft) return; //还未打开左滑，不需要执行右滑
    
    [UIView animateWithDuration: 0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        // 放大
        self.contentView.center = CGPointMake(SCREENWIDTH * 0.5, self.contentView.bounds.size.height * 0.5);
    } completion:nil];
    self.isOpenLeft = NO;
}

- (void)addMenuItems:(NSArray<MBSwipCellMenuItem *> *)items {
    self.menuArrM = [NSMutableArray arrayWithArray:items];
    [self initialMenuView];
}


- (void)updateMenuView:(MBSwipCellMenuItem *)item {
    [self.menuArrM addObject:item];
    UIButton *btn = [UIButton buttonWithItem:item];
    btn.tag = kMENUBUTTON_TAG + self.menuButtons.count;
    [self.containerView addSubview:btn];
    [self.menuButtons addObject:btn];
    [btn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initialMenuView {
    self.contentView.backgroundColor = [UIColor redColor];

    UIView *containerView = [[UIView alloc] init];
    self.containerView = containerView;
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    NSUInteger buttonIdx = 0;
    self.menuButtons = [NSMutableArray array];
    for (MBSwipCellMenuItem *item in self.menuArrM) {
        UIButton *btn = [UIButton buttonWithItem:item];
        btn.tag = kMENUBUTTON_TAG + buttonIdx;
        [self.containerView addSubview:btn];
        buttonIdx ++;
        [self.menuButtons addObject:btn];
        [btn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone; //设置单元格选中样式
    
    [self insertSubview:containerView belowSubview:self.contentView];

}

- (void)menuBtnClick:(UIButton *)btn {
    if (self.autoClose) {
        [self closeLeftSwipe];
    }
    MBSwipCellMenuItem *item = self.menuArrM[btn.tag - kMENUBUTTON_TAG];
    if (item.handler) {
        item.handler(item);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UITableView class]]) {
            NSArray *cells = [(UITableView *)nextResponder visibleCells];
            for (MBSwipTableViewCell *cell in cells) {
                if ([cell isEqual:self]) {
                    continue;
                }
                [cell closeLeftSwipe];
            }
            break;
        }
    }
    UITouch *touch=[touches anyObject];
    _lastMovePoint = CGPointMake(0, 0);
    _beginPoint = [touch locationInView:self.contentView];
    _isMoveToLeft = NO;
    _lockMoveRight = NO;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_lockMoveRight) {
        self.contentView.center = CGPointMake(self.center.x + 20, self.contentView.center.y);
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.contentView];
    _isMoveToLeft = (point.x - _lastMovePoint.x) > 0;
    _lastMovePoint = point;
    
    CGFloat pointChangeX = _beginPoint.x - point.x;
    CGFloat contentViewX = self.contentView.center.x - pointChangeX;
    self.containerView.frame = CGRectMake(self.containerView.frame.origin.x - pointChangeX, 0, _menuWidth, CGRectGetHeight(self.contentView.bounds));
    if (!self.isOpenLeft && !_isMoveToLeft && contentViewX >= self.center.x + 20) {
        _lockMoveRight = YES;
        _lastMovePoint = CGPointMake(0, 0);
        _beginPoint = [touch locationInView:self.contentView];
        _isMoveToLeft = NO;
        self.isOpenLeft = NO;
        
        self.contentView.center = CGPointMake(self.center.x, self.contentView.center.y);
        return;
    } else {
        self.contentView.center = CGPointMake(contentViewX, self.contentView.center.y);
    }
    NSLog(@"%@", @(_beginPoint.x - point.x));
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"---------1");
    if (!_isMoveToLeft) {
        [self closeLeftSwipe];
    }
    if (self.contentView.center.x <= (self.center.x - _menuWidth * 0.5)) {
        self.isOpenLeft = YES;
//        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
//            self.contentView.center = CGPointMake(self.center.x - _menuWidth, self.contentView.bounds.size.height * 0.5);
//        } completion:nil];
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.center = CGPointMake(self.center.x - _menuWidth, self.contentView.bounds.size.height * 0.5);
            self.containerView.frame = CGRectMake(self.frame.size.width - _menuWidth, 0, _menuWidth, CGRectGetHeight(self.contentView.bounds));
        }];
    } else {
//        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
//            self.contentView.center = CGPointMake(self.center.x, self.contentView.bounds.size.height * 0.5);
//        } completion:nil];
        self.isOpenLeft = NO;
        _isMoveToLeft = NO;
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.center = CGPointMake(self.center.x, self.contentView.bounds.size.height * 0.5);
            self.containerView.frame = CGRectMake(self.frame.size.width, 0, _menuWidth, CGRectGetHeight(self.contentView.bounds));
        }];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"---------2");
    if (!_isMoveToLeft) {
        [self closeLeftSwipe];
    }
    if (self.contentView.center.x <= (self.center.x - _menuWidth * 0.5)) {
        self.isOpenLeft = YES;
//        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
//            self.contentView.center = CGPointMake(self.center.x - _menuWidth, self.contentView.bounds.size.height * 0.5);
//        } completion:nil];
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.center = CGPointMake(self.center.x - _menuWidth, self.contentView.bounds.size.height * 0.5);
            self.containerView.frame = CGRectMake(self.frame.size.width - _menuWidth, 0, _menuWidth, CGRectGetHeight(self.contentView.bounds));
        }];
    } else {
//        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
//            self.contentView.center = CGPointMake(self.center.x, self.contentView.bounds.size.height * 0.5);
//        } completion:nil];
        self.isOpenLeft = NO;
        _isMoveToLeft = NO;
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.center = CGPointMake(self.center.x, self.contentView.bounds.size.height * 0.5);
            self.containerView.frame = CGRectMake(self.frame.size.width, 0, _menuWidth, CGRectGetHeight(self.contentView.bounds));
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
