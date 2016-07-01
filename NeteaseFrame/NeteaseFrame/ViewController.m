//
//  ViewController.m
//  NeteaseFrame
//
//  Created by zhengbing on 7/1/16.
//  Copyright © 2016 zhengbing. All rights reserved.
//

#import "ViewController.h"
#import "ContentCell.h"

// 新闻分类的个数
#define TITLE_COUNT _newsTitle.count

#define BTN_TAG 100

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

{
    
    CGFloat _btnW;  /**< 标题按钮的宽度 */
    CGFloat _btnH;  /**< 标题按钮的高度 */
    
    UIButton *_lastSelectBtn; /**< 记录上一次选择的标题按钮 */
    
    NSArray *_newsTitle;  /**< 新闻分类集合 */
}

@property (nonatomic, strong) UIScrollView * newsTitleScrollView;  /**< 新闻分类所在的滚动视图 */

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;

- (void)initializeDataSource; /**< 初始化数据源 */
- (void)initializeUserInterface; /**< 初始化用户界面 */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeDataSource];
    [self initializeUserInterface];
}

#pragma mark - Initialize
- (void)initializeDataSource {
    
    _btnW = SCREEN_WIDTH * 0.2;
    _btnH = 45;
    
    _newsTitle = @[@"头条", @"娱乐", @"热点", @"科技", @"金融", @"图片", @"时尚", @"军事", @"历史"];
    
    
}

- (void)initializeUserInterface {
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 关闭系统自动偏移
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 配置导航栏
    self.navigationItem.title = @"网易新闻";
    self.navigationController.navigationBar.barTintColor = RGB_COLOR(255, 97, 76, 1);
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:25], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    // 加载视图
    [self.view addSubview:self.newsTitleScrollView];
    // 循环添加标题按钮
    
    [_newsTitle enumerateObjectsUsingBlock:^(NSString *  _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(idx * _btnW, 0, _btnW, _btnH)];
        // 设置tag值
        [btn setTag:BTN_TAG + idx];
        // 设置标题
        [btn setTitle:title forState:UIControlStateNormal];
        // 设置标题颜色
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        // 设置标题字体
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        // 添加事件
        [btn addTarget:self action:@selector(respondsToBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [_newsTitleScrollView addSubview:btn];
        
        if (idx == 0) {
            [self updateWith:btn isSelected:YES];
        }
    }];
    
    // 加载内容视图
    [self.view addSubview:self.collectionView];
}

#pragma mark - Events
- (void)respondsToBtn:(UIButton *)sender {
    [self updateWith:sender isSelected:YES];
}

#pragma mark - Update
- (void)updateWith:(UIButton *)btn isSelected:(BOOL)isSelected {
    
    // 判断上一次选择的按钮是否有值，如果有值，就将该按钮的样式归位。
    if (_lastSelectBtn) {
        _lastSelectBtn.transform = CGAffineTransformIdentity;
        [_lastSelectBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    _lastSelectBtn = btn;
    
    [UIView animateWithDuration:0.3 animations:^{
        // 为标题添加动画效果
        // 缩放效果
        btn.transform = CGAffineTransformMakeScale(1.3, 1.3);
        // 颜色变换
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        
        // 获取按钮下标
        NSInteger idx = btn.tag - BTN_TAG;
        // 判断，如果点击的按钮位于第2个到倒数第2个按钮之间，将按钮置于中间显示。
        if (idx > 2 && idx < TITLE_COUNT - 2) {
            [_newsTitleScrollView setContentOffset:CGPointMake((idx - 2) * _btnW, 0) animated:YES];
        }
        // 如果点击的是前两个按钮
        else if (idx >= 0 && idx <= 2) {
            [_newsTitleScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        // 如果点击的是后两个按钮
        else if (idx >= TITLE_COUNT - 2) {
            [_newsTitleScrollView setContentOffset:CGPointMake((TITLE_COUNT - 5) * _btnW, 0) animated:YES];
        }
        
        // 动画执行完之后更新内容的偏移
        if (isSelected) {
            [_collectionView setContentOffset:CGPointMake(idx * SCREEN_WIDTH, 0)];
        }
        
    }];
    
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return TITLE_COUNT;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"123" forIndexPath:indexPath];
    cell.backgroundColor = [self specialRandomColor];
    
    return cell;
}

// 减速完成，更新标题按钮显示
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 如果滚动的是内容视图（collectionView）
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        
        // 获取按钮下标
        NSInteger idx = scrollView.contentOffset.x / SCREEN_WIDTH;
        NSInteger tag = BTN_TAG + idx;
        
        UIButton *btn = (UIButton *)[self.view viewWithTag:tag];
        
        [self updateWith:btn isSelected:false];
        
    }
}

- (UIColor *)specialRandomColor {
    
    CGFloat hue = arc4random() % 256 / 256.0 ;  //  0.0 to 1.0
    CGFloat saturation = arc4random() % 128 / 256.0 + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = arc4random() % 128 / 256.0 + 0.5;  //  0.5 to 1.0, away from black
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark - Getters
- (UIScrollView *)newsTitleScrollView {
    if (!_newsTitleScrollView) {
        _newsTitleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 45)];
        _newsTitleScrollView.backgroundColor = RGB_COLOR(242, 242, 242, 1);
        
        // 滚动视图内容大小
        _newsTitleScrollView.contentSize = CGSizeMake(TITLE_COUNT * _btnW, _btnH);
    }
    return _newsTitleScrollView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        
        CGFloat height = CGRectGetMaxY(self.newsTitleScrollView.frame);
        
        _layout = [[UICollectionViewFlowLayout alloc] init];
        
        _layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - height);
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
        // 方向
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat height = CGRectGetMaxY(self.newsTitleScrollView.frame);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, height, SCREEN_WIDTH, SCREEN_HEIGHT - height) collectionViewLayout:self.layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        // 注册单元格
        [_collectionView registerClass:[ContentCell class] forCellWithReuseIdentifier:@"123"];
    }
    return _collectionView;
}





@end
