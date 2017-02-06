//
//  ARCWeakRef.h
//  M9
//
//  Created by iwill on 2013-07-08.
//  Copyright (c) 2013年 iwill. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EXTScope.h"

/**
 *  Bring ARC weak ref to MRC code.
 *  !!!: Use weakify and strongify from extobjc instead in ARC.
 *
 *  Usage:
 *      weakifyself;
 *      [object setCallback:^{
 *          strongifyself;
 *          NSLog(@"self: %@", self);
 *      }];
 *  OR
 *      __typeof__(self) selfType;
 *      ARCWeakRef *weakRef = [ARCWeakRef weakRefWithObject:self];
 *      [object setCallback:^{
 *          __typeof__(selfType) self = weakRef.object
 *          NSLog(@"self: %@", self);
 *      }];
 */

#define weakifyself __typeof__(self) $selfType; ARCWeakRef *$weakRef = [ARCWeakRef weakRefWithObject:self]
#define strongifyself __typeof__($selfType) self = $weakRef.object

@interface ARCWeakRef : NSObject

@property(nonatomic, weak) id object;

+ (instancetype)weakRefWithObject:(id)object;

@end

