%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "symtab.h"
extern int yylex(void);
int yyerror(const char *msg);
%}

%token FORWARD CIRCLE SEMICIRCLE ARC ARCFILL ROTATE COLOR THICKNESS THIN
%token OPEN CLOSE OPENCURLYBRACE CLOSECURLYBRACE EXPONENT MUL DIV MOD PLUS MINUS COMMA EQUALS VAR
%token IF ELSE FUNC WHILE ISEQUAL ISNOTEQUAL AND OR NOT GREATERTHAN LESSTHAN
%token RESET RAND SEMICOLON
%token <i> INTEGER 
%token <n> ID;
%union { int i; node *n; }

%%
program: { printf("%%!PS\n"); } commandList trailer;
/* COMMANDS */
commandList: ;
commandList: commandList command;
command: functionCall;
command: functionDecleration;
command: CIRCLE { printf("\n0 0 "); } OPEN expr CLOSE SEMICOLON 
       { printf("0 360 arc closepath fill\n"); };
command: SEMICIRCLE { printf("\n0 0 "); } OPEN expr 
       { printf("0 \n"); } COMMA expr CLOSE SEMICOLON
       { printf("arc closepath fill\n"); };
command: ARC { printf("\n0 1 "); } OPEN expr COMMA expr
       { printf(" \n"); } COMMA expr CLOSE SEMICOLON
       { printf("arc currentpoint translate stroke\n"); };
command: ARCFILL { printf("\n0 1 "); } OPEN expr COMMA expr
       { printf(" \n"); } COMMA expr CLOSE SEMICOLON
       { printf("arc closepath stroke \n"); };
command: RESET OPEN expr COMMA expr CLOSE SEMICOLON 
       { printf("\nmoveto currentpoint translate stroke\n"); };
command: FORWARD OPEN expr CLOSE SEMICOLON
       { printf("\nnewpath 0 0 moveto 0 exch lineto currentpoint translate stroke\n");};
command: ROTATE OPEN MINUS INTEGER CLOSE SEMICOLON
       { printf("-%i rotate\n", $4); };
command: ROTATE OPEN INTEGER CLOSE SEMICOLON
       { printf("%i rotate\n", $3); };
command: ROTATE OPEN expr CLOSE SEMICOLON
       { printf("rotate\n"); };
command: COLOR OPEN expr COMMA expr COMMA expr CLOSE SEMICOLON
       { printf(" setrgbcolor\n"); };
command: THICKNESS OPEN expr CLOSE SEMICOLON
       { printf("setlinewidth\n"); }; 
command: THICKNESS THIN SEMICOLON
       { printf("1 setlinewidth\n"); }; 
command: RESET OPEN CLOSE SEMICOLON
       { printf(" 0 0 moveto currentpoint translate stroke\n"); };
command: variableDecl;
command: bool;
command: conditional;
command: SEMICOLON;

/* FUNCTIONS */
functionCall: ID OPEN argList CLOSE SEMICOLON 
      { printf("func%s \n", $1->name); };
argList: ;
argList:args;
args:expr;
args:args COMMA expr;
functionDecleration: functDecl;
functDecl: FUNC ID
      { scope_open(); printf("/func%s { \n4 dict begin\n" ,$2->name); }
OPEN paramList CLOSE 
OPENCURLYBRACE commandList CLOSECURLYBRACE
      { $2->defined=1; printf("end\n} def \n\n"); scope_close(); };

paramList: ;
paramList: params;
params: ID 
      {$1->defined=1; printf("/tlt%s exch def\n", $1->name);};
params: ID COMMA params
      {$1->defined=1; printf("/tlt%s exch def\n", $1->name);};

/* CONDITIONALS */
conditional: ifsignal commandList CLOSECURLYBRACE {printf("\n}\nif\n");};
conditional: ifsignal commandList CLOSECURLYBRACE elsehead commandList CLOSECURLYBRACE  {printf("\n}\nifelse\n");};
conditional: whilehead whilehead2 commandList CLOSECURLYBRACE {printf("\n}\nloop\n");};

ifsignal : IF OPEN bool CLOSE OPENCURLYBRACE {printf("{\n");};
elsehead: ELSE OPENCURLYBRACE {printf("}\n{\n");};
whilehead: WHILE OPEN {printf("\n{\n");};
whilehead2: stackBool CLOSE OPENCURLYBRACE {printf("\n{ exit }\nif\n");};

variableDecl: assign;
variableDecl: decl;
assign: ID EQUALS expr SEMICOLON 
      {if($1->defined=1) printf("\n/tlt%s exch store ",$1->name);};
assign: VAR ID EQUALS expr SEMICOLON 
      {$2->defined=1;printf("\n/tlt%s exch def ",$2->name);};
decl: VAR ID SEMICOLON 
      {$2->defined=1; printf("\n/tlt%s 0 def ", $2->name);};

/* LOGIC */
stackBool: bool {printf(" not ");};
bool: expr GREATERTHAN expr {printf("gt ");};
bool: expr LESSTHAN expr {printf("lt ");};
bool: expr ISEQUAL expr {printf("eq ");};
bool: expr ISNOTEQUAL expr {printf("ne ");};
bool: firstCompare;
firstCompare: secondCompare;
firstCompare: bool OR bool {printf("or ");};
firstCompare: bool AND bool {printf("and ");};
firstCompare: NOT bool {printf(" not ");};
secondCompare: OPEN bool CLOSE;

/* EXPRESSIONS */
expr: prod;
expr: expr PLUS prod { printf("add "); };
expr: expr MINUS prod { printf("sub "); };
expr: MINUS prod { printf("-1 mul "); };
expr: PLUS prod { printf("abs "); };
expr: INTEGER { printf(" %d ",$1); };
prod: exp;
prod: prod MUL exp { printf("mul "); };
prod: prod DIV exp { printf("div "); };
prod: prod MOD exp { printf("mod "); };
exp: factor;
exp: exp EXPONENT factor { printf("exp "); };
factor: INTEGER { printf(" %d ",$1); };
factor: RAND OPEN CLOSE { printf("%d ", (1+rand()%20)); };
factor: ID  
      { 
      if($1->defined){ printf(" tlt%s ", $1->name); }
      else{ int yyerror(const char *msg){ fprintf(stderr, "Error: Missing Constant Val: %s\n", msg); } } 
      };
factor: OPEN expr CLOSE;

trailer: {printf("%% Program Complete\n");};
%%
int yyerror(const char *msg) { fprintf(stderr, "GENERIC ERROR: %s\n", msg); return -1; }
int main(void) { time_t t; srand((unsigned) time(&t)); yyparse(); return 0; }
