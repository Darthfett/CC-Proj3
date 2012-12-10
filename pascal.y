%{
/*
 * grammar.y
 *
 * Pascal grammar in Yacc format, based originally on BNF given
 * in "Standard Pascal -- User Reference Manual", by Doug Cooper.
 * This in turn is the BNF given by the ANSI and ISO Pascal standards,
 * and so, is PUBLIC DOMAIN. The grammar is for ISO Level 0 Pascal.
 * The grammar has been massaged somewhat to make it LALR.
 */

#include "shared.h"
#include "intermediate_rep.h"
#include "symtab.h"
#include <assert.h>

  int yylex(void);
  void yyerror(const char *error);

  extern char *yytext;          /* yacc text variable */
  extern int line_number;       /* Holds the current line number; specified
				   in the lexer */
  struct program_t *program;    /* points to our program */
%}

%token AND ARRAY ASSIGNMENT CLASS COLON COMMA DIGSEQ
%token DO DOT DOTDOT ELSE END EQUAL EXTENDS FUNCTION
%token GE GT IDENTIFIER IF LBRAC LE LPAREN LT MINUS MOD NEW NOT
%token NOTEQUAL OF OR PBEGIN PLUS PRINT PROGRAM RBRAC
%token RPAREN SEMICOLON SLASH STAR THEN
%token VAR WHILE

%type <tden> type_denoter
%type <id> result_type
%type <id> identifier
%type <idl> identifier_list
%type <fdes> function_designator
%type <apl> actual_parameter_list
%type <apl> params
%type <ap> actual_parameter
%type <vd> variable_declaration
%type <vdl> variable_declaration_list
%type <r> range
%type <un> unsigned_integer
%type <fpsl> formal_parameter_section_list
%type <fps> formal_parameter_section
%type <fps> value_parameter_specification
%type <fps> variable_parameter_specification
%type <va> variable_access
%type <as> assignment_statement
%type <os> object_instantiation
%type <ps> print_statement
%type <e> expression
%type <s> statement
%type <ss> compound_statement
%type <ss> statement_sequence
%type <ss> statement_part
%type <is> if_statement
%type <ws> while_statement
%type <e> boolean_expression
%type <iv> indexed_variable
%type <ad> attribute_designator
%type <md> method_designator
%type <iel> index_expression_list
%type <e> index_expression
%type <se> simple_expression
%type <t> term
%type <f> factor
%type <i> sign
%type <p> primary
%type <un> unsigned_constant
%type <un> unsigned_number
%type <at> array_type
%type <cb> class_block
%type <vdl> variable_declaration_part
%type <fdl> func_declaration_list
%type <funcd> function_declaration
%type <fb> function_block
%type <fh> function_heading
%type <id> function_identification
%type <fpsl> formal_parameter_list
%type <cl> class_list
%type <ci> class_identification
%type <program> program
%type <ph> program_heading
%type <op> relop
%type <op> addop
%type <op> mulop

%union {
  struct type_denoter_t *tden;
  char *id;
  struct identifier_list_t *idl;
  struct function_designator_t *fdes;
  struct actual_parameter_list_t *apl;
  struct actual_parameter_t *ap;
  struct variable_declaration_list_t *vdl;
  struct variable_declaration_t *vd;
  struct range_t *r;
  struct unsigned_number_t *un;
  struct formal_parameter_section_list_t *fpsl;
  struct formal_parameter_section_t *fps;
  struct variable_access_t *va;
  struct assignment_statement_t *as;
  struct object_instantiation_t *os;
  struct print_statement_t *ps;
  struct expression_t *e;
  struct statement_t *s;
  struct statement_sequence_t *ss;
  struct if_statement_t *is;
  struct while_statement_t *ws;
  struct indexed_variable_t *iv;
  struct attribute_designator_t *ad;
  struct method_designator_t *md;
  struct index_expression_list_t *iel;
  struct simple_expression_t *se;
  struct term_t *t;
  struct factor_t *f;
  int *i;
  struct primary_t *p;
  struct array_type_t *at;
  struct class_block_t *cb;
  struct func_declaration_list_t *fdl;
  struct function_declaration_t *funcd;
  struct function_block_t *fb;
  struct function_heading_t *fh;
  struct class_identification_t *ci;
  struct class_list_t *cl;
  struct program_t *program;
  struct program_heading_t *ph;
  int op;
}



%%

program : program_heading semicolon class_list DOT
	{
	
	// printf("program : program_heading semicolon class_list DOT \n");
	$$ = (struct program_t*) malloc(sizeof(struct program_t));

	program = $$;
	$$->ph = $1;
	$$->cl = $3;
	}
 ;

