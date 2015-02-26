//
//  WeakContainer.m
//  ObjcAssociatedObjectHelpers
//
//  Created by Jonathan Crooke on 26/02/2015.
//  Copyright (c) 2015 jbsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjcAssociatedObjectHelpers.h"
#import "TestClass.h"

@interface WeakContainer : XCTestCase
@property (nonatomic, strong) TestClass *testObject;
@property (nonatomic, strong) NSArray *strongContainer;
@end

@implementation WeakContainer

- (void)testGetAndSetAValueAsNormal {
  XCTAssertNotNil(self.testObject.weakObject);
  XCTAssertEqual(self.testObject.weakObject, self.strongContainer.firstObject);
}

- (void)testNilOfWeakProperty {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Weak property becomes nil"];
  self.strongContainer = nil;
  dispatch_async(dispatch_get_main_queue(), ^{
    XCTAssertNil(self.testObject.weakObject);
    [expectation fulfill];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark -

- (void)setUp {
  [super setUp];
  self.testObject = [[TestClass alloc] init];
  self.strongContainer = @[[[NSObject alloc] init]];
  self.testObject.weakObject = self.strongContainer.firstObject;
}

@end
