//
//  TestClass.m
//  ObjcAssociatedObjectHelpers
//
//  Created by Jonathan Crooke on 20/02/2014.
//  Copyright (c) 2014 jbsoft. All rights reserved.
//

#import "TestClass.h"
#import "ObjcAssociatedObjectHelpers.h"

static NSString *_strongString = @"StrongString";

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

// Weak
#if __has_feature(objc_arc)
SYNTHESIZE_ASC_OBJ_WEAK(weakObject, setWeakObject)
SYNTHESIZE_ASC_OBJ_WEAK_BLOCK(weakObject2,
                              setWeakObject2,
                              ^(NSString *object) { return [object stringByAppendingString:object]; },
                              ^(NSObject *object) { return _strongString; });
#endif

// overrides
SYNTHESIZE_ASC_OBJ_ASSIGN_BLOCK(overrideAssignObj,
                                setOverrideAssignObj,
                                ^(id v){ TEST_EXCEPTION; return v; },
                                ^(id v){ TEST_EXCEPTION; return v; });
SYNTHESIZE_ASC_OBJ_BLOCK(overrideObj,
                         setOverrideObj,
                         ^(id v){ TEST_EXCEPTION; return v; },
                         ^(id v){ TEST_EXCEPTION; return v; });
SYNTHESIZE_ASC_OBJ_LAZY_BLOCK(overrideObjLazy,
                              [NSString class],
                              ^(NSString *v){ TEST_EXCEPTION; return v; })
SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(overrideObjLazyWithExpression,
                                  [NSDate date],
                                  ^(NSDate *v){ TEST_EXCEPTION; return v; })
SYNTHESIZE_ASC_PRIMITIVE_BLOCK(overridePrimitive,
                               setOverridePrimitive,
                               NSUInteger,
                               ^(NSUInteger v){ TEST_EXCEPTION; return v; },
                               ^(NSUInteger v){ TEST_EXCEPTION; return v; })
SYNTHESIZE_ASC_OBJ_BLOCK(overrideObjBlockGetter,
                         setOverrideObjBlockGetter,
                         ^(id v){ return @"foo"; },
                         ^(id v){ return v; })
SYNTHESIZE_ASC_OBJ_BLOCK(overrideObjBlockSetter,
                         setOverrideObjBlockSetter,
                         ^(id v){ return v; },
                         ^(id v){ return @"foo"; })
SYNTHESIZE_ASC_PRIMITIVE_BLOCK(overrideBlockPrimitiveGetter,
                               setOverrideBlockPrimitiveGetter,
                               NSUInteger,
                               ^(NSUInteger v){ return v+1; },
                               ^(NSUInteger v){ return v; })
SYNTHESIZE_ASC_PRIMITIVE_BLOCK(overrideBlockPrimitiveSetter,
                               setOverrideBlockPrimitiveSetter,
                               NSUInteger,
                               ^(NSUInteger v){ return v; },
                               ^(NSUInteger v){ return v-1; })

- (id)init {
  if ((self = [super init])) {
    self.readWriteObject = [[NSObject alloc] init];
  }
  return self;
}

@end