program_heading : PROGRAM identifier
	{
	// printf("program_heading : PROGRAM identifier \n");
	$$ = (struct program_heading_t *) malloc(sizeof(struct program_heading_t));
	$$->id = $2;
	}
 | PROGRAM identifier LPAREN identifier_list RPAREN
	{
	// printf("PROGRAM identifier LPAREN identifier_list RPAREN \n");

	$$ = (struct program_heading_t *) malloc(sizeof(struct program_heading_t));
	$$->id = $2;
	$$->il = $4;
	}
 ;

identifier_list : identifier_list comma identifier
        {
        // printf("identifier_list : identifier_list comma identifier \n%s",yytext);
        $$ = (struct identifier_list_t*) malloc(sizeof(struct identifier_list_t));
        $$->next = $1;
        $$->id = $3;
	$$->offset = $1->offset + 1;
        }
 | identifier
        {
        // printf("identifier_list : identifier \n");
        $$ = (struct identifier_list_t*) malloc(sizeof(struct identifier_list_t));
        $$->next = NULL;
        $$->id = $1;
        $$->offset = 0;
	}
 ;

class_list : class_list class_identification PBEGIN class_block END
	{
	// printf("class_list : class_list class_identification PBEGIN class_block END \n");
	$$ = current_class;

	$$->next = $1;
	$$->ci = $2;
	$$->cb = $4;

        struct hash_table_t *class_table = get_class_table();
        struct ht_item_t *class_item = (struct ht_item_t*) malloc(sizeof(struct ht_item_t));
        class_item->value = (void*) $$;
        insert_item(class_table, $2->id, class_item);
	}
 | class_identification PBEGIN class_block END
	{
	// printf("class_list : class_identification PBEGIN class_block END \n");
	$$ = current_class;

	$$->next = NULL;
	$$->ci = $1;
	$$->cb = $3;

        struct hash_table_t *class_table = get_class_table();
        struct ht_item_t *class_item = (struct ht_item_t*) malloc(sizeof(struct ht_item_t));
        class_item->value = (void*) $$;
        insert_item(class_table, $1->id, class_item);
	}
 ;

class_identification : CLASS identifier
	{
	// printf("class_identification : CLASS identifier \n");

	$$ = (struct class_identification_t*) malloc(sizeof(struct class_identification_t));

	$$->id = $2;
	$$->line_number = line_number;

        current_class = (struct class_list_t*) malloc(sizeof(struct class_list_t));
        current_class->ci = $$;
	}
| CLASS identifier EXTENDS identifier
	{
	// printf("class_identification : CLASS identifier EXTENDS identifier \n");
	$$ = (struct class_identification_t*) malloc(sizeof(struct class_identification_t));

	$$->id = $2;
        $$->extend = $4;
	$$->line_number = line_number;

        current_class = (struct class_list_t*) malloc(sizeof(struct class_list_t));
        current_class->ci = $$;
	}
;

class_block : variable_declaration_part func_declaration_list
	{
	// printf("class_block : variable_declaration_part func_declaration_list \n");
	$$ = (struct class_block_t*) malloc(sizeof(struct class_block_t));

	$$->vdl = $1;
	$$->fdl = $2;
	}
 ;

type_denoter : array_type
	{
	// printf("type_denoter : array_type \n");
        $$ = (struct type_denoter_t*) malloc(sizeof(struct type_denoter_t));

        $$->type = TYPE_DENOTER_T_ARRAY_TYPE; 
        // TODO: $$->name
        $$->data.at = $1;

        $$->size = ($1->r->max->ui - $1->r->min->ui) * $1->td->size;
	}
 | identifier
	{
	// printf("type_denoter : identifier \n");
        $$ = (struct type_denoter_t*) malloc(sizeof(struct type_denoter_t));

        struct hash_table_t *class_table = get_class_table();
        struct ht_item_t *class_item = get_hashtable_item(class_table, $1);

        if (class_item == NULL) {
            // Class is either not parsed yet, or a base type.  Forward references are not supported, so assuming base type.
            $$->type = TYPE_DENOTER_T_IDENTIFIER;
            $$->data.id = $$->name = $1;
        } else {
            $$->type = TYPE_DENOTER_T_CLASS_TYPE;
            $$->data.cl = (struct class_list_t*) class_item->value;
        }
	}
 ;

array_type : ARRAY LBRAC range RBRAC OF type_denoter
	{
	// printf("array_type : ARRAY LBRAC range RBRAC OF type_denoter \n");
        $$ = (struct array_type_t*) malloc(sizeof(struct array_type_t));

        $$->r = $3;
        $$->td = $6;
	}
 ;

range : unsigned_integer DOTDOT unsigned_integer
	{
	// printf("range : unsigned_integer DOTDOT unsigned_integer\nValue1 = %i\nValue2 = %i\n",$1->ui,$3->ui);
        $$ = (struct range_t*) malloc(sizeof(struct range_t));

        $$->min = $1;
        $$->max = $3;
	}
 ;

