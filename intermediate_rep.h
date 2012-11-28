
#ifndef _INTERMEDIATE_REP_H_
#define _INTERMEDIATE_REP_H_

/* Structure definitions */

struct code_t {
    int type;

    int lhs;
    int op;
    int op1;
    int op2;

    struct code_t *next;
};

struct block_t {
    struct code_t *first;
    struct code_t *last;
};

/* End structure definitions */

/* Function definitions */

int make_const_id(int const_val);

struct code_t* increment_stack(void);
struct code_t* decrement_stack(void);

int get_temporary(void);
void release_temporary(int temporary);

struct block_t* pop_from_stack(int out);
struct block_t* push_to_stack(int source);

struct code_t* perform_op(int lhs, int op, int op1, int op2);

void init_intermediate_rep(void);

/* End function definitions */


#endif /* _INTERMEDIATE_REP_H_ */
