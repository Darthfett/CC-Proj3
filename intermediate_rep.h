#ifndef _INTERMEDIATE_REP_H_
#define _INTERMEDIATE_REP_H_

extern const char * const TOP_OF_TACK;
extern const char * const STACK_PTR;
extern const char * const FRAME_PTR;

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
};

struct cfg_t {
    struct block_t *first;
    struct block_t *last;
};

/* End structure definitions */

/* Function definitions */

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
