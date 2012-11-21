/* symtab.h
 *
 * Holds function definitions for the symbol table. The symbol table
 * is implemented as a global hash table that contains local symbol
 * tables for each function
 */

#ifndef SYMTAB_H
#define SYMTAB_H

#include "shared.h"
#include <stdlib.h>
#include <string.h>



struct ht_item_t {
    void *value; // data that is used for this scope or id.
    int value_type; // this is the type that the void * value represents
};

struct ht_node_t {
    char *key; // This is either the scope or the id of the element found in a scope table.
    struct ht_item_t *value;

    struct ht_node_t *next;
};

struct hash_table_t {
    int size;
    struct ht_node_t **table;
};

/* ----------------------------------------------------------------
 * Function declarations
 * ----------------------------------------------------------------
 */

int hash(struct hash_table_t *hashtable, char *key);
struct hash_table_t* new_hash_table(int size);
struct ht_item_t* get_hashtable_item(struct hash_table_t *hashtable, char *key);
struct ht_item_t* insert_item(struct hash_table_t *hashtable, char *key, struct ht_item_t *value);
struct ht_item_t* remove_item(struct hash_table_t *hashtable, char *key);

void printTable(struct hash_table_t *table);

int get_name_hashval(char *name);
char* get_hashval_name(int hashval);
void symtab_init(void);

#endif
