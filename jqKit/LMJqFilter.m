//
//  LMJqFilter.m
//  jqKit
//
//  Created by Micha Mazaheri on 8/26/19.
//  Copyright © 2019 Paw. All rights reserved.
//

#import "LMJqFilter.h"

#include "jv.h"
#include "jq.h"


enum {
    JQ_OK              =  0,
    JQ_OK_NULL_KIND    = -1, /* exit 0 if --exit-status is not set*/
    JQ_ERROR_SYSTEM    =  2,
    JQ_ERROR_COMPILE   =  3,
    JQ_OK_NO_OUTPUT    = -4, /* exit 0 if --exit-status is not set*/
    JQ_ERROR_UNKNOWN   =  5,
};

static int lm_jq_process(jq_state *jq, jv value, int flags, int dumpopts, void (^callback)(bool, const char* output, const char* error, bool* __stop)) {
    int ret = JQ_OK_NO_OUTPUT;
    jv result;
    bool stop = false;

    // start and loop over results
    jq_start(jq, value, flags);
    while (jv_is_valid(result = jq_next(jq))) {
        if (jv_get_kind(result) == JV_KIND_FALSE || jv_get_kind(result) == JV_KIND_NULL) {
            ret = JQ_OK_NULL_KIND;
        }
        else {
            ret = JQ_OK;
        }

        // get string
        jv string_dump = jv_dump_string(result, dumpopts);
        const char* output = jv_string_value(string_dump);

        // callback
        callback(true, output, NULL, &stop);

        // stop?
        if (stop) {
            break;
        }
    }

    // do not run checks if stopped
    if (!stop) {
        // jq program invoked `halt` or `halt_error`
        if (jq_halted(jq)) {
            // get exit code
            jv exit_code = jq_get_exit_code(jq);
            if (!jv_is_valid(exit_code)) {
                ret = JQ_OK;
            }
            else if (jv_get_kind(exit_code) == JV_KIND_NUMBER) {
                ret = jv_number_value(exit_code);
            }
            else {
                ret = JQ_ERROR_UNKNOWN;
            }
            jv_free(exit_code);
            
            // get error message
            jv error_message = jq_get_error_message(jq);
            if (jv_get_kind(error_message) == JV_KIND_STRING) {
                callback(false, NULL, jv_string_value(error_message), &stop);
            } else if (jv_get_kind(error_message) == JV_KIND_NULL) {
                // halt with no output
            } else if (jv_is_valid(error_message)) {
                error_message = jv_dump_string(jv_copy(error_message), 0);
                callback(false, NULL, jv_string_value(error_message), &stop);
            };
            jv_free(error_message);
        }
        // uncaught jq exception
        else if (jv_invalid_has_msg(jv_copy(result))) {
            jv msg = jv_invalid_get_msg(jv_copy(result));
            if (jv_get_kind(msg) == JV_KIND_STRING) {
                callback(false, NULL, jv_string_value(msg), &stop);
            } else {
                msg = jv_dump_string(msg, 0);
                callback(false, NULL, jv_string_value(msg), &stop);
            }
            ret = JQ_ERROR_UNKNOWN;
            jv_free(msg);
        }
    }

    jv_free(result);
    return ret;
}

static void lm_jq_err_cb(void *data, jv msg) {
    //    msg = jq_format_error(msg);
    //    printf(" => JQ ERRLR: %s\n", jv_string_value(msg));
    //    jv_free(msg);
}

LMJqFilterResult lm_jq_filter(const char* program, const char* data, void (^callback)(bool, const char* output, const char* error, bool* __stop))
{
    // init jq
    jq_state* jq = jq_init();

    // set error callback
    jq_set_error_cb(jq, lm_jq_err_cb, NULL);

    // compile or return error
    if (0 == jq_compile(jq, program)) {
        return LMJqFilterCompileError;
    }

    // parse JSON
    jv v = jv_parse(data) ;
    if (!jv_is_valid(v)) {
        return LMJqFilterParsingError;
    }

    // process
    int ret = lm_jq_process(jq, v, 0 /* jq_flags */, JV_PRINT_INDENT_FLAGS(2) /* dumpopts */, callback);

    jq_teardown(&jq);
    return ((ret == JQ_OK || ret == JQ_OK_NO_OUTPUT) ? LMJqFilterSuccess : LMJqFilterExecutionError);
}

