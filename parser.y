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
%}

%union{
    int num;
    char* id;
}

%type <num> E
%token <num> NUM
%token <id> ID
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
            printf("Assigned %s = %d\n", $1, $3);
        }
    };
E:
      E PLUS E { $$ = $1 + $3; }
    | E MUL E { $$ = $1 * $3; }
    | E MINUS E { $$ = $1 - $3; }
    | E DIV E { $$ = $1 / $3; }
    | LPAREN E RPAREN { $$ = $2; }
    | NUM { $$ = $1; };
%%

void yyerror(const char *s){
    printf("Syntax Error: %s\n", s);
}

int main() {
    return yyparse();
}