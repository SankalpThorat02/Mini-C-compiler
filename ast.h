#ifndef AST_H
#define AST_H

typedef struct ASTNode {
    char* type;
    char* value;
    char* exprType; 
    struct ASTNode* left;
    struct ASTNode* right;
} ASTNode;

ASTNode* createNode(char* type, char* value, ASTNode* left, ASTNode* right);

#endif