
/*  ObjcAssociatedObjectHelpers.h -  ObjcAssociatedObjectHelpers

	Created by Jon Crooke on 01/10/2012. - Copyright (c) 2012 Jonathan Crooke. All rights reserved.

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <objc/runtime.h>
#import <TargetConditionals.h>
#import <Availability.h>

#if      !__has_feature(objc_arc)   /** Need Clang ARC */
#warning Associated object macros require Clang ARC to be enabled
#endif   /**  ┏(-_-)┛┗(-_-)┓┗(-_-)┛┏(-_-)┓  */

/** Platform minimum requirements (associated object availability) */
#if		 (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_0
#error Associated references available from iOS 4.0
#elif  TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_6
#error Associated references available from OS X 10.6
#endif

# /**.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:._.:*~*:.*/	pragma mark Quotation helper

#define __OBJC_ASC_QUOTE(x) #x
#define   OBJC_ASC_QUOTE(x) __OBJC_ASC_QUOTE(x)


@interface NSObject (AssociatedDictionary) @property (readonly) NSMutableDictionary *associatedDictionary; @end


/** All the macros have a `_BLOCK` suffix companion which takes a `dispatch_block_t`-type void block in the format 

		void(^block)()
		
	for the getter, AND setter (if available). This allows additional code to be run in the accessors, similar to overriding an accessor.

	@warning  since these are preprocessor macros, it's not possible to pass `nil` to any of these macros. Instead, pass an empty block; `^{}`.

	@discussion In the context of the macro, the passed setter value, or the current associated value will be available as the symbol `value`!Its type will be appropriate to the context in which the macro was declared. `value` is always declared with the `__block` attribute and so can be modified inside the block. Note that this is a little cumbersome since, *as far as I know*, there is no way to specify block parameter types in a macro and have the `value` variable passed explicitly into the block. If there is a way, [I'd love to here about it](mailto:joncrooke@gmail.com).
	
	    SYNTHESIZE_ASC_OBJ					(               object, setObject									);    Most basic form.  Only objects!
			SYNTHESIZE_ASC_OBJ_LAZY			(						lazyObject,	NSString.class						);
			SYNTHESIZE_ASC_OBJ_ASSIGN		(						 assignObj,	setAssignObj							);
			SYNTHESIZE_ASC_OBJ_LAZY_EXP	( nonDefaultLazyObject,	@"foo"										);
			SYNTHESIZE_ASC_OBJ					(      readWriteObject,	setReadWriteObject				);
			SYNTHESIZE_ASC_PRIMITIVE		(            primitive,	setPrimitive, NSUInteger	);
			SYNTHESIZE_ASC_PRIMITIVE		(            structure,	setStructure, TestStruct	);
      SYNTHESIZE_ASC_CAST     		(               object,	setOject, cast            );

*/

# /**--/\/--/\/--/\/--/\/--/\/--/\/--/\/--/\/--/\/--/\/--/\/--/\/--\*/	pragma mark Assign readwrite

#define SYNTHESIZE_ASC_OBJ_ASSIGN(getterName, setterName) \
  SYNTHESIZE_ASC_OBJ_ASSIGN_BLOCK(getterName, setterName, ^{}, ^{})

