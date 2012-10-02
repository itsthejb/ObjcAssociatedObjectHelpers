//
//  MyClass.m
//  ascMacro
//
//  Created by jc on 01/10/2012.
//  Copyright (c) 2012 soundcloud. All rights reserved.
//

#import "TestClass.h"
#import "ObjcAssociatedObjectMacros.h"

@interface TestClass ()
@property (strong, readwrite) id readWriteObject;
@end

@implementation TestClass

SYNTHESIZE_ASC_OBJ(object, setObject);
SYNTHESIZE_ASC_OBJ(lazyObject, setLazyObject);
SYNTHESIZE_ASC_OBJ(readWriteObject, setReadWriteObject);
SYNTHESIZE_ASC_PRIMITIVE(primitive, setPrimitive, NSUInteger);
SYNTHESIZE_ASC_PRIMITIVE(structure, setStructure, NSRect);

- (id)init {
    if ((self = [super init])) {
        self.readWriteObject = [[NSObject alloc] init];
    }
    return self;
}

@end
