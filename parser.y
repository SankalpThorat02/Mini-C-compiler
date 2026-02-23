%{
#include<stdio.h>
#include<stdlib.h>

void yyerror(const char *s);
int yylex();
%}

%union{
    int num;
    char* id;
}

%token <num> NUM
%token <id> ID
%token ASSIGN SEMI

%%
S:
    ID ASSIGN NUM SEMI{
        printf("Parsed %s = %d\n", $1, $3);
    }
%%

void yyerror(const char *s){
    printf("Syntax Error: %s\n", s);
}

int main() {
    return yyparse();
}