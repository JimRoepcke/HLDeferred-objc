//
//  HLFailure.m
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLFailure.h"

@implementation HLFailure
{
	id value_;
}

- (instancetype) initWithValue: (id)v
{
	self = [super init];
	if (self) {
		value_ = ([v isKindOfClass: [HLFailure class]] ? [(HLFailure *)v value] : v);
	}
	return self;
}

+ (HLFailure *) wrap: (id)v
{
	if ([v isKindOfClass: [HLFailure class]]) return v;
	return [[[self class] alloc] initWithValue: v];
}

- (id) value { return value_; }

- (NSError *) valueAsError
{
    if ([value_ isKindOfClass: [NSError class]]) {
        return value_;
    } else {
        return [NSError errorWithDomain: @"HLFailure" code: 0 userInfo: [NSDictionary dictionaryWithObject: value_ forKey: @"value"]];
    }
}

@end
