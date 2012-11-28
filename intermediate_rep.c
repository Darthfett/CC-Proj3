#include "intermediate_rep.h"
#include "shared.h"

const int TOP_OF_STACK = 1;
const int STACK_PTR = 2;
const int FRAME_PTR = 3;

const int TEMPORARY_COUNT = 3;
const int TEMPORARY_START = 10;

int avail_temporaries_count;
int *avail_temporaries;

int make_const_id(int const_val)
{
    // TODO: Somehow turn const_val into a unique value
    return -1;
}

struct code_t* increment_stack(void)
{
    return perform_op(STACK_PTR, OP_PLUS, STACK_PTR, make_const_id(1));
}

struct code_t* decrement_stack(void)
{
    return perform_op(STACK_PTR, OP_MINUS, STACK_PTR, make_const_id(1));
}

int get_temporary(void)
{
    if (avail_temporaries_count <= 0) {
        error_flag = 1;
        printf("ERROR: We have run out temporary variables.");
        return -1;
    }
    avail_temporaries_count--;
    return avail_temporaries[avail_temporaries_count];
}

void release_temporary(int temporary)
{
    if (avail_temporaries_count == TEMPORARY_COUNT) {
        error_flag = 1;
        printf("ERROR: A temporary variable %d has been released twice.", temporary);
        return;
    }
    avail_temporaries[avail_temporaries_count] = temporary;
    avail_temporaries_count++;
}



struct block_t* pop_from_stack(int out)
{
    struct block_t *block = (struct block_t*) malloc(sizeof(struct block_t));

    struct code_t *decrement = decrement_stack();

    struct code_t *pop = perform_op(out, OP_ASSIGNMENT, TOP_OF_STACK, 0);

    decrement->next = pop;

    block->first = decrement;
    block->last = pop;

    return block;
}

struct block_t* push_to_stack(int source)
{
    struct block_t *block = (struct block_t*) malloc(sizeof(struct block_t));

    struct code_t *push = perform_op(TOP_OF_STACK, OP_ASSIGNMENT, source, 0);

    struct code_t *increment = increment_stack();

    push->next = increment;

    block->first = push;
    block->last = increment;

    return block;
}



struct code_t* perform_op(int lhs, int op, int op1, int op2)
{
    struct code_t *code = (struct code_t*) malloc(sizeof(struct code_t));
    code->type = CODE_ASSIGNMENT;
    code->lhs = lhs;
    code->op = op;
    code->op1 = op1;
    code->op2 = op2;

    return code;
}

void init_intermediate_rep(void)
{
    int i;

    avail_temporaries_count = TEMPORARY_COUNT;
    avail_temporaries = (int*) malloc(sizeof(int) * TEMPORARY_COUNT);

    for (i = 0; i < TEMPORARY_COUNT; i++) {
        avail_temporaries[i] = i + TEMPORARY_START;
    }
}
