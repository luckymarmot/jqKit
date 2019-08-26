//
//  jqKitTests.m
//  jqKitTests
//
//  Created by Micha Mazaheri on 8/26/19.
//  Copyright © 2019 Paw. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LMJqFilter.h"

@interface jqKitTests : XCTestCase

@end

@implementation jqKitTests

- (void)testSimpleSelf
{
    // {"foo": 0, "bar":1}
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@"." data:[@"{\"foo\": 0, \"bar\":42}" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNotNil(results);
    XCTAssertNil(error);
    XCTAssertEqualObjects(results, (@[[@"{\n  \"foo\": 0,\n  \"bar\": 42\n}" dataUsingEncoding:NSASCIIStringEncoding]]));
}

- (void)testSimpleOneKey
{
    // {"foo": 0, "bar":1}
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@".bar" data:[@"{\"foo\": 0, \"bar\":42}" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNotNil(results);
    XCTAssertNil(error);
    XCTAssertEqualObjects(results, (@[[@"42" dataUsingEncoding:NSASCIIStringEncoding]]));
}

- (void)testSimpleAllValues
{
    // {"foo": 0, "bar":1}
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@".[]" data:[@"{\"foo\": 0, \"bar\":42}" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNotNil(results);
    XCTAssertNil(error);
    XCTAssertEqualObjects(results, (@[[@"0" dataUsingEncoding:NSASCIIStringEncoding], [@"42" dataUsingEncoding:NSASCIIStringEncoding]]));
}

- (void)testErrorInvalidProgram
{
    // {"foo": 0, "bar":1}
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@"(." data:[@"{\"foo\": 0, \"bar\":42}" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNil(results);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, LMJqFilterErrorDomain);
    XCTAssertEqual(error.code, LMJqFilterCompileError);
}

- (void)testErrorInvalidJSON
{
    // {"foo": 0, "bar":1}
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@"." data:[@"{\"foo\": 0, XXXXX}" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNil(results);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, LMJqFilterErrorDomain);
    XCTAssertEqual(error.code, LMJqFilterParsingError);
}

@end
