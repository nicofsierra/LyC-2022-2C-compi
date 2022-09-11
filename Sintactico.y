%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "arbol.h"
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
%token DECVAR
%token ENDDEC
%token INT
%token FLOAT
%token STRING
%token READ
%token WRITE
%token AVG
%token INLIST

%%
start:
		programa { Stp = Pp; exportar(Stp); }
;
programa:
		sentencia {printf(" Sentencia es Programa\n"); Pp = crearNodo( ";" , Pp, Sp); } 
		| programa sentencia {printf( " Programa y Sentencia es Programa\n"); Pp = crearNodo( ";" , Pp, Sp); }
		;
		
sentencia:
		asignacion	{ printf(" Asignacion es Sentencia\n");  Sp = Ap; /*exportar( Sp ); */}
		| iteracion { printf(" Iteracion es Sentencia\n"); }
		| seleccion { printf(" Seleccion es Sentencia\n"); }
		| zonadec { printf(" Zona Declaracion es Sentencia\n"); Sp = Zp; /*exportar( Sp );*/ }
		| read { printf("Read es Sentencia\n"); Sp = Rp; exportar( Sp ); }
		| write { printf("Write es Sentencia\n"); Sp = Wp; exportar( Sp ); }
		;

asignacion:
		ID OP_ASIG expresion {printf(" ID := Expresion es Asignacion\n");  Ap = crearNodo(":=" , crearHoja("ID") , Ep); }
		| ID OP_ASIG constante_string {printf(" ID := Constante String es Asignacion\n"); Ap = crearNodo(":=",crearHoja("ID"),CSp);}
		| ID OP_ASIG promedio {printf(" ID := AVG es Asignacion\n");}
		;

seleccion:
		IF PARA condicion PARC THEN LA programa LC { _THEN = Pp; } ELSE LA programa LC {_IF = crearNodo("C",_THEN,Pp);  selp = crearNodo("IF",Condp,_IF); } ENDIF{printf(" IF (Condicion) THEN {Programa} ELSE {Programa} ENDIF Es Seleccion\n"); }
		| IF PARA condicion PARC THEN LA programa LC { _THEN = Pp; } ENDIF {printf(" IF (Condicion) THEN {Programa} ENDIF es Seleccion\n"); }
		;

iteracion:
		WHILE PARA condicion PARC LA programa LC {printf(" WHILE (Condicion) { programa } es Iteracion\n"); }
		;

condicion:
		  condicion AND comparacion {printf(" Condicion AND Comparacion es Condicion\n"); Condp = crearNodo("AND",Condp,Compp); }
		| condicion OR comparacion {printf(" Condicion OR Comparacion es Condicion\n"); Condp = crearNodo("OR",Condp,Compp); }
		| inlist {printf(" INLIST es Condicion\n"); }
		| comparacion {printf(" Comparacion es Condicion\n"); Condp = Compp;}
		;
		
comparacion:
		expresion comparador expresion {printf(" Expresion es Comparador y Expresion\n"); Compp = crearNodo( OPCompp->dato , Ep , Ep ); }
		;
		
comparador:
		CO_IGUAL {printf(" == es Comparador\n"); OPCompp = crearHoja("==");}
		| CO_DIST {printf(" != es Comparador\n"); OPCompp = crearHoja("!=");}
		| CO_MENI {printf(" <= es Comparador\n"); OPCompp = crearHoja("<=");}
		| CO_MEN {printf(" < es Comparador\n"); OPCompp = crearHoja("<");}
		| CO_MAYI {printf(" >= es Comparador\n"); OPCompp = crearHoja(">=");}
		| CO_MAY {printf(" > es Comparador\n"); OPCompp = crearHoja(">");}
		;

expresion:
		expresion OP_SUM termino {printf(" Expresion + Termino es Expresion\n"); Ep = crearNodo("+",Ep,Tp);}
		| expresion OP_RES termino {printf(" Expresion - Termino es Expresion\n");  Ep = crearNodo("-",Ep,Tp); }
		| termino {printf(" Termino es Expresion\n");  Ep = Tp; } 
		;
		
