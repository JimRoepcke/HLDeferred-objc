//
//  HLDownloadDataSource.h
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLURLDataSource.h"

@interface HLDownloadDataSource : HLURLDataSource

- (instancetype) initWithSourceURL: (NSURL *)sourceURL destinationPath: (NSString *)destinationPath;

@end
