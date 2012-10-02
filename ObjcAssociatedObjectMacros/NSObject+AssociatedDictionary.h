//
//  NSObject+AssociatedDictionary.h
//  ObjcAssociatedObjectMacros
//
//  Created by jc on 02/10/2012.
//  Copyright (c) 2012 jbsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AssociatedDictionary)

@property (readonly) NSMutableDictionary *associatedDictionary;

@end
