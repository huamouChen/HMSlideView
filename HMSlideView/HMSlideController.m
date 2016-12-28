//
//  HMSlideController.m
//  HMSliedView
//
//  Created by minstone on 16/8/3.
//  Copyright © 2016年 minstone. All rights reserved.
//

#import "HMSlideController.h"
#import "HMController.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height
#define kTitleScrollviewH 42
#define kNavH 64
#define kTabH 49
#define kTitleBtnW (kScreenW / 4.0)
#define kTitleBtnH 40

@interface HMSlideController () <UIScrollViewDelegate>
/// 标题scrollView
@property (strong, nonatomic) UIScrollView *titleScrollView;
/// 标题下面的提醒线条
@property (strong, nonatomic) UIView *shadowView;
/// 内容scrollView
@property (strong, nonatomic) UIScrollView *contentScrollview;
/// 按钮数组
@property (strong, nonatomic) NSMutableArray *buttonArray;
/// 当前选中的标题按钮
@property (strong, nonatomic) UIButton *currenButton;
@end

@implementation HMSlideController

#pragma mark - 添加子控制器
- (void)addChildViewControllers {
    HMController *vc = [HMController new];
    vc.title = @"精卫科普";
    [self addChildViewController:vc];
    
    HMController *vc2 = [HMController new];
    vc2.title = @"前沿资讯";
    [self addChildViewController:vc2];
    
    HMController *vc3 = [HMController new];
    vc3.title = @"在线学习";
    [self addChildViewController:vc3];
    
    HMController *vc4 = [HMController new];
    vc4.title = @"政策法规";
    [self addChildViewController:vc4];
    
//    HMController *vc5 = [HMController new];
//    vc5.title = @"每日八卦";
//    [self addChildViewController:vc5];
//    
//    HMController *vc6 = [HMController new];
//    vc6.title = @"新闻联播";
//    [self addChildViewController:vc6];
//    
//    HMController *vc7 = [HMController new];
//    vc7.title = @"韩国棒子";
//    [self addChildViewController:vc7];
}

#pragma mark - 设置标题按钮
- (void)setupTitle {
    // 获取标题数组个数
    NSInteger count = self.childViewControllers.count;
    
    for (int i = 0; i < count; i++) {
        // 取出控制器
        UIViewController *controller = self.childViewControllers[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        // 设置frame
        btn.frame = CGRectMake(i * kTitleBtnW, 0, kTitleBtnW, kTitleBtnH);
        // 绑定 tag
        btn.tag = i;
        // 设置标题
        [btn setTitle:controller.title forState:UIControlStateNormal];
        // 设置标题颜色
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        // 设置文字大小
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        // 添加方法
        [btn addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
        // 添加到 titleScrollView 上
        [self.titleScrollView addSubview:btn];
        // 添加到数组中
        [self.buttonArray addObject:btn];
        // 默认选中第 0 个
        if (i == 0) {
            [self selectedButton:btn];
        }
    }
    // 添加提醒下划线
    [self.titleScrollView addSubview:self.shadowView];
    // 设置 titleScrollView 的可滚动范围
    self.titleScrollView.contentSize = CGSizeMake(count * kTitleBtnW, 0);
}

#pragma mark - 点击按钮
- (void)selectedButton:(UIButton *)button {
    // 1. 设置按钮
    [self changeButton:button];
    
    // 2. 设置界面
    [self changeDisplayView:button.tag];
}

/// 选中之后的按钮
- (void)changeButton:(UIButton *)button {
    __weak typeof(self) weakSelf = self;
    // 恢复之前按钮的颜色
    [self.currenButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    // 恢复
    // 设置当前选中按钮的颜色
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.currenButton = button;
    // 偏移下划线
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf setupSelectedButtonCenter:button];
        weakSelf.shadowView.transform = CGAffineTransformMakeTranslation(button.tag * kTitleBtnW , 0);
    }];
    
}

