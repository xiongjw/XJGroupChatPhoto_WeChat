//
//  XJGroupChatPhoto.h
//  XJGroupChatPhoto_WeChat
//
//  Created by mac on 2019/4/2.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface XJGroupChatPhoto : NSObject

+ (void)createGroupChatPhotoWithObjs:(NSArray *)objs complete:(void(^)(UIImage *image))complete;

@end
