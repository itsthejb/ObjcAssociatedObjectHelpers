//
//  MyClass.h
//  ascMacro
//
//  Created by jc on 01/10/2012.
//  Copyright (c) 2012 soundcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestClass : NSObject

@property (strong) id object;
@property (readonly) id lazyObject;
@property (strong, readonly) id readWriteObject;
@property (assign) NSUInteger primitive;
@property (assign) NSRect structure;

@end
