ObjcAssociatedObjectHelpers
==========================

What's New
----------

**v1.1**

* Pass a block to the macros in order to *override* their default behaviour.

**v1.0**

* Static library target for iOS, and framework target for OS X.
* [MIT Licensed](http://jc.mit-license.org/)

Introduction
------------

[Associated Objects, or Associated References](http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocAssociativeReferences.html) were introduced in OS X 10.6 and iOS 10.4. This feature gives class instances a dictionary of sorts within which to store arbitrary objects using the runtime functions `objc_setAssociatedObject()` and `objc_getAssociatedObject()`. This project aims to make their use more convenient in a light-weight and thoroughly tested fashion.

1. **Adding ivars to categories** - An unforunate drawback of Obj-C categories in the inability to add or synthesize ivars, even though properties can be added. Associated objects can be used to provide storage and overcome this limitation:
		
		@interface NSObject (MyCategory)
		@property (strong) id myCategoryObject;
		@end
		
		@implementation NSObject (MyCategory)
		SYNTHESIZE_ASC_OBJ(myCategoryObject, setMyCategoryObject);
		@end
	
2. **Abitrary dictionary for NSObject** - The `NSObject` category adds a lazily-initialized `NSMutableDictionary` to `NSObject`, allowing key-value pairs to be associated with any `NSObject` subclass instance:

		[self.associatedDictionary setValue:@"value" forKey:@"myKey"];

Notes
-----
1. **getter / setter names** - There is no way to manipulate strings in the preprocessor so that standard getter and setter names can easily be generated. As such, the read/write macros require both names to be provided manually.
2. **ARC** - Clang ARC is currently required, although it wouldn't be hard to also support manual reference counting.
3. **Property memory management semantics** - Since properties use associated objects for storage, any property setter semantics can be used:

		@property () id myProperty;		
		@property (strong) id myProperty;
		@property (retain) id myProperty;
		@property (assign) id myProperty;
		@property (copy) id myProperty;

    Currently, the macros check at runtime for `NSCopying` protocol compliance and use `OBJC_ASSOCIATION_COPY` if found and `OBJC_ASSOCIATION_RETAIN` otherwise. The test `-[UnitTests testMutableObject]` confirms that a copy is made. I think this is The Right Way™. It's probably best to use normal semantics with these setters, however.

Usage
-----
Static library provided for the `NSObject` category, or just use the header file for basic usage. Prefered installation by using [CocoaPods](http://cocoapods.org/).

Testing
-------
Thorough test cases provided with near 100% coverage.

		
Macros
------
1. `SYNTHESIZE_ASC_OBJ(getterName, setterName)` - The most basic usage. Synthesize a getter and setter for a read/write object property. If you would like to generate a read-only property with a private or protected setter then you can define this in another category:

		@interface MyClass : NSObject
		@property (readonly) id readWriteObject;
		@end
		
		@interface MyClass (PrivateOrProtectedOrAnonymous)
		@property (readwrite) id readWriteObject;
		@end
		
		@implementaton MyClass
		
		- (id) init {
			if ((self = [super init])) {
				self.readWriteObject = @"foo";
			}
			return self;
		}

2. `SYNTHESIZE_ASC_PRIMITIVE(getterName, setterName, type)` - Synthesize for any kind of primitive object. Any type supported by the `@encode()` operator is supported. So that *should* be everything…?
3. `SYNTHESIZE_ASC_OBJ_LAZY(getterName, class)` - Synthesize a read-only object that in initialized lazily. The object's class must be provided so that an object can be initialized (with `alloc/init`) on first access.
4. `SYNTHESIZE_ASC_OBJ_LAZY_EXP(getterName, initExpression)` - Synthesize a read-only object that in initialized lazily, with the provided initialiser Expression. For example;

		SYNTHESIZE_ASC_OBJ_LAZY_EXP(nonDefaultLazyObject, [NSString stringWithFormat:@"foo"])	 
	Uses the expression `[NSString stringWithFormat:@"foo"]` to initialise the object. Note that `SYNTHESIZE_ASC_OBJ_LAZY` uses this macro with `[[class alloc] init]`.
5. All the macros have a `_BLOCK` suffix companion which takes a `void` block in the format `void(^block)()` for the getter, and setter (if available). This allows additional code to be run in the accessors, similar to overriding an accessor.

Todo
----
* No ideas here right now…! Do you have any?

Have fun!
---------

[MIT Licensed](http://jc.mit-license.org/) >> joncrooke@gmail.com 
		
