//
//  LMJqFilter.m
//  jqKit
//
//  Created by Micha Mazaheri on 8/26/19.
//  Copyright © 2019 Paw. All rights reserved.
//

#import "LMJqFilter.h"

//#include "compile.h"
#include "jv.h"
#include "jq.h"
//#include "jv_alloc.h"
//#include "util.h"
//#include "src/version.h"

typedef enum {
    lm_jq_success = 0,
    lm_jq_invalid_program = 1,
    lm_jq_invalid_json = 2,
} lm_jq_error;

enum {
    JQ_OK              =  0,
    JQ_OK_NULL_KIND    = -1, /* exit 0 if --exit-status is not set*/
    JQ_ERROR_SYSTEM    =  2,
    JQ_ERROR_COMPILE   =  3,
    JQ_OK_NO_OUTPUT    = -4, /* exit 0 if --exit-status is not set*/
    JQ_ERROR_UNKNOWN   =  5,
};

static int process(jq_state *jq, jv value, int flags, int dumpopts) {
    int ret = JQ_OK_NO_OUTPUT; // No valid results && -e -> exit(4)
    jq_start(jq, value, flags);
    jv result;
    while (jv_is_valid(result = jq_next(jq))) {
        if (jv_get_kind(result) == JV_KIND_FALSE || jv_get_kind(result) == JV_KIND_NULL)
        ret = JQ_OK_NULL_KIND;
        else
        ret = JQ_OK;
        jv string_dump = jv_dump_string(result, dumpopts);
        printf(" >> %s\n", jv_string_value(string_dump));
    }
    
    if (jq_halted(jq)) {
        // jq program invoked `halt` or `halt_error`
        jv exit_code = jq_get_exit_code(jq);
        if (!jv_is_valid(exit_code))
        ret = JQ_OK;
        else if (jv_get_kind(exit_code) == JV_KIND_NUMBER)
        ret = jv_number_value(exit_code);
        else
        ret = JQ_ERROR_UNKNOWN;
        jv_free(exit_code);
        jv error_message = jq_get_error_message(jq);
        if (jv_get_kind(error_message) == JV_KIND_STRING) {
            fprintf(stderr, "jq: error: %s", jv_string_value(error_message));
        } else if (jv_get_kind(error_message) == JV_KIND_NULL) {
            // Halt with no output
        } else if (jv_is_valid(error_message)) {
            error_message = jv_dump_string(jv_copy(error_message), 0);
            fprintf(stderr, "jq: error: %s\n", jv_string_value(error_message));
        } // else no message on stderr; use --debug-trace to see a message
        fflush(stderr);
        jv_free(error_message);
    } else if (jv_invalid_has_msg(jv_copy(result))) {
        // Uncaught jq exception
        jv msg = jv_invalid_get_msg(jv_copy(result));
        jv input_pos = jq_util_input_get_position(jq);
        if (jv_get_kind(msg) == JV_KIND_STRING) {
            fprintf(stderr, "jq: error (at %s): %s\n",
                    jv_string_value(input_pos), jv_string_value(msg));
        } else {
            msg = jv_dump_string(msg, 0);
            fprintf(stderr, "jq: error (at %s) (not a string): %s\n",
                    jv_string_value(input_pos), jv_string_value(msg));
        }
        ret = JQ_ERROR_UNKNOWN;
        jv_free(input_pos);
        jv_free(msg);
    }
    jv_free(result);
    return ret;
}

static void lm_jq_err_cb(void *data, jv msg) {
    //    msg = jq_format_error(msg);
    //    printf(" => JQ ERRLR: %s\n", jv_string_value(msg));
    //    jv_free(msg);
}

unsigned int lm_jq_process(const char * program, const char * input)
{
    int ret = JQ_OK_NO_OUTPUT;
    
    jq_state* jq = jq_init();
    
    jq_set_error_cb(jq, lm_jq_err_cb, NULL);
    
    if (0 == jq_compile(jq, program)) {
        printf(" => compile error\n");
        return lm_jq_invalid_program;
    }
    
    jv v = jv_parse(input) ;
    if (!jv_is_valid(v)) {
        printf(" => error\n");
        return lm_jq_invalid_json;
    }
    
    printf(" => begin\n");
    ret = process(jq, v, 0 /* jq_flags */, JV_PRINT_INDENT_FLAGS(2) /* dumpopts */);
    printf("\n");
    printf(" => end\n");
    
    jq_teardown(&jq);
    
    return lm_jq_success;
}


@implementation LMJqFilter

@end
