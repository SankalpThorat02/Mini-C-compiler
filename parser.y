%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#include "ast.h"
#include "symTab.h"
#include "semantic.h"
#include "tac.h"

void yyerror(const char *s);
int yylex();

ASTNode* root = NULL;

%}

%union{
    ASTNode* node;
    char* str;
}

%type <node> E S program TYPE
%token <str> NUM
%token <str> ID
%token ASSIGN SEMI
%token PLUS MUL MINUS DIV
%token LPAREN RPAREN LBRACE RBRACE

%token EQ NE GE LE GT LT
%token IF ELSE WHILE FOR

%token INT FLOAT CHAR

%left EQ NE GE LE GT LT
%left PLUS MINUS
%left MUL DIV

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
program:
      /* empty */ { $$ = NULL; }
    | program S { 
        $$ = createNode("PROGRAM", NULL, $1, $2); 
        root = $$;
      };

TYPE:
      INT { $$ = createNode("TYPE", "int", NULL, NULL); }
    | FLOAT { $$ = createNode("TYPE", "float", NULL, NULL); }
    | CHAR { $$ = createNode("TYPE", "char", NULL, NULL); };

S:  
    TYPE ID SEMI {  
        ASTNode* idNode = createNode("ID", $2, NULL, NULL);
        $$ = createNode("DECL", NULL, $1, idNode);
    }
    | ID ASSIGN E SEMI { 
        ASTNode* idNode = createNode("ID", $1, NULL, NULL);
        $$ = createNode("=", NULL, idNode, $3);
    }
    | IF LPAREN E RPAREN S %prec LOWER_THAN_ELSE {
        $$ = createNode("IF", NULL, $3, $5);
    }
    | IF LPAREN E RPAREN S ELSE S {
        ASTNode* ifNode = createNode("IF", NULL, $3, $5);
        $$ = createNode("IF-ELSE", NULL, ifNode, $7);
    }
    | WHILE LPAREN E RPAREN S {
        $$ = createNode("WHILE", NULL, $3, $5);
    }
    | LBRACE program RBRACE {
        $$ = createNode("BLOCK", NULL, $2, NULL);
    };
E:
      E PLUS E { $$ = createNode("+", NULL, $1, $3); }
    | E MUL E { $$ = createNode("*", NULL, $1, $3); }
    | E MINUS E { $$ = createNode("-", NULL, $1, $3); }
    | E DIV E { $$ = createNode("/", NULL, $1, $3); }

    | E GT E { $$ = createNode(">", NULL, $1, $3); }
    | E LT E { $$ = createNode("<", NULL, $1, $3); }
    | E GE E { $$ = createNode(">=", NULL, $1, $3); }
    | E LE E { $$ = createNode("<=", NULL, $1, $3); }
    | E EQ E { $$ = createNode("==", NULL, $1, $3); }
    | E NE E { $$ = createNode("!=", NULL, $1, $3); }

    | LPAREN E RPAREN { $$ = $2; }
    | NUM { $$ = createNode("NUM", $1, NULL, NULL); }
    | ID { $$ = createNode("ID", $1, NULL, NULL); };
%%

void yyerror(const char *s){
    printf("Syntax Error: %s\n", s);
}
