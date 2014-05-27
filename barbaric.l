%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define YYSTYPE char*
#include "barbaric.tab.h"

%}

%option noyywrap noinput nounput

%%

[[:blank:]]               { }
-?[0-9]+                  { yylval = strdup(yytext); return NUMBER; }
[[:alpha:]][_[:alnum:]]*  { yylval = strdup(yytext); return IDENTIFIER; }
"&&"                      { return AND; }
[|]/[|]                   { return COMBINING_BAR; }
[|]                       { return NON_COMBINING_BAR; }
.|\n                      { return *yytext; }
