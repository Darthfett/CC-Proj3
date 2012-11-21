/*
 * main.c
 *
 * Implements an object oriented pascal compiler
 */

#include "shared.h"
#include "symtab.h"

int error_flag = 0;

/* -----------------------------------------------------------------------
 * Printout on error message and exit
 * ----------------------------------------------------------------------- 
 */
void exit_on_errors()
{
  if (error_flag == 1) {
    printf("Errors detected. Exiting.\n");
    exit(-1);
  }
}

/* This is the data structure we are left with (the parse tree) after
   yyparse() is done . */
extern struct program_t *program;

extern void yyparse();

int main() {
    symtab_init();

    /* begin parsing */
    yyparse();

    /* If there were parsing errors, exit. */
    exit_on_errors();

    return 0;
}
