%{
#include<stdio.h>
#include<stdlib.h>
#include "y.tab.h"
#include<string.h>
int countn=0;
%}
ALPHA [A-Za-z]
DIGIT [0-9]
rel   ("<"|">"|">="|"<="|"=="|"!=")
%%
^"#include"[ ]*<.+\.h> return INCLUDE; 
int	return INT;
float return FLOAT;
char return CHAR;
void return VOID;
"printf" return PRINTF;
"main()" return MAIN;
while                return WHILE;
['][a-zA-Z][']		      {strcpy(yylval.nam.name,yytext); return CH;}
{ALPHA}({ALPHA}|{DIGIT})*    {strcpy(yylval.nam.name,yytext); return ID;}
{rel}		{strcpy(yylval.nam.name,yytext); return REL;}
{DIGIT}+             {strcpy(yylval.nam.name,yytext); return NUM;}
[ \t]                 ;
.                 return yytext[0];
["].*["]   	  {strcpy(yylval.nam.name,yytext); return STRL;}
[\n]   		  countn++;
%%

