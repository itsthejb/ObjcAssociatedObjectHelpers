//
//  MyClass.m
//  ascMacro
//
//  Created by jc on 01/10/2012.
//  Copyright (c) 2012 soundcloud. All rights reserved.
//

#import <objc/runtime.h>
#import "TestClass.h"

#define Q(x) #x
#define QUOTE(x) Q(x)

#define SYNTHESIZE_ASCOBJ_PRIMITIVE(getterName, setterName, type, wrapBlock, unwrapBlock) \
static char getterName##Key[] = QUOTE( getterName##key ); \
- (void) setterName:(NSUInteger)getterName { \
    id (^wrap)() = wrapBlock; \
    id wrapped = wrap(); \
    objc_setAssociatedObject(self, QUOTE(getterName), wrapped, OBJC_ASSOCIATION_RETAIN); } \
- (type) getterName { \
    __block id unwrapped = objc_getAssociatedObject(self, QUOTE(getterName)); \
    type (^unwrap)() = unwrapBlock; \
    return unwrap(); }

@implementation TestClass

SYNTHESIZE_ASCOBJ_PRIMITIVE(primitive,
                            setPrimitive,
                            NSUInteger,
                            ^ id { return [NSNumber numberWithUnsignedInteger:primitive]; },
                            ^ NSUInteger { return [unwrapped unsignedIntegerValue]; };)

/*
- (void)setPrimitive:(NSUInteger)primitive
{
    id (^wrap)() = ^ id { return [NSNumber numberWithUnsignedInteger:primitive]; };
    id wrapped = wrap();
    objc_setAssociatedObject(self, "primitive", wrapped, OBJC_ASSOCIATION_RETAIN);
}

- (NSUInteger)primitive
{
    __block id unwrapped = objc_getAssociatedObject(self, "primitive");
    NSUInteger (^unwrap)() = ^ NSUInteger { return [unwrapped unsignedIntegerValue]; };
    return unwrap();
}*/

@end