variable_declaration_part : VAR variable_declaration_list semicolon
	{
	// printf("variable_declaration_part : VAR variable_declaration_list semicolon \n");
        $$ = $2;
        current_variables = $$;
	}
 |
	{
	// printf("variable_declaration_part :  \n");
        $$ = NULL;
        current_variables = $$;
	}
 ;

variable_declaration_list : variable_declaration_list semicolon variable_declaration
	{
	// printf("variable_declaration_list : variable_declaration_list semicolon variable_declaration \n");
        $$ = (struct variable_declaration_list_t*) malloc(sizeof(struct variable_declaration_list_t));

	$$->next = $1;
	$$->vd = $3;
	$$->size = $1->size + $3->size;
	}
 | variable_declaration
	{
	// printf("variable_declaration_list : variable_declaration \n");
        $$ = (struct variable_declaration_list_t*) malloc(sizeof(struct variable_declaration_list_t));

	$$->next = NULL;
	$$->vd = $1;
	$$->size = $1->size;
	}

 ;

variable_declaration : identifier_list COLON type_denoter
	{
	// printf("variable_declaration : identifier_list COLON type_denoter \n");
        $$ = (struct variable_declaration_t*) malloc(sizeof(struct variable_declaration_t));

	$$->il = $1;
	$$->tden = $3;
	$$->size = $1->offset;
	$$->line_number = line_number;
	}
 ;

func_declaration_list : func_declaration_list semicolon function_declaration
	{
	// printf("func_declaration_list : func_declaration_list semicolon function_declaration \n");
        $$ = (struct func_declaration_list_t*) malloc(sizeof(struct func_declaration_list_t));

        $$->fd = $3;
        $$->next = $1;
	}
 | function_declaration
	{
	// printf("func_declaration_list : function_declaration \n");
	$$ = (struct func_declaration_list_t*) malloc(sizeof(struct func_declaration_list_t));

	$$->fd = $1;
	$$->next = NULL;
	}
 |
	{
	// printf("func_declaration_list :  \n");
	$$ = (struct func_declaration_list_t*) malloc(sizeof(struct func_declaration_list_t));

	$$->next = NULL;
	$$->fd = NULL;
	}
 ;

formal_parameter_list : LPAREN formal_parameter_section_list RPAREN 
	{
	// printf("formal_parameter_list : LPAREN formal_parameter_section_list RPAREN  \n");
        $$ = (struct formal_parameter_section_list_t*) malloc(sizeof(struct formal_parameter_section_list_t));

        $$->fps = NULL;
        $$->next = $2;
	}
;
formal_parameter_section_list : formal_parameter_section_list semicolon formal_parameter_section
	{
	// printf("formal_parameter_section_list : formal_parameter_section_list semicolon formal_parameter_section \n");
        $$ = (struct formal_parameter_section_list_t*) malloc(sizeof(struct formal_parameter_section_list_t));

	$$->fps = $3;
	$$->next = $1;
	}
 | formal_parameter_section
	{
	// printf("formal_parameter_section_list : formal_parameter_section \n");
        $$ = (struct formal_parameter_section_list_t*) malloc(sizeof(struct formal_parameter_section_list_t));

	$$->fps = $1;
	$$->next = NULL;
	}
 ;

formal_parameter_section : value_parameter_specification
	{
	// printf("formal_parameter_section : value_parameter_specification \n");
        $$ = $1;
	}
 | variable_parameter_specification
 	{
	// printf("formal_parameter_section : variable_parameter_specification \n");
        $$ = $1;
 	}
 ;

value_parameter_specification : identifier_list COLON identifier
	{
	// printf("value_parameter_specification : identifier_list COLON identifier \n");
        $$ = (struct formal_parameter_section_t*) malloc(sizeof(struct formal_parameter_section_t));

        $$->il = $1;
	$$->id = $3;
        $$->is_var = 0;
	}
 ;

variable_parameter_specification : VAR identifier_list COLON identifier
	{
	// printf("variable_parameter_specification : VAR identifier_list COLON identifier \n");
        $$ = (struct formal_parameter_section_t*) malloc(sizeof(struct formal_parameter_section_t));

        $$->il = $2;
        $$->id = $4;
        $$->is_var = 1;
	}
 ;

function_declaration : function_identification semicolon function_block
	{
	// printf("function_declaration : function_identification semicolon function_block \n");
        $$ = current_function;

        $$->fh = NULL;
        $$->fb = $3;
        $$->line_number = line_number;

		parsing_function_flag = FALSE;	
	}
 | function_heading semicolon function_block
	{
	// printf("function_declaration : function_heading semicolon function_block \n");
        $$ = current_function;

        $$->fh = $1;
        $$->fb = $3;
        $$->line_number = line_number;
    }
 ;

