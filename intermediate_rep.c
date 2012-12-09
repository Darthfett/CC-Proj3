#include "intermediate_rep.h"
#include "shared.h"

const char * const TOP_OF_STACK = "__RESERVED_TOP_OF_STACK";
const char * const STACK_PTR = "__RESERVED_STACK_PTR";
const char * const FRAME_PTR = "__RESERVED_FRAME_PTR";

const int TEMPORARY_COUNT = 3;
const int TEMPORARY_START = 10;

int avail_temporaries_count;
int *avail_temporaries;

struct block_t **seen_blocks;
int seen_blocks_count = 0;
int seen_blocks_size = 20;

int seen_block(struct block_t *block)
{
    int i;
    for (i = 0; i < seen_blocks_count; i++) {
        if (seen_blocks[i] == block) {
            return 1;
        }
    }
    return 0;
}

void mark_block_seen(struct block_t *block)
{
    /* Check if there is room for the block */
    if (seen_blocks_size == seen_blocks_count) {
        /* Not enough room to add block -- double the size */
        struct block_t **new_seen_blocks = (struct block_t**) malloc(sizeof(struct block_t*) * seen_blocks_size * 2);
        memcpy(new_seen_blocks, seen_blocks, sizeof(struct block_t*) *seen_blocks_size);
        free(seen_blocks);
        seen_blocks = new_seen_blocks;
        seen_blocks_size *= 2;
    }

    /* Add block to seen blocks */
    seen_blocks[seen_blocks_count] = block;
    seen_blocks_count++;
}

void clear_blocks_seen(void)
{
    free(seen_blocks);
    seen_blocks_count = 0;
    seen_blocks = (struct block_t**) malloc(sizeof(struct block_t*) * seen_blocks_size);
}


