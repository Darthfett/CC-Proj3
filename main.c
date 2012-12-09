/*
 * main.c
 *
 * Implements an object oriented pascal compiler
 */

#include "shared.h"
#include "symtab.h"
#include "intermediate_rep.h"

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

/*
    -- Casey commenting this out, as it does not compile.

	VARIABLE ACCESS CODE (I don't know where to put this, so I'll put it here.)
*/
/*
struct class_list_t* find_class(char* c_id)
{
	struct class_list_t *cl = NULL;
	for (cl = CLASS_LIST; cl; cl = cl->next)
	{
		if (strcmp(cl->ci->id, c_id) == 0)
			return cl;
	}
	
	return NULL;
}
*/
// Make sure this isn't called in cases where an int or a bool could be the case

/*
    -- Casey commenting this out, as it does not compile.

struct type_denoter_t* create_temp_class_type_denoter(char* id)
{
	struct type_denoter_t* td = (struct type_denoter_t*)malloc(sizeof(struct type_denoter_t));
	
	td->type = TYPE_DENOTER_CLASS_TYPE;
	td->name = id;
	return td;
}
*/

/*
    -- Casey commenting this out, as it does not compile.

void find_cfv(
	char* c_id,
	char* f_id,
	char* v_id,
	struct type_denoter_t** type,
	int* offset,
	int* loc)	// loc == TRUE when it's a class variable, else when it's a function variable
{
	struct class_list_t *cl = find_class(c_id);
	*type = NULL;
	*offset = 0;
	*loc = TRUE;

	if (!cl)
		return;
		
	if (!cl->cb)
		return;
		
	if (!cl->cb->vdl)
		return;
		
	struct variable_declaration_list_t *vdl = NULL;
	struct identifier_list_t *il = NULL;
	
	for (vdl = cl->cb->vdl; vdl; vdl = vdl->next)
	{
		for (il = vdl->vd->il; il; il = il->next)
		{
			if (strcmp(il->id, v_id) == 0)
			{
				*type = vdl->vd->tden;
				*offset = il->offset;
				*loc = TRUE;
				return;
			}
		}
	}
	
	struct func_declaration_list_t *fdl = NULL;
	struct formal_parameter_section_list_t *fpsl = NULL;
	
	fdl = cl->cb->fdl;
	fdl = fdl->next;

	// search through functions if f_id is given
	if (f_id)
	{
		// search through functions
		for (fdl = cl->cb->fdl; fdl; fdl = fdl->next)
		{
			if (strcmp(fdl->fd->fh->id, f_id) == 0)
			{
				// search through function parameters
				for (fpsl = fdl->fd->fh->fpsl; fpsl; fpsl = fpsl->next)
				{
					for (il = fpsl->fps->il; il; il = il->next)
					{
						if (strcmp(il->id, v_id) == 0)
						{
							*type = create_temp_class_type_denoter(fpsl->fps->id);
							*offset = il->offset;
							*loc = FALSE;
							return;
						}
					}
				}
				
				// search through function variables
				for (vdl = fdl->fd->fb->vdl; vdl; vdl = vdl->next)
				{
					for (il = vdl->vd->il; il; il = il->next)
					{
						if (strcmp(il->id, v_id) == 0)
						{
							*type = vdl->vd->tden;
							*offset = il->offset;
							*loc = TRUE;
							return;
						}
					}
				}
			}
		}
	}
	
	// search through base classes
	while (cl->ci->extend)
	{
		cl = find_class(cl->ci->extend);
		
		vdl = NULL;
		il = NULL;
		
		if (!cl)
			return;
			
		if (!cl->cb)
			return;
			
		if (!cl->cb->vdl)
			return;
		
		for (vdl = cl->cb->vdl; vdl; vdl = vdl->next)
		{
			for (il = vdl->vd->il; il; il = il->next)
			{
				if (strcmp(il->id, v_id) == 0)
				{
					*type = vdl->vd->tden;
					*offset = il->offset;
					*loc = TRUE;
					return;
				}
			}
		}
		
		// search through the functions of the base classes
		if (f_id)
		{
			// search through functions
			for (fdl = cl->cb->fdl; fdl; fdl = fdl->next)
			{
				if (strcmp(fdl->fd->fh->id, f_id) == 0)
				{
					// search through function parameters
					for (fpsl = fdl->fd->fh->fpsl; fpsl; fpsl = fpsl->next)
					{
						for (il = fpsl->fps->il; il; il = il->next)
						{
							if (strcmp(il->id, v_id) == 0)
							{
								*type = create_temp_class_type_denoter(fpsl->fps->id);
								*offset = il->offset;
								*loc = FALSE;
								return;
							}
						}
					}
					
					// search through function variables
					for (vdl = fdl->fd->fb->vdl; vdl; vdl = vdl->next)
					{
						for (il = vdl->vd->il; il; il = il->next)
						{
							if (strcmp(il->id, v_id) == 0)
							{
								*type = vdl->vd->tden;
								*offset = il->offset;
								*loc = TRUE;
								return;
							}
						}
					}
				}
			}
		}
	}
}
*/

