//
//  UnitTests.m
//  UnitTests
//
//  Created by Jon Crooke on 01/10/2012.
//  Copyright (c) 2012 Jonathan Crooke. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <XCTest/XCTest.h>
#import "NSObject+AssociatedDictionary.h"
#import "ObjcAssociatedObjectHelpers.h"

static NSString *const kConstString = @"ConstString";

#define TEST_EXCEPTION \
  [[NSException exceptionWithName:NSStringFromSelector(_cmd) \
                           reason:NSStringFromSelector(_cmd) \
                         userInfo:nil] raise]

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Test Class

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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark -
#pragma mark Tests

@interface AssociatedObjectTests : XCTestCase
@property (strong) TestClass *testClass;
@property (strong) NSObject *dictionaryObject;
@end

@implementation AssociatedObjectTests

#pragma mark Basic set/get

- (void) testObject
{
  NSBundle *testObject = [[NSBundle alloc] init];
  self.testClass.object = testObject;
  XCTAssertEqual(self.testClass.object, testObject, @"Didn't return same object");
}

- (void) testPrimitive
{
  NSUInteger value = 99;
  self.testClass.primitive = value;
  XCTAssertEqual(self.testClass.primitive, value, @"Not the correct value");
}

- (void) testStructure
{
  TestStruct struct1 = { 1, 2.0 };
  self.testClass.structure = struct1;
  TestStruct struct2 = self.testClass.structure;
  XCTAssertTrue(memcmp(&struct1, &struct2, sizeof(TestStruct)) == 0, @"Returned wrong value");
}

- (void) testAssignObject
{
  self.testClass.assignObj = kConstString;
  XCTAssertEqualObjects(self.testClass.assignObj, kConstString, @"Didn't do assing");
}

#pragma mark Edge cases

- (void) testMutableObject
{
  id string = @"mutableString";

  NSMutableString *mutable = [NSMutableString stringWithString:string];
  self.testClass.object = mutable;

  // should copy the object
  XCTAssertFalse(self.testClass.object == mutable, @"Should have made a copy");
  XCTAssertEqualObjects(self.testClass.object, string, @"Should have same value");

  // change the original
  [mutable appendString:@"Foo"];
  XCTAssertEqualObjects(mutable, @"mutableStringFoo", @"Should have appended");
  XCTAssertEqualObjects(self.testClass.object, string, @"Should not have changed");
}

- (void) testReadWriteObjectWithCategory
{
  XCTAssertNotNil(self.testClass.readWriteObject, @"Readwrite object should be created in -init");
}

#pragma mark Lazy Object

- (void) testLazyObject
{
  id lazy = self.testClass.lazyObject;
  XCTAssertTrue([lazy isKindOfClass:[NSString class]], @"Should be lazy init NSString");
}

- (void) testNonDefaultLazyObject
{
  id lazy = self.testClass.nonDefaultLazyObject;
  XCTAssertEqualObjects(lazy, @"foo", @"Didn't use non-default initialiser");
}

#pragma mark -

- (void) testNonInitialisedPrimitive
{
  XCTAssertTrue(self.testClass.primitive == 0, @"Non-initialised primitive should be zero");
}

#pragma mark Associated dictionary

- (void) testInitialize
{
  id dictionary = self.dictionaryObject.associatedDictionary;
  XCTAssertNotNil(dictionary, @"Dictionary is nil");
  XCTAssertTrue([dictionary isKindOfClass:[NSMutableDictionary class]], @"Not mutable dictionary");
}

- (void) testSetGet
{
  NSString *key = @"bar";
  NSString *value = @"foo";
  [self.dictionaryObject.associatedDictionary setValue:value forKey:key];
  XCTAssertEqualObjects([self.dictionaryObject.associatedDictionary valueForKey:key],
                       value,
                       @"Not correct value");
}

#pragma mark Blocks

- (void) testAssignWithBlocksSetter
{
  XCTAssertThrowsSpecificNamed(self.testClass.overrideAssignObj = kConstString,
                              NSException,
                              @"setOverrideAssignObj:",
                              @"Expected to raise an exception with the setter's name");
}

- (void) testAssignWithBlocksGetter
{
  id foo = nil;
  XCTAssertThrowsSpecificNamed(foo = self.testClass.overrideAssignObj,
                              NSException,
                              @"overrideAssignObj",
                              @"Expected to raise an exception with the getter's name");
}

- (void) testObjectWithBlocksSetter
{
  XCTAssertThrowsSpecificNamed(self.testClass.overrideObj = kConstString,
                              NSException,
                              @"setOverrideObj:",
                              @"Expected to raise an exception with the setter's name");
}

- (void) testObjectWithBlocksGetter
{
  id foo = nil;
  XCTAssertThrowsSpecificNamed(foo = self.testClass.overrideObj,
                              NSException,
                              @"overrideObj",
                              @"Expected to raise an exception with the getter's name");
}

- (void) testObjectWithBlocksLazyGetter
{
  id foo = nil;
  XCTAssertThrowsSpecificNamed(foo = self.testClass.overrideObjLazy,
                              NSException,
                              @"overrideObjLazy",
                              @"Expected to raise an exception with the getter's name");
}

- (void) testObjectWithBlocksLazyGetterWithInitExpression
{
  id foo = nil;
  XCTAssertThrowsSpecificNamed(foo = self.testClass.overrideObjLazyWithExpression,
                              NSException,
                              @"overrideObjLazyWithExpression",
                              @"Expected to raise an exception with the getter's name");
}

- (void) testPrimitiveWithBlocksSetter
{
  XCTAssertThrowsSpecificNamed(self.testClass.overridePrimitive = 100,
                              NSException,
                              @"setOverridePrimitive:",
                              @"Expected to raise an exception with the setter's name");
}

- (void) testPrimitiveWithBlocksGetter
{
  NSUInteger primitive = 0;
  XCTAssertThrowsSpecificNamed(primitive = self.testClass.overridePrimitive,
                              NSException,
                              @"overridePrimitive",
                              @"Expected to raise an exception with the getter's name");
}

#pragma mark Mainpulate values

- (void) testPrimitiveBlockOverrideValuePrimitives
{
  self.testClass.overrideBlockPrimitiveGetter = 99;
  XCTAssertTrue(self.testClass.overrideBlockPrimitiveGetter == 100,
               @"Should have incremented the value");

  self.testClass.overrideBlockPrimitiveSetter = 50;
  XCTAssertTrue(self.testClass.overrideBlockPrimitiveSetter == 49,
                 @"Should have decremented the value");
}

- (void) testBlockOverrideObjects
{
  self.testClass.overrideObjBlockGetter = @"bar";
  XCTAssertEqualObjects(self.testClass.overrideObjBlockGetter, @"foo",
                       @"Should have used the overridden value");

  self.testClass.overrideObjBlockSetter = @"cat";
  XCTAssertEqualObjects(self.testClass.overrideObjBlockSetter, @"foo",
                       @"Should have used the overridden value");
}

#pragma mark -

- (void)setUp
{
  [super setUp];
  self.testClass = [[TestClass alloc] init];
  self.dictionaryObject = [[NSObject alloc] init];
}

- (void)tearDown
{
  self.testClass = nil;
  self.dictionaryObject = nil;
  [super tearDown];
}

@end
