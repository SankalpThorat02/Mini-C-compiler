#ifndef TAC_H
#define TAC_H

#include "ast.h"

char* generateExprTAC(ASTNode* node);
char* generateStmtTAC(ASTNode* node);

char* newTemp();
char* newLabel();

#endif