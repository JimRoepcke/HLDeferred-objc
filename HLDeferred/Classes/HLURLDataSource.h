//
//  HLURLDataSource.h
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLDeferredConcurrentDataSource.h"

@interface HLURLDataSource : HLDeferredConcurrentDataSource

@property (nonatomic, strong) NSDictionary *context;
@property (nonatomic, strong) NSMutableData *responseData;

// designated initializer
- (instancetype) initWithContext: (NSDictionary *)aContext;

// convenience initializers
- (instancetype) initWithURL: (NSURL *)url;
- (instancetype) initWithURLString: (NSString *)urlString;

+ (HLURLDataSource *) postToURL: (NSURL *)url
                       withBody: (NSString *)body;

- (NSString *) responseHeaderValueForKey: (NSString *)key;
- (NSInteger) responseStatusCode;

- (BOOL) entityWasOK;
- (BOOL) entityWasNotModified;
- (BOOL) entityWasNotFound;

#pragma mark -
#pragma mark Public API: template methods, override these to customize behaviour (do NOT call directly)

- (NSMutableURLRequest *) urlRequest;

- (BOOL) responseBegan;
- (void) responseReceivedData: (NSData *)data;
- (void) responseFinished;
- (void) responseFailed;

@end
