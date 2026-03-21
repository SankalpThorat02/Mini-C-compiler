#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "symTab.h"

int symCount = 0;
int currentScope = 0;

int lookup(char* name) {
    for(int i = symCount - 1; i >= 0; i--){
        if(strcmp(symtab[i].name, name) == 0)
            return i;   
    }
    return -1;
}

int lookupCurrentScope(char* name) {
    for(int i = symCount - 1; i >= 0; i--) {
        if(symtab[i].scope != currentScope) break;
        if(strcmp(symtab[i].name, name) == 0) return i;
    }
    return -1;
}

void insert(char* name, char* type) {
    if(symCount < MAX) {
        symtab[symCount].name = strdup(name);
        symtab[symCount].type = strdup(type);
        symtab[symCount].scope = currentScope;
        symCount++;
    }
}

void enterScope() {
    currentScope++;
}

void exitScope() {
    while(symCount > 0 && symtab[symCount - 1].scope == currentScope) {
        symCount--;
    }

    currentScope--;
}

void printSymbolTable() {
    printf("\n=========================================================\n");
    printf("              GLOBAL SYMBOL TABLE                        \n");
    printf("=========================================================\n");
    
    printf("| %-5s | %-15s | %-10s | %-10s |\n", "INDEX", "NAME", "TYPE", "SCOPE");
    printf("---------------------------------------------------------\n");

    if (symCount == 0) {
        printf("| %-51s |\n", "               (No Global Variables)                 ");
    } else {
        for(int i = 0; i < symCount; i++) {
            printf("| %-5d | %-15s | %-10s | %-10d |\n", 
                   i, symtab[i].name, symtab[i].type, symtab[i].scope);
        }
    }
    printf("=========================================================\n\n");
}