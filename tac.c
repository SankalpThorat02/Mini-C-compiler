#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tac.h"

int tempCount = 1;
int labelCount = 1;

char* newTemp() {
    char buffer[10];
    sprintf(buffer, "t%d", tempCount++);
    return strdup(buffer);
}

char* newLabel() {
    char buffer[10];
    sprintf(buffer, "L%d", labelCount++);
    return strdup(buffer);
}

char* generateExprTAC(ASTNode* node) {
    if(!node) return NULL;

    if(strcmp(node->type, "ID") == 0 || strcmp(node->type, "NUM") == 0) {
        return node->value;
    }

    if(strcmp(node->type, "+") == 0 || 
       strcmp(node->type, "-") == 0 || 
       strcmp(node->type, "*") == 0 ||
       strcmp(node->type, "/") == 0 || 
       strcmp(node->type, ">") == 0 ||
       strcmp(node->type, "<") == 0 ||
       strcmp(node->type, ">=") == 0 ||
       strcmp(node->type, "<=") == 0 ||
       strcmp(node->type, "==") == 0 ||
       strcmp(node->type, "!=") == 0 ) {
        
        char* left = generateExprTAC(node->left);
        char* right = generateExprTAC(node->right);

        char* temp = newTemp();
        printf("%s = %s %s %s\n", temp, left, node->type, right);

        return temp;
    }

    return NULL;
}

char* generateStmtTAC(ASTNode* node) {
    if(!node) 
        return NULL;

    if(strcmp(node->type, "=") == 0) {
        char* right = generateExprTAC(node->right);
        printf("%s = %s\n", node->left->value, right);
        
        return node->left->value;
    }

    else if(strcmp(node->type, "<=>") == 0) {
        char* temp = newTemp();
        printf("%s = %s\n", temp, node->left->value);
        printf("%s = %s\n", node->left->value, node->right->value);
        printf("%s = %s\n", node->right->value, temp);
        return NULL;
    }

    else if(strcmp(node->type, "++") == 0) {
        printf("%s = %s + 1\n", node->left->value, node->left->value);
        return NULL;
    }

    else if(strcmp(node->type, "--") == 0) {
        printf("%s = %s - 1\n", node->left->value, node->left->value);
        return NULL;
    }

    else if(strcmp(node->type, "IF") == 0) {
        char* condTemp = generateExprTAC(node->left);
        char* label = newLabel();

        printf("ifFalse %s goto %s\n", condTemp, label);
        generateStmtTAC(node->right);

        printf("%s:\n", label);

        return NULL;
    }
    
    else if(strcmp(node->type, "IF-ELSE") == 0) {
        ASTNode* ifNode = node->left;
        ASTNode* elseStmt = node->right;

        char* condTemp = generateExprTAC(ifNode->left);

        char* label1 = newLabel();
        char* label2 = newLabel();

        printf("ifFalse %s goto %s\n", condTemp, label1);

        generateStmtTAC(ifNode->right);
        printf("goto %s\n", label2);

        printf("%s:\n", label1);
        generateStmtTAC(elseStmt);

        printf("%s:\n", label2);

        return NULL;
    }

    else if(strcmp(node->type, "WHILE") == 0) {
        char* startLabel = newLabel();
        char* endLabel = newLabel();

        printf("%s:\n", startLabel);
        char* condTemp = generateExprTAC(node->left);
        printf("ifFalse %s goto %s\n", condTemp, endLabel);

        generateStmtTAC(node->right);

        printf("goto %s\n", startLabel);
        printf("%s:\n", endLabel);

        return NULL;
    }

    else if(strcmp(node->type, "BLOCK") == 0) {
        generateStmtTAC(node->left);
        generateStmtTAC(node->right);
        return NULL;
    }

    generateStmtTAC(node->left);
    generateStmtTAC(node->right);

    return NULL;
}