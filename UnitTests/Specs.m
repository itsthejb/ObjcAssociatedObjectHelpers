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

static NSString *const kConstString = @"ConstString";

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Test Class

SpecBegin(Specs)

__block TestClass *testClass;
__block NSObject *dictionaryObject;

before(^{
  testClass = [[TestClass alloc] init];
  dictionaryObject = [[NSObject alloc] init];
});

after(^{
  testClass = nil;
  dictionaryObject = nil;
});

describe(@"basic set / get", ^{

  it(@"should set a simple retained object", ^{
    NSBundle *testObject = [[NSBundle alloc] init];
    testClass.object = testObject;
    expect(testClass.object).to.equal(testObject);
  });

  it(@"should set a primitive", ^{
    NSUInteger value = 99;
    testClass.primitive = value;
    expect(testClass.primitive).to.equal(value);
  });

  it(@"should set a structure", ^{
    TestStruct struct1 = { 1, 2.0 };
    testClass.structure = struct1;
    TestStruct struct2 = testClass.structure;
    expect(memcmp(&struct1, &struct2, sizeof(TestStruct))).to.equal(NSOrderedSame);
  });

  it(@"should assign a simple object", ^{
    testClass.assignObj = kConstString;
    expect(testClass.assignObj).to.equal(kConstString);
  });
});

describe(@"mutable object", ^{

  NSString *string = @"mutableString";
  __block NSMutableString *mutableString = nil;

  before(^{
    mutableString = string.mutableCopy;
    testClass.object = mutableString;
  });

  it(@"should make a copy of the mutable object", ^{
    expect(testClass.object == mutableString).to.beFalsy();
    expect(testClass.object).to.equal(mutableString);
    expect(testClass.object).to.equal(string);
    expect(testClass.object).notTo.beInstanceOf([NSMutableString class]);
  });

  it(@"should not modify the original", ^{
    [mutableString appendString:@"Foo"];
    expect(mutableString).to.equal(@"mutableStringFoo");
    expect(testClass.object).to.equal(@"mutableString");
  });
});

describe(@"read/write object with category", ^{
  it(@"should be created", ^{
    expect(testClass.readWriteObject).notTo.beNil();
    expect(testClass.readWriteObject).to.beInstanceOf([NSObject class]);
  });
});

describe(@"lazy objects", ^{

  specify(@"a simple case should be created", ^{
    expect(testClass.lazyObject).to.beKindOf([NSString class]);
  });

  specify(@"non-default lazy object should use specified initialization expression", ^{
    expect(testClass.nonDefaultLazyObject).to.equal(@"foo");
  });

});

describe(@"non-initialized primitive", ^{

  it(@"should default to zero", ^{
    expect(testClass.primitive).to.equal(0);
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

  __block id variable = nil;
  __block NSUInteger primitive = 0;

  describe(@"assign", ^{
    it(@"should execute the block with setter", ^{
      expect(^{
        testClass.overrideAssignObj = kConstString;
      }).to.raise(@"setOverrideAssignObj:");
    });

    it(@"should execute the block with getter", ^{
      expect(^{
        variable = testClass.overrideAssignObj;
      }).to.raise(@"overrideAssignObj");
    });
  });

  describe(@"retain", ^{
    it(@"should execute the block with setter", ^{
      expect(^{
        testClass.overrideObj = kConstString;
      }).to.raise(@"setOverrideObj:");
    });

    it(@"should execute the block with getter", ^{
      expect(^{
        variable = testClass.overrideObj;
      }).to.raise(@"overrideObj");
    });
  });

  describe(@"lazy getter", ^{
    it(@"should execute the block with getter", ^{
      expect(^{
        variable = testClass.overrideObjLazy;
      }).to.raise(@"overrideObjLazy");
    });
  });

  describe(@"lazy getter with custom init", ^{
    it(@"should execute the block with getter", ^{
      expect(^{
        variable = testClass.overrideObjLazyWithExpression;
      }).to.raise(@"overrideObjLazyWithExpression");
    });
  });

  describe(@"primitive", ^{
    it(@"should execute the block with setter", ^{
      expect(^{
        testClass.overridePrimitive = 100;
      }).to.raise(@"setOverridePrimitive:");
    });

    it(@"should execute the block with getter", ^{
      expect(^{
        primitive = testClass.overridePrimitive;
      }).to.raise(@"overridePrimitive");
    });
  });

  describe(@"modify values", ^{

    describe(@"primtives", ^{
      it(@"getter block should modify the value parameter", ^{
        testClass.overrideBlockPrimitiveGetter = 99;
        expect(testClass.overrideBlockPrimitiveGetter).to.equal(100);
      });

      it(@"setter block should modify the value parameter", ^{
        testClass.overrideBlockPrimitiveSetter = 50;
        expect(testClass.overrideBlockPrimitiveSetter).to.equal(49);
      });
    });

    describe(@"objects", ^{
      it(@"getter block should modify the value parameter", ^{
        testClass.overrideObjBlockGetter = @"bar";
        expect(testClass.overrideObjBlockGetter).to.equal(@"foo");
      });

      it(@"setter block should modify the value parameter", ^{
        testClass.overrideObjBlockSetter = @"cat";
        expect(testClass.overrideObjBlockSetter).to.equal(@"foo");
      });
    });

  });

});

SpecEnd

