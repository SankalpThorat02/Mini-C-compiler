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

ASTNode* createNode(char* type, char* value, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = value ? strdup(value) : NULL;
    node->left = left;
    node->right = right;

    return node;
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
    | program S { $$ = createNode("PROGRAM", NULL, $1, $2); };

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
    return yyparse();
}