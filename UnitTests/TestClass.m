//
//  TestClass.m
//  ObjcAssociatedObjectHelpers
//
//  Created by Jonathan Crooke on 20/02/2014.
//  Copyright (c) 2014 jbsoft. All rights reserved.
//

#import "TestClass.h"

#define TEST_EXCEPTION \
[[NSException exceptionWithName:NSStringFromSelector(_cmd) \
reason:NSStringFromSelector(_cmd) \
userInfo:nil] raise]

@implementation TestClass

SYNTHESIZE_ASC_OBJ(object, setObject);
SYNTHESIZE_ASC_OBJ_LAZY(lazyObject, [NSString class])
SYNTHESIZE_ASC_OBJ_ASSIGN(assignObj, setAssignObj);
SYNTHESIZE_ASC_OBJ_LAZY_EXP(nonDefaultLazyObject, [NSString stringWithFormat:@"foo"])
SYNTHESIZE_ASC_OBJ(readWriteObject, setReadWriteObject);
SYNTHESIZE_ASC_PRIMITIVE(primitive, setPrimitive, NSUInteger);
SYNTHESIZE_ASC_PRIMITIVE(structure, setStructure, TestStruct);

// overrides
SYNTHESIZE_ASC_OBJ_ASSIGN_BLOCK(overrideAssignObj,
                                setOverrideAssignObj,
                                ^{ TEST_EXCEPTION; },
                                ^{ TEST_EXCEPTION; });
SYNTHESIZE_ASC_OBJ_BLOCK(overrideObj,
                         setOverrideObj,
                         ^{ TEST_EXCEPTION; },
                         ^{ TEST_EXCEPTION; })
SYNTHESIZE_ASC_OBJ_LAZY_BLOCK(overrideObjLazy,
                              [NSString class],
                              ^{ TEST_EXCEPTION; })
SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(overrideObjLazyWithExpression,
                                  [NSDate date],
                                  ^{ TEST_EXCEPTION; })
SYNTHESIZE_ASC_PRIMITIVE_BLOCK(overridePrimitive,
                               setOverridePrimitive,
                               NSUInteger,
                               ^{ TEST_EXCEPTION; },
                               ^{ TEST_EXCEPTION; })
SYNTHESIZE_ASC_OBJ_BLOCK(overrideObjBlockGetter,
                         setOverrideObjBlockGetter,
                         ^{ value = @"foo"; },
                         ^{ })
SYNTHESIZE_ASC_OBJ_BLOCK(overrideObjBlockSetter,
                         setOverrideObjBlockSetter,
                         ^{ },
                         ^{ value = @"foo"; })
SYNTHESIZE_ASC_PRIMITIVE_BLOCK(overrideBlockPrimitiveGetter,
                               setOverrideBlockPrimitiveGetter,
                               NSUInteger,
                               ^{ value++; },
                               ^{ })
SYNTHESIZE_ASC_PRIMITIVE_BLOCK(overrideBlockPrimitiveSetter,
                               setOverrideBlockPrimitiveSetter,
                               NSUInteger,
                               ^{ },
                               ^{ value--; })

- (id)init {
  if ((self = [super init])) {
    self.readWriteObject = [[NSObject alloc] init];
  }
  return self;
}

@end

@implementation TestSubclass

- (void)setObject:(id)object {
	[super setObject:@"bar"];
}

@end