function_heading : FUNCTION identifier COLON result_type
	{
	// printf("function_heading : FUNCTION identifier COLON result_type \n");
        $$ = (struct function_heading_t*) malloc(sizeof(struct function_heading_t));

        $$->id = $2;
        $$->res = $4;
        $$->fpsl = NULL;

        current_function = (struct function_declaration_t*) malloc(sizeof(struct function_declaration_t));
        current_function->fh = $$;
        current_function->size = 0;

		parsing_function_flag = TRUE;
	}
 | FUNCTION identifier formal_parameter_list COLON result_type
	{
	// printf("function_heading : FUNCTION identifier formal_parameter_list COLON result_type \n");
        $$ = (struct function_heading_t*) malloc(sizeof(struct function_heading_t));

        $$->id = $2;
        $$->res = $5;
        $$->fpsl = $3;

        current_function = (struct function_declaration_t*) malloc(sizeof(struct function_declaration_t));
        current_function->fh = $$;
        current_function->size = 0;
	}
 ;

result_type : identifier
	{
	// printf("result_type : identifier \n");
        $$ = $1;
	}
 ;

function_identification : FUNCTION identifier
	{
	// printf("function_identification : FUNCTION identifier \n");
        $$ = $2;

        current_function = (struct function_declaration_t*) malloc(sizeof(struct function_declaration_t));
        current_function->fh = (struct function_heading_t*) malloc(sizeof(struct function_heading_t));
        current_function->fh->id = $2;
        current_function->fh->res = NULL;
        current_function->fh->fpsl = NULL;
        current_function->size = 0;

		parsing_function_flag = TRUE;
	}
;

function_block : variable_declaration_part statement_part
	{
	// printf("function_block : variable_declaration_part statement_part \n");
        $$ = (struct function_block_t*) malloc(sizeof(struct function_block_t));

        $$->vdl = $1;
        $$->ss = $2;
	$$->size = $1->size;
	}
;

statement_part : compound_statement
	{
	// printf("statement_part : compound_statement \n");
        $$ = $1;

        print_cfg($1->cfg);

	}
 ;

compound_statement : PBEGIN statement_sequence END
	{
	// printf("compound_statement : PBEGIN statement_sequence END \n");
        $$ = $2;
	}
 ;

statement_sequence : statement
	{
	// printf("statement_sequence : statement \n");
        $$ = (struct statement_sequence_t*) malloc(sizeof(struct statement_sequence_t));

        $$->s = $1;
        $$->next = NULL;

        $$->cfg = $1->cfg;
	}
 | statement_sequence semicolon statement
	{
	// printf("statement_sequence : statement_sequence semicolon statement \n");
        $$ = (struct statement_sequence_t*) malloc(sizeof(struct statement_sequence_t));

        $$->s = $3;
        $$->next = $1;

        if (can_merge_blocks($1->cfg->last, $3->cfg->first)) {
            merge_blocks($1->cfg->last, $3->cfg->first);
        } else {
            chain_blocks($1->cfg->last, $3->cfg->first);
        }

        struct cfg_t *cfg = new_cfg();
        cfg->first = $1->cfg->first;
        cfg->last = $3->cfg->last;

        $$->cfg = cfg;
	}
 ;

statement : assignment_statement
	{
	// printf("statement : assignment_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));

        $$->data.as = $1;
        $$->type = STATEMENT_T_ASSIGNMENT;
        $$->line_number = line_number;

        $$->cfg = $1->cfg;
	}
 | compound_statement
	{
	// printf("statement : compound_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));

        $$->data.ss = $1;
        $$->type = STATEMENT_T_SEQUENCE;
        $$->line_number = line_number;

        $$->cfg = $1->cfg;
	}
 | if_statement
	{
	// printf("statement : if_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));

        $$->data.is = $1;
        $$->type = STATEMENT_T_IF;
        $$->line_number = line_number;

        $$->cfg = $1->cfg;
	}
 | while_statement
	{
	// printf("statement : while_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));

        $$->data.ws = $1;
        $$->type = STATEMENT_T_WHILE;
        $$->line_number = line_number;

        $$->cfg = $1->cfg;
	}
 | print_statement
        {
	// printf("statement : print_statement \n");
        $$ = (struct statement_t*) malloc(sizeof(struct statement_t));

        $$->data.ps = $1;
        $$->type = STATEMENT_T_PRINT;
        $$->line_number = line_number;

        $$->cfg = $1->cfg;
        }
 ;

