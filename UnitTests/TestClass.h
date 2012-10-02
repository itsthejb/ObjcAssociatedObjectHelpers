//
//  MyClass.h
//  ascMacro
//
//  Created by jc on 01/10/2012.
//  Copyright (c) 2012 soundcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestClass : NSObject

@property (assign) NSUInteger primitive;
@property (readonly) id lazyObject;
@property (strong) id object;
@property (assign) NSRect structure;

@end
