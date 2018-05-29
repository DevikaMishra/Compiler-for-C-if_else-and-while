%{
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#include<time.h>
#include "lex.yy.c"
struct node
 {
  char *left;
  char *right;
  char *token;
 } syntax[100];
int o=0;
int optcount=0;
struct opt
{
	char *t;
	char *arg;
	char *arg2;
	char *op;
}optim[100];



void yyerror(const char*);
int yylex();
char *temp1;
int yywrap();
void insert_type();
void add(char);
int search(char *,int);
int search1(char*,int);
void FOO();
void add_ptr();
int dep=0;
void insert_type_table();
struct dataType{
	char * id_name;
	char * data_type;
	char * type;
	int line_no;
	int depth;
	}symbolTable[100];

char typeStack[10][100];
int typeStack_top = 0;
char type[10];
char count=0;

int c=0;
int t=0;
int flag;
int z=0;
int q;
int k=0;
extern countn;
%}
%union {struct var_name{char name[100];char *type;}nam;}
%token <nam> ID NUM WHILE REL VOID INCLUDE RETURN INT FLOAT CHAR MAIN  PRINTF STRL CH
%type <nam> E V S 
%right '='
%left '+' '-'
%left '*' '/'
%left UMINUS
%%
S1: H F S1;
H : H H | INCLUDE{add('H');};
F : INT{insert_type();}|FLOAT{insert_type();}|CHAR{insert_type();}|VOID{insert_type();};
S1: MAIN'{'{add('t');dep++;} S '}'{add('t');dep--;}  
T : ID{push();insert_type_table();} G| T','{add('t');}T| '*'{add_ptr();} T
G : '['{add('t');} NUM{add('n');} ']'{add('t');}| ;
S : WHILE{insert_type();c++;if(c>=2){flag=1;};lab1();} '('{add('t');} E ')'{add('t');lab2();} '{' {dep++;} {add('t');} S '}'{add('t');dep--;lab3();} S2{syntax[k].left = "cond"; syntax[k].right= "stmt"; syntax[k].token = "while";k++;  }| E ';' S2| DECL S2 |PRINTF{add('f');} '('{add('t');} STRL{add('a');} ')'{add('t');}';'{add('t');} S2{syntax[k].left = strdup($5.name); syntax[k].right= " "; syntax[k].token = "printf";k++;};
S2:S S2| ;
DECL: F T DECL_2';'{add('t');}| ;
DECL_2: '='{push();add('o');} E{codegen();}| ;
E :V '='{push();add('o');} E{codegen_assign();syntax[k].left = strdup($1.name); syntax[k].right= strdup("expr"); syntax[k].token = "=";k++;}
  | E '+'{push();add('o');} E{codegen();syntax[k].left = strdup($1.name); syntax[k].right= strdup($4.name); syntax[k].token = "+";k++;optcount++; }
  | E '-'{push();add('o');} E{codegen();syntax[k].left = strdup($1.name); syntax[k].right= strdup($4.name); syntax[k].token = "-";k++;}
  | E '*'{push();add('o');} E{codegen();syntax[k].left = $1.name; syntax[k].right= $4.name; syntax[k].token = "*";k++;}
  | E '/'{push();add('o');} E{codegen();syntax[k].left = $1.name; syntax[k].right= $4.name; syntax[k].token = "/";k++;}
  | E REL{push();add('r');} E{codegen();syntax[k].left = strdup($1.name); syntax[k].right= strdup($4.name); syntax[k].token = strdup($2.name);k++;}
  | '('{add('t');} E ')'{add('t');}
  | '-'{push();add('o');} E{codegen_umin();} %prec UMINUS
  | V   
  | NUM{push();add('n');$$=$1;}
  | CH{push();add('c');$$=$1;} 
  |
  ;
V : ID {push();add('d');$$=$1;}
  ;
%%


#include<ctype.h>
char st[100][10];
int top=0;
char i_[2]="0";
char temp[2]="t";
char temp2[2]="t";

