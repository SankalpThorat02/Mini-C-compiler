%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "ast.h"

#define MAX 100

void yyerror(const char *s);
int yylex();

typedef struct {
    char* name;
    char* type;
} Symbol;

Symbol symtab[MAX];
int symCount = 0;

int tempCount = 1;
int labelCount = 1;
ASTNode* root = NULL;

int lookup(char* name) {
    for(int i = 0; i < symCount; i++){
        if(strcmp(symtab[i].name, name) == 0)
            return i;   
    }
    return -1;
}

void insert(char* name, char* type) {
    if(symCount < MAX) {
        symtab[symCount].name = strdup(name);
        symtab[symCount].type = strdup(type);
        symCount++;
    }
}

ASTNode* createNode(char* type, char* value, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = value ? strdup(value) : NULL;
    node->exprType = NULL;
    node->left = left;
    node->right = right;

    return node;
}

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
    else if(strcmp(root->type, "IF") == 0) {
        if(root->left && root->left->exprType && strcmp(root->left->exprType, "int") != 0) {
            printf("Condition must evaluate to true or false\n");
        }
    }
}

void printAST(ASTNode* root, int depth){
    if(!root) return;

    for(int i = 0; i < depth; i++) {
        printf("  ");
    }

    if(root->value) {
        printf("%s (%s)\n", root->type, root->value);
    }
    else printf("%s\n", root->type);

    printAST(root->left, depth + 1);
    printAST(root->right, depth + 1);
}

char* newTemp() {
    char buffer[10];
    sprintf(buffer, "t%d", tempCount++);
    return strdup(buffer);
}

char* newLabel() {
    char buffer[10];
    sprintf(buffer, "L%d", labelCount++);
    return strdup(buffer);
}

char* generateExprTAC(ASTNode* node) {
    if(!node) return NULL;

    if(strcmp(node->type, "ID") == 0 || strcmp(node->type, "NUM") == 0) {
        return node->value;
    }

    if(strcmp(node->type, "+") == 0 || 
       strcmp(node->type, "-") == 0 || 
       strcmp(node->type, "*") == 0 ||
       strcmp(node->type, "/") == 0 || 
       strcmp(node->type, ">") == 0 ||
       strcmp(node->type, "<") == 0 ||
       strcmp(node->type, ">=") == 0 ||
       strcmp(node->type, "<=") == 0 ||
       strcmp(node->type, "==") == 0 ||
       strcmp(node->type, "!=") == 0 ) {
        
        char* left = generateExprTAC(node->left);
        char* right = generateExprTAC(node->right);

        char* temp = newTemp();
        printf("%s = %s %s %s\n", temp, left, node->type, right);

        return temp;
    }

    return NULL;
}

char* generateStmtTAC(ASTNode* node) {
    if(!node) 
        return NULL;

    if(strcmp(node->type, "=") == 0) {
        char* right = generateExprTAC(node->right);
        printf("%s = %s\n", node->left->value, right);
        
        return node->left->value;
    }

    else if(strcmp(node->type, "IF") == 0) {
        char* condTemp = generateExprTAC(node->left);
        char* label = newLabel();

        printf("ifFalse %s goto %s\n", condTemp, label);
        generateStmtTAC(node->right);

        printf("%s:\n", label);

        return NULL;
    }
    
    else if(strcmp(node->type, "IF-ELSE") == 0) {
        ASTNode* ifNode = node->left;
        ASTNode* elseStmt = node->right;

        char* condTemp = generateExprTAC(ifNode->left);

        char* label1 = newLabel();
        char* label2 = newLabel();

        printf("ifFalse %s goto %s\n", condTemp, label1);

        generateStmtTAC(ifNode->right);
        printf("goto %s\n", label2);

        printf("%s:\n", label1);
        generateStmtTAC(elseStmt);

        printf("%s:\n", label2);

        return NULL;
    }

    else if(strcmp(node->type, "WHILE") == 0) {
        char* startLabel = newLabel();
        char* endLabel = newLabel();

        printf("%s:\n", startLabel);
        char* condTemp = generateExprTAC(node->left);
        printf("ifFalse %s goto %s\n", condTemp, endLabel);

        generateStmtTAC(node->right);

        printf("goto %s\n", startLabel);
        printf("%s:\n", endLabel);

        return NULL;
    }

    else if(strcmp(node->type, "BLOCK") == 0) {
        generateStmtTAC(node->left);
        return NULL;
    }

    generateStmtTAC(node->left);
    generateStmtTAC(node->right);

    return NULL;
}

