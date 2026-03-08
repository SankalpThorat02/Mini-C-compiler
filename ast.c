#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "ast.h"

ASTNode* createNode(char* type, char* value, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = value ? strdup(value) : NULL;
    node->exprType = NULL;
    node->left = left;
    node->right = right;

    return node;
}

void printAST(ASTNode* root, int depth){
    if(!root) return;

    for(int i = 0; i < depth; i++) {
        printf("  ");
    }

    if(root->value) {
        printf("%s (%s)\n", root->type, root->value);
    }
    else printf("%s\n", root->type);

    printAST(root->left, depth + 1);
    printAST(root->right, depth + 1);
}