int lnum=1;
int start=1;
int main()
{
	optim[o].t='\0';
	optim[o].arg='\0';
	optim[o].arg2='\0';
	optim[o].op='\0';
	o++;
	//x.val=10;
	printf("--------------------------------------------------------------\n");
	printf("Intermediate code\n"); 
	printf("--------------------------------------------------------------\n");
	yyparse();
	printf("Parsing is Successful\n");	
	//printf("size : %ld",sizeof(symbolTable));
	printf("--------------------------------------------------------------\n");
	printf("Symbol Table\n");
	printf("--------------------------------------------------------------\n");
	int i=0;
	for(i=0;i<count;i++){
		printf("%s\t%s\t%s\t%d\t%d\n",symbolTable[i].id_name,symbolTable[i].data_type,symbolTable[i].type,symbolTable[i].line_no,symbolTable[i].depth);
		
	}
	printf("-----------------------------------------\n");
	printf("Syntax tree\n");
	printf("-----------------------------------------\n");
	int j=0;
	//printf("%s\n",temp1);
	for(j=0;j<k;j++)
	{
		printf("%s\t%s\t%s\n",syntax[j].token,syntax[j].left,syntax[j].right);
		printf("\n");
	}
	return 0;
}
void yyerror(const char* s)
{
	printf("Not accepted\n");
	printf("error at the line no:%d\n",countn);
	exit(0);
}
void insert_type(){
	strcpy(type,yytext);
	//printf("hey");
	q=search(type,dep);
	//printf("qval=%d",q);
	if(q==0){
		symbolTable[count].id_name=strdup(yytext);
		symbolTable[count].data_type=strdup("N/A");
		symbolTable[count].line_no = countn;
		symbolTable[count].type=strdup("KEYWORD\t");
		symbolTable[count].depth=0;
		count++;
	}
	
	
}
void insert_type_table(){
	
		q=search1(yytext,dep);
	//printf("qval=%d",q);
		if(q==0){
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("IDENTIFIER");
			symbolTable[count].depth=dep;
			count++;
		}
	
	
}
void add(char c)
{
	q=search(yytext,dep);
	
	if(q==0){
		if(c=='H')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Header");
			
			count++;
		}
		else if(c=='t')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Punctuation");
			count++;
		}
		else if(c=='o')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Operator");
			count++;
		}
		else if(c=='r')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Rel Op\t");
			count++;
		}
		else if(c=='n')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("NUMBER\t");
			count++;
		}
		else if(c=='[')
		{
			symbolTable[count].id_name=strdup("[");
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Punctuation");
			count++;
		}
		else if(c=='f')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("function");
			count++;
		}
		else if(c=='a')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("argument");
			count++;
		}
		else if(c=='c')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Character");
			count++;
		}
		else if(c=='d')
		{
			printf("%s not defined at line no. %d\n",yytext,countn+1);
			exit(0);	
		}
	}
	
}
int  search(char *type,int d)
{
	int i;
	for(i=0;i<count;i++)
	{
		if(strcmp(symbolTable[i].id_name,type)==0 &&(symbolTable[i].depth)<=d)
		{
			return -1;
			break;
		}
	
	}
	return 0;
}
int  search1(char *type,int d)
{
	int i;
	for(i=0;i<count;i++)
	{
		if(strcmp(symbolTable[i].id_name,type)==0 &&(symbolTable[i].depth)==d)
		{
			return -1;
			break;
		}
	
	}
	return 0;
}

void add_ptr(){
	strcat(type,"*");
}
void check(char *p1,char *p2)
{
	if(strcmp(p1,p2)==0)
	{
		printf("corect bro\n");
	}
}

push()
 {
  strcpy(st[++top],yytext);
 }

codegen()
 {
 int s;
 strcpy(temp,"t");
 strcat(temp,i_);
 //printf("came atleast here\n");

/*for(s=0;s<2;s++)
{
	
	//printf("value%s\t%s\t%s\t%s\n",optim[s].arg,optim[s].arg2,optim[s].op,st[top-2]);
	st[top-2];
	//printf("came here\n");
	
	//if(ccc==2)
	//{
	if(optim[s].arg!='\0'&& optim[s].arg2!='\0'&&optim[s].op!='\0' && optim[s].t!='\0' &&strcmp(optim[s].arg,st[top-2])==0 && strcmp(optim[s].arg2,st[top])==0 &&strcmp(optim[s].op,st[top-1])==0  )
	 {
		
		//printf("ho sucess\n");
		if(ccc==1)
		{
			printf("%s =%s\n",temp,optim[s].t);
		}
	

 	 }
	//}	
	 else
	{
		//printf("came here bro");
		optim[o].t=strdup(temp);
		optim[o].arg=strdup(st[top-2]);
		optim[o].arg2=strdup(st[top]);
		optim[o].op=strdup(st[top-1]);
		o++;
	}
}*/
//if(ccc!=1)
//{
 printf("%s = %s %s %s\n",temp,st[top-2],st[top-1],st[top]);
//}
 top-=2;
 strcpy(st[top],temp);
 i_[0]++;
 }

codegen_umin()
 {
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = -%s\n",temp,st[top]);
 top--;
 strcpy(st[top],temp);
 i_[0]++;
 }

codegen_assign()
 {
 printf("%s = %s\n",st[top-2],st[top]);
 top-=2;
 }



lab1()
{
if(flag==1)
{	
	//lnum++;
	printf("L%d: \n",c);

}
else
if(flag==0)
{
printf("L%d: \n",++lnum);
}
}

lab2()
{
 strcpy(temp,"t");
 strcat(temp,i_);
 printf("%s = %s\n",temp,st[top]);
if(flag==1)
{	t=c+1;
	printf("ifFalse %s goto L%d\n",temp,t);
}
else
 printf("ifFalse %s goto L%d\n",temp,lnum);
 i_[0]++;
 }

lab3()
{
if(flag==1)
{	
	printf("goto L%d \n",c);
	//flag=0;	
}
else
printf("goto L%d \n",start);
if(flag==1)
{	
	t=c+1;
	printf("L%d: \n",t);	
	flag=0;
}
else
if(flag==0)
{
printf("L%d: \n",0);
}
}

