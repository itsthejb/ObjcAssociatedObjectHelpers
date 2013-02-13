//
//  ObjcAssociatedObjectHelpers.h
//  ObjcAssociatedObjectHelpers
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

#import <objc/runtime.h>
#import <TargetConditionals.h>
#import <Availability.h>

/** Need Clang ARC */
#if !__has_feature(objc_arc)
#error Associated object macros require Clang ARC to be enabled
#endif

/** Platform minimum requirements (associated object availability) */
#if ( TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR ) && __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_0
#error Associated references available from iOS 4.0
#elif TARGET_OS_MAC && !( TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR ) && __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_6
#error Associated references available from OS X 10.6
#endif

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Quotation helper
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define __OBJC_ASC_QUOTE(x) #x
#define OBJC_ASC_QUOTE(x) __OBJC_ASC_QUOTE(x)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Assign readwrite
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define SYNTHESIZE_ASC_OBJ_ASSIGN(getterName, setterName) \
  SYNTHESIZE_ASC_OBJ_ASSIGN_BLOCK(getterName, setterName, ^{}, ^{})

#define SYNTHESIZE_ASC_OBJ_ASSIGN_BLOCK(getterName, setterName, getterBlock, setterBlock) \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName); \
- (void)setterName:(id)object { \
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_ASSIGN; \
    @synchronized(self) { \
        objc_setAssociatedObject(self, getterName##Key, object, policy); \
    } \
    setterBlock(); \
} \
- (id) getterName { \
    id ret = nil; \
    @synchronized(self) { \
        ret = objc_getAssociatedObject(self, getterName##Key); \
    }; \
    getterBlock(); \
    return ret; \
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Readwrite Object
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define SYNTHESIZE_ASC_OBJ(getterName, setterName) \
    SYNTHESIZE_ASC_OBJ_BLOCK(getterName, setterName, ^{}, ^{})

#define SYNTHESIZE_ASC_OBJ_BLOCK(getterName, setterName, getterBlock, setterBlock) \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName); \
- (void)setterName:(id)object { \
    objc_AssociationPolicy policy = \
    [object conformsToProtocol:@protocol(NSCopying)] ? OBJC_ASSOCIATION_COPY : OBJC_ASSOCIATION_RETAIN; \
    @synchronized(self) { \
        objc_setAssociatedObject(self, getterName##Key, object, policy); \
    } \
    setterBlock(); \
} \
- (id) getterName { \
    id ret = nil; \
    @synchronized(self) { \
        ret = objc_getAssociatedObject(self, getterName##Key); \
    }; \
    getterBlock(); \
    return ret; \
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Lazy readonly object
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define SYNTHESIZE_ASC_OBJ_LAZY_EXP(getterName, initExpression) \
    SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(getterName, initExpression, ^{})

#define SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(getterName, initExpression, block) \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName); \
- (id)getterName { \
    id object = nil; \
    @synchronized(self) { \
        object = objc_getAssociatedObject(self, getterName##Key); \
        if (!object) { \
            object = initExpression; \
            objc_setAssociatedObject(self, getterName##Key, object, OBJC_ASSOCIATION_RETAIN); \
        } \
    } \
    block(); \
    return object; \
}

// Use default initialiser
#define SYNTHESIZE_ASC_OBJ_LAZY(getterName, class) \
    SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(getterName, [[class alloc] init], ^{})
#define SYNTHESIZE_ASC_OBJ_LAZY_BLOCK(getterName, class, block) \
    SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(getterName, [[class alloc] init], block)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Primitive
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define SYNTHESIZE_ASC_PRIMITIVE(getterName, setterName, type) \
    SYNTHESIZE_ASC_PRIMITIVE_BLOCK(getterName, setterName, type, ^{}, ^{})

#define SYNTHESIZE_ASC_PRIMITIVE_BLOCK(getterName, setterName, type, getterBlock, setterBlock) \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName); \
- (void)setterName:(type)newValue { \
    @synchronized(self) { \
        objc_setAssociatedObject(self, getterName##Key, \
            [NSValue value:&newValue withObjCType:@encode(type)], OBJC_ASSOCIATION_RETAIN); \
    } \
    getterBlock(); \
} \
- (type) getterName { \
    type ret; \
    memset(&ret, 0, sizeof(type)); \
    @synchronized(self) { \
        [objc_getAssociatedObject(self, getterName##Key) getValue:&ret]; \
    } \
    setterBlock(); \
    return ret; \
}