%}

%union{
    ASTNode* node;
    char* str;
}

%type <node> E S program TYPE
%token <str> NUM
%token <str> ID
%token ASSIGN SEMI
%token PLUS MUL MINUS DIV
%token LPAREN RPAREN LBRACE RBRACE

%token EQ NE GE LE GT LT
%token IF ELSE WHILE

%token INT FLOAT CHAR

%left EQ NE GE LE GT LT
%left PLUS MINUS
%left MUL DIV

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
program:
      /* empty */ { $$ = NULL; }
    | program S { 
        $$ = createNode("PROGRAM", NULL, $1, $2); 
        root = $$;
      };

TYPE:
      INT { $$ = createNode("TYPE", "int", NULL, NULL); }
    | FLOAT { $$ = createNode("TYPE", "float", NULL, NULL); }
    | CHAR { $$ = createNode("TYPE", "char", NULL, NULL); };

S:  
    TYPE ID SEMI {  
        ASTNode* idNode = createNode("ID", $2, NULL, NULL);
        $$ = createNode("DECL", NULL, $1, idNode);
    }
    | ID ASSIGN E SEMI { 
        ASTNode* idNode = createNode("ID", $1, NULL, NULL);
        $$ = createNode("=", NULL, idNode, $3);
    }
    | IF LPAREN E RPAREN S %prec LOWER_THAN_ELSE {
        $$ = createNode("IF", NULL, $3, $5);
    }
    | IF LPAREN E RPAREN S ELSE S {
        ASTNode* ifNode = createNode("IF", NULL, $3, $5);
        $$ = createNode("IF-ELSE", NULL, ifNode, $7);
    }
    | WHILE LPAREN E RPAREN S {
        $$ = createNode("WHILE", NULL, $3, $5);
    }
    | LBRACE program RBRACE {
        $$ = createNode("BLOCK", NULL, $2, NULL);
    };
E:
      E PLUS E { $$ = createNode("+", NULL, $1, $3); }
    | E MUL E { $$ = createNode("*", NULL, $1, $3); }
    | E MINUS E { $$ = createNode("-", NULL, $1, $3); }
    | E DIV E { $$ = createNode("/", NULL, $1, $3); }

    | E GT E { $$ = createNode(">", NULL, $1, $3); }
    | E LT E { $$ = createNode("<", NULL, $1, $3); }
    | E GE E { $$ = createNode(">=", NULL, $1, $3); }
    | E LE E { $$ = createNode("<=", NULL, $1, $3); }
    | E EQ E { $$ = createNode("==", NULL, $1, $3); }
    | E NE E { $$ = createNode("!=", NULL, $1, $3); }

    | LPAREN E RPAREN { $$ = $2; }
    | NUM { $$ = createNode("NUM", $1, NULL, NULL); }
    | ID { $$ = createNode("ID", $1, NULL, NULL); };
%%

void yyerror(const char *s){
    printf("Syntax Error: %s\n", s);
}

int main() {
    yyparse();
    printf("--------------- AST ----------------\n");
    printAST(root, 0);

    printf("--------------- Semantic Check ---------------\n");
    semanticCheck(root);

    printf("--------------- Symbol Table ---------------\n");
    for(int i = 0; i < symCount; i++) {
        printf("%s : %s\n", symtab[i].name, symtab[i].type);
    }

    printf("--------------- TAC ---------------\n");
    generateStmtTAC(root); 

    return 0;
}