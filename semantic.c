#include <stdio.h>
#include <string.h>

#include "semantic.h"
#include "symTab.h"

int semanticErrors = 0;
int loopDepth = 0;

void semanticCheck(ASTNode* root) {
    if(!root) return;

    if(strcmp(root->type, "DECL") == 0) {
        char* type = root->left->value;
        char* name = root->right->value;

        if(lookupCurrentScope(name) != -1) {
            printf("[Line: %d] Semantic Error: Redeclaration of %s\n", root->lineNum, name);
            semanticErrors++;
        } else {
            insert(name, type);
        }
        
        return;
    }
    
    else if(strcmp(root->type, "BLOCK") == 0) {
        enterScope();
        semanticCheck(root->left);
        semanticCheck(root->right);
        exitScope();

        return;
    }

    else if(strcmp(root->type, "BREAK") == 0 || strcmp(root->type, "CONTINUE") == 0) {
        if(loopDepth == 0) {
            printf("[Line: %d] Semantic Error: '%s' statement must be inside a loop\n", root->lineNum, root->type);
            semanticErrors++;
        }
        return;
    }

    else if(strcmp(root->type, "WHILE") == 0) {
        loopDepth++;
        semanticCheck(root->left);  
        semanticCheck(root->right);
        loopDepth--;
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
            printf("[Line: %d] Semantic Error: %s not declared\n", root->lineNum, name);
            root->exprType = "error";
            semanticErrors++;
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

            if(strcmp(root->left->exprType, "error") != 0 && strcmp(root->right->exprType, "error") != 0) {
                if(strcmp(root->left->exprType, root->right->exprType) != 0) {
                    printf("[Line: %d] Semantic Error: Type mismatch in arithmetic expression (%s vs %s)\n", 
                        root->lineNum, root->left->exprType, root->right->exprType);
                    semanticErrors++;
                } 
                else {
                    root->exprType = root->left->exprType;
                }
            } 
            else {
                root->exprType = "error";
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

            if(strcmp(root->left->exprType, "error") != 0 && strcmp(root->right->exprType, "error") != 0) {
                if(strcmp(root->left->exprType, root->right->exprType) != 0) {
                    printf("[Line: %d] Semantic Error: Type mismatch in relational expression (%s vs %s)\n", 
                        root->lineNum, root->left->exprType, root->right->exprType);
                    semanticErrors++;   
                }
            }
            root->exprType = "int";
        }
    }
    else if(strcmp(root->type, "=") == 0) {
        if(root->left && root->right) {
            int idx = lookup(root->left->value);
            if(idx != -1 && root->right->exprType) {
                char* idType = symtab[idx].type;

                if(strcmp(root->right->exprType, "error") != 0) {
                    int isExact = (strcmp(idType, root->right->exprType) == 0);
                    int isIntBool = (strcmp(idType, "bool") == 0 && strcmp(root->right->exprType, "int") == 0);
                    int isBoolInt = (strcmp(idType, "int") == 0 && strcmp(root->right->exprType, "bool") == 0);

                    if(!isExact && !isIntBool && !isBoolInt) {
                        printf("[Line: %d] Semantic Error: Cannot assign '%s' to variable '%s' of type '%s'\n", 
                               root->lineNum, root->right->exprType, root->left->value, idType);
                        semanticErrors++;
                    }
                }
            }
        }
    }
    else if(strcmp(root->type, "IF") == 0 || strcmp(root->type, "IF-ELSE") == 0) {

        if(root->left && root->left->exprType) {
            if(strcmp(root->left->exprType, "error") != 0 && strcmp(root->left->exprType, "int") != 0) {
                printf("[Line: %d] Semantic Error: IF condition must evaluate to an integer(boolean), got '%s'\n", 
                       root->lineNum, root->left->exprType);
                semanticErrors++;
            }
        }
    }
    
    else if(strcmp(root->type, "<=>") == 0) {
        if(root->left && root->right) {
            int idxLeft = lookup(root->left->value);
            int idxRight = lookup(root->right->value);

            if(idxLeft != -1 && idxRight != -1) {
                if(strcmp(symtab[idxLeft].type, symtab[idxRight].type) != 0) {
                    printf("[Line: %d] Semantic Error: Cannot swap variables of different types ('%s' vs '%s')\n", 
                        root->lineNum, symtab[idxLeft].type, symtab[idxRight].type);
                    semanticErrors++;
                }
            } 
            else {
                if(idxLeft == -1) printf("[Line: %d] Semantic Error: '%s' not declared\n", root->lineNum, root->left->value);
                if(idxRight == -1) printf("[Line: %d] Semantic Error: '%s' not declared\n", root->lineNum, root->right->value);
                semanticErrors++;
            }
        }
    }
    else if(strcmp(root->type, "++") == 0 || strcmp(root->type, "--") == 0) {
        if(root->left) {
            int idx = lookup(root->left->value);
            if(idx != -1) {
                if(strcmp(symtab[idx].type, "int") != 0 && strcmp(symtab[idx].type, "float") != 0) {
                    printf("[Line: %d] Semantic Error: Increment/Decrement requires a numeric type.\n", root->lineNum);
                    semanticErrors++;
                }
            } else {
                printf("[Line: %d] Semantic Error: '%s' not declared\n", root->lineNum, root->left->value);
                semanticErrors++;
            }
        }
    }
}

void semanticAnalysis(ASTNode* root) {
    semanticErrors = 0; 
    semanticCheck(root);

    if (semanticErrors == 0) {
        printf("[SUCCESS] No semantic errors found.\n");
    } else {
        printf("[FAILED]  Semantic analysis finished with %d error(s).\n", semanticErrors);
    }
}