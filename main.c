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
    
    printf("<PHASE_AST>\n");
    printAST(root, 0);

    printf("<PHASE_SEMANTIC>\n");
    semanticAnalysis(root);

    printf("<PHASE_SYMTAB>\n");
    printSymbolTable();

    printf("<PHASE_TAC>\n");
    generateStmtTAC(root); 


    printf("<PHASE_OPT_TAC>\n");
    root = runOptimizer(root);
    generateStmtTAC(root); 

    printf("<PHASE_RISCV>\n");
    generateDataSection();
    generateTextSection();
    generateStmtRISCV(root);
    generateExit();

    return 0;
}   