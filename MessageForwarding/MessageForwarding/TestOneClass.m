//
//  TestOneClass.m
//  MessageForwarding
//
//  Created by penghe on 2018/7/27.
//  Copyright © 2018年 WondersGroup. All rights reserved.
//


#import "TestOneClass.h"
#import "TestTowClass.h"
#import "TestThreeClass.h"

#import <objc/runtime.h>


@implementation TestOneClass

/*
void myMethod(id self, SEL _cmd) {
    NSLog(@"%@ %s",self,sel_getName(_cmd));
}


+ (BOOL)resolveInstanceMethod:(SEL)sel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (sel == @selector(run)) {
#pragma clang diagnostic pop
        class_addMethod([self class],sel,(IMP)myMethod,"v@:");
        return YES;
    }else {
        return [super resolveInstanceMethod:sel];
    }
}

*/

/*
- (id)forwardingTargetForSelector:(SEL)aSelector {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (aSelector == @selector(run)) {
#pragma clang diagnostic pop
        return [TestTowClass new];
    }else{
        return [super forwardingTargetForSelector:aSelector];
    }
}
*/

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (aSelector == @selector(run)) {
#pragma clang diagnostic pop
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    TestTowClass *towClass = [TestTowClass new];
    TestThreeClass *threeClass = [TestThreeClass new];

    if ([towClass respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:towClass];
    }
    if ([threeClass respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:threeClass];
    }
}


@end