while_statement : WHILE boolean_expression DO statement
	{
	// printf("while_statement : WHILE boolean_expression DO statement \n");
        $$ = (struct while_statement_t*) malloc(sizeof(struct while_statement_t));

        $$->e = $2;
        $$->s = $4;

        $$->cfg = new_cfg();

        struct block_t *dummy_block = new_dummy_block();

        struct block_t *branch = perform_branch($4->cfg->first, dummy_block);

        $2->cfg->last = merge_blocks($2->cfg->last, branch);

        // Chain expr block to end of statement

        chain_blocks($4->cfg->last, $2->cfg->first);
        $2->cfg->first->has_parent = 1;

        // Assign while statement cfg
        $$->cfg->first = $2->cfg->first;
        $$->cfg->last = dummy_block;
        }
 ;

if_statement : IF boolean_expression THEN statement ELSE statement
	{
	// printf("if_statement : IF boolean_expression THEN statement ELSE statement \n");
        $$ = (struct if_statement_t*) malloc(sizeof(struct if_statement_t));
        $$->e = $2;
        $$->s1 = $4;
        $$->s2 = $6;

        $$->cfg = new_cfg();

        struct block_t *branch = perform_branch($4->cfg->first, $6->cfg->first);

        $2->cfg->last = merge_blocks($2->cfg->last, branch);

        // Chain dummy block to end of statements
        struct block_t *dummy_block = new_dummy_block();

        chain_blocks($4->cfg->last, dummy_block);
        chain_blocks($6->cfg->last, dummy_block);

        // Assign if statement cfg
        $$->cfg->first = $2->cfg->first;
        $$->cfg->last = dummy_block;
	}
 ;

assignment_statement : variable_access ASSIGNMENT expression
	{
	// printf("assignment_statement : variable_access ASSIGNMENT expression \n");
        $$ = (struct assignment_statement_t*) malloc(sizeof(struct assignment_statement_t));

        $$->va = $1;
        $$->e = $3;
        $$->oe = NULL;

        merge_blocks($1->cfg->last, $3->cfg->first);

        struct block_t *block = perform_assign_stmnt();

        block = merge_blocks($3->cfg->last, block);

        $$->cfg = new_cfg();

        $$->cfg->first = $1->cfg->first;
        $$->cfg->last = block;
	}
 | variable_access ASSIGNMENT object_instantiation
	{
	// printf("assignment_statement : variable_access ASSIGNMENT object_instantiation \n");
        $$ = (struct assignment_statement_t*) malloc(sizeof(struct assignment_statement_t));

        $$->va = $1;
        $$->e = NULL;
        $$->oe = $3;

        merge_blocks($1->cfg->last, $3->cfg->first);

        struct block_t *block = perform_assign_stmnt();

        block = merge_blocks($3->cfg->last, block);

        $$->cfg = new_cfg();

        $$->cfg->first = $1->cfg->first;
        $$->cfg->last = block;
	}
 ;

object_instantiation: NEW identifier
	{
	// printf("object_instantiation: NEW identifier \n");
        $$ = (struct object_instantiation_t*) malloc(sizeof(struct object_instantiation_t));

        $$->id = $2;
        $$->apl = NULL;

        $$->cfg = perform_object_instantiation($2, NULL);
	}
 | NEW identifier params
	{
	// printf("object_instantiation: NEW identifier params \n");
        $$ = (struct object_instantiation_t*) malloc(sizeof(struct object_instantiation_t));

        $$->id = $2;
        $$->apl = $3;

        $$->cfg = perform_object_instantiation($2, $3);
	}
;

print_statement : PRINT variable_access
        {
	// printf("print_statement : PRINT variable_access \n");
        $$ = (struct print_statement_t*) malloc(sizeof(struct print_statement_t));

        $$->va = $2;
        }
;

variable_access : identifier
	{
	// printf("variable_access : identifier \n");
        $$ = (struct variable_access_t*) malloc(sizeof(struct variable_access_t));

        $$->type = VARIABLE_ACCESS_T_IDENTIFIER;
        $$->data.id = $1;
        // TODO: $$->recordname
        // TODO: $$->expr

        struct cfg_t *cfg = new_cfg();
        struct block_t *push = push_to_stack($1);

        cfg->first = cfg->last = push;

        $$->cfg = cfg;
	}
 | indexed_variable
	{
	// printf("variable_access : indexed_variable \n");
        $$ = (struct variable_access_t*) malloc(sizeof(struct variable_access_t));

        $$->type = VARIABLE_ACCESS_T_INDEXED_VARIABLE;
        $$->data.iv = $1;
        // TODO: $$->recordname
        // TODO: $$->expr
	}
 | attribute_designator
	{
	// printf("variable_access : attribute_designator \n");
        $$ = (struct variable_access_t*) malloc(sizeof(struct variable_access_t));

        $$->type = VARIABLE_ACCESS_T_ATTRIBUTE_DESIGNATOR;
        $$->data.ad = $1;
        // TODO: $$->recordname
        // TODO: $$->expr
	}
 | method_designator
	{
	// printf("variable_access : method_designator \n");
        $$ = (struct variable_access_t*) malloc(sizeof(struct variable_access_t));

        $$->type = VARIABLE_ACCESS_T_METHOD_DESIGNATOR;
        $$->data.md = $1;
        // TODO: $$->recordname
        // TODO: $$->expr
	}
 ;

