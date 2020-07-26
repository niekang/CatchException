//
//  AppDelegate+UncaughtException.h
//  CatchException
//
//  Created by 聂康 on 2020/7/25.
//  Copyright © 2020 com.nk. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (UncaughtException)

- (void)setUncaughtExceptionHandler: (BOOL)shouldSet;

+ (NSArray *)backtrace;

@end

NS_ASSUME_NONNULL_END
