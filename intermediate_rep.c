#include "intermediate_rep.h"
#include "shared.h"

const int TEMPORARY_COUNT = 3;
const int TEMPORARY_START = 10;

int avail_temporaries_count;
int *avail_temporaries;

struct code_t* increment_stack(void)
{
    return perform_op(STACK_PTR, OP_PLUS, STACK_PTR, "1");
}

struct code_t* decrement_stack(void)
{
    return perform_op(STACK_PTR, OP_MINUS, STACK_PTR, "1");
}

char* get_temporary(void)
{
    if (avail_temporaries_count <= 0) {
        error_flag = 1;
        printf("ERROR: We have run out temporary variables.");
        return NULL;
    }
    avail_temporaries_count--;
    char *buffer = (char*) malloc(sizeof(char) * 20);
    snprintf(buffer, 20, "__RESERVED_TEMP_%d", avail_temporaries[avail_temporaries_count]);

    return buffer;
}

void release_temporary(char *temporary)
{
    if (avail_temporaries_count == TEMPORARY_COUNT) {
        error_flag = 1;
        printf("ERROR: A temporary variable %s has been released twice.", temporary);
        return;
    }

    char *temp_num = temporary;
    temp_num += strlen("__RESERVED_TEMP_");
    int temp = atoi(temp_num);

    avail_temporaries[avail_temporaries_count] = temp;
    avail_temporaries_count++;
}



struct block_t* pop_from_stack(const char * const out)
{
    struct block_t *block = (struct block_t*) malloc(sizeof(struct block_t));

    struct code_t *decrement = decrement_stack();

    struct code_t *pop = perform_op(out, OP_ASSIGNMENT, TOP_OF_STACK, NULL);

    decrement->next = pop;

    block->first = decrement;
    block->last = pop;

    return block;
}

struct block_t* push_to_stack(const char * const source)
{
    struct block_t *block = (struct block_t*) malloc(sizeof(struct block_t));

    struct code_t *push = perform_op(TOP_OF_STACK, OP_ASSIGNMENT, source, NULL);

    struct code_t *increment = increment_stack();

    push->next = increment;

    block->first = push;
    block->last = increment;

    return block;
}



struct code_t* perform_op(const char * const lhs, int op, const char * const op1, const char * const op2)
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