/*
    -- Casey commenting this out, as it does not compile.

struct function_declaration_t* find_function(struct class_list_t *cl, char* f_id)
{
	struct func_declaration_list_t *fdl = NULL;
	struct formal_parameter_section_list_t *fpsl = NULL;
	
	// search through functions
	for (fdl = cl->cb->fdl; fdl; fdl = fdl->next)
	{
		if (strcmp(fdl->fd->fh->id, f_id) == 0)
		{
			return fdl->fd;
		}
	}
}
*/

/*
    -- Casey commenting this out, as it does not compile.

void create_function_use_code(char* c_id, char* f_id, struct function_designator_t* fdes, struct type_denoter_t** type)
{
	struct function_declaration_t* fdef = find_function(find_class(c_id), f_id);
	struct actual_parameter_list_t* apl = NULL;
	
	// TODO: find out how a procedure (aka function with no return type) can be caled in this language
	if (!fdef->fh->res)
		return;
		
	// TODO: load return address
	create_push_code();				// create spot for return value, Note: the name of the function is the return value. TODO(SP): Make a special case to check if the v_id == f_id
	create_push_address_code(FP);	// 
	create_load_code(FP, SP);	// m[FP] = m[SP]
	create_push_code(THIS);	// is located before the return address
	for (apl = fdes->apl; apl; apl = apl->next)
	{
		create_expr_code(apl->ap->e1);
	}
}
*/

// HOW TO CALL create_variable_access_code:
// node = first variable access
// c_id = name of current class
// f_id = name of current function
// type = NULL
// offset = 0
/*
    -- Casey commenting this out, as it does not compile.

void create_variable_access_code(
	struct variable_access_t* node,
	char* c_id,
	char* f_id,
	struct type_denoter_t** type,
	int* offset)
{
	struct index_expression_list_t *iel = NULL;
	
	int loc = FALSE;
	
	if (node == NULL)
		return;

	if (node->type == VARIABLE_ACCESS_T_IDENTIFIER)	// identifier
	{
		// base case of this recursive function
		// implicit "this."
		find_cfv(c_id, f_id, node->data.id, type, offset, &loc);
		if (loc)	// class variable
		{
			create_push_address_code(FP);
			create_push_code(*offset);
			create_add_code();
		}
		else
		{
			create_push_address_code(THIS);
			create_push_code(*offset);
			create_add_code();
		}
	}
	else if (node->type == VARIABLE_ACCESS_T_ATTRIBUTE_DESIGNATOR)		// attribute denoter
	{
		create_variable_access_code(node->data.ad->va, c_id, f_id, type, offset);
		find_cfv((*type)->name, NULL, node->data.ad->id, type, offset, NULL);
	}
	else if (node->type == VARIABLE_ACCESS_T_METHOD_DESIGNATOR)	// method designator
	{
		create_variable_access_code(node->data.md->va, c_id, f_id, type, offset);
		create_function_use_code((*type)->name, node->data.md->fd->id, node->data.md->fd, type);
		
		// generate code to add the offset if it's useful
		if (offset != 0)
		{
			create_push_code(*offset);
			create_add_code();
			*offset = 0;
		}
	}
	else if (node->type == VARIABLE_ACCESS_T_INDEXED_VARIABLE)			// indexed variable
	{
		create_variable_access_code(node->data.md->va, c_id, f_id, type, offset);
		
		// add the offset if it's useful
		if (offset != 0)
		{
			create_push_code(*offset);
			create_add_code();
			*offset = 0;
		}
		
		// create code to compute the offset for the multidimensional array
		for (iel = node->data.iv->iel; iel; iel = iel->next)
		{
			create_expr_code(iel->expr);		// TODO: implement these kinds of functions
			create_push_code((*type)->data.at->mult_factor);
			create_multiply_code();
			create_add_code();
			*type = (*type)->data.at->td;
		}
	}
}
*/

/* This is the data structure we are left with (the parse tree) after
   yyparse() is done . */
extern struct program_t *program;

extern void yyparse();

int main() {
    symtab_init();
    init_intermediate_rep();

    /* begin parsing */
    yyparse();

    /* If there were parsing errors, exit. */
    exit_on_errors();

    return 0;
}
