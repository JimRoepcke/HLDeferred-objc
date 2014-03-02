//
//  HLJSONDataSource.m
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLJSONDataSource.h"

@implementation HLJSONDataSource
{
    NSJSONReadingOptions JSONReadingOptions_;
}

@synthesize JSONReadingOptions=JSONReadingOptions_;

- (void) responseFinished
{
    if ([self responseData]) {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData: [self responseData] options: [self JSONReadingOptions] error: &error];
        if (result) {
            [self setResponseData: nil];
            [self setResult: result];
            [self asyncCompleteOperationResult];
        } else {
            [self setError: error];
            [self asyncCompleteOperationError];
        }
    } else {
        [super responseFinished];
    }
}

@end
