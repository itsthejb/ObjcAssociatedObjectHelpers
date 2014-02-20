//
//  TestClass.h
//  ObjcAssociatedObjectHelpers
//
//  Created by Jonathan Crooke on 20/02/2014.
//  Copyright (c) 2014 jbsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _testStruct {
  int member1;
  float member2;
} TestStruct;

@interface TestClass : NSObject
@property () id object;
@property (assign) id assignObj;
@property (readonly) id lazyObject;
@property (readonly) id nonDefaultLazyObject;
@property (readwrite) id readWriteObject;
@property (assign) NSUInteger primitive;
@property (assign) TestStruct structure;
// overrides
@property (assign) id overrideAssignObj;
@property (strong) id overrideObj;
@property (readonly) id overrideObjLazy;
@property (readonly) id overrideObjLazyWithExpression;
@property (assign) NSUInteger overridePrimitive;
// Override value
@property (strong) NSString *overrideObjBlockGetter;
@property (strong) NSString *overrideObjBlockSetter;
@property (assign) NSUInteger overrideBlockPrimitiveGetter;
@property (assign) NSUInteger overrideBlockPrimitiveSetter;
@end