indexed_variable : variable_access LBRAC index_expression_list RBRAC
	{
	// printf("indexed_variable : variable_access LBRAC index_expression_list RBRAC \n");
        $$ = (struct indexed_variable_t*) malloc(sizeof(struct indexed_variable_t));

        $$->va = $1;
        $$->iel = $3;
        // TODO: $$->expr
	}
 ;

index_expression_list : index_expression_list comma index_expression
	{
	// printf("index_expression_list : index_expression_list comma index_expression \n");
        $$ = (struct index_expression_list_t*) malloc(sizeof(struct index_expression_list_t));

        $$->e = $3;
        $$->next = $1;
        // TODO: $$->expr
	}
 | index_expression
	{
	// printf("index_expression_list : index_expression \n");
        $$ = (struct index_expression_list_t*) malloc(sizeof(struct index_expression_list_t));

        $$->e = $1;
        $$->next = NULL;
        // TODO: $$->expr
	}
 ;

index_expression : expression
	{
	// printf("index_expression : expression \n");
        $$ = $1;
	} ;

attribute_designator : variable_access DOT identifier
	{
	// printf("attribute_designator : variable_access DOT identifier \n");
        $$ = (struct attribute_designator_t*) malloc(sizeof(struct attribute_designator_t));

        $$->va = $1;
        $$->id = $3;
	}
;

method_designator: variable_access DOT function_designator
	{
	// printf("method_designator: variable_access DOT function_designator \n");
        $$ = (struct method_designator_t*) malloc(sizeof(struct method_designator_t));

        $$->va = $1;
        $$->fd = $3;
	}
 ;


params : LPAREN actual_parameter_list RPAREN 
	{
	// printf("params : LPAREN actual_parameter_list RPAREN  \n");
        $$ = $2;
	}
 ;

actual_parameter_list : actual_parameter_list comma actual_parameter
	{
	// printf("actual_parameter_list : actual_parameter_list comma actual_parameter \n");
        $$ = (struct actual_parameter_list_t*) malloc(sizeof(struct actual_parameter_list_t));

        $$->ap = $3;
        $$->next = $1;

        $$->cfg = new_cfg();

        if (can_merge_blocks($1->cfg->last, $3->cfg->first)) {
            merge_blocks($1->cfg->last, $3->cfg->first);
        } else {
            chain_blocks($1->cfg->last, $3->cfg->first);
        }
        $$->cfg->first = $1->cfg->first;
        $$->cfg->last = $3->cfg->last;
	}
 | actual_parameter 
	{
	// printf("actual_parameter_list : actual_parameter \n");
        $$ = (struct actual_parameter_list_t*) malloc(sizeof(struct actual_parameter_list_t));

        $$->ap = $1;
        $$->next = NULL;

        $$->cfg = $1->cfg;
	}
 ;

actual_parameter : expression
	{
	// printf("actual_parameter : expression \n");
        $$ = (struct actual_parameter_t*) malloc(sizeof(struct actual_parameter_t));

        $$->e1 = $1;
        $$->e2 = NULL;
        $$->e3 = NULL;

        $$->cfg = $1->cfg;
	}
 | expression COLON expression
	{
	// printf("actual_parameter : expression COLON expression \n");
        $$ = (struct actual_parameter_t*) malloc(sizeof(struct actual_parameter_t));

        $$->e1 = $1;
        $$->e2 = $3;
        $$->e3 = NULL;

        $$->cfg = new_cfg();

        if (can_merge_blocks($1->cfg->last, $3->cfg->first)) {
            merge_blocks($1->cfg->last, $3->cfg->first);
        } else {
            chain_blocks($1->cfg->last, $3->cfg->first);
        }
        $$->cfg->first = $1->cfg->first;
        $$->cfg->last = $3->cfg->last;
	}
 | expression COLON expression COLON expression
	{
	// printf("actual_parameter : expression COLON expression COLON expression \n");
        $$ = (struct actual_parameter_t*) malloc(sizeof(struct actual_parameter_t));

        $$->e1 = $1;
        $$->e2 = $3;
        $$->e3 = $5;

        $$->cfg = new_cfg();

        if (can_merge_blocks($1->cfg->last, $3->cfg->first)) {
            merge_blocks($1->cfg->last, $3->cfg->first);
        } else {
            chain_blocks($1->cfg->last, $3->cfg->first);
        }

        if (can_merge_blocks($3->cfg->last, $5->cfg->first)) {
            merge_blocks($3->cfg->last, $5->cfg->first);
        } else {
            chain_blocks($3->cfg->last, $5->cfg->first);
        }
        $$->cfg->first = $1->cfg->first;
        $$->cfg->last = $5->cfg->last;
	}
 ;

