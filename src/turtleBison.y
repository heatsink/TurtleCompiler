%{
#include <stdio.h>
#include <stdlib.h>
extern int yylex(void);
int yyerror(const char *msg);
%}

%token SEMICOLON


%%

command: SEMICOLON { printf("TEST"); };

%%

int yyerror(const char *msg) { fprintf(stderr, "ERROR: %s\n", msg); return -1; }
int main(void) { yyparse(); return 0; }
