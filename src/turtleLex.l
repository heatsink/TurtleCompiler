%{
#include "symtab.h"
#include "turtleBison.tab.h"
%}
%%
forward               return FORWARD;
circle                return CIRCLE;
rotate                return ROTATE;
color                 return COLOR;
thickness             return THICKNESS;
while                 return WHILE;
if                    return IF;
\=\=                  return ISEQUAL;
\!\=                  return ISNOTEQUAL;
\&\&                  return AND;
\|\|                  return OR;
\!                    return NOT;
\>\>                  return GREATERTHAN;
\<\<                  return LESSTHAN;
;                     return SEMICOLON;
\(                    return OPEN;
\)                    return CLOSE;
\^                    return EXPONENT;
\*                    return MUL;
\\                    return DIV;
\+                    return PLUS;
\-                    return MINUS;
\,                    return COMMA;
\=                    return EQUALS;
var                   return VAR;
Integer               return INTEGER;
[0-9]+   yylval.i=atoi(yytext); return INTEGER;
[a-z]+      {
               yylval.n=lookup(yytext);
               if (yylval.n==NULL) yylval.n=insert(yytext);
               return ID;
            }

\/\/.*               ;
\n                   ;
[[:space:]]          ;

.  fprintf(stderr, "Unexpected '%c'\n", yytext[0]);

%%
