%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "ast.h"

#define MAX 100

void yyerror(const char *s);
int yylex();

char* symtab[MAX];
int symCount = 0;

ASTNode* root = NULL;

int lookup(char* name) {
    for(int i = 0; i < symCount; i++){
        if(strcmp(symtab[i], name) == 0)
            return 1;
    }
    return 0;
}

void insert(char* name) {
    if(symCount < MAX) {
        symtab[symCount++] = strdup(name);
    }
}

ASTNode* createNode(char* type, char* value, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = value ? strdup(value) : NULL;
    node->left = left;
    node->right = right;

    return node;
}

void semanticCheck(ASTNode* root) {
    if(!root) return;

    if(strcmp("DECL", root->type) == 0) {
        char* name = root->left->value;
        if(lookup(name)) {
            printf("Semantic Error: Redeclaration of %s\n", name);
        } else {
            insert(name);
        }
    }

    if(strcmp("ID", root->type) == 0) {
        char* name = root->value;
        if(!lookup(name)) {
            printf("Semantic Error: %s not declared\n", name);
        }
    }

    semanticCheck(root->left);
    semanticCheck(root->right);
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

%}

%union{
    ASTNode* node;
    char* str;
}

%type <node> E S program
%token <str> NUM
%token <str> ID
%token ASSIGN SEMI
%token PLUS MUL MINUS DIV
%token LPAREN RPAREN

%token INT

%left PLUS MINUS
%left MUL DIV

%%
program:
      /* empty */ { $$ = NULL; }
    | program S { 
        $$ = createNode("PROGRAM", NULL, $1, $2); 
        root = $$;
      };

S:  
    INT ID SEMI {  
        ASTNode* idNode = createNode("ID", $2, NULL, NULL);
        $$ = createNode("DECL", "int", idNode, NULL);
    }
    | ID ASSIGN E SEMI { 
        ASTNode* idNode = createNode("ID", $1, NULL, NULL);
        $$ = createNode("=", NULL, idNode, $3);
        
    };
E:
      E PLUS E { $$ = createNode("+", NULL, $1, $3); }
    | E MUL E { $$ = createNode("*", NULL, $1, $3); }
    | E MINUS E { $$ = createNode("-", NULL, $1, $3); }
    | E DIV E { $$ = createNode("/", NULL, $1, $3); }
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

    return 0;
}