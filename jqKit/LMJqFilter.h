//
//  LMJqFilter.h
//  jqKit
//
//  Created by Micha Mazaheri on 8/26/19.
//  Copyright © 2019 Paw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LMJqFilterSuccess = 0,
    LMJqFilterCompileError = 1 /* compiling jq program/query */,
    LMJqFilterParsingError = 2 /* parsing JSON */,
    LMJqFilterExecutionError = 3 /* error during execution */,
} LMJqFilterResult;

FOUNDATION_EXPORT NSString* LMJqFilterErrorDomain;

FOUNDATION_EXPORT NSString* LMJqFilterErrorJQString;

@interface LMJqFilter : NSObject

+ (LMJqFilterResult)filterWithProgram:(NSString*)program data:(NSData*)data callback:(void(^)(NSData*, BOOL*))callback error:(NSError * _Nullable * _Nullable)__error;
+ (nullable NSArray<NSData*>*)filterWithProgram:(NSString*)program data:(NSData*)data error:(NSError * _Nullable * _Nullable)__error;
+ (nullable NSData*)firstResultWithProgram:(NSString*)program data:(NSData*)data error:(NSError * _Nullable * _Nullable)__error;

@end

NS_ASSUME_NONNULL_END
