# MessageForwarding
消息转发
有时候我们常常看到一个cash 信息，意思是这个对象不存在这个方法，你向这个对象发送消息就会crash。

我们除了用respondsToSelector 这个方法来判断这个对象是否响应这个方法，还可以用消息转发来解决。

在系统抛出异常的时候你有还有三次机会来处理这个crash

## 第一次机会
让你有机会提供一个函数实现。如果你添加了函数，那运行时系统就会重新启动一次消息发送的过程，否则 ，运行时就会移到下一步。主要是下面两个方法：
```
+ (BOOL)resolveInstanceMethod:(SEL)sel

+ (BOOL)resolveClassMethod:(SEL)sel
```
在这个类的实现文件动态添加一个这个方法并重写上述方法来解决crash
```
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
```
## 第二次机会 
如果目标对象实现了-forwardingTargetForSelector:，Runtime 这时就会调用这个方法，给你把这个消息转发给其他对象的机会。 只要这个方法返回的不是nil和self，整个消息发送的过程就会被重启，当然发送的对象会变成你返回的那个对象。

创建一个新的类 ，然后把这个消息，转发到新类上实现。
```
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
```
## 第三次机会 
这一步是Runtime最后一次给你挽救的机会。首先它会发送-methodSignatureForSelector:消息获得函数的参数和返回值类型。如果-methodSignatureForSelector:返回nil，Runtime则会发出-doesNotRecognizeSelector:消息，程序这时也就挂掉了。

如果返回了一个函数签名，Runtime就会创建一个NSInvocation对象并发送-forwardInvocation:消息给目标对象。这次的转发作用和第二次的比较类似，都是将 A 类的某个方法，转发到 B 类的实现中去。不同的是，第三次的转发相对于第二次更加灵活，forwardingTargetForSelector: 只能固定的转发到一个对象；forwardInvocation:  可以让我们转发到多个对象中去。
```
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
```
## 注意：
关于生成签名的类型"v@:"解释一下。每一个方法会默认隐藏两个参数，self、_cmd，self代表方法调用者，_cmd代表这个方法的SEL，签名类型就是用来描述这个方法的返回值、参数的，v代表返回值为void，@表示self，:表示_cmd。

下面苹果官方文档参考 ：[https://developer.apple.com/documentation/foundation/nsmethodsignature?language=objc](https://developer.apple.com/documentation/foundation/nsmethodsignature?language=objc)

For example, the NSString instance method containsString: has a method signature with the following arguments:
```
@encode(BOOL) (c) for the return type

@encode(id) (@) for the receiver (self)

@encode(SEL) (:) for the selector (_cmd)

@encode(NSString *) (@) for the first explicit argument
```
参考链接：

 [https://github.com/bang590/JSPatch/wiki/JSPatch-%E5%AE%9E%E7%8E%B0%E5%8E%9F%E7%90%86%E8%AF%A6%E8%A7%A3](https://github.com/bang590/JSPatch/wiki/JSPatch-%E5%AE%9E%E7%8E%B0%E5%8E%9F%E7%90%86%E8%AF%A6%E8%A7%A3)

[http://llyblog.com/2017/04/01/iOS-Runtime-%E5%8A%A8%E6%80%81%E6%B6%88%E6%81%AF%E8%A7%A3%E6%9E%90%E5%92%8C%E6%B6%88%E6%81%AF%E8%BD%AC%E5%8F%91%E6%9C%BA%E5%88%B6/](http://llyblog.com/2017/04/01/iOS-Runtime-%E5%8A%A8%E6%80%81%E6%B6%88%E6%81%AF%E8%A7%A3%E6%9E%90%E5%92%8C%E6%B6%88%E6%81%AF%E8%BD%AC%E5%8F%91%E6%9C%BA%E5%88%B6/)

[http://www.cocoachina.com/ios/20150604/12013.html](http://www.cocoachina.com/ios/20150604/12013.html)

[https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8A%EF%BC%89.md#18-%E4%BB%80%E4%B9%88%E6%97%B6%E5%80%99%E4%BC%9A%E6%8A%A5unrecognized-selector%E7%9A%84%E5%BC%82%E5%B8%B8](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88/%E3%80%8A%E6%8B%9B%E8%81%98%E4%B8%80%E4%B8%AA%E9%9D%A0%E8%B0%B1%E7%9A%84iOS%E3%80%8B%E9%9D%A2%E8%AF%95%E9%A2%98%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88%EF%BC%88%E4%B8%8A%EF%BC%89.md#18-%E4%BB%80%E4%B9%88%E6%97%B6%E5%80%99%E4%BC%9A%E6%8A%A5unrecognized-selector%E7%9A%84%E5%BC%82%E5%B8%B8)