boolean_expression : expression
	{
	// printf("boolean_expression : expression \n");
        $$ = $1;
	} ;

expression : simple_expression
	{
	// printf("expression : simple_expression \n");
        $$ = (struct expression_t*) malloc(sizeof(struct expression_t));

        $$->se1 = $1;
        $$->relop = 0;
        $$->se2 = NULL;
        $$->expr = $1->expr;

        $$->cfg = $1->cfg;
	}
 | simple_expression relop simple_expression
	{
	// printf("expression : simple_expression relop simple_expression \n");
        $$ = (struct expression_t*) malloc(sizeof(struct expression_t));

        $$->se1 = $1;
        $$->relop = $2;
        $$->se2 = $3;

        // CFG
        $$->cfg = new_cfg();

        if (can_merge_blocks($1->cfg->last, $3->cfg->first)) {
            merge_blocks($1->cfg->last, $3->cfg->first);
        } else {
            chain_blocks($1->cfg->last, $3->cfg->first);
        }

        // At this point, both ops are on the stack.
        struct block_t *block = perform_stack_op2($2);

        block = merge_blocks($3->cfg->last, block);

        $$->cfg->first = $1->cfg->first;
        $$->cfg->last = block;
	}
 ;

simple_expression : term
	{
	// printf("simple_expression : term \n");
        $$ = (struct simple_expression_t*) malloc(sizeof(struct simple_expression_t));

        $$->t = $1;
        $$->addop = 0;
        $$->expr = $1->expr;
        $$->next = NULL;

        $$->cfg = $1->cfg;
	}
 | simple_expression addop term
	{
	// printf("simple_expression : simple_expression addop term \n");
        $$ = (struct simple_expression_t*) malloc(sizeof(struct simple_expression_t));

        $$->t = $3;
        $$->addop = $2;
        $$->next = $1;

        // CFG
        $$->cfg = new_cfg();
        $$->cfg->first = $1->cfg->first;

        merge_blocks($1->cfg->last, $3->cfg->first);

        // At this point, simple_expression and term are on the stack.
        struct block_t *block = perform_stack_op2($2);

        block = merge_blocks($3->cfg->last, block);

        $$->cfg->last = block;
	}
 ;

term : factor
	{
	// printf("term : factor \n");
        $$ = (struct term_t*) malloc(sizeof(struct term_t));

        $$->f = $1;
        $$->mulop = 0;
        $$->expr = $1->expr;
        $$->next = NULL;

        $$->cfg = $1->cfg;
	}
 | term mulop factor
	{
	// printf("term : term mulop factor \n");
        $$ = (struct term_t*) malloc(sizeof(struct term_t));

        $$->f = $3;
        $$->mulop = $2;
        $$->next = $1;

        $$->cfg = new_cfg();
        $$->cfg->first = $1->cfg->first;

        merge_blocks($1->cfg->last, $3->cfg->first);

        // At this point, term and factor are on the stack.
        struct block_t *block = perform_stack_op2($2);

        block = merge_blocks($3->cfg->last, block);

        $$->cfg->last = block;
	}
 ;

sign : PLUS
	{
	// printf("sign : PLUS \n");
        $$ = (int*) malloc(sizeof(int));

        *$$ = OP_PLUS;
	}
 | MINUS
	{
	// printf("sign : MINUS \n");
        $$ = (int*) malloc(sizeof(int));

        *$$ = OP_MINUS;
	}
 ;

factor : sign factor
	{
	// printf("factor : sign factor\n");
        $$ = (struct factor_t*) malloc(sizeof(struct factor_t));

        $$->type = FACTOR_T_SIGNFACTOR;
        $$->data.f.sign = $1;
        $$->data.f.next = $2;
        // TODO: $$->expr

        if (*$1 == OP_MINUS) {

            struct block_t *negate = perform_stack_op1(OP_NEGATE);
            $2->cfg->last = merge_blocks($2->cfg->last, negate);
        }
        $$->cfg = $2->cfg;
	}
 | primary 
	{
	// printf("factor : primary\n");
        $$ = (struct factor_t*) malloc(sizeof(struct factor_t));

        $$->type = FACTOR_T_PRIMARY;
        $$->data.p = $1;
        $$->expr = $1->expr;

        // Keep existing cfg

        $$->cfg = $1->cfg;
	}
 ;

