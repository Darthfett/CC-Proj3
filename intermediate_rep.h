#ifndef _INTERMEDIATE_REP_H_
#define _INTERMEDIATE_REP_H_

extern const char * const STACK_PTR;
extern const char * const FRAME_PTR;
extern const char * const REGISTER_PREFIX;
extern const char * const REGISTER_FORMAT;

struct function_declaration_t *current_function;
struct class_list_t *current_class;

/* Structure definitions */

struct block_t;

struct code_t {
    int type;

    const char *lhs;
    int op;
    const char *op1;
    const char *op2;

    struct code_t *next;
    struct block_t *next_b1;
    struct block_t *next_b2;
};

struct block_t {
    struct code_t *first;
    struct code_t *last;
    int has_parent;
    const char *label;
};

struct cfg_t {
    struct block_t *first;
    struct block_t *last;
};

/* End structure definitions */

/* Function definitions */

struct class_list_t* get_current_class(void);
struct function_declaration_t* get_current_function(void);

const char * const get_top_of_stack(void);

const char * const label(struct block_t *block);

void print_cfg(struct cfg_t *cfg);
void print_block(struct block_t *block);
void print_code(struct code_t *code);

struct block_t* new_dummy_block(void);
struct code_t* new_code(void);
struct block_t* new_block(void);
struct cfg_t* new_cfg(void);

struct block_t* perform_branch(struct block_t *b1, struct block_t *b2);
struct block_t* perform_assign_stmnt(void);
struct block_t* perform_stack_op1(int op);
struct block_t* perform_stack_op2(int op);

struct block_t* merge_blocks(struct block_t *b1, struct block_t *b2);
struct block_t* chain_blocks(struct block_t *b1, struct block_t *b2);
int can_merge_blocks(struct block_t *b1, struct block_t *b2);

char* mem_at(const char * const location);

struct code_t* increment_stack(void);
struct code_t* decrement_stack(void);

char *get_temporary(void);
void release_temporary(char *temporary);

struct block_t* pop_from_stack(const char * const out);
struct block_t* push_to_stack(const char * const source);

struct code_t* perform_op(const char * const lhs, int op, const char * const op1, const char * const op2);

void init_intermediate_rep(void);

/* End function definitions */


#endif /* _INTERMEDIATE_REP_H_ */
