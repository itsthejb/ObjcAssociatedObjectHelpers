//
//  Specs.m
//  ObjcAssociatedObjectHelpers
//
//  Created by Jonathan Crooke on 20/02/2014.
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

#import "TestClass.h"
#import "ReactiveCocoa.h"

#import "ObjcAssociatedObjectHelpers.h"
#import "NSObject+AssociatedDictionary.h"

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>

SpecBegin(Specs)

__block TestClass *testObject;
__block NSObject *dictionaryObject;

NSString *const CONSTANT_STRING = @"ConstString";

before(^{
  testObject = [[TestClass alloc] init];
  dictionaryObject = [[NSObject alloc] init];
});

after(^{
  testObject = nil;
  dictionaryObject = nil;
});

describe(@"basic set / get", ^{

  it(@"should set a simple retained object", ^{
    NSBundle *bundle = [[NSBundle alloc] init];
    testObject.object = bundle;
    expect(testObject.object).to.equal(bundle);
  });

  it(@"should set a primitive", ^{
    NSUInteger value = 99;
    testObject.primitive = value;
    expect(testObject.primitive).to.equal(value);
  });

  it(@"should set a structure", ^{
    TestStruct struct1 = { 1, 2.0 };
    testObject.structure = struct1;
    TestStruct struct2 = testObject.structure;
    expect(memcmp(&struct1, &struct2, sizeof(TestStruct))).to.equal(NSOrderedSame);
  });

  it(@"should assign a simple object", ^{
    testObject.assignObj = CONSTANT_STRING;
    expect(testObject.assignObj).to.equal(CONSTANT_STRING);
  });
});

describe(@"mutable object", ^{

  NSString *string = @"mutableString";
  __block NSMutableString *mutableString = nil;

  before(^{
    mutableString = string.mutableCopy;
    testObject.object = mutableString;
  });

  it(@"should make a copy of the mutable object", ^{
    expect(testObject.object == mutableString).to.beFalsy();
    expect(testObject.object).to.equal(mutableString);
    expect(testObject.object).to.equal(string);
    expect(testObject.object).notTo.beInstanceOf([NSMutableString class]);
  });

  it(@"should not modify the original", ^{
    [mutableString appendString:@"Foo"];
    expect(mutableString).to.equal(@"mutableStringFoo");
    expect(testObject.object).to.equal(@"mutableString");
  });
});

describe(@"read/write object with category", ^{
  it(@"should be created", ^{
    expect(testObject.readWriteObject).notTo.beNil();
    expect(testObject.readWriteObject).to.beInstanceOf([NSObject class]);
  });
});

describe(@"lazy objects", ^{

  specify(@"a simple case should be created", ^{
    expect(testObject.lazyObject).to.beKindOf([NSString class]);
  });

  specify(@"non-default lazy object should use specified initialization expression", ^{
    expect(testObject.nonDefaultLazyObject).to.equal(@"foo");
  });

});

describe(@"non-initialized primitive", ^{

  it(@"should default to zero", ^{
    expect(testObject.primitive).to.equal(0);
  });

});

describe(@"associated dictionary", ^{

  it(@"should be initialized lazily", ^{
    expect(dictionaryObject.associatedDictionary).to.beKindOf([NSMutableDictionary class]);
  });

  it(@"should correctly get/set", ^{
    NSString *key = @"bar"; NSString *value = @"foo";
    dictionaryObject.associatedDictionary[key] = value;
    expect(dictionaryObject.associatedDictionary[key]).to.equal(value);
  });

});

