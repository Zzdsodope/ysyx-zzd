#ifndef QUEUE_H
#define QUEUE_H
#include "list.h"

typedef List Queue;

#define Queue_create() List_create()
#define Queue_destroy(A) List_destroy(A)
#define Queue_send(A, B) List_push(A, B)
#define Queue_peek(A) A->first->value
#define Queue_count(A) List_count(A)
#define QUEUE_FOREACH(S, V) LIST_FOREACH(S, first, next, V)
#define Queue_recv(A) List_remove(A, A->first)

#endif
