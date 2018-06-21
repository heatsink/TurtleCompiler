%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "symtab.h"
extern int yylex(void);
int yyerror(const char *msg);
%}

%token FORWARD CIRCLE ROTATE COLOR THICKNESS
%token OPEN CLOSE EXPONENT MUL DIV PLUS MINUS COMMA EQUALS VAR
%token IF WHILE ISEQUAL ISNOTEQUAL AND OR NOT LESSTHAN GREATERTHAN

%token <i> INTEGER 
%token SEMICOLON
%token <n> ID;

/* Numerical Values */
%union { int i; node *n; }

%%

program: header commandlist trailer;
header: { printf("%%!PS\n"); };
commandlist: ;
commandlist: commandlist command;
command: startCircle CIRCLE OPEN expr CLOSE SEMICOLON endCircle
       { printf("0 0 50 0 360 arc closepath fill\n"); };
command: FORWARD OPEN expr CLOSE SEMICOLON
       { printf("\nnewpath 0 0 moveto 0 exch lineto currentpoint translate stroke\n");};
command: ROTATE OPEN MINUS INTEGER CLOSE SEMICOLON
       { printf("-%i rotate\n", $4); };
command: ROTATE OPEN INTEGER CLOSE SEMICOLON
       { printf("%i rotate\n", $3); };
command: ROTATE OPEN expr CLOSE SEMICOLON
       { printf("rotate\n"); };
command: COLOR OPEN INTEGER INTEGER INTEGER CLOSE SEMICOLON
       { printf("%.11f %.11f %.11f setrgbcolor\n", ($3/255.0), ($4/255.0), ($5/255.0));};
command: THICKNESS OPEN INTEGER CLOSE SEMICOLON
       { printf("%d setlinewidth\n", $3); }; 
command: variableDecl;
command: bool;
command: SEMICOLON;

startCircle:
       { printf("0 0 \n"); };
endCircle:
       { printf("0 360 arc closepath fill\n"); };

variableDecl: assign;
variableDecl: decl;
assign: ID EQUALS expr SEMICOLON 
      {if($1->defined=1) printf("\n/tlt%s exch store ",$1->name);};
assign: VAR ID EQUALS expr SEMICOLON 
      {$2->defined=1;printf("\n/tlt%s exch def ",$2->name);};
decl: VAR ID SEMICOLON 
      {$2->defined=1; printf("\n/tlt%s 0 def ", $2->name);};

expr: prod;
expr: expr PLUS prod { printf("add "); };
expr: expr MINUS prod { printf("sub "); };
expr: MINUS prod { printf("-1 mul "); };
expr: PLUS prod { printf("abs "); };

prod: exp;
prod: prod MUL exp { printf("mul "); };
prod: prod DIV exp { printf("div "); };

exp: factor;
exp: exp EXPONENT factor { printf("exp "); };

factor: INTEGER { printf("\n%d ",$1); };
factor: ID  
      { 
      if($1->defined){ printf("\ntlt%s ", $1->name); }
      else{ int yyerror(const char *msg){ fprintf(stderr, "Error: Missing Constant Val: %s\n", msg); } } 
      };

bool: expr GREATERTHAN expr {printf("gt ");};
bool: expr LESSTHAN expr {printf("lt ");};
bool: expr ISEQUAL expr {printf("eq ");};
bool: expr ISNOTEQUAL expr {printf("ne ");};
bool: xbool;

xbool: ybool;
xbool: bool OR bool {printf("or ");};
xbool: bool AND bool {printf("and ");};
xbool: NOT bool {printf(" not ");};

ybool: OPEN bool CLOSE;


factor: OPEN expr CLOSE;
trailer: {printf("%% Program Complete\n");};
%%
int yyerror(const char *msg) { fprintf(stderr, "ERROR: %s\n", msg); return -1; }
int main(void) { yyparse(); return 0; }
