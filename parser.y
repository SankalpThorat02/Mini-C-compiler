%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define MAX 100

void yyerror(const char *s);
int yylex();

char* symtab[MAX];
int symCount = 0;

int lookup(char* name) {
    for(int i = 0; i < symCount; i++) {
        if(strcmp(symtab[i], name) == 0){
            return 1;
        }
    }
    return 0;
}

void insert(char* name) {
    if(symCount < MAX) {
        symtab[symCount++] = strdup(name);
    }
}

typdef struct ASTNode {
    char* type;
    char* value;
    struct ASTNode* left;
    struct ASTNode* right;
} ASTNode;

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

%type <node> E S 
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
      /* empty */
    | program S;

S:  
    INT ID SEMI {  
        if(lookup($2)) {
            printf("Semantic Error: Redeclaration of %s\n", $2);
        } else {
            insert($2);
            printf("Declared %s\n", $2);
        }
    }
    | ID ASSIGN E SEMI { 
        if(!lookup($1)) {
            printf("Semantic Error: %s not declared\n", $1);
        } else {
            ASTNode* idNode = createNode("ID", $1, NULL, NULL);
            $$ = createNode("=", NULL, idNode, $3)
        }
    };
E:
      E PLUS E { $$ = createNode("+", NULL, $1, $3); }
    | E MUL E { $$ = createNode("*", NULL, $1, $3); }
    | E MINUS E { $$ = createNode("-", NULL, $1, $3); }
    | E DIV E { $$ = createNode("/", NULL, $1, $3); }
    | LPAREN E RPAREN { $$ = $2; }
    | NUM { $$ = createNode("NUM", $1, NULL, NULL); };
%%

void yyerror(const char *s){
    printf("Syntax Error: %s\n", s);
}

int main() {
    return yyparse();
}