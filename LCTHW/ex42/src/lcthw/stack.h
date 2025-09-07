#ifndef STACK_H
#define STACK_H
#include "list.h"

typedef List Stack;

#define Stack_create() List_create()
#define Stack_destroy(A) List_destroy(A)
#define Stack_push(A, B) List_push(A, B)
#define Stack_peek(A) A->last->value
#define Stack_count(A) List_count(A)
#define STACK_FOREACH(S, V) LIST_FOREACH(S, last, prev, V)
#define Stack_pop(A) List_remove(A, A->last)

#endif
