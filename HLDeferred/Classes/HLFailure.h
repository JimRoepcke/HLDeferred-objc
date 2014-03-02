//
//  HLFailure.h
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

@interface HLFailure : NSObject

+ (HLFailure *) wrap: (id)v;

- (instancetype) initWithValue: (id)v;
- (id) value;
- (NSError *) valueAsError;

@end
