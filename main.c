#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#include "ast.h"
#include "symTab.h"
#include "semantic.h"
#include "tac.h"

int yyparse();
extern ASTNode* root;

int main() {
    yyparse();
    printf("--------------- AST ----------------\n");
    printAST(root, 0);

    printf("--------------- Semantic Check ---------------\n");
    semanticCheck(root);

    printSymbolTable();

    printf("--------------- TAC ---------------\n");
    generateStmtTAC(root); 

    return 0;
}