termino:
		termino OP_MUL factor {printf(" Termino * Factor es Termino\n"); Tp = crearNodo("*",Tp,Fp); }
		| termino OP_DIV factor {printf(" Termino / Factor es Termino\n");  Tp = crearNodo("/",Tp,Fp); }
		| factor {printf(" Factor es Termino\n");  Tp = Fp; }
		;
		
factor:
		PARA  expresion PARC {printf(" ( Expresion ) es Factor\n"); Fp = Ep; }
		| ID {printf(" ID es Factor\n"); Fp = crearHoja("ID"); }
		| CTE_E {printf(" CTE_E es Factor\n"); Fp = crearHoja("CTE_E");}
		| CTE_R {printf(" CTE_R es Factor\n"); Fp = crearHoja("CTE_R");}
		| promedio {printf(" Promedio es Factor\n"); }
		;
		
zonadec:
		DECVAR  declaracion {printf (" DECVAR Declaracion es Zonadec\n"); Zp = Dp; }
		| declaracion {printf (" Declaracion es Zonadec\n"); Zp = Dp; }
		| declaracion {Zp = Dp; } ENDDEC {printf (" Declaracion ENDDEC es Zonadec\n"); }
		;
		
declaracion:
		lista_dec DP tipo {printf(" Lista_Declaracion : Tipo es Declaracion\n"); Dp = crearNodo(":",LDp,TPp ); }
		;

lista_dec:
		lista_dec COMA variable {printf(" Lista_Declaracion , Variable es Lista_Declaracion\n"); LDp = crearNodo(",",LDp,Vp); }
		| variable {printf(" Variable es Lista_Declaracion\n"); LDp = Vp ; }
		;
		
variable:
		ID { printf(" ID es Variable\n"); printf("%s",$$); Vp = crearHoja($$);} 
		;
		
tipo:
		FLOAT {printf (" FLOAT es Tipo\n"); TPp = crearHoja("FLOAT");} 
		| INT {printf (" INT es Tipo\n"); TPp = crearHoja("INT");}
		| STRING {printf (" STRING es Tipo\n"); TPp = crearHoja("STRING");}
		;
		
constante_string:
		CTE_S {printf (" CTE_S es Constante String\n"); CSp = crearHoja("CTE_S");}
		;

promedio: 
		AVG PARA CORA lista_avg CORC PARC {printf("AVG ( [Lista_Avg] es AVG )\n");}
		;
lista_avg:
		lista_avg COMA expresion {printf("Lista_Avg , Expresion es Lista_Avg\n");}
		| expresion {printf("Expresion es Lista_Avg\n");}
		;
		
inlist:
		INLIST PARA ID PC CORA lista_inlist CORC PARC { printf( "INLIST ( id , [lista_inlist] ) es INLIST\n"); }
		;

lista_inlist:
		lista_inlist PC expresion { printf( "Lista_Inlist ; Expresion es Lista_Inlist\n"); }
		| expresion
		;
		
read:
		READ CTE_S { printf("READ CTE_S es Read\n"); Rp = crearHoja("CTE_S");}
		| READ CTE_E {printf(" READ CTE_E es Read\n"); Rp = crearHoja("CTE_E");}
		| READ ID {printf(" READ ID es Read\n"); Rp = crearHoja("ID");}
		| READ CTE_R {printf(" READ CTE_R es Read\n"); Rp = crearHoja("CTE_R"); }
		;
write:
		WRITE CTE_S { printf("WRITE CTE_S es Write\n"); Wp = crearHoja("CTE_S");}
		| WRITE CTE_E {printf(" WRITE CTE_E es Write\n"); Wp = crearHoja("CTE_E");}
		| WRITE ID {printf(" WRITE ID es Write\n"); Wp = crearHoja("ID");}
		| WRITE CTE_R {printf(" WRITE CTE_R es Write\n"); Wp = crearHoja("CTE_R");}
		;
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
