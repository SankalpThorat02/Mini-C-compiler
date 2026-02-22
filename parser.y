%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex();
%}

%token INT ID NUMBER ASSIGN SEMI

%%

program:
      declaration
    | assignment
    ;

declaration:
      INT ID SEMI
        { printf("Declaration valid\n"); }
    ;

assignment:
      ID ASSIGN NUMBER SEMI
        { printf("Assignment valid\n"); }
    ;

%%

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}

int main() {
    printf("Enter program:\n");
    yyparse();
    return 0;
}