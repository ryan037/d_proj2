/*noyywrap用途： 不需要讀多個檔案,以及避免編譯錯誤*/
%option noyywrap

digit       [0-9]
letter      [a-zA-Z]
integer     [+-]?(0|[1-9]){digit}*
real        [+-]?(0|[1-9]){digit}*\.{digit}+([eE][-+]?{digit}+)?
identifier  {letter}+({letter}|{digit}|_)*
string      \"([^\"\n]|\"\")*\"
%{
#include "symtab.h"
#include "y.tab.hpp"
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n", #t);  return(t);}                     
#define tokenInteger(t,i) {LIST; printf("<%s: %d>\n",#t,atoi(i)); \
                          yylval.int_dataType = atoi(i); return(t);}
#define tokenFloat(t,i) {LIST; printf("<%s: %f>\n",#t,atof(i));     \
                         yylval.double_dataType = atof(i); return(t);} 
#define tokenString(t,s) {LIST; printf("<%s: %s>\n",#t,s); return(t);} 
#define MAX_LINE_LENG 256
int linenum = 1;
char buf[MAX_LINE_LENG];
char string_revise[MAX_LINE_LENG];
%}
%%
"//".*    {LIST;}

\/\*([^*]|(\*+[^*/]))*\*+\/    {LIST;}

".."    {token(DD);}
","     {token(',');}
":"     {token(':');}
";"     {token(';');}
"."     {token('.');}
"("     {token('(');}
")"     {token(')');}
"["     {token('[');}
"]"     {token(']');}
"{"     {token('{');}
"}"     {token('}');}

"++"	{token(ADD);}
"--"	{token(SUB);}
"&&"	{token(AND);}
"||"	{token(OR);}


"+"     {token('+');}
"-"     {token('-');}
"*"     {token('*');}
"/"     {token('/');}
"%"     {token('%');}
"<"     {token('<');}
"<="    {token(LEQ);}
">="    {token(GEQ);}
">"     {token('>');}
"=="    {token(EQ);}
"!="    {token(NEQ);}
"!"     {token('!');}
"="     {token('=');}
"+="    {token(ADDEQ);}
"-="    {token(SUBEQ);}
"*="    {token(MULEQ);}
"/="    {token(DIVEQ);}

"bool"  {token(BOOL);}
"break"  {token(BREAK);}
"char"  {token(CHAR);}
"case"  {token(CASE);}
"const"  {token(CONST);}
"continue"  {token(CONTINUE);}
"default"   {token(DEFAULT);}
"do"  {token(DO);}
"double"  {token(DOUBLE);}
"else"  {token(ELSE);}
"extern"  {token(EXTERN);}
"float"  {token(FLOAT);}
"for"  {token(FOR);}
"foreach" {token(FOREACH);}
"if"  {token(IF);}
"int"  {token(INT);}
"print"  {token(PRINT);}
"println"  {token(PRINTLN);}
"read"  {token(READ);}
"return"  {token(RETURN);}
"string"  {token(STRING);}
"switch"  {token(SWITCH);}
"void"  {token(VOID);}
"while"  {token(WHILE);}



{real}        {tokenFloat(REAL_CONST,yytext);}
{integer}     {tokenInteger(INT_CONST, yytext);}

"true"   {yylval.bool_dataType = true;   tokenString(BOOL_CONST, yytext);}
"false"   {yylval.bool_dataType = false;  tokenString(BOOL_CONST, yytext);}
{identifier}  {yylval.string_dataType = strdup(yytext); tokenString(ID,yytext);}
{string}      {
                yylval.string_dataType = strdup(yytext);
		int idx = 0;           
		for(int i=1; i<strlen(yytext)-1; i++){
   			if(yytext[i]=='"' && yytext[i+1] == '"'){
     				i+=1;
   			}
   			string_revise[idx++] = yytext[i];
		}
			string_revise[idx] = '\0';
			tokenString(STR_CONST, string_revise);
                        
              }





\n      {
        LIST;
        int idx = 0;
        for(int i=0; i<strlen(buf); i++){
            if(buf[i] == '\n'){   
               string_revise[idx] = '\0';
               printf("%d: %s\n", linenum++, string_revise);
               idx=0;
            }
            else
               string_revise[idx++] = buf[i];
        
        }

        
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        LIST;
        printf("/*%d:%s*/\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }





%%
