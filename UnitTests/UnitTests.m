//
//  UnitTests.m
//  UnitTests
//
//  Created by jc on 01/10/2012.
//  Copyright (c) 2012 jbsoft. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TestClass.h"

@interface UnitTests : SenTestCase
@property (strong) TestClass *testClass;
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
    NSRect rect = NSMakeRect(11, 22, 33, 44);
    self.testClass.structure = rect;
    STAssertTrue(NSEqualRects(self.testClass.structure, rect), @"Returned wrong value");
}

#pragma mark Edge cases

- (void) testMutableObject
{
    NSMutableString *mutable = [NSMutableString stringWithString:@"mutableString"];
    self.testClass.object = mutable;
    STAssertFalse(self.testClass.object == mutable, @"Should have made a copy");
}

#pragma mark -

- (void)setUp
{
    [super setUp];
    self.testClass = [[TestClass alloc] init];
}

- (void)tearDown
{
    self.testClass = nil;
    [super tearDown];
}

@end
