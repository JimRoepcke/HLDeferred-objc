//
//  HLDeferredList.m
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLDeferredList.h"

NSString * const kHLDeferredListNilSentinel = @"__HLDeferredListNilSentinel__";

@implementation HLDeferredList
{
    NSArray *deferreds_;
    NSMutableArray *results_;
    BOOL fireOnFirstResult_;
    BOOL fireOnFirstError_;
    BOOL consumeErrors_;
    NSUInteger finishedCount_;
	BOOL cancelDeferredsWhenCancelled_;
}

- (instancetype) initWithDeferreds: (NSArray *)list
       fireOnFirstResult: (BOOL)flFireOnFirstResult
        fireOnFirstError: (BOOL)flFireOnFirstError
           consumeErrors: (BOOL)flConsumeErrors
{
    self = [super init];
    if (self) {
        deferreds_ = [(list ?: @[]) copy];
        fireOnFirstResult_ = flFireOnFirstResult;
        fireOnFirstError_ = flFireOnFirstError;
        consumeErrors_ = flConsumeErrors;
        results_ = [[NSMutableArray alloc] initWithCapacity: [list count]];
        finishedCount_ = 0;
        cancelDeferredsWhenCancelled_ = NO;
		
        for (int i = 0; i < [deferreds_ count]; i++) {
            [results_ addObject: [NSNull null]];
        }
        
        if (([deferreds_ count] == 0) && (!fireOnFirstResult_)) {
            [self takeResult: results_];
        }
        
        [deferreds_ enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            __unsafe_unretained ThenBlock deferredCallback = ^(id result) {
                if ([result isKindOfClass: [HLDeferred class]]) {
                    [result both: deferredCallback];
                    return result;
                };
                [results_ replaceObjectAtIndex: idx withObject: result ?: [NSNull null]];
                ++finishedCount_;
                BOOL succeeded = ![result isKindOfClass: [HLFailure class]];
                if (![self isCalled]) {
                    if (succeeded && fireOnFirstResult_)
                        [self takeResult: result];
                    else if (!succeeded && fireOnFirstError_)
                        [self takeError: result];
                    else if (finishedCount_ == [results_ count])
                        [self takeResult: results_];
                }
                
                if ((!succeeded) && consumeErrors_) {
                    result = nil;
                }
                return result;
            };
            [obj both: deferredCallback];
        }];
    }
    return self;
}

- (instancetype) initWithDeferreds: (NSArray *)list
{
    self = [self initWithDeferreds: list
                 fireOnFirstResult: NO
                  fireOnFirstError: NO
                     consumeErrors: NO];
    return self;
}

- (instancetype) initWithDeferreds: (NSArray *)list fireOnFirstResult: (BOOL)flFireOnFirstResult
{
    self = [self initWithDeferreds: list
                 fireOnFirstResult: flFireOnFirstResult
                  fireOnFirstError: NO
                     consumeErrors: NO];
    return self;
}

- (instancetype) initWithDeferreds: (NSArray *)list fireOnFirstResult: (BOOL)flFireOnFirstResult consumeErrors: (BOOL)flConsumeErrors
{
    self = [self initWithDeferreds: list
                 fireOnFirstResult: flFireOnFirstResult
                  fireOnFirstError: NO
                     consumeErrors: flConsumeErrors];
    return self;
}

- (instancetype) initWithDeferreds: (NSArray *)list fireOnFirstError: (BOOL)flFireOnFirstError
{
    self = [self initWithDeferreds: list
                 fireOnFirstResult: NO
                  fireOnFirstError: flFireOnFirstError
                     consumeErrors: NO];
    return self;
}

- (instancetype) initWithDeferreds: (NSArray *)list consumeErrors: (BOOL)flConsumeErrors
{
    self = [self initWithDeferreds: list
                 fireOnFirstResult: NO
                  fireOnFirstError: NO
                     consumeErrors: flConsumeErrors];
    return self;
}

- (void) dealloc
{
     deferreds_ = nil;
     results_ = nil;
}

- (void) cancelDeferredsWhenCancelled
{
	cancelDeferredsWhenCancelled_ = YES;
}

- (void) cancel
{
	[super cancel];
	if (cancelDeferredsWhenCancelled_) {
		[deferreds_ makeObjectsPerformSelector: @selector(cancel)];
	}
}

@end
