#ifndef SYM_TAB_H
#define SYM_TAB_H

#define MAX 100

typedef struct {
    char* name;
    char* type;
    int scope;
} Symbol;

Symbol symtab[MAX];
extern int symCount;

void insert(char* name, char* type);
int lookup(char* name);
int lookupCurrentScope(char* name);
void printSymbolTable();
void enterScope();
void exitScope();

#endif