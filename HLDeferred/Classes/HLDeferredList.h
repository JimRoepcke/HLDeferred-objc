//
//  HLDeferredList.h
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLDeferred.h"

@interface HLDeferredList : HLDeferred

- (instancetype) initWithDeferreds: (NSArray *)list
       fireOnFirstResult: (BOOL)flFireOnFirstResult
        fireOnFirstError: (BOOL)flFireOnFirstError
           consumeErrors: (BOOL)flConsumeErrors;

- (instancetype) initWithDeferreds: (NSArray *)list;
- (instancetype) initWithDeferreds: (NSArray *)list fireOnFirstResult: (BOOL)flFireOnFirstResult;
- (instancetype) initWithDeferreds: (NSArray *)list fireOnFirstResult: (BOOL)flFireOnFirstResult consumeErrors: (BOOL)flConsumeErrors;
- (instancetype) initWithDeferreds: (NSArray *)list fireOnFirstError: (BOOL)flFireOnFirstError;
- (instancetype) initWithDeferreds: (NSArray *)list consumeErrors: (BOOL)flConsumeErrors;

- (void) cancelDeferredsWhenCancelled;

@end
