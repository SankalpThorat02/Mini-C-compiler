#include <stdio.h>
#include "symTab.h"

void generateDataSection() {
    printf(".data:\n");
    for(int i = 0; i < symCount; i++) {
        printf("%s: .word 0\n", symtab[i].name);
    }
    printf("\n");
}