#define SYNTHESIZE_ASC_OBJ_ASSIGN_BLOCK(getterName, setterName, getterBlock, setterBlock) \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName);																\
- (void)setterName:(id)__newValue {	__block id value = __newValue;												\
  setterBlock();																																					\
  objc_AssociationPolicy policy = OBJC_ASSOCIATION_ASSIGN;																\
  @synchronized(self) { objc_setAssociatedObject(self, getterName##Key, value, policy); } \
}																																													\
- (id) getterName { 																																		  \
  __block id value = nil; 																															  \
  @synchronized(self) { value = objc_getAssociatedObject(self, getterName##Key); };       \
  getterBlock();                     																											\
  return value; 																																		      \
}

# /** -<<O>>--<<O>>--<<O>>--<<O>>--<<O>>--<<O>>--<<O>>--<<O>>--<<O>>-*/	pragma mark Readwrite Object

/** Synthesize a getter and setter for a read/write object property. 
	@discussion If you would like to generate a read-only property with a private or protected setter then you can define this in another category, with the same name and type, but with a (readwrite) ualifier.  it can then be assigned a value (in init, etc.)
	@param getterName Unquoted string that is the same as the property name declared in @interface.
	@param setterName Unquoted string that is that will "set" your property, named in @interface.  ie. for property named "goal", "setGoal"
*/

#define SYNTHESIZE_ASC_OBJ(getterName, setterName) \
  SYNTHESIZE_ASC_OBJ_BLOCK(getterName, setterName, ^{}, ^{})

#define SYNTHESIZE_ASC_OBJ_BLOCK(getterName, setterName, getterBlock, setterBlock)                   \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName); 																			     \
- (void)setterName:(id)__newValue { __block id value = __newValue; 																	 \
  setterBlock(); 																																										 \
  objc_AssociationPolicy policy = 																																	 \
  [value conformsToProtocol:@protocol(NSCopying)] ? OBJC_ASSOCIATION_COPY : OBJC_ASSOCIATION_RETAIN; \
  @synchronized(self) { objc_setAssociatedObject(self, getterName##Key, value, policy); }						 \
} 																																																	 \
- (id) getterName { __block id value = nil; 																												 \
  @synchronized(self) { value = objc_getAssociatedObject(self, getterName##Key); };                  \
  getterBlock(); 																																		                 \
  return value; 																																										 \
}

#/** .*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*O*.*/ pragma mark Lazy readonly object

/**
4. `SYNTHESIZE_ASC_OBJ_LAZY_EXP(getterName, initExpression)` - Synthesize a read-only object that in initialized lazily, with the provided initialiser Expression. For example;

		SYNTHESIZE_ASC_OBJ_LAZY_EXP(nonDefaultLazyObject, [NSString stringWithFormat:@"foo"])	 
	Uses the expression `[NSString stringWithFormat:@"foo"]` to initialise the object. Note that `SYNTHESIZE_ASC_OBJ_LAZY` uses this macro with `[class.alloc init]`.
*/
#define SYNTHESIZE_ASC_OBJ_LAZY_EXP(getterName, initExpression) \
  SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(getterName, initExpression, ^{})

#define SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(getterName, initExpression, block)            \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName); 														  \
- (id)getterName {  __block id value = nil;																							\
  @synchronized(self) { 																																\
    value = objc_getAssociatedObject(self, getterName##Key); 														\
    if (!value) { 																																		  \
      value = initExpression; 																													\
      objc_setAssociatedObject(self, getterName##Key, value, OBJC_ASSOCIATION_RETAIN);  \
    } 																																									\
  } 																																		                \
  block(); 																																		          \
  return value; 																																		    \
}

/**
3. `SYNTHESIZE_ASC_OBJ_LAZY(getterName, class)` - Synthesize a read-only object that in initialized lazily. The object's class must be provided so that an object can be initialized (with `alloc/init`) on first access.
*/
// Use default initialiser
#define SYNTHESIZE_ASC_OBJ_LAZY(getterName, class) \
  SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(getterName, [class.alloc init], ^{})

#define SYNTHESIZE_ASC_OBJ_LAZY_BLOCK(getterName, class, block) \
  SYNTHESIZE_ASC_OBJ_LAZY_EXP_BLOCK(getterName, [class.alloc init], block)


# /** -=*****=-.-=*****=-.-=*****=-.-=*****=-.-=*****=-.-=*****=-.*/		pragma mark Primitive

/**
2. `SYNTHESIZE_ASC_PRIMITIVE(getterName, setterName, type)` - Synthesize for any kind of primitive object. Any type supported by the `@encode()` operator is supported. So that *should* be everything…?
*/

#define SYNTHESIZE_ASC_PRIMITIVE(getterName, setterName, type) \
  SYNTHESIZE_ASC_PRIMITIVE_BLOCK(getterName, setterName, type, ^{}, ^{})

#define SYNTHESIZE_ASC_PRIMITIVE_BLOCK(getterName, setterName, type, getterBlock, setterBlock)  \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName);																			\
- (void)setterName:(type)__newValue {  __block type value = __newValue; 												\
  setterBlock();																																								\
  @synchronized(self) {																																					\
    objc_setAssociatedObject(self, getterName##Key, 																					  \
      [NSValue value:&value withObjCType:@encode(type)], OBJC_ASSOCIATION_RETAIN);					    \
  } 																																		                        \
} 																																		                          \
- (type) getterName {  __block type value; 																											\
  memset(&value, 0, sizeof(type)); 																															\
  @synchronized(self) { [objc_getAssociatedObject(self, getterName##Key) getValue:&value]; }		\
  getterBlock();																																								\
  return value; 																																		            \
}


#pragma todo
// FIX DOCS
# /** -<<O>>--<<O>>--<<O>>--<<O>>--<<O>>--<<O>>--<<O>>--<<O>>--<<O>>-*/	pragma mark Readwrite Object

/** Synthesize a getter and setter for a read/write object property. 
	@discussion If you would like to generate a read-only property with a private or protected setter then you can define this in another category, with the same name and type, but with a (readwrite) ualifier.  it can then be assigned a value (in init, etc.)
	@param getterName Unquoted string that is the same as the property name declared in @interface.
	@param setterName Unquoted string that is that will "set" your property, named in @interface.  ie. for property named "goal", "setGoal"
*/

#define SYNTHESIZE_ASC_CAST(getterName, setterName, casting) \
static void* getterName##Key = OBJC_ASC_QUOTE(getterName);                                                \
- (void)setterName:(casting)__newValue {                                                                  \
  objc_AssociationPolicy policy =                                                                         \
  [__newValue conformsToProtocol:@protocol(NSCopying)] ? OBJC_ASSOCIATION_COPY : OBJC_ASSOCIATION_RETAIN; \
  @synchronized(self) { objc_setAssociatedObject(self, getterName##Key, __newValue, policy); }            \
}                                                                                                         \
- (casting) getterName { __block id value = nil;                                                          \
  @synchronized(self) { value = objc_getAssociatedObject(self, getterName##Key); };                       \
  return value;                                                                                           \
}
