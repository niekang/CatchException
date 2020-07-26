//
//  AppDelegate+UncaughtException.m
//  CatchException
//
//  Created by 聂康 on 2020/7/25.
//  Copyright © 2020 com.nk. All rights reserved.
//

#import "AppDelegate+UncaughtException.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>
#import <CoreFoundation/CoreFoundation.h>


void UncaughtExceptionHandler(NSException *exception) {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"app.log"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    NSArray *callStacks = exception.callStackSymbols;
    NSString *reason = exception.reason;
    NSString *name = exception.name;
    NSDictionary *userInfo = exception.userInfo;
    if (userInfo && userInfo[@"callStacks"]) {
        callStacks = userInfo[@"callStacks"];
    }
    NSString *log = [NSString stringWithFormat:@"UncaughtException\nname:   %@\nreason:  %@\ncallStacks:%@", name, reason, callStacks];
    
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFArrayRef modes = CFRunLoopCopyAllModes(runloop);
    
    __block BOOL run = true;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
               [log writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
//               run = NO;
           });
    });
   // 开启runloop保证app不崩溃
    while (run) {
        for (NSString *mode in (__bridge NSArray *)modes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(modes);
}

void SignalExceptionHandler(int signal) {
    NSString* description = nil;
    switch (signal) {
        case SIGABRT:
            description = @"Signal SIGABRT\n";
            break;
        case SIGILL:
            description = @"Signal SIGILL\n";
            break;
        case SIGSEGV:
            description = @"Signal SIGSEGV\n";
            break;
        case SIGFPE:
            description = @"Signal SIGFPE\n";
            break;
        case SIGBUS:
            description = @"Signal SIGBUS\n";
            break;
        case SIGPIPE:
            description = @"Signal SIGPIPE\n";
            break;
        default:
            description = [NSString stringWithFormat:@"Signal %d",signal];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSArray *callStacks = [AppDelegate backtrace];
    [userInfo setObject:callStacks forKey:@"callStacks"];
    
    //在主线程中，执行指定的方法, withObject是执行方法传入的参数
    
    NSException *exception = [NSException exceptionWithName:@"UncaughtSignalExceptionHandler"
      reason: description
                          userInfo: userInfo];
    
    UncaughtExceptionHandler(exception);

}


@implementation AppDelegate (UncaughtException)

- (void)setUncaughtExceptionHandler:(BOOL)shouldSet {
    if(!shouldSet) return;
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    [self setUnCaughtSignalException];
}

- (void)setUnCaughtSignalException {
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}

//获取调用堆栈
+ (NSArray *)backtrace {
    //指针列表
    void* callstack[128];
    //backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
    //128用来指定当前的buffer中可以保存多少个void*元素
    //返回值是实际获取的指针个数
    int frames = backtrace(callstack, 128);
    //backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
    //返回一个指向字符串数组的指针
    //每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i++) {
        
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}


@end
