#ifndef TAC_H
#define TAC_H

#include "ast.h"

typedef struct {
    char result[20];
    char arg1[20];
    char arg2[20];
    char op[10];
} TAC;

extern TAC tacList[1000];
extern int tacCount;

char* generateExprTAC(ASTNode* node);
char* generateStmtTAC(ASTNode* node);

char* newTemp();
char* newLabel();

#endif