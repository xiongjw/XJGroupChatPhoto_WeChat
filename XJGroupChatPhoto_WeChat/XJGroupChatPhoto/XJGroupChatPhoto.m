//
//  XJGroupChatPhoto.m
//  XJGroupChatPhoto_WeChat
//
//  Created by mac on 2019/4/2.
//  Copyright © 2019 mac. All rights reserved.
//

#import "XJGroupChatPhoto.h"

#import "SDImageCache.h"
#import "SDWebImageDownloader.h"

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0] 

@implementation XJGroupChatPhoto

+ (void)createGroupChatPhotoWithObjs:(NSArray *)objs complete:(void(^)(UIImage *image))complete
{
    if (objs == nil || objs.count < 3) {
        if (complete) complete(nil);
        return;
    }
    BOOL needDownload = NO;
    for (int i = 0; i < objs.count; i++) {
        id obj = objs[i];
        if ([obj isKindOfClass:[NSString class]]) {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:obj];
            if (!image) {
                needDownload = YES;
                break;
            }
        }
    }
    if (!needDownload) {
        // 开始合成
        if (complete) {
            complete([self beginMergePhoto:objs]);
        }
        return;
    }
    NSMutableArray *resultList = [[NSMutableArray alloc] initWithArray:objs];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    for (int i = 0; i < MIN(9, objs.count); i++)
    {
        if ([objs[i] isKindOfClass:[UIImage class]]) {
            continue;
        }
        NSString *urlStr = objs[i];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
        if (image) {
            [resultList replaceObjectAtIndex:i withObject:image];
        }
        else
        {
            //dispatch_group_enter(group);
            // 开始下载图片
            dispatch_group_async(group, queue, ^{
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if (image) {
                        [resultList replaceObjectAtIndex:i withObject:image];
                    }
                    else {
                        // 失败了，一般说明此图片链接有问题，这里暂时用占位图替换吧
                        [resultList replaceObjectAtIndex:i withObject:[UIImage imageNamed:@"2.jpg"]];
                    }
                    dispatch_group_leave(group);
                }];
            });
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        // 开始合成
        if (complete) {
            complete([self beginMergePhoto:resultList]);
        }
    });
}

+ (UIImage *)beginMergePhoto:(NSArray *)imageList
{
    NSInteger count = imageList.count;
    
    CGFloat totalWidth = 240;
    UIGraphicsBeginImageContext(CGSizeMake(totalWidth, totalWidth));
    
    // 设置背景色(因为不想导入一些工具类，就先屏蔽这里了)
    UIImage *image = [self imageWithColor:RGBCOLOR(235, 235, 235)];
    [image drawInRect:CGRectMake(0, 0, totalWidth, totalWidth)];
    
    CGFloat posX = 0;
    CGFloat posY = 0;
    CGFloat width = 0;
    CGFloat padding = totalWidth/30;
    
    if (count == 1) {
        width = (totalWidth - padding*2);
        posX = padding;
        posY = padding;
    }else if (count == 2){
        width = (totalWidth - padding*3)/2;
        posX = padding;
        posY = (totalWidth - width)/2;
    }else if (count == 3) {
        // 12结构（铺满）
        width = (totalWidth - padding*3)/2;
        posX = (totalWidth - width)/2;
        posY = padding;
    }
    else if (count == 4) {
        // 22结构（铺满）
        width = (totalWidth - padding*3)/2;
        posX = padding;
        posY = padding;
    }
    else if (count == 5) {
        // 23结构 （上下有间距）
        width = (totalWidth - padding*4)/3;
        posX = (totalWidth-width*2-padding)/2;
        posY = (totalWidth-width*2-padding)/2;
    }
    else if (count == 6) {
        // 33 结构 居中（上下有间距）
        posX = padding;
        width = (totalWidth - padding*4)/3;
        posY = (totalWidth-width*2-padding)/2;
    }
    else if (count == 7) {
        // 133结构
        width = (totalWidth - padding*4)/3;
        posX = (totalWidth-width)/2;
        posY = padding;
    }
    else if (count == 8) {
        // 233结构
        width = (totalWidth - padding*4)/3;
        posX = (totalWidth-width*2-padding)/2;
        posY = padding;
    }
    else if (count == 9) {
        // 333结构
        posX = padding;
        posY = padding;
        width = (totalWidth - padding*4)/3;
    }
    
    for (int i = 0; i < count; i++)
    {
        BOOL shouldReturn = NO;
        if (count == 3) {
            if (i == 1) shouldReturn = YES;
        }
        else if (count == 4) {
            if (i == 2) shouldReturn = YES;
        }
        else if (count == 5) {
            if (i == 2) shouldReturn = YES;
        }
        else if (count == 6) {
            if (i == 3) shouldReturn = YES;
        }
        else if (count == 7) {
            if (i == 1 || i == 4) shouldReturn = YES;
        }
        else if (count == 8) {
            if (i == 2 || i == 5) shouldReturn = YES;
        }
        else if (count == 9) {
            if (i == 3 || i == 6) shouldReturn = YES;
        }
        if (shouldReturn) {
            posX = padding;
            posY += width + padding;
        }
        [(UIImage *)imageList[i] drawInRect:CGRectMake(posX, posY, width, width)];
        posX += width + padding;
    }
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color{
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return theImage;
}

@end
