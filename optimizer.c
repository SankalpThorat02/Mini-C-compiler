#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "optimizer.h"

ASTNode* constantFold(ASTNode* node) {
    if(!node)
        return NULL;

    node->left = constantFold(node->left);
    node->right = constantFold(node->right);

    if(node->left && node->right && strcmp(node->left->type, "NUM") == 0 && strcmp(node->right->type, "NUM") == 0) {
        int a = atoi(node->left->value);
        int b = atoi(node->right->value);

        int result;
        if(strcmp(node->type, "+") == 0) result = a + b;
        else if(strcmp(node->type, "-") == 0) result = a - b;
        else if(strcmp(node->type, "*") == 0) result = a * b;
        else if(strcmp(node->type, "/") == 0) result = a / b;

        char temp[10];
        sprintf(temp, "%d", result);

        return createNode("NUM", temp, NULL, NULL);
    }

    return node;
}