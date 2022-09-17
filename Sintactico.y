%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
//#include "ts.h"

int yystopparser=0;
FILE  *yyin;
int yyerror();
int yylex();
int crear_TS();
char *buffer;


%}

%union
 {
 char* cadena;
 int numero;
 }


%token CTE_E
%token CTE_R
%token ID
%token OP_ASIG   
%token OP_SUM
%token OP_MUL      
%token OP_RES
%token OP_DIV      
%token LA          
%token LC
%token PARA
%token PARC
%token CORA
%token CORC
%token AND 
%token OR
%token CO_IGUAL
%token CO_DIST
%token CO_MENI
%token CO_MEN
%token CO_MAYI
%token CO_MAY
%token IF
%token THEN
%token ELSE
%token ENDIF
%token WHILE
%token CTE_S 			
%token DP				
%token PC				
%token COMA
%token PUNTO
%token INIT
%token INT
%token FLOAT
%token STRING
%token READ
%token WRITE
%token NOT
%token DO
%token CASE
%token ENDDO
%token DEFAULT
%token REPEAT

%%
start:
		programa
;
programa:
		sentencia {printf(" Sentencia es Programa\n"); } 
		| programa sentencia {printf( " Programa y Sentencia es Programa\n");}
		;
		
sentencia:
		asignacion	{ printf(" Asignacion es Sentencia\n");}
		| iteracion { printf(" Iteracion es Sentencia\n"); }
		| seleccion { printf(" Seleccion es Sentencia\n"); }
		| zonadec { printf(" Zona Declaracion es Sentencia\n"); }
		| read { printf("Read es Sentencia\n"); }
		| write { printf("Write es Sentencia\n"); }
		| repeat { printf("Repeat es Sentencia\n"); }
		| do { printf("Do es Sentencia\n"); }
		;

asignacion:
		ID OP_ASIG expresion {printf(" ID := Expresion es Asignacion\n"); }
		| ID OP_ASIG constante_string {printf(" ID := Constante String es Asignacion\n"); }
		;

seleccion:
		IF PARA condicion PARC LA programa LC ELSE LA programa LC {printf(" IF (Condicion)  {Programa} ELSE {Programa}  Es Seleccion\n"); }
		| IF PARA condicion PARC  LA programa LC  {printf(" IF (Condicion)  {Programa}  es Seleccion\n"); }
		;

iteracion:
		WHILE PARA condicion PARC LA programa LC {printf(" WHILE (Condicion) { programa } es Iteracion\n"); }
		;

condicion:
		  condicion AND comparacion {printf(" Condicion AND Comparacion es Condicion\n"); }
		| condicion OR comparacion {printf(" Condicion OR Comparacion es Condicion\n");} 
		| comparacion {printf(" Comparacion es Condicion\n"); }
		;
		
comparacion:
		expresion comparador expresion {printf(" Expresion es Comparador y Expresion\n"); }
		| NOT expresion comparador expresion {printf(" NOT Expresion es Comparador y Expresion\n"); }
		;
		
comparador:
		CO_IGUAL {printf(" == es Comparador\n"); }
		| CO_DIST {printf(" != es Comparador\n"); }
		| CO_MENI {printf(" <= es Comparador\n"); }
		| CO_MEN {printf(" < es Comparador\n"); }
		| CO_MAYI {printf(" >= es Comparador\n"); }
		| CO_MAY {printf(" > es Comparador\n"); }
		;

expresion:
		expresion OP_SUM termino {printf(" Expresion + Termino es Expresion\n"); }
		| expresion OP_RES termino {printf(" Expresion - Termino es Expresion\n"); }
		| termino {printf(" Termino es Expresion\n"); } 
		;
		
termino:
		termino OP_MUL factor {printf(" Termino * Factor es Termino\n"); }
		| termino OP_DIV factor {printf(" Termino / Factor es Termino\n"); }
		| factor {printf(" Factor es Termino\n"); }
		;
		
factor:
		PARA  expresion PARC {printf(" ( Expresion ) es Factor\n"); }
		| ID {printf(" ID es Factor\n"); }
		| CTE_E {printf(" CTE_E es Factor\n"); }
		| CTE_R {printf(" CTE_R es Factor\n"); }
		;
		
zonadec:
		INIT LA declaracion {printf ("INIT { Declaracion es Zonadec\n"); }
		| declaracion {printf (" Declaracion es Zonadec\n"); }
		| declaracion LC {printf (" Declaracion } es Zonadec\n"); }
		;
		
declaracion:
		lista_dec DP tipo {printf(" Lista_Declaracion : Tipo es Declaracion\n"); }
		;

lista_dec:
		lista_dec COMA variable {printf(" Lista_Declaracion , Variable es Lista_Declaracion\n"); }
		| variable {printf(" Variable es Lista_Declaracion\n"); }
		;
		
variable:
		ID { printf(" ID es Variable\n"); } 
		;
		
tipo:
		FLOAT {printf (" FLOAT es Tipo\n"); } 
		| INT {printf (" INT es Tipo\n"); }
		| STRING {printf (" STRING es Tipo\n"); }
		;
		
constante_string:
		CTE_S {printf (" CTE_S es Constante String\n"); }
		;
		
read:
		READ PARA CTE_S PARC { printf("READ CTE_S es Read\n"); }
		| READ PARA CTE_E PARC {printf(" READ CTE_E es Read\n"); }
		| READ PARA ID PARC {printf(" READ ID es Read\n"); }
		| READ PARA CTE_R PARC {printf(" READ CTE_R es Read\n"); }
		;
write:
		WRITE PARA CTE_S PARC { printf("WRITE CTE_S es Write\n"); }
		| WRITE PARA CTE_E PARC {printf(" WRITE CTE_E es Write\n"); }
		| WRITE PARA ID PARC {printf(" WRITE ID es Write\n"); }
		| WRITE PARA CTE_R PARC {printf(" WRITE CTE_R es Write\n"); }
		;
do:
	DO ID dolist ENDDO { printf("DO ID dolist ENDDO es DO\n"); }
	;
	
dolist:
	case { printf("case es Dolist\n"); }
	|dolist default { printf("dolist default es Dolist\n"); }
	|dolist case { printf("dolist case es Dolist\n"); }
	;
	
case:
	CASE comparacion { printf(" CASE comparacion es case\n"); }
	|CASE comparacion sentencia { printf(" CASE comparacion sentencia es case\n"); }
	|CASE comparacion LA programa LC { printf(" CASE comparacion LA Programa LC es case\n"); }
	;
	
default:
	DEFAULT{ printf(" DEFAULT es default\n"); }
	|DEFAULT sentencia { printf(" DEFAULT sentencia es default\n"); }
	|DEFAULT LA programa LC { printf(" DEFAULT LA programa LC es default\n"); }
	;
	
repeat:
	REPEAT CTE_E CORA lista_repeat CORC { printf(" REPEAT CTE_E CORA sentencia CORC es repeat\n"); }
	;

lista_repeat:
	lista_repeat sentencia { printf("lista_repeat sentencia es lista_repeat\n"); }
	|sentencia { printf("sentencia es lista_repeat\n"); }

%%


int main(int argc, char *argv[])
{

    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
       
    }
    else
    { 
        
        yyparse();
        
    }
	
	fclose(yyin);
	crear_TS();
    return 0;
}
int yyerror(void)
{
	printf("Error Sintactico\n");
	exit (1);
}