void print_code(struct code_t *code)
{
    switch(code->type) {
    case CODE_ASSIGNMENT:
        switch(code->op) {
            case OP_ASSIGNMENT:
                printf("%s = %s;\n", code->lhs, code->op1);
                break;
            case OP_DEREFERENCE:
                printf("%s = *%s;\n", code->lhs, code->op1);
                break;
            case OP_NEGATE:
                printf("%s = -%s;\n", code->lhs, code->op1);
                break;
            case OP_NOT:
                printf("%s = !%s;\n", code->lhs, code->op1);
                break;
            case OP_OR:
                printf("%s = %s || %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_AND:
                printf("%s = %s && %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_PLUS:
                printf("%s = %s + %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_MINUS:
                printf("%s = %s - %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_STAR:
                printf("%s = %s * %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_SLASH:
                printf("%s = %s / %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_MOD:
                printf("%s = %s %% %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_EQUAL:
                printf("%s = %s == %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_NOTEQUAL:
                printf("%s = %s != %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_LT:
                printf("%s = %s < %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_GT:
                printf("%s = %s > %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_LE:
                printf("%s = %s <= %s;\n", code->lhs, code->op1, code->op2);
                break;
            case OP_GE:
                printf("%s = %s >= %s;\n", code->lhs, code->op1, code->op2);
                break;
            default:
                printf("ERROR: Invalid op %d for code.\n", code->op);
                error_flag = 1;
                break;
        }
        break;
    case CODE_BRANCH:
        printf("branch %s, %p, %p;\n", code->op1, code->next_b1, code->next_b2);
        break;
    case CODE_JUMP:
        printf("jump %s, %p;\n", code->op1, code->next_b1);
        break;
    case CODE_DUMMY:
        printf(";\n");
        break;
    }
}

void print_block(struct block_t *block)
{
    if (block == NULL) {
        printf("ERROR: print NULL block\n");
        error_flag = 1;
        return;
    }

    if (seen_block(block)) {
        return;
    }

    mark_block_seen(block);

    printf("BLOCK BEGIN %p\n", block);

    struct code_t *next = block->first;

    while(next != NULL) {
        print_code(next);
        if (next->next == NULL) {
            printf("BLOCK END\n");
            if (next->type == CODE_BRANCH) {
                print_block(next->next_b1);
                print_block(next->next_b2);
            } else if (next->next_b1 != NULL) {
                printf("jump %p;\n", next->next_b1);
                print_block(next->next_b1);
            } else {
                printf("jump exit;\n");
            }
            break;
        }
        next = next->next;
    }
}

void print_cfg(struct cfg_t *cfg)
{
    print_block(cfg->first);
}

struct block_t* new_dummy_block(void)
{
    struct block_t *dummy = new_block();
    struct code_t *noop = new_code();
    noop->type = CODE_DUMMY;
    dummy->first = dummy->last = noop;

    return dummy;
}

struct code_t* new_code(void)
{
    struct code_t *new = (struct code_t*) malloc(sizeof(struct code_t));
    new->lhs = NULL;
    new->op = 0;
    new->op1 = NULL;
    new->op2 = NULL;
    new->next = NULL;
    new->next_b1 = NULL;
    new->next_b2 = NULL;

    return new;
}

struct block_t* new_block(void)
{
    struct block_t *new = (struct block_t*) malloc(sizeof(struct block_t));
    new->first = new->last = NULL;
    new->has_parent = 0;

    return new;
}
struct cfg_t* new_cfg(void)
{
    struct cfg_t *new = (struct cfg_t*) malloc(sizeof(struct cfg_t));
    new->first = new->last = NULL;

    return new;
}

struct block_t* perform_branch(struct block_t *b1, struct block_t *b2)
{
    struct block_t *block = new_block();

    // Make the branching code
    char *r1 = get_temporary();

    struct code_t *dec = decrement_stack();
    struct code_t *pop = perform_op(r1, OP_ASSIGNMENT, mem_at(STACK_PTR), NULL);
    struct code_t *branch = new_code();
    branch->type = CODE_BRANCH;
    branch->op1 = mem_at(r1);
    branch->next_b1 = b1;
    branch->next_b2 = b2;

    release_temporary(r1);

    dec->next = pop;
    pop->next = branch;

    block->first = dec;
    block->last = branch;

    return block;
}

struct block_t* perform_assign_stmnt(void)
{
    struct block_t *block = new_block();

    // Get temp registers
    char *r1 = get_temporary();
    char *r2 = get_temporary();

    // Generate assignment code
    struct code_t *dec = decrement_stack();
    struct code_t *get_rhs = perform_op(r2, OP_ASSIGNMENT, mem_at(STACK_PTR), NULL);
    struct code_t *dec2 = decrement_stack();
    struct code_t *get_lhs = perform_op(r1, OP_ASSIGNMENT, mem_at(STACK_PTR), NULL);
    struct code_t *assign = perform_op(r1, OP_ASSIGNMENT, mem_at(r2), NULL);

    // Release temp registers
    release_temporary(r1);
    release_temporary(r2);

    // Chain together block and statements
    block->first = dec;
    block->last = assign;

    dec->next = get_rhs;
    get_rhs->next = dec2;
    dec2->next = get_lhs;
    get_lhs->next = assign;

    return block;
}

struct block_t* perform_stack_op1(int op)
{
    struct block_t *block = new_block();

    // Generate code
    struct code_t *dec = decrement_stack();
    struct code_t *do_op = perform_op(STACK_PTR, op, mem_at(STACK_PTR), NULL);
    struct code_t *inc = increment_stack();

    // Link block and code
    block->first = dec;
    block->last = inc;

    dec->next = do_op;
    do_op->next = inc;

    return block;
}

struct block_t* perform_stack_op2(int op)
{
    struct block_t *block = new_block();

    // Get temp registers
    char *r1 = get_temporary();
    char *r2 = get_temporary();

    // Create code
    struct code_t *dec1 = decrement_stack();
    struct code_t *get_op1 = perform_op(r2, OP_ASSIGNMENT, mem_at(STACK_PTR), NULL);
    struct code_t *dec2 = decrement_stack();
    struct code_t *get_op2 = perform_op(r1, OP_ASSIGNMENT, mem_at(STACK_PTR), NULL);
    struct code_t *do_op = perform_op(r1, op, mem_at(r1), mem_at(r2));
    struct code_t *push = perform_op(STACK_PTR, OP_ASSIGNMENT, mem_at(r1), NULL);
    struct code_t *inc = increment_stack();

    // Release temp registers
    release_temporary(r1);
    release_temporary(r2);

    // link code together into block
    block->first = dec1;
    block->last = inc;

    dec1->next = get_op1;
    get_op1->next = dec2;
    dec2->next = get_op2;
    get_op2->next = do_op;
    do_op->next = push;
    push->next = inc;

    return block;
}

struct block_t* merge_blocks(struct block_t *b1, struct block_t *b2)
{
    int err = 0;
    if (b1 == b2) {
        printf("WARNING: merge_blocks called with identical blocks\n");
        err = 1;
    }
    if (b1 == NULL || b2 == NULL) {
        printf("ERROR: merge_blocks called with NULL block\n");
        error_flag = 1;
        err = 1;
    }
    if (b2->has_parent) {
        printf("ERROR: Cannot merge two blocks where the second has a parent\n");
        error_flag = 1;
        err = 1;
    }
    if (err) {
        return b2;
    }

    b1->last->next = b2->first;
    b1->last = b2->last;

    return b1;
}

struct block_t* chain_blocks(struct block_t *b1, struct block_t *b2)
{
    // Attempt to chain two blocks together, returning the last block
    if (b1 == NULL || b2 == NULL) {
        printf("ERROR: chain_blocks called with NULL block\n");
        error_flag = 1;
        return b2;
    }
    
    b1->last->next_b1 = b2;
    return b2;
}

int can_merge_blocks(struct block_t *b1, struct block_t *b2)
{
    if (b1 == NULL || b2 == NULL) {
        return 0;
    }

    if (b2->has_parent) {
        return 0;
    }

    return 1;
}

char* mem_at(const char * const location)
{
    int size = strlen("*") + strlen(location) + 1;
    char *buffer = (char*) malloc(sizeof(char) * size);
    snprintf(buffer, size, "*%s", location);
    return buffer;
}

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
    struct block_t *block = new_block();

    struct code_t *decrement = decrement_stack();

    struct code_t *pop = perform_op(out, OP_ASSIGNMENT, TOP_OF_STACK, NULL);

    decrement->next = pop;

    block->first = decrement;
    block->last = pop;

    return block;
}

struct block_t* push_to_stack(const char * const source)
{
    struct block_t *block = new_block();

    struct code_t *push = perform_op(TOP_OF_STACK, OP_ASSIGNMENT, source, NULL);

    struct code_t *increment = increment_stack();

    push->next = increment;

    block->first = push;
    block->last = increment;

    return block;
}



struct code_t* perform_op(const char * const lhs, int op, const char * const op1, const char * const op2)
{
    struct code_t *code = new_code();
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
    seen_blocks = (struct block_t**) malloc(sizeof(struct block_t*) * seen_blocks_size);

    avail_temporaries_count = TEMPORARY_COUNT;
    avail_temporaries = (int*) malloc(sizeof(int) * TEMPORARY_COUNT);

    for (i = 0; i < TEMPORARY_COUNT; i++) {
        avail_temporaries[i] = i + TEMPORARY_START;
    }
}
