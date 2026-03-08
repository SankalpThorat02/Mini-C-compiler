#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "symTab.h"

int symCount = 0;

int lookup(char* name) {
    for(int i = 0; i < symCount; i++){
        if(strcmp(symtab[i].name, name) == 0)
            return i;   
    }
    return -1;
}

void insert(char* name, char* type) {
    if(symCount < MAX) {
        symtab[symCount].name = strdup(name);
        symtab[symCount].type = strdup(type);
        symCount++;
    }
}

void printSymbolTable() {
    printf("--------------- Symbol Table ---------------\n");
    for(int i = 0; i < symCount; i++) {
        printf("%s : %s\n", symtab[i].name, symtab[i].type);
    }
}