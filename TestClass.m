//
//  MyClass.m
//  ascMacro
//
//  Created by jc on 01/10/2012.
//  Copyright (c) 2012 soundcloud. All rights reserved.
//

#import <objc/runtime.h>
#import "TestClass.h"

#define SYNTHESIZE_ASC_OBJC(getterName, setterName) \
static void* getterName##key = NULL; \
- (void)setterName:(id)object { \
    objc_AssociationPolicy policy = [object conformsToProtocol:@protocol(NSCopying)] ? OBJC_ASSOCIATION_COPY : OBJC_ASSOCIATION_RETAIN; \
    objc_setAssociatedObject(self, getterName##key, object, policy); \
} \
- (id) getterName { return objc_getAssociatedObject(self, getterName##key); }

#define SYNTHESIZE_ASC_PRIMITIVE(getterName, setterName, type) \
static void* getterName##key = NULL; \
- (void)setterName:(type)structure { \
    objc_setAssociatedObject(self, getterName##key, [NSValue value:&structure withObjCType:@encode(type)], OBJC_ASSOCIATION_RETAIN); \
} \
- (type) getterName { \
    type ret; \
    [objc_getAssociatedObject(self, getterName##key) getValue:&ret]; \
    return ret; \
}

@implementation TestClass

SYNTHESIZE_ASC_PRIMITIVE(primitive, setPrimitive, NSUInteger);
SYNTHESIZE_ASC_PRIMITIVE(structure, setStructure, NSRect);
SYNTHESIZE_ASC_OBJC(object, setObject);

@end
