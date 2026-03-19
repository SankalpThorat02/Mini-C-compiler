%{
#include "ast.h"
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>

int totalTokens = 0;
int totalLines = 0;

void printToken(const char* tokenType, const char* lexeme) {
    static int headerPrinted = 0;
    
    if (!headerPrinted) {
        printf("\n===================================================\n");
        printf("              LEXICAL ANALYSIS PHASE               \n");
        printf("===================================================\n");
        printf("%-18s | %s\n", "TOKEN TYPE", "LEXEME");
        printf("---------------------------------------------------\n");
        headerPrinted = 1;
    }
    
    printf("%-18s | %s\n", tokenType, lexeme);
    totalTokens++;
}
%}

%%
"int"                       { printToken("KEYWORD", yytext); return INT; }
"float"                     { printToken("KEYWORD", yytext); return FLOAT; }
"char"                      { printToken("KEYWORD", yytext); return CHAR; }
"if"                        { printToken("KEYWORD", yytext); return IF; }
"else"                      { printToken("KEYWORD", yytext); return ELSE; }
"while"                     { printToken("KEYWORD", yytext); return WHILE; }
"for"                       { printToken("KEYWORD", yytext); return FOR; }

[0-9]+                      { yylval.str = strdup(yytext); printToken("NUMBER", yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); printToken("IDENTIFIER", yytext); return ID; }

"=="                        { printToken("REL_OP (EQ)", yytext); return EQ; }
"!="                        { printToken("REL_OP (NE)", yytext); return NE; }
">="                        { printToken("REL_OP (GE)", yytext); return GE; }
"<="                        { printToken("REL_OP (LE)", yytext); return LE; }
">"                         { printToken("REL_OP (GT)", yytext); return GT; }
"<"                         { printToken("REL_OP (LT)", yytext); return LT; }

"="                         { printToken("ASSIGN_OP", yytext); return ASSIGN; }
"+"                         { printToken("ARITH_OP (PLUS)", yytext); return PLUS; }
"*"                         { printToken("ARITH_OP (MUL)", yytext); return MUL; }
"-"                         { printToken("ARITH_OP (MINUS)", yytext); return MINUS; }
"/"                         { printToken("ARITH_OP (DIV)", yytext); return DIV; }
";"                         { printToken("PUNCTUATION", "SEMI_COLON"); return SEMI; }

"("                         { printToken("PUNCTUATION", "LPAREN"); return LPAREN; }
")"                         { printToken("PUNCTUATION", "RPAREN"); return RPAREN; }
"{"                         { printToken("PUNCTUATION", "LBRACE"); return LBRACE; }
"}"                         { printToken("PUNCTUATION", "RBRACE"); return RBRACE; }

[ \t]                       ;
[ \n]                       { totalLines++; printf("\n"); }
.                           { printf("Lexical Error on line %d: %s\n", totalLines, yytext); }

%%

int yywrap() {
    printf("---------------------------------------------------\n");
    printf("              LEXICAL ANALYSIS SUMMARY             \n");
    printf("---------------------------------------------------\n");
    printf("Total Tokens Scanned  : %d\n", totalTokens);
    printf("Total Lines Processed : %d\n", totalLines);
    printf("===================================================\n\n");

    return 1;
}