describe(@"block feature", ^{

  __block id object = nil;
  __block NSUInteger primitive = 0;

  describe(@"assign", ^{
    it(@"should execute the block with setter", ^{
      expect(^{
        testObject.overrideAssignObj = CONSTANT_STRING;
      }).to.raise(@"setOverrideAssignObj:");
    });

    it(@"should execute the block with getter", ^{
      expect(^{
        object = testObject.overrideAssignObj;
      }).to.raise(@"overrideAssignObj");
    });
  });

  describe(@"retain", ^{
    it(@"should execute the block with setter", ^{
      expect(^{
        testObject.overrideObj = CONSTANT_STRING;
      }).to.raise(@"setOverrideObj:");
    });

    it(@"should execute the block with getter", ^{
      expect(^{
        object = testObject.overrideObj;
      }).to.raise(@"overrideObj");
    });
  });

  describe(@"lazy getter", ^{
    it(@"should execute the block with getter", ^{
      expect(^{
        object = testObject.overrideObjLazy;
      }).to.raise(@"overrideObjLazy");
    });
  });

  describe(@"lazy getter with custom init", ^{
    it(@"should execute the block with getter", ^{
      expect(^{
        object = testObject.overrideObjLazyWithExpression;
      }).to.raise(@"overrideObjLazyWithExpression");
    });
  });

  describe(@"primitive", ^{
    it(@"should execute the block with setter", ^{
      expect(^{
        testObject.overridePrimitive = 100;
      }).to.raise(@"setOverridePrimitive:");
    });

    it(@"should execute the block with getter", ^{
      expect(^{
        primitive = testObject.overridePrimitive;
      }).to.raise(@"overridePrimitive");
    });
  });

  describe(@"modify values", ^{

    describe(@"primtives", ^{
      it(@"getter block should modify the value parameter", ^{
        testObject.overrideBlockPrimitiveGetter = 99;
        expect(testObject.overrideBlockPrimitiveGetter).to.equal(100);
      });

      it(@"setter block should modify the value parameter", ^{
        testObject.overrideBlockPrimitiveSetter = 50;
        expect(testObject.overrideBlockPrimitiveSetter).to.equal(49);
      });
    });

    describe(@"objects", ^{
      it(@"getter block should modify the value parameter", ^{
        testObject.overrideObjBlockGetter = @"bar";
        expect(testObject.overrideObjBlockGetter).to.equal(@"foo");
      });

      it(@"setter block should modify the value parameter", ^{
        testObject.overrideObjBlockSetter = @"cat";
        expect(testObject.overrideObjBlockSetter).to.equal(@"foo");
      });
    });
  });
});

describe(@"KVO notifications", ^{

	it(@"should send kvo notifications with object retain", ^{
		waitUntil(^(DoneCallback done) {
			[[[RACObserve(testObject, readWriteObject) skip:1] take:1] subscribeNext:^(id x) {
				expect(x).to.equal(@"1234");
				done();
			}];
			testObject.readWriteObject = @"1234";
		});
	});

  it(@"should send notifications with object assign", ^{
		waitUntil(^(DoneCallback done) {
			[[[RACObserve(testObject, assignObj) skip:1] take:1] subscribeNext:^(id x) {
				expect(x).to.equal(@"asdf");
				done();
			}];
			testObject.assignObj = @"asdf";
		});
  });

  it(@"should send notifications with primitive", ^{
		waitUntil(^(DoneCallback done) {
			[[[RACObserve(testObject, primitive) skip:1] take:1] subscribeNext:^(id x) {
				expect(x).to.equal(9675);
				done();
			}];
			testObject.primitive = 9675;
		});
  });
});

describe(@"weak container", ^{

  NSMutableArray *array = [NSMutableArray arrayWithObject:@"foo"];

  it(@"should get and set a value as normal", ^{
    testObject.weakObject = array.firstObject;
    expect(testObject.weakObject && testObject.weakObject == array.firstObject).to.beTruthy();
  });

  it(@"should nil the weak property", ^{
    testObject.weakObject = array.firstObject;
    expect(testObject.weakObject && testObject.weakObject == array.firstObject).to.beTruthy();
    [array removeAllObjects];
    expect(testObject.weakObject).to.beNil();
  });
});

SpecEnd