NSString* LMJqFilterErrorDomain = @"com.luckymarmot.JqFilterErrorDomain";

NSString* LMJqFilterErrorJQString = @"JQString";

@implementation LMJqFilter

+ (LMJqFilterResult)filterWithProgram:(NSString*)program data:(NSData*)data callback:(void(^)(NSData*, BOOL* __stop))callback error:(NSError**)__error
{
    // get program C string
    const char* programStr = [program cStringUsingEncoding:NSUTF8StringEncoding];

    // get data buffer (null terminated C string)
    NSUInteger dataLen = data.length;
    char* dataBuf = malloc(sizeof(char) * (dataLen + 1));
    memcpy(dataBuf, data.bytes, dataLen);
    dataBuf[dataLen] = '\0';

    // run filter
    __block NSError* error = nil;
    LMJqFilterResult result = lm_jq_filter(programStr, dataBuf, ^(bool status, const char *outputStr, const char *errorStr, bool* __stop) {
        if (status) {
            NSUInteger outputLen = strlen(outputStr);
            NSData* output = [NSData dataWithBytes:outputStr length:outputLen];
            BOOL stop = NO;
            callback(output, &stop);
            if (stop) {
                *__stop = true;
            }
        }
        else {
            NSString* errorJq = (errorStr != NULL ? [NSString stringWithCString:errorStr encoding:NSUTF8StringEncoding] : nil);
            error = [LMJqFilter jqFilterExecutionErrorWithString:errorJq];
        }
    });

    // set error pointer
    if (result != LMJqFilterSuccess && __error != NULL) {
        if (result == LMJqFilterCompileError) {
            error = [LMJqFilter jqFilterCompileError];
        }
        else if (result == LMJqFilterParsingError) {
            error = [LMJqFilter jqFilterParsingError];
        }
        *__error = error;
    }

    free(dataBuf);
    return result;
}

+ (NSArray<NSData*>*)filterWithProgram:(NSString*)program data:(NSData*)data error:(NSError**)__error
{
    NSError* error;
    NSMutableArray<NSData*>* resultArray = [NSMutableArray array];
    LMJqFilterResult result = [LMJqFilter filterWithProgram:program data:data callback:^(NSData* output, BOOL* __stop) {
        [resultArray addObject:output];
    } error:&error];

    // if error, set error and return nil
    if (result != LMJqFilterSuccess) {
        if (__error != NULL) {
            *__error = error;
        }
        return nil;
    }

    return [resultArray copy];
}

#pragma mark - Errors

+ (NSError*)jqFilterExecutionErrorWithString:(NSString*)jqErrorString
{
    return [NSError errorWithDomain:LMJqFilterErrorDomain code:LMJqFilterExecutionError userInfo:@{
		NSLocalizedDescriptionKey:[NSString stringWithFormat:@"jq: %@", (jqErrorString ?: @"")],
        LMJqFilterErrorJQString:(jqErrorString ?: @""),
	}];
}

+ (NSError*)jqFilterCompileError
{
    return [NSError errorWithDomain:LMJqFilterErrorDomain code:LMJqFilterCompileError userInfo:@{
		NSLocalizedDescriptionKey:@"jq: compile error",
	}];
}

+ (NSError*)jqFilterParsingError
{
    return [NSError errorWithDomain:LMJqFilterErrorDomain code:LMJqFilterParsingError userInfo:@{
		NSLocalizedDescriptionKey:@"jq: invalid JSON input",
	}];
}

@end
