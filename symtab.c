/* symtab.c
 *
 * Implements the symbol table
 *
 * A flat symbol table is the root of all evil.
 */

#include <assert.h>
#include "symtab.h"
#include "shared.h"

struct hash_table_t* new_hash_table(int size)
{
    struct hash_table_t *table;
    int i;
    
    if (size <= 0) {
        return NULL;
    }
    
    table = (struct hash_table_t*) malloc(sizeof(struct hash_table_t));
    CHECK_MEM_ERROR(table);
    
    table->size = size;
    
    table->table = (struct ht_node_t **) malloc(sizeof(struct ht_node_t *) * size);
    CHECK_MEM_ERROR(table);
    
    for(i = 0; i < size; i++) {
        table->table[i] = NULL;
    }
    
    return table;
}

int hash(struct hash_table_t *hashtable, char *key)
{
    return makekey(key, hashtable->size);
}

struct ht_item_t* get_hashtable_item(struct hash_table_t *hashtable, char *key)
{
    struct ht_node_t *node;
    int hashed_key = hash(hashtable, key);
    
    for(node = hashtable->table[hashed_key]; node != NULL; node = node->next) {
        if (strcmp(key, node->key) == 0) {
            return node->value;
        }
    }
    
    return NULL;
}

struct ht_item_t* insert_item(struct hash_table_t *hashtable, char *key, struct ht_item_t *value)
{
    // Insert a value into the hashtable.  If a value already exists for the given key, the old value is returned, and the user must take responsibility for freeing that memory.
    struct ht_node_t *node;
    int hashed_key = hash(hashtable, key);
    struct ht_item_t *item = get_hashtable_item(hashtable, key);
    if (item != NULL) {
        // value already exists, overwrite value in table and return old value to user
        for(node = hashtable->table[hashed_key]; node != NULL; node = node->next) {
            if (strcmp(key, node->key) == 0) {
                node->value = value;
                return item;
            }
        }
    }

    // Implicit else

    node = (struct ht_node_t*) malloc(sizeof(struct ht_node_t));
    node->key = (char*) malloc(strlen(key) + 1);
    strcpy(node->key, key);
    node->value = value;

    node->next = hashtable->table[hashed_key];
    hashtable->table[hashed_key] = node;
    return NULL;
}

struct ht_item_t *remove_item(struct hash_table_t* table, char *key)
{
    /* Remove an item from a hashtable, and return the item to the user (user becomes responsible for memory of the item */
    int hashed_key = hash(table, key);
    struct ht_node_t *prev = NULL;
    struct ht_node_t *node = table->table[hashed_key];
    struct ht_item_t *value = NULL;

    while (node != NULL) {
        if (strcmp(key, node->key) == 0) {
            value = node->value;
            if (prev == NULL) {
                table->table[hashed_key] = node->next;
            } else {
                prev->next = node->next;
            }

            free(node->key);
            free(node);
            break;
        }
        prev = node;
        node = node->next;
    }
    return value;
}

/* ------------------------------------------------------------
 * Initializes the symbol table
 * ------------------------------------------------------------
 */
void symtab_init(void)
{

}
