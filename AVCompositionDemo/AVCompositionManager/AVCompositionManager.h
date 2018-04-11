//
//  AVCompositionManager.h
//  AVCompositionDemo
//
//  Created by navy on 2018/4/11.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompositionCompletion)(void);

// 这个单例类必须得被别的类强引用要不然创建之后就会释放.
// 和之前的普通的类的全局强引用是一样的，只不过起到了在类没释放掉之前都是同一个对象的效果。

@interface AVCompositionManager : NSObject
+ (instancetype)sharedInstance;
- (void)composeWithUrls:(NSArray <NSString *>*)urlArr completion:(CompositionCompletion)completion;
@end