/// 设置按钮中心
- (void)setupSelectedButtonCenter:(UIButton *)button {
    // 如果偏移量和屏幕一样大，就直接返回
    if (self.titleScrollView.contentSize.width == [UIScreen mainScreen].bounds.size.width) { return; }
    CGFloat offset = button.center.x - kScreenW * 0.5;
    // 最左边
    if (offset < 0) {
        offset = 0;
    }
    
    CGFloat maxOffset = self.titleScrollView.contentSize.width - kScreenW;
    // 最右边
    if (offset > maxOffset) {
        offset = maxOffset;
    }
    
    [self.titleScrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

/// 选中按钮后界面的改变
- (void)changeDisplayView:(NSInteger)index {
    // 设置偏移量
    [self.contentScrollview setContentOffset:CGPointMake(index * kScreenW, 0)];
    
    // 获取对应的控制器
    UIViewController *vc = self.childViewControllers[index];
    // 如果已经添加过了，就直接返回
    if (vc.view.superview) { return; }
    // 设置 frame
    vc.view.frame = CGRectMake(index * kScreenW, 0, self.contentScrollview.bounds.size.width, self.contentScrollview.bounds.size.height);
    // 添加视图
    [self.contentScrollview addSubview:vc.view];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 1. 获得偏移量 下标
    NSInteger index = self.contentScrollview.contentOffset.x / self.contentScrollview.bounds.size.width;
    
    // 标题按钮做出改变
    [self changeButton:self.buttonArray[index]];
    // 内容界面错处改变
    [self changeDisplayView:index];
}

/// 设置外观
- (void)setupAppearance {
    // ios7后会自动帮你设置缩进
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 判断是否存在导航控制器来判断y值
    CGFloat y = self.navigationController ? kNavH : 0;
    CGRect rect = CGRectMake(0, y, self.view.bounds.size.width, kTitleScrollviewH);
    self.titleScrollView.frame = rect;
    
    // 内容scrollView的 frame
    CGFloat contenScrollViewH = self.view.bounds.size.height - kTitleScrollviewH;
    if (self.navigationController) {
        contenScrollViewH = self.view.bounds.size.height - kTitleScrollviewH - kNavH;
    }
    if (self.tabBarController) {
        contenScrollViewH = self.view.bounds.size.height - kTitleScrollviewH - kTabH;
    }
    if (self.navigationController && self.tabBarController) {
        contenScrollViewH = self.view.bounds.size.height - kTitleScrollviewH - kNavH - kTabH;
    }
    self.contentScrollview.frame = CGRectMake(0, CGRectGetMaxY(self.titleScrollView.frame), self.view.bounds.size.width, contenScrollViewH);
    
    // 添加子控制器
    [self addChildViewControllers];
    
    // 添加子控件
    [self.view addSubview:self.titleScrollView];
    [self.view addSubview:self.contentScrollview];
    
    // 设置 contentScrollView 的课滚动范围
    self.contentScrollview.contentSize = CGSizeMake(self.childViewControllers.count * self.contentScrollview.bounds.size.width, 0);

    // 添加标题
    [self setupTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
}

#pragma mark - 懒加载
- (UIScrollView *)titleScrollView {
    if (!_titleScrollView) {
        _titleScrollView = [[UIScrollView alloc] init];
    }
    _titleScrollView.showsHorizontalScrollIndicator = NO;
    _titleScrollView.backgroundColor = [UIColor whiteColor];
    return _titleScrollView;
}

- (UIScrollView *)contentScrollview {
    if (!_contentScrollview) {
        _contentScrollview = [[UIScrollView alloc] init];
    }
    _contentScrollview.backgroundColor = [UIColor whiteColor];
    _contentScrollview.showsHorizontalScrollIndicator = NO;
    // 分页效果
    _contentScrollview.pagingEnabled = YES;
    _contentScrollview.delegate = self;
    return _contentScrollview;
}

- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, kTitleBtnH, kTitleBtnW, 2)];
    }
    _shadowView.backgroundColor = [UIColor blueColor];
    return _shadowView;
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
