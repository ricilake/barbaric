%{
/* For asprintf */
#define _GNU_SOURCE
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char* s) {
  fprintf(stderr, "%s\n", s);
}

/* Like GNU asprintf, but returns the resulting string buffer;
 * it is the responsibility of the caller to freee the buffer
 */
char* concatf(const char* fmt, ...);

#define YYSTYPE char*

%}
%error-verbose
%glr-parser
%debug

%token NUMBER IDENTIFIER
%token AND "&&"
%token COMBINING_BAR "|/[|]"
%token NON_COMBINING_BAR "|/[^|]"

%%

program
     : /* empty */
     | statement program
     ;

statement
     : expression '\n'
          { puts($1); free($1); }
     | /* blank line */ '\n'
     | error '\n' { /* memory leak */ }
     ;


bar  : COMBINING_BAR
     | NON_COMBINING_BAR
     ;
or   : COMBINING_BAR bar
     ;

expression
     : alternation                         %dprec 2
     | expression ',' alternation          %dprec 1
          { $$ = concatf("%s, %s", $1, $3); free($1); free($3); }
     ;
alternation
     : conjunction                         %dprec 2
     | alternation or conjunction          %dprec 1
          { $$ = concatf(u8"%s \u2016 %s", $1, $3); free($1); free($3); }
     ;
conjunction
     : term                                %dprec 2
     | conjunction "&&" term               %dprec 1
          { $$ = concatf(u8"%s && %s", $1, $3); free($1); free($3); }
     ;
term : NUMBER
     | IDENTIFIER
     | '(' expression ')'
          { $$ = concatf(u8"(%s)", $2); free($2); }
     | bar expression bar
          { $$ = concatf(u8"\u2308%s\u230b", $2); free($2); }
     ;

%%

#if HAVE_VASPRINTF
char* concatf(const char* fmt, ...) {
  va_list args;
  char* buf = NULL;
  va_start(args, fmt);
  int n = vasprintf(&buf, fmt, args);
  va_end(args);
  if (n < 0) { free(buf); buf = NULL; }
  return buf;
}
#else
char* concatf(const char* fmt, ...) {
  va_list args;
  va_start(args, fmt);
  char* buf = NULL;
  int n = vsnprintf(NULL, 0, fmt, args);
  va_end(args);
  if (n >= 0) {
    va_start(args, fmt);
    buf = malloc(n+1);
    if (buf) vsnprintf(buf, n+1, fmt, args);
    va_end(args);
  }
  return buf;
}
#endif

int main(int argc, char** argv) {
  if (argc > 1 && strcmp(argv[1], "-d") == 0) {
    yydebug = 1;
  }
  return yyparse();
}
