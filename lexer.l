%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"
%}

%%

[0-9]+                      { yylval.num = atoi(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*      { yylval.id = strdup(yytext); return ID; }

"+"                         { return PLUS; }
"*"                         { return MUL; }
"-"                         { return MINUS; }
"/"                         { return DIV; }
"="                         { return ASSIGN; }
";"                         { return SEMI; }

[ \t\n]                     ;
.                           {printf("Lexical Error: %s\n", yytext);}

%%

int yywrap() {
    return 1;
}