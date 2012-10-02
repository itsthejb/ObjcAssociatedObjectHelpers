//
//  MyClass.m
//  ascMacro
//
//  Created by jc on 01/10/2012.
//  Copyright (c) 2012 soundcloud. All rights reserved.
//

#import "TestClass.h"
#import "ObjcAssociatedObjectMacros.h"

@implementation TestClass

SYNTHESIZE_ASC_OBJC(object, setObject);
SYNTHESIZE_ASC_OBJC(lazyObject, setLazyObject);
SYNTHESIZE_ASC_PRIMITIVE(primitive, setPrimitive, NSUInteger);
SYNTHESIZE_ASC_PRIMITIVE(structure, setStructure, NSRect);

@end