primary : variable_access
	{
	// printf("primary : variable_access\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));

        $$->type = PRIMARY_T_VARIABLE_ACCESS;
        $$->data.va = $1;
        $$->expr = $1->expr;

        // Take address and convert to value

        struct block_t *deref = perform_stack_op1(OP_DEREFERENCE);
        $1->cfg->last = merge_blocks($1->cfg->last, deref);
        $$->cfg = $1->cfg;
	}
 | unsigned_constant
	{
	// printf("primary : | unsigned_constant\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));

        $$->type = PRIMARY_T_UNSIGNED_CONSTANT;
        $$->data.un = $1;
        $$->expr = $1->expr;

        // Push value to stack

        char *buffer = (char*) malloc(sizeof(char) * 20);
        snprintf(buffer, 20, "%d", $1->ui);

        struct cfg_t *cfg = (struct cfg_t*) malloc(sizeof(struct cfg_t));
        struct block_t *push = push_to_stack(buffer);

        cfg->first = cfg->last = push;

        $$->cfg = cfg;
	}
 | function_designator
	{
	// printf("primary : | function_designator\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));

        $$->type = PRIMARY_T_FUNCTION_DESIGNATOR;
        $$->data.fd = $1;
        $$->expr = NULL;

        // TODO

	}
 | LPAREN expression RPAREN
	{
	// printf("primary : | LPAREN expression RPAREN\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));

        $$->type = PRIMARY_T_EXPRESSION;
        $$->data.e = $2;
        $$->expr = $2->expr;

        // Keep the cfg for the expression
        $$->cfg = $2->cfg;
	}
 | NOT primary
	{
	// printf("primary :  | NOT primary\n");
        $$ = (struct primary_t*) malloc(sizeof(struct primary_t));

        $$->type = PRIMARY_T_PRIMARY;
        $$->data.p.next = $2;
        // TODO: $$->expr

        struct block_t *do_not = perform_stack_op1(OP_NOT);
        $2->cfg->last = merge_blocks($2->cfg->last, do_not);
        $$->cfg = $2->cfg;
	}
 ;

unsigned_constant : unsigned_number
	{
	// printf("unsigned_constant : unsigned_number\n");
        $$ = $1;
	}
 ;

unsigned_number : unsigned_integer 
        {
	// printf("unsigned_number : unsigned_integer\n");
        $$ = $1;
        }
;

unsigned_integer : DIGSEQ
	{
	// printf("unsigned_integer : DIGSEQ\nval = %s\n",yytext);
	$$ = (struct unsigned_number_t*) malloc (sizeof(struct unsigned_number_t));

	$$->ui = atoi(yytext);
	}
 ;

/* functions with no params will be handled by plain identifier */
function_designator : identifier params
	{
	// printf("function_designator : identifier params\n");
        $$ = (struct function_designator_t*) malloc(sizeof(struct function_designator_t));

        $$->id = $1;
        $$->apl = $2;
	}
 ;

addop: PLUS
	{
	// printf("addop: PLUS\n");
        $$ = OP_PLUS;
	}
 | MINUS
	{
	// printf("addop: | MINUS\n");
        $$ = OP_MINUS;
	}
 | OR
	{
	// printf("addop: | OR\n");
        $$ = OP_OR;
	}
 ;

mulop : STAR
	{
	// printf("mulop : STAR\n");
        $$ = OP_STAR;
	}
 | SLASH
	{
	// printf("mulop :  | SLASH\n");
        $$ = OP_SLASH;
	}
 | MOD
	{
	// printf("mulop :  | MOD\n");
        $$ = OP_MOD;
	}
 | AND
	{
	// printf("mulop :  | AND\n");
        $$ = OP_AND;
	}
 ;

relop : EQUAL
	{
	// printf("relop : EQUAL\n");
        $$ = OP_EQUAL;
	}
 | NOTEQUAL
	{
	// printf("relop : | NOTEQUAL\n");
        $$ = OP_NOTEQUAL;
	}
 | LT
	{
	// printf("relop : | LT\n");
        $$ = OP_LT;
	}
 | GT
	{
	// printf("relop : | GT\n");
        $$ = OP_GT;
	}
 | LE
	{
	// printf("relop : | LE\n");
        $$ = OP_LE;
	}
 | GE
	{
	// printf("relop :  | GE\n");
        $$ = OP_GE;
	}
 ;

identifier : IDENTIFIER
	{
	// printf("identifier : IDENTIFIER\nid = %s\n",yytext);
	$$ = (char*) malloc((strlen(yytext) + 1));

	strcpy($$, yytext);
	}
 ;

semicolon : SEMICOLON
	{
	// printf("semicolon : SEMICOLON\n");
	}
 ;

comma : COMMA
	{
	// printf("comma : COMMA\n");
	}
 ;

%%
