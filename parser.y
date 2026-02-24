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

%type <num> E
%token <num> NUM
%token <id> ID
%token ASSIGN SEMI
%token PLUS MUL

%left PLUS
%left MUL

%%
S:
    ID ASSIGN E SEMI
    {
        printf("Parsed %s = %d\n", $1, $3);
    };
E:
    E PLUS E { $$ = $1 + $3; }
    | E MUL E { $$ = $1 * $3; }
    | NUM { $$ = $1; };
%%

void yyerror(const char *s){
    printf("Syntax Error: %s\n", s);
}

int main() {
    return yyparse();
}