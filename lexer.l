%{
#include "ast.h"
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
%}

%%

"int"                       { return INT; }
"if"                        { return IF; }
"while"                     { return WHILE; }
[0-9]+                      { yylval.str = strdup(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*      { yylval.str = strdup(yytext); return ID; }

"+"                         { return PLUS; }
"*"                         { return MUL; }
"-"                         { return MINUS; }
"/"                         { return DIV; }
"="                         { return ASSIGN; }
";"                         { return SEMI; }

"("                         { return LPAREN; }
")"                         { return RPAREN; }

[ \t\n]                     ;
.                           {printf("Lexical Error: %s\n", yytext);}

%%

int yywrap() {
    return 1;
}