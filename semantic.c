#include <stdio.h>
#include <string.h>

#include "semantic.h"
#include "symTab.h"

void semanticCheck(ASTNode* root) {
    if(!root) return;

    if(strcmp(root->type, "DECL") == 0) {
        char* name = root->right->value;
        char* type = root->left->value;

        if(lookup(name) != -1) {
            printf("Semantic Error: Redeclaration of %s\n", name);
        } else {
            insert(name, type);
        }
        
        return;
    }

    semanticCheck(root->left);
    semanticCheck(root->right);

    if(strcmp(root->type, "NUM") == 0) {
        root->exprType = "int";
    }
    else if(strcmp(root->type, "ID") == 0) {
        char* name = root->value;
        int idx = lookup(name);

        if(idx == -1) {
            printf("Semantic Error: %s not declared\n", name);
            root->exprType = "error";
        } else {
            root->exprType = symtab[idx].type;
        }
    }
    else if(strcmp(root->type, "+") == 0 ||
            strcmp(root->type, "-") == 0 ||
            strcmp(root->type, "*") == 0 ||
            strcmp(root->type, "/") == 0) {

        if(root->left && root->right &&
           root->left->exprType && root->right->exprType) {

            if(strcmp(root->left->exprType, root->right->exprType) != 0) {
                printf("Type mismatch in expression\n");
            } else {
                root->exprType = root->left->exprType;
            }
        }
    }
    else if(strcmp(root->type, ">") == 0 ||
            strcmp(root->type, "<") == 0 ||
            strcmp(root->type, ">=") == 0 ||
            strcmp(root->type, "<=") == 0 ||
            strcmp(root->type, "==") == 0 ||
            strcmp(root->type, "!=") == 0) {

        if(root->left && root->right &&
           root->left->exprType && root->right->exprType) {

            if(strcmp(root->left->exprType, root->right->exprType) != 0) {
                printf("Type mismatch in expression\n");
            }

            root->exprType = "int";
        }
    }
    else if(strcmp(root->type, "=") == 0) {
        if(root->left && root->right) {
            int idx = lookup(root->left->value);
            if(idx != -1 && root->right->exprType) {
                char* idType = symtab[idx].type;
                if(strcmp(idType, root->right->exprType) != 0) {
                    printf("Type mismatch in assignment\n");
                }
            }
        }
    }
    else if(strcmp(root->type, "IF") == 0 || strcmp(root->type, "IF-ELSE") == 0) {
        if(root->left && root->left->exprType && strcmp(root->left->exprType, "int") != 0) {
            printf("Condition must evaluate to true or false\n");
        }
    }
}
