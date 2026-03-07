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

char* generateTAC(ASTNode* node) {
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
        
        char* left = generateTAC(node->left);
        char* right = generateTAC(node->right);

        char* temp = newTemp();
        printf("%s = %s %s %s\n", temp, left, node->type, right);

        return temp;
    }

    if(strcmp(node->type, "=") == 0) {
        char* right = generateTAC(node->right);
        printf("%s = %s\n", node->left->value, right);
        
        return node->left->value;
    }

    if(strcmp(node->type, "IF") == 0) {
        char* condTemp = generateTAC(node->left);
        char* label = newLabel();

        printf("if FALSE %s goto %s\n", condTemp, label);
        generateTAC(node->right);

        printf("%s:\n", label);

        return NULL;
    }

    generateTAC(node->left);
    generateTAC(node->right);

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
%token LPAREN RPAREN

%token EQ NE GE LE GT LT
%token IF ELSE WHILE

%token INT FLOAT CHAR

%left EQ NE GE LE GT LT
%left PLUS MINUS
%left MUL DIV

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
    | IF LPAREN E RPAREN S {
        $$ = createNode("IF", NULL, $3, $5);
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
    generateTAC(root); 

    return 0;
}