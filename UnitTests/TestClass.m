//
//  MyClass.m
//  ascMacro
//
//  Created by Jon Crooke on 01/10/2012.
//  Copyright (c) 2012 soundcloud. All rights reserved.
//

#import "TestClass.h"
#import "ObjcAssociatedObjectHelpers.h"

@interface TestClass ()
@property (readwrite) id readWriteObject;
@end

@implementation TestClass

SYNTHESIZE_ASC_OBJ(object, setObject);
SYNTHESIZE_ASC_OBJ_LAZY(lazyObject, [NSString class])
SYNTHESIZE_ASC_OBJ_LAZY_EXP(nonDefaultLazyObject, [NSString stringWithFormat:@"foo"])
SYNTHESIZE_ASC_OBJ(readWriteObject, setReadWriteObject);
SYNTHESIZE_ASC_PRIMITIVE(primitive, setPrimitive, NSUInteger);
SYNTHESIZE_ASC_PRIMITIVE(structure, setStructure, TestStruct);

- (id)init {
    if ((self = [super init])) {
        self.readWriteObject = [[NSObject alloc] init];
    }
    return self;
}

@end
