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
%token OPEN CLOSE
%token EXPONENT MUL DIV PLUS MINUS COMMA EQUALS

%token <i> INTEGER 
%token SEMICOLON
%token <n> ID;

/* Numerical Values */
%union { int i; node *n; }

%%
program: header commandlist trailer;
header: { printf("%%!PS\n\n"); };
commandlist: ;
commandlist: commandlist command;
command: CIRCLE OPEN INTEGER CLOSE SEMICOLON
       { printf("0 0 %d 0 360 arc closepath fill\n", $3); };
command: FORWARD OPEN expr CLOSE SEMICOLON
       { printf("\nnewpath 0 0 moveto 0 exch lineto currentpoint translate stroke\n");};
command: ROTATE OPEN MINUS INTEGER CLOSE SEMICOLON
       { printf("-%i rotate\n", $4); };
command: ROTATE OPEN INTEGER CLOSE SEMICOLON
       { printf("%i rotate\n", $3); };
command: COLOR OPEN INTEGER INTEGER INTEGER CLOSE SEMICOLON
       {printf("%.11f %.11f %.11f setrgbcolor\n", ($3/255.0), ($4/255.0), ($5/255.0));};
command: THICKNESS OPEN INTEGER CLOSE SEMICOLON
       { printf("%d setlinewidth\n", $3); }; 


command: SEMICOLON;
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
         factor: OPEN expr CLOSE;
trailer: {printf("%% Program Complete\n");};
%%
int yyerror(const char *msg) { fprintf(stderr, "ERROR: %s\n", msg); return -1; }
int main(void) { yyparse(); return 0; }
