#include <stdio.h>
#include <string.h>

#include "symTab.h"
#include "ast.h"

int rvLabelCount = 1;

char* newRiscVLabel() {
    char buffer[10];
    sprintf(buffer, "L%d", rvLabelCount++);
    return strdup(buffer);
}

void generateDataSection() {
    printf(".data:\n");
    for(int i = 0; i < symCount; i++) {
        printf("    %s: .word 0\n", symtab[i].name);
    }
    printf("\n");
}

void generateTextSection() {
    printf(".text:\n");
    printf("main:\n\n");
}

void generateExit() {
    printf("\nli a7, 10\n");
    printf("ecall\n");
}

void generateExprRISCV(ASTNode* node) {
    if (!node) return;

    if (strcmp(node->type, "NUM") == 0) {
        printf("    li a0, %s\n", node->value);
        return;
    }

    if (strcmp(node->type, "ID") == 0) {
        printf("    la t0, %s\n", node->value);
        printf("    lw a0, 0(t0)\n\n");
        return;
    }

    generateExprRISCV(node->left);
    
    printf("    addi sp, sp, -4\n");
    printf("    sw a0, 0(sp)\n\n");

    generateExprRISCV(node->right);
    
    printf("    mv t1, a0\n");
    printf("    lw t0, 0(sp)\n");
    printf("    addi sp, sp, 4\n\n");

    if (strcmp(node->type, "+") == 0) {
        printf("    add a0, t0, t1\n");
    } else if (strcmp(node->type, "-") == 0) {
        printf("    sub a0, t0, t1\n");
    } else if (strcmp(node->type, "*") == 0) {
        printf("    mul a0, t0, t1\n");
    } else if (strcmp(node->type, "/") == 0) {
        printf("    div a0, t0, t1\n");
    } else if (strcmp(node->type, "==") == 0) {
        printf("    sub a0, t0, t1\n");
        printf("    seqz a0, a0\n");
    } else if (strcmp(node->type, "!=") == 0) {
        printf("    sub a0, t0, t1\n");
        printf("    snez a0, a0\n"); 
    } else if (strcmp(node->type, ">") == 0) {
        printf("    sgt a0, t0, t1\n");
    } else if (strcmp(node->type, "<") == 0) {
        printf("    slt a0, t0, t1\n");
    } else if (strcmp(node->type, ">=") == 0) {
        printf("    slt a0, t0, t1\n");
        printf("    xori a0, a0, 1\n");
    } else if (strcmp(node->type, "<=") == 0) {
        printf("    sgt a0, t0, t1\n");
        printf("    xori a0, a0, 1\n"); 
    }
}

void generateStmtRISCV(ASTNode* node) {
    if (!node) return;

    if (strcmp(node->type, "BLOCK") == 0) {
        generateStmtRISCV(node->left);
        generateStmtRISCV(node->right);
        return;
    }

    if (strcmp(node->type, "=") == 0) {
        generateExprRISCV(node->right); 
        printf("    la t0, %s\n", node->left->value);
        printf("    sw a0, 0(t0)\n\n");
        return;
    }

    if (strcmp(node->type, "IF") == 0) {
        char* endLabel = newRiscVLabel();
        generateExprRISCV(node->left);
        printf("    beqz a0, %s\n", endLabel); 

        generateStmtRISCV(node->right);
        printf("%s:\n\n", endLabel);
        return;
    }

    if (strcmp(node->type, "IF-ELSE") == 0) {
        char* elseLabel = newRiscVLabel();
        char* endLabel = newRiscVLabel();
        
        generateExprRISCV(node->left->left); 
        printf("    beqz a0, %s\n", elseLabel);
        
        generateStmtRISCV(node->left->right); 
        printf("    j %s\n", endLabel);
        
        printf("%s:\n", elseLabel);
        generateStmtRISCV(node->right);
        
        printf("%s:\n\n", endLabel);
        return;
    }

    if (strcmp(node->type, "WHILE") == 0) {
        char* startLabel = newRiscVLabel();
        char* endLabel = newRiscVLabel();
        
        printf("%s:\n", startLabel);
        generateExprRISCV(node->left);
        printf("    beqz a0, %s\n", endLabel);
        
        generateStmtRISCV(node->right);
        printf("    j %s\n", startLabel);
        
        printf("%s:\n\n", endLabel);
        return;
    }

    generateStmtRISCV(node->left);
    generateStmtRISCV(node->right);
}