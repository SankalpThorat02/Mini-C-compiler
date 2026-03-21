#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#include "ast.h"
#include "symTab.h"
#include "semantic.h"
#include "tac.h"
#include "optimizer.h"
#include "targetcode.h"

int yyparse();
extern ASTNode* root;

int main() {
    yyparse();
    
    printf("\n===================================================\n");
    printf("               ABSTRACT SYNTAX TREE                \n");
    printf("===================================================\n");
    printAST(root, 0);
    printf("===================================================\n\n");

    semanticAnalysis(root);

    printSymbolTable();

    printf("\n=========================================================\n");
    printf("              Three Address Code (TAC)                      \n");
    printf("=========================================================\n");
    generateStmtTAC(root); 
    printf("===================================================\n\n");


    printf("\n=========================================================\n");
    printf("              Optimized TAC                             \n");
    printf("=========================================================\n");
    root = runOptimizer(root);
    generateStmtTAC(root); 
    printf("===================================================\n\n");

    printf("\n=========================================================\n");
    printf("              Target Code (RISC V)                      \n");
    printf("=========================================================\n");
    generateDataSection();
    generateTextSection();
    generateStmtRISCV(root);
    generateExit();
    printf("===================================================\n\n");

    return 0;
}   