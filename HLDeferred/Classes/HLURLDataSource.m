//
//  HLURLDataSource.m
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLURLDataSource.h"

@implementation HLURLDataSource
{
    NSURLConnection *conn_;
    NSURLResponse *response_;
    NSMutableData *responseData_;
    NSDictionary *context_;
}

@synthesize context=context_;
@synthesize responseData=responseData_;

+ (HLURLDataSource *) postToURL: (NSURL *)url
                       withBody: (NSString *)body
{
    return [[HLURLDataSource alloc] initWithContext: [NSDictionary dictionaryWithObjectsAndKeys:
                                                       @"POST", @"requestMethod",
                                                       url, @"requestURL",
                                                       body, @"requestBody", nil]];
}

- (instancetype) initWithContext: (NSDictionary *)aContext
{
    self = [super init];
    if (self) {
        context_ = aContext;
    }
    return self;
}

- (instancetype) initWithURL: (NSURL *)url
{
	self = [self initWithContext: [NSDictionary dictionaryWithObject: url forKey: @"requestURL"]];
	return self;
}

- (instancetype) initWithURLString: (NSString *)urlString
{
	self = [self initWithContext: [NSDictionary dictionaryWithObject: urlString forKey: @"requestURL"]];
	return self;
}

#pragma mark -
#pragma mark Public API: template methods, override these to customize behaviour

- (NSMutableURLRequest *) urlRequest
{
    NSMutableURLRequest *result = nil;
    id requestURL = context_[@"requestURL"];
    if (requestURL) {
        if ([requestURL isKindOfClass: [NSString class]]) {
            requestURL = [NSURL URLWithString: requestURL];
        }
      
        NSTimeInterval timoutInterval = context_[@"timoutInterval"] ?
          [context_[@"timoutInterval"] doubleValue] : 18;
      
        result = [NSMutableURLRequest requestWithURL: requestURL
                                         cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval: timoutInterval];
        // allow response to be gzip compressed
        [result setValue: @"gzip" forHTTPHeaderField: @"Accept-Encoding"];
        NSString *requestMethod = context_[@"requestMethod"];
        [result setHTTPMethod: requestMethod ?: @"GET"];
        NSData *requestBody = context_[@"requestBody"];
        if (requestBody) {
            [result setHTTPBody: requestBody];
            [result setValue: [NSString stringWithFormat: @"%d", [requestBody length]] forHTTPHeaderField: @"Content-Length"];
        }
        NSString *requestBodyContentType = context_[@"requestBodyContentType"];
        if (requestBodyContentType) [result setValue: requestBodyContentType forHTTPHeaderField: @"content-type"];
        NSString *lastModified = context_[@"requestIfModifiedSince"];
		if (lastModified) [result setValue: lastModified forHTTPHeaderField: @"If-Modified-Since"];
    }
    return result;
}

- (void) execute
{
    conn_ = [[NSURLConnection alloc] initWithRequest: [self urlRequest]
                                            delegate: self];
}

- (void) cancelOnRunLoopThread
{
    [conn_ cancel];
    [super cancelOnRunLoopThread];
}

- (void) responseFailed
{
    [self asyncCompleteOperationError];
}

- (BOOL) responseBegan
{
    BOOL result = NO;
    if ([response_ isKindOfClass: [NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response_;
		NSInteger statusCode = [httpResponse statusCode];
        if ((statusCode >= 200) && (statusCode < 300)) {
            responseData_ = [[NSMutableData alloc] init]; // YAY!
            result = YES;
        }
    } else {
        responseData_ = [[NSMutableData alloc] init]; // YAY!
        result = YES;
    }
    return result;
}

- (void) responseReceivedData: (NSData *)data
{
    if (responseData_) {
        [responseData_ appendData: data];
    }
}

- (void) responseFinished
{
	[self asyncCompleteOperationResult];
}

#pragma mark -
#pragma mark Private API

- (void) connection: (NSURLConnection *)connection didFailWithError: (NSError *)anError
{
    [self setError: anError];
    [self responseFailed];
}

- (void) connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)aResponse
{
    response_ = aResponse;
    [self responseBegan];
}

- (void) connection: (NSURLConnection *)connection didReceiveData: (NSData *)data
{
    [self responseReceivedData: data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
    [self setResult: responseData_];
    [self responseFinished];
}

#pragma mark -
#pragma mark Public API

- (NSString *) responseHeaderValueForKey: (NSString *)key
{
    if ([response_ isKindOfClass: [NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response_;
        return [r allHeaderFields][key];
    }
    return nil;
}

- (NSInteger) responseStatusCode
{
    NSInteger result = 0;
    if ([response_ isKindOfClass: [NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response_;
        result = [httpResponse statusCode];
    }
    return result;
}

- (BOOL) entityWasOK
{
    return [self responseStatusCode] == 200;
}

- (BOOL) entityWasNotModified
{
    return [self responseStatusCode] == 304;
}

- (BOOL) entityWasNotFound
{
    return [self responseStatusCode] == 404;
}

@end
