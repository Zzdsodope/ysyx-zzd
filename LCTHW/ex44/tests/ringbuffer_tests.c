#include "minunit.h"    // 引入MinUnit头文件
#include "lcthw/ringbuffer.h" // 引入环形缓冲区的实现
#include <assert.h>

#define NUM_TESTS 5
static RingBuffer *rb = NULL;

char *test_create()
{
    rb = RingBuffer_create(1024);
    mu_assert(rb != NULL, "Failed to create RingBuffer");
    mu_assert(rb->length == 1025, "RingBuffer length incorrect");
    mu_assert(RingBuffer_empty(rb), "RingBuffer should be empty after creation");

    return NULL;
}

char *test_write_read()
{
    char *data = "test";
    int result = RingBuffer_write(rb, data, 4);
    mu_assert(result == 4, "RingBuffer_write should write 4 bytes");

    char output[5] = {0}; // 确保有足够的空间和零初始化
    result = RingBuffer_read(rb, output, 4);
    mu_assert(result == 4, "RingBuffer_read should read 4 bytes");
    mu_assert(strcmp(output, "test") == 0, "RingBuffer_read did not read the correct data");

    return NULL;
}

char *test_puts_get_all()
{
    bstring data = bfromcstr("test");
    RingBuffer_puts(rb, data);
    bstring result = RingBuffer_get_all(rb);
    mu_assert(biseq(data, result), "RingBuffer_get_all did not return the correct data");
    bdestroy(data);
    bdestroy(result);

    return NULL;
}

char *test_puts_gets()
{
    bstring data = bfromcstr("test");
    RingBuffer_puts(rb, data);
    bstring result = RingBuffer_gets(rb, 4);
    mu_assert(biseq(data, result), "RingBuffer_gets did not return the correct data");
    bdestroy(data);
    bdestroy(result);

    return NULL;
}

char *test_destroy()
{
    mu_assert(rb != NULL, "Failed to create RingBuffer#2");
    RingBuffer_destroy(rb);

    return NULL;
}

static char *all_tests()
{
    mu_suite_start(); // 初始化测试套件
    mu_run_test(test_create);
    mu_run_test(test_write_read);
    mu_run_test(test_puts_get_all);
    mu_run_test(test_puts_gets);
    mu_run_test(test_destroy);
    return NULL;
}

// 使用RUN_TESTS宏运行所有测试
RUN_TESTS(all_tests);
