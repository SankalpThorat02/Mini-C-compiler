%{
#include <stdio.h>

/*token definitions*/
#define INT 1
#define ID 2
#define ASSIGN 3
#define NUM 4
#define SEMI 5

#define PLUS    6
#define MINUS   7
#define MUL     8
#define DIV     9

#define LT      10
#define GT      11
#define LE      12
#define GE      13
#define EQ      14
#define NE      15

#define LPAREN  16
#define RPAREN  17
#define LBRACE  18
#define RBRACE  19

#define IF      20
#define WHILE   21
%}

%%

"int"                       { return INT; }
"if"                        { return IF; }
"while"                     { return WHILE; }
[0-9]+                      { yylval = atoi(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*      { yylval = strdup(yytext); return ID; }

"<="                        { return LE; }
">="                        { return GE; } 
"=="                        { return EQ; }
"!="                        { return NE; }
"<"                         { return LT; }
">"                         { return GT; }
"="                         { return ASSIGN; }
";"                         { return SEMI; }

"+"                         { return PLUS; }
"-"                         { return MINUS; }
"*"                         { return MUL; }
"/"                         { return DIV; }

"("                         { return LPAREN; }
")"                         { return RPAREN; }
"{"                         { return LBRACE; }
"}"                         { return RBRACE; }

[ \t\n]                     ;
.                           {printf("Unknown \n");}

%%

int yywrap() {
    return 1;
}

int main() {
    int token;

    printf("Enter code:\n");
    while((token = yylex())) {
        printf("Token: %d\n", token);
    }
    return 0;
}