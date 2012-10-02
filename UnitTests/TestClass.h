//
//  MyClass.h
//  ascMacro
//
//  Created by Jon Crooke on 01/10/2012.
//  Copyright (c) 2012 soundcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _testStruct {
    int member1;
    float member2;
} TestStruct;

@interface TestClass : NSObject

@property () id object;
@property (readonly) id lazyObject;
@property (readonly) id readWriteObject;
@property (assign) NSUInteger primitive;
@property (assign) TestStruct structure;

@end
