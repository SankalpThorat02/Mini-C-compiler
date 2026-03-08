#ifndef SYM_TAB_H
#define SYM_TAB_H

#define MAX 100

typedef struct {
    char* name;
    char* type;
} Symbol;

Symbol symtab[MAX];

void insert(char* name, char* type);
int lookup(char* name);
void printSymbolTable();


#endif