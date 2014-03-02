//
//  HLJSONDataSourceTest.m
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLJSONDataSource.h"

@interface HLJSONDataSourceTest : GHAsyncTestCase
@end

@implementation HLJSONDataSourceTest

- (void) testSimple
{
	[self prepare];
	
	HLJSONDataSource *ds = [[HLJSONDataSource alloc] initWithURLString: @"http://graph.facebook.com/19292868552"];
	HLDeferred *d = [ds requestStartOnQueue: [NSOperationQueue mainQueue]];
	[ds release]; ds = nil;
	
	__block BOOL success = NO;
	__block id theResult = nil;
	[d then: ^(id result) {
		success = YES;
        theResult = [result retain];
		[self notify: kGHUnitWaitStatusSuccess forSelector: @selector(testSimple)];
		return result;
	} fail: ^(HLFailure *failure) {
		[self notify: kGHUnitWaitStatusFailure forSelector: @selector(testSimple)];
		return failure;
	}];
	[self waitForStatus: kGHUnitWaitStatusSuccess timeout: 10.0];
	GHAssertTrue(success, @"callback didn't run");	
    GHAssertNotNil(theResult, nil);
    GHAssertTrue([theResult isKindOfClass: [NSDictionary class]], @"theResult is a %@, not NSDictionary", NSStringFromClass([theResult class]));
    [theResult release];
}

- (void) testFail
{
	[self prepare];
	
	HLJSONDataSource *ds = [[HLJSONDataSource alloc] initWithURLString: @"http://www.google.com/"];
	HLDeferred *d = [ds requestStartOnQueue: [NSOperationQueue mainQueue]];
	[ds release]; ds = nil;
	
	__block BOOL success = NO;
	
	[d then: ^(id result) {
		[self notify: kGHUnitWaitStatusFailure forSelector: @selector(testFail)];
		return result;
	} fail: ^(HLFailure *failure) {
		success = YES;
		[self notify: kGHUnitWaitStatusSuccess forSelector: @selector(testFail)];
		return failure;
	}];
	[self waitForStatus: kGHUnitWaitStatusSuccess timeout: 5.0];
	GHAssertTrue(success, @"errback didn't run");	
}

- (void) testNotFound
{
	[self prepare];
	
	HLJSONDataSource *ds = [[HLJSONDataSource alloc] initWithURLString: @"http://www.google.com/asdfasdfasdf"];
	HLDeferred *d = [ds requestStartOnQueue: [NSOperationQueue mainQueue]];
	[ds release]; ds = nil;
	
	__block BOOL success = NO;
	__block id theResult = nil;
    
	[d then: ^(id result) {
		success = YES;
        theResult = [result retain];
		[self notify: kGHUnitWaitStatusSuccess forSelector: @selector(testNotFound)];
		return result;
	} fail: ^(HLFailure *failure) {
		[self notify: kGHUnitWaitStatusFailure forSelector: @selector(testNotFound)];
		return failure;
	}];
	[self waitForStatus: kGHUnitWaitStatusSuccess timeout: 5.0];
	GHAssertTrue(success, @"callback didn't run");	
    GHAssertNil(theResult, nil);
    [theResult release]; theResult = nil;
}

@end
