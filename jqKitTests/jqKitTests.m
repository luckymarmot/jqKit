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

- (NSData*)_getTestFileContents:(NSString*)filePath
{
    NSURL* dirURL = [[NSBundle bundleForClass:[self class]].resourceURL URLByAppendingPathComponent:@"json" isDirectory:YES];
    NSURL* fileURL = [dirURL URLByAppendingPathComponent:filePath isDirectory:NO];
    return [NSData dataWithContentsOfURL:fileURL];
}

#pragma mark - Simple Tests

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

#pragma mark - Large Tests

- (void)testSmallSelf
{
    NSData* data = [self _getTestFileContents:@"small.json"];
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@"." data:data error:&error];
    XCTAssertNotNil(results);
    XCTAssertNil(error);
    XCTAssertEqual(results.count, 1);
    XCTAssertEqualObjects([NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL] options:kNilOptions error:NULL], [NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:results.firstObject options:kNilOptions error:NULL] options:kNilOptions error:NULL]);
}

- (void)testMediumSelf
{
    NSData* data = [self _getTestFileContents:@"medium.json"];
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@"." data:data error:&error];
    XCTAssertNotNil(results);
    XCTAssertNil(error);
    XCTAssertEqual(results.count, 1);
    XCTAssertEqualObjects([NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL] options:NSJSONWritingSortedKeys error:NULL], [NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:results.firstObject options:kNilOptions error:NULL] options:NSJSONWritingSortedKeys error:NULL]);
}

- (void)test10MBSelf
{
    NSData* data = [self _getTestFileContents:@"10-MB.json"];
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@"." data:data error:&error];
    XCTAssertNotNil(results);
    XCTAssertNil(error);
    XCTAssertEqual(results.count, 1);
    XCTAssertEqualObjects([NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL] options:NSJSONWritingSortedKeys error:NULL], [NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:results.firstObject options:kNilOptions error:NULL] options:NSJSONWritingSortedKeys error:NULL]);
}

- (void)testMediumFirst
{
    NSData* data = [self _getTestFileContents:@"medium.json"];
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@".[0]" data:data error:&error];
    XCTAssertNotNil(results);
    XCTAssertNil(error);
    XCTAssertEqual(results.count, 1);
    XCTAssertEqualObjects([NSJSONSerialization dataWithJSONObject:((NSArray*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL]).firstObject options:NSJSONWritingSortedKeys error:NULL], [NSJSONSerialization dataWithJSONObject:[NSJSONSerialization JSONObjectWithData:results.firstObject options:kNilOptions error:NULL] options:NSJSONWritingSortedKeys error:NULL]);
}

- (void)testMediumError
{
    NSData* data = [self _getTestFileContents:@"medium.json"];
    NSError* error = nil;
    NSArray<NSData*>* results = [LMJqFilter filterWithProgram:@"[4].key" data:data error:&error];
    XCTAssertNil(results);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, LMJqFilterErrorDomain);
    XCTAssertEqual(error.code, LMJqFilterExecutionError);
}

@end
