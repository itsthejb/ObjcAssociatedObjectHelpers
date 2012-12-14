//
//  UnitTests.m
//  UnitTests
//
//  Created by Jon Crooke on 01/10/2012.
//  Copyright (c) 2012 jcrooke. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TestClass.h"
#import "NSObject+AssociatedDictionary.h"

@interface UnitTests : SenTestCase
@property (strong) TestClass *testClass;
@property (strong) NSObject *dictionaryObject;
@end

@implementation UnitTests

#pragma mark Basic set/get

- (void) testObject
{
    NSBundle *testObject = [[NSBundle alloc] init];
    self.testClass.object = testObject;
    STAssertEquals(self.testClass.object, testObject, @"Didn't return same object");
}

- (void) testPrimitive
{
    NSUInteger value = 99;
    self.testClass.primitive = value;
    STAssertEquals(self.testClass.primitive, value, @"Not the correct value");
}

- (void) testStructure
{
    TestStruct struct1 = { 1, 2.0 };
    self.testClass.structure = struct1;
    TestStruct struct2 = self.testClass.structure;
    STAssertTrue(memcmp(&struct1, &struct2, sizeof(TestStruct)) == 0, @"Returned wrong value");
}

#pragma mark Edge cases

- (void) testMutableObject
{
    id string = @"mutableString";
    
    NSMutableString *mutable = [NSMutableString stringWithString:string];
    self.testClass.object = mutable;
    
    // should copy the object
    STAssertFalse(self.testClass.object == mutable, @"Should have made a copy");
    STAssertEqualObjects(self.testClass.object, string, @"Should have same value");
    
    // change the original
    [mutable appendString:@"Foo"];
    STAssertEqualObjects(mutable, @"mutableStringFoo", @"Should have appended");
    STAssertEqualObjects(self.testClass.object, string, @"Should not have changed");
}

- (void) testReadWriteObjectWithCategory
{
    STAssertNotNil(self.testClass.readWriteObject, @"Readwrite object should be created in -init");
}

#pragma mark Lazy Object

- (void) testLazyObject
{
    id lazy = self.testClass.lazyObject;
    STAssertTrue([lazy isKindOfClass:[NSString class]], @"Should be lazy init NSString");
}

- (void) testNonDefaultLazyObject
{
    id lazy = self.testClass.nonDefaultLazyObject;
    STAssertEqualObjects(lazy, @"foo", @"Didn't use non-default initialiser");
}

#pragma mark -

- (void) testNonInitialisedPrimitive
{
    STAssertTrue(self.testClass.primitive == 0, @"Non-initialised primitive should be zero");
}

#pragma mark Associated dictionary

- (void) testInitialize
{
    id dictionary = self.dictionaryObject.associatedDictionary;
    STAssertNotNil(dictionary, @"Dictionary is nil");
    STAssertTrue([dictionary isKindOfClass:[NSMutableDictionary class]], @"Not mutable dictionary");
}

- (void) testSetGet
{
    NSString *key = @"bar";
    NSString *value = @"foo";
    [self.dictionaryObject.associatedDictionary setValue:value forKey:key];
    STAssertEqualObjects([self.dictionaryObject.associatedDictionary valueForKey:key],
                         value,
                         @"Not correct value");
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
