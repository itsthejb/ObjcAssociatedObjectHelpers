//
//  ObjcAssociatedObjectMacros.h
//  ObjcAssociatedObjectMacros
//
//  Created by jc on 01/10/2012.
//  Copyright (c) 2012 jbsoft. All rights reserved.
//

#import <objc/runtime.h>
#import <TargetConditionals.h>
#import <Availability.h>

/** Need Clang ARC */
#if __has_feature(objc_arc) == 0
#error Associated object macros require Clang ARC to be enabled
#endif

/** Min OS X target 10.6 */
#if TARGET_OS_MAC 
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_6
#error Minimum Mac OS version is 10.6
#endif

/** Min iOS target 4.0 */
#elif TARGET_OS_IPHONE
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_0
#error Minimum iOS version is 4.0
#endif

/** Something else? */
#elif
#error Unsupported target OS
#endif

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Readwrite Object
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define SYNTHESIZE_ASC_OBJ(getterName, setterName) \
static void* getterName##Key = NULL; \
- (void)setterName:(id)object { \
    objc_AssociationPolicy policy = \
    [object conformsToProtocol:@protocol(NSCopying)] ? OBJC_ASSOCIATION_COPY : OBJC_ASSOCIATION_RETAIN; \
    @synchronized(self) { \
        objc_setAssociatedObject(self, getterName##Key, object, policy); \
    } \
} \
- (id) getterName { \
    id ret = nil; \
    @synchronized(self) { \
        ret = objc_getAssociatedObject(self, getterName##Key); \
    }; \
    return ret; \
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Lazy readonly object
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define SYNTHESIZE_ASC_OBJ_LAZY(getterName, class) \
static void* getterName##Key = NULL; \
- (id) associatedDictionary { \
    id object = nil; \
    @synchronized(self) { \
        object = objc_getAssociatedObject(self, getterName##Key); \
        if (!object) { \
            object = [[class alloc] init]; \
            objc_setAssociatedObject(self, getterName##Key, object, OBJC_ASSOCIATION_RETAIN); \
        } \
    } \
    return object; \
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark Primitive
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define SYNTHESIZE_ASC_PRIMITIVE(getterName, setterName, type) \
static void* getterName##Key = NULL; \
- (void)setterName:(type)structure { \
    @synchronized(self) { \
        NSValue *value = [NSValue value:&structure withObjCType:@encode(type)]; \
        objc_setAssociatedObject(self, getterName##Key, value, OBJC_ASSOCIATION_RETAIN); \
    } \
} \
- (type) getterName { \
    type ret; \
    @synchronized(self) { \
        [objc_getAssociatedObject(self, getterName##Key) getValue:&ret]; \
    } \
    return ret; \
}
