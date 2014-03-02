//
//  HLDeferred.h
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLFailure.h"

extern NSString * const kHLDeferredCancelled;
extern NSString * const kHLDeferredNoResult;
extern NSString * const HLDeferredAlreadyCalledException;
extern NSString * const HLDeferredAlreadyFinalizedException;

typedef id (^ThenBlock)(id result);
typedef id (^FailBlock)(HLFailure *failure);
typedef void (^HLVoidBlock)(void);

@class HLDeferred;
@class HLLink;

@protocol HLDeferredCancellable <NSObject>

- (void) deferredWillCancel: (HLDeferred *)d;

@end

@interface HLDeferred : NSObject

@property (nonatomic, weak) id <HLDeferredCancellable> canceller;
@property (nonatomic, readonly, assign, getter=isCalled) BOOL called;

// designated initializer
- (instancetype) initWithCanceller: (id <HLDeferredCancellable>) theCanceller;
- (instancetype) init; // calls initWithCanceller: nil

+ (instancetype) deferredWithResult: (id)result;
+ (instancetype) deferredWithError:  (id)error;
+ (instancetype) deferredObserving: (HLDeferred *)otherDeferred;

- (instancetype) then: (ThenBlock)cb;
- (instancetype) fail: (FailBlock)eb;
- (instancetype) both: (ThenBlock)bb;

- (instancetype) then: (ThenBlock)cb fail: (FailBlock)eb;

- (instancetype) thenReturn: (id)aResult;

- (instancetype) thenFinally: (ThenBlock)aThenFinalizer;
- (instancetype) failFinally: (FailBlock)aFailFinalizer;
- (instancetype) bothFinally: (ThenBlock)aBothFinalizer;

- (instancetype) thenFinally: (ThenBlock)atThenFinalizer failFinally: (FailBlock)aFailFinalizer;

- (instancetype) takeResult: (id)aResult;
- (instancetype) takeError: (id)anError;
- (instancetype) notify: (HLDeferred *)otherDeferred;
- (void) cancel;

@end
