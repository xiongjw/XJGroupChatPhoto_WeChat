//
//  ViewController.m
//  XJGroupChatPhoto_WeChat
//
//  Created by mac on 2019/4/2.
//  Copyright © 2019 mac. All rights reserved.
//

#import "ViewController.h"

#import "XJGroupChatPhoto/XJGroupChatPhoto.h"

@interface ViewController ()
{
    NSInteger count;
}
@property (nonatomic,strong) UIButton *createBtn;

@property (nonatomic,strong) NSArray *dataList;
@property (nonatomic,strong) NSMutableArray *resultList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    self.dataList = @[
//                       @"https://img4.duitang.com/uploads/item/201507/11/20150711193532_E2zF8.thumb.700_0.jpeg",
//                       @"http://img0.imgtn.bdimg.com/it/u=3597064406,4175245334&fm=26&gp=0.jpg",
//                       @"http://img0.imgtn.bdimg.com/it/u=289689127,489314165&fm=26&gp=0.jpg",
//                       @"http://img1.imgtn.bdimg.com/it/u=1152076356,451506265&fm=26&gp=0.jpg",
//                       @"http://img1.touxiang.cn/uploads/20121101/01-062532_365.jpg",
//                       @"http://img0.imgtn.bdimg.com/it/u=2680457105,3319046135&fm=26&gp=0.jpg",
//                       @"http://img5.imgtn.bdimg.com/it/u=1049733067,1194234148&fm=26&gp=0.jpg",
//                       @"http://img4.imgtn.bdimg.com/it/u=1928060807,3044989527&fm=26&gp=0.jpg",
//                       @"http://img1.imgtn.bdimg.com/it/u=2137258058,407864327&fm=26&gp=0.jpg"
//                       ];
    self.dataList = @[
                      [UIImage imageNamed:@"1.jpg"],
                      [UIImage imageNamed:@"2.jpg"],
                      [UIImage imageNamed:@"3.jpg"],
                      [UIImage imageNamed:@"4.jpg"],
                      [UIImage imageNamed:@"5.jpg"],
                      [UIImage imageNamed:@"6.jpg"],
                      [UIImage imageNamed:@"7.jpg"],
                      [UIImage imageNamed:@"8.jpg"],
                      [UIImage imageNamed:@"9.jpg"]
                      ];
    
    self.resultList = [NSMutableArray new];
    [self.resultList addObject:self.dataList[0]];
    [self.resultList addObject:self.dataList[1]];
    
    count = 3;
    [self.view addSubview:self.createBtn];
}

- (void)createAction:(UIButton *)btn
{
    if (count > 9) {
        return;
    }
    [self.resultList addObject:self.dataList[count-1]];
    [XJGroupChatPhoto createGroupChatPhotoWithObjs:self.resultList complete:^(UIImage *image) {
        [self afterGetImage:image];
    }];
    
}

- (void)afterGetImage:(UIImage *)image
{
    CGFloat padding = 5;
    CGFloat width = (self.view.frame.size.width - padding*4)/3;
    
    UIImageView *imageView = [self createImageView:image];
    if (count == 3)  imageView.frame = CGRectMake(5, 100, width, width);
    else if (count == 4)  imageView.frame = CGRectMake(5*2+width, 100, width, width);
    else if (count == 5)  imageView.frame = CGRectMake(5*3+width*2, 100, width, width);
    
    else if (count == 6)  imageView.frame = CGRectMake(5, 100+width+5, width, width);
    else if (count == 7)  imageView.frame = CGRectMake(5*2+width, 100+width+5, width, width);
    else if (count == 8)  imageView.frame = CGRectMake(5*3+width*2, 100+width+5, width, width);
    
    else if (count == 9)  imageView.frame = CGRectMake(5, 100+width*2+5*2, width, width);
    
    [self.view addSubview:imageView];
    
    count++;
    if (count > 9) {
        [self.createBtn setTitle:@"结束" forState:UIControlStateNormal];
        return;
    }
    [self.createBtn setTitle:[NSString stringWithFormat:@"生成%ld宫格",count] forState:UIControlStateNormal];
}

-(UIButton *)createBtn
{
    if (!_createBtn) {
        _createBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _createBtn.frame = CGRectMake((self.view.frame.size.width - 80)/2, self.view.frame.size.height - 60, 80, 40);
        [_createBtn setTitle:@"生成3宫格" forState:UIControlStateNormal];
        [_createBtn addTarget:self action:@selector(createAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createBtn;
}

-(UIImageView *)createImageView:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.layer.cornerRadius = 8;
    imageView.layer.masksToBounds = YES;
    return imageView;
}

@end
