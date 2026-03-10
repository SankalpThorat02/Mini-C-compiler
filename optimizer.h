#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include "ast.h"

ASTNode* constantFold(ASTNode* node);
ASTNode* deadCodeElimination(ASTNode* node);

#endif