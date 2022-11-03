%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
//#include "ts.h"

int yystopparser=0;
FILE  *yyin;
int yyerror();
int yylex();
int crear_TS();
char *buffer;

/* defines */

#define MAX_REGS 1000
#define CADENA_MAXIMA 31
#define TRUE 1
#define FALSE 0
#define ERROR -1
#define OK 3

/* enums */

enum tipoSalto{
	normal,
	inverso
};

enum and_or{
	and,
	or,
	condicionSimple
};

enum tipoDato{
	tipoInt,
	tipoFloat,
	tipoString,
	sinTipo
};

typedef struct
{
	int cont;
	int salto1;
	int salto2;
	int saltoElse;
	int nro;
	enum and_or andOr;
	enum tipoDato tipo;
}t_info;

enum tipoCondicion{
	condicionIf,
	condicionWhile
};

/* structs */

typedef struct {
    char lexeme[50];
    char datatype[50];
    char value[50];
    int length;
} t_symbol_table;

typedef struct
{
	char cadena[CADENA_MAXIMA];
	int nro;
}t_infoPolaca;

typedef struct s_nodoPolaca{
	t_infoPolaca info;
	struct s_nodoPolaca* psig;
}t_nodoPolaca;

typedef t_nodoPolaca *t_polaca;

typedef struct s_nodoPila{
    	t_info info;
    	struct s_nodoPila* psig;
	}t_nodoPila;

typedef t_nodoPila *t_pila;
t_pila pilaIf;
t_pila pilaWhile;
t_pila pilaRepeat;
t_pila pilaDo;

/* funciones */
void guardarPolaca(t_polaca*);
int ponerEnPolacaNro(t_polaca*,int, char *);
int ponerEnPolaca(t_polaca*, char *);
void crearPolaca(t_polaca*);
char* obtenerSalto(enum tipoSalto);

void vaciarPila(t_pila*);
t_info* sacarDePila(t_pila*);
void crearPila(t_pila*);
int ponerEnPila(t_pila*,t_info*);
t_info* topeDePila(t_pila*);

int contadorIf=0;
int contadorWhile=0;
int contadorRepeat=0;
int contadorDo=0;
enum tipoCondicion tipoCondicion;

/* variables globales */


t_polaca polaca;
int contadorPolaca=0;
char ultimoComparador[3];
enum and_or ultimoOperadorLogico;



%}

%union
 {
 char* cadena;
 int numero;
 	char*vals;
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
		programa {guardarPolaca(&polaca);}
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
		ID OP_ASIG expresion { ponerEnPolaca(&polaca,$<vals>1); ponerEnPolaca(&polaca,$<vals>2);}
		| ID OP_ASIG constante_string {ponerEnPolaca(&polaca,$<vals>1); ponerEnPolaca(&polaca,$<vals>2); }
		;

seleccion:
		IF 
			{
				t_info info;
				info.nro=contadorIf++;
				ponerEnPila(&pilaIf,&info);
				tipoCondicion=condicionIf;
			}
		PARA condicion PARC
		bloque_seleccion
		{
			sacarDePila(&pilaIf);
		}
		;

bloque_seleccion: 
	LA programa LC
	{
		char aux[20];
		sprintf(aux, "%d", contadorPolaca);
		
		switch (topeDePila(&pilaIf)->andOr)
		{
		case condicionSimple:
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto1, aux);
			break;
		case and:
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto1, aux);
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto2, aux);
		case or:
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto2, aux);
			break;
		}
	}
	{printf(" IF (Condicion)  {Programa}  es Seleccion\n"); }
	| LA programa LC
	{
		char aux[20];
		ponerEnPolaca(&polaca,"BI");
		topeDePila(&pilaIf)->saltoElse = contadorPolaca;
		ponerEnPolaca(&polaca, "");
		/*if(topeDePila(&pilaIf)->andOr != or){
			sprintf(aux, "%d", contadorPolaca);
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto1, aux);
		}*/
	}
	bloque_else
	{printf(" IF (Condicion)  {Programa} ELSE {Programa}  Es Seleccion\n"); }
	;
	
bloque_else:
	ELSE
	{
		char aux[20];
		sprintf(aux, "%d", contadorPolaca);
		switch (topeDePila(&pilaIf)->andOr)
		{
		case condicionSimple:
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto1, aux);
			break;
		case and:
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto1, aux);
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto2, aux);
		case or:
			ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto2, aux);
			break;
		}
	}
	LA programa LC
	{
	
		char aux[20];
		sprintf(aux, "%d", contadorPolaca);
		ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->saltoElse, aux);
	}
	;

iteracion:
		WHILE
		{
			t_info info;
			info.nro=contadorWhile++;
			info.saltoElse=contadorPolaca;
			ponerEnPila(&pilaWhile,&info);
			tipoCondicion=condicionWhile;
			ponerEnPolaca(&polaca,"ET");
		}
		PARA condicion PARC LA programa LC
		{
			char aux[20];
			sprintf(aux, "%d", topeDePila(&pilaWhile)->saltoElse);
			ponerEnPolaca(&polaca,"BI");
			ponerEnPolaca(&polaca, aux);
			sprintf(aux, "%d", contadorPolaca);
			switch (topeDePila(&pilaWhile)->andOr)
			{
			case condicionSimple:
				ponerEnPolacaNro(&polaca, topeDePila(&pilaWhile)->salto1, aux);
				break;
			case and:
				ponerEnPolacaNro(&polaca, topeDePila(&pilaWhile)->salto1, aux);
				ponerEnPolacaNro(&polaca, topeDePila(&pilaWhile)->salto2, aux);
			case or:
				ponerEnPolacaNro(&polaca, topeDePila(&pilaWhile)->salto2, aux);
				break;
			}
			sacarDePila(&pilaWhile);
		}
		{printf(" WHILE (Condicion) { programa } es Iteracion\n"); }
		;

condicion:
		  comparacion AND
		  	{
				switch(tipoCondicion)
				{
					case condicionIf:
						ponerEnPolaca(&polaca,"CMP");
						ponerEnPolaca(&polaca,obtenerSalto(inverso));
						topeDePila(&pilaIf)->salto1=contadorPolaca;
						ponerEnPolaca(&polaca,"");
						printf("%d", topeDePila(&pilaIf)->salto1);
						topeDePila(&pilaIf)->andOr = and;
						break;

					case condicionWhile:
						ponerEnPolaca(&polaca,"CMP");
						ponerEnPolaca(&polaca,obtenerSalto(inverso));
						topeDePila(&pilaWhile)->salto1=contadorPolaca;
						ponerEnPolaca(&polaca,"");
						topeDePila(&pilaWhile)->andOr = and;
						break;
				}
			}
			comparacion 				
				{
					switch(tipoCondicion)
					{
						case condicionIf:
							ponerEnPolaca(&polaca,"CMP");
							ponerEnPolaca(&polaca,obtenerSalto(inverso));
							topeDePila(&pilaIf)->salto2=contadorPolaca;
							ponerEnPolaca(&polaca,"");
							break;

						case condicionWhile:
							ponerEnPolaca(&polaca,"CMP");
							ponerEnPolaca(&polaca,obtenerSalto(inverso));
							topeDePila(&pilaWhile)->salto2=contadorPolaca;
							ponerEnPolaca(&polaca,"");
							break;
					}
	            } {printf(" Condicion AND Comparacion es Condicion\n"); }
		| comparacion OR
			{
				switch(tipoCondicion)
				{
					case condicionIf:
						ponerEnPolaca(&polaca,"CMP");
						ponerEnPolaca(&polaca,obtenerSalto(normal));
						topeDePila(&pilaIf)->salto1=contadorPolaca;
						ponerEnPolaca(&polaca,"");
						topeDePila(&pilaIf)->andOr = or;
						break;

					case condicionWhile:
						ponerEnPolaca(&polaca,"CMP");
						ponerEnPolaca(&polaca,obtenerSalto(normal));
						topeDePila(&pilaWhile)->salto1=contadorPolaca;
						ponerEnPolaca(&polaca,"");
						topeDePila(&pilaWhile)->andOr = or;
						break;
				}
			}
			comparacion
				{
					char aux[20];
					switch(tipoCondicion)
					{
						case condicionIf:
							ponerEnPolaca(&polaca,"CMP");
							ponerEnPolaca(&polaca,obtenerSalto(inverso));
							topeDePila(&pilaIf)->salto2=contadorPolaca;
							ponerEnPolaca(&polaca,"");
							sprintf(aux, "%d", contadorPolaca);
							ponerEnPolacaNro(&polaca, topeDePila(&pilaIf)->salto1, aux);
							break;

						case condicionWhile:
							ponerEnPolaca(&polaca,"CMP");
							ponerEnPolaca(&polaca,obtenerSalto(inverso));
							topeDePila(&pilaWhile)->salto2=contadorPolaca;
							ponerEnPolaca(&polaca,"");
							sprintf(aux, "%d", contadorPolaca);
							ponerEnPolacaNro(&polaca, topeDePila(&pilaWhile)->salto1, aux);
							break;
					}
	            }			{printf(" Condicion OR Comparacion es Condicion\n");} 
		| comparacion			
			{
				switch(tipoCondicion)
				{
					case condicionIf:
						ponerEnPolaca(&polaca,"CMP");
						ponerEnPolaca(&polaca,obtenerSalto(inverso));
						topeDePila(&pilaIf)->salto1=contadorPolaca;
						ponerEnPolaca(&polaca,"");
						topeDePila(&pilaIf)->andOr = condicionSimple;
						break;

					case condicionWhile:
						ponerEnPolaca(&polaca,"CMP");
						ponerEnPolaca(&polaca,obtenerSalto(inverso));
						topeDePila(&pilaWhile)->salto1=contadorPolaca;
						ponerEnPolaca(&polaca,"");
						topeDePila(&pilaWhile)->andOr = condicionSimple;
						break;
				}
			} {printf(" Comparacion es Condicion\n"); }
		;
		
comparacion:
		expresion comparador expresion {printf(" Expresion es Comparador y Expresion\n"); }
		| NOT expresion comparador expresion {printf(" NOT Expresion es Comparador y Expresion\n"); }
		;
		
comparador:
		CO_IGUAL { strcpy(ultimoComparador,$<vals>1); }  {printf(" == es Comparador\n"); }
		| CO_DIST { strcpy(ultimoComparador,$<vals>1); }  {printf(" != es Comparador\n"); }
		| CO_MENI { strcpy(ultimoComparador,$<vals>1); }  {printf(" <= es Comparador\n"); }
		| CO_MEN { strcpy(ultimoComparador,$<vals>1); } {printf(" < es Comparador\n"); }
		| CO_MAYI { strcpy(ultimoComparador,$<vals>1); }  {printf(" >= es Comparador\n"); }
		| CO_MAY { strcpy(ultimoComparador,$<vals>1); }  {printf(" > es Comparador\n"); }
		;

expresion:
		expresion OP_SUM termino {ponerEnPolaca(&polaca,$<vals>1); }
		| expresion OP_RES termino {ponerEnPolaca(&polaca,$<vals>1); }
		| termino {printf(" Termino es Expresion\n"); } 
		;
		
termino:
		termino OP_MUL factor {ponerEnPolaca(&polaca,$<vals>1); }
		| termino OP_DIV factor {ponerEnPolaca(&polaca,$<vals>1); }
		| factor {printf(" Factor es Termino\n"); }
		;
		
factor:
		PARA  expresion PARC {printf(" ( Expresion ) es Factor\n"); }
		| ID {ponerEnPolaca(&polaca,$<vals>1); }
		| CTE_E {ponerEnPolaca(&polaca,$<vals>1); }
		| CTE_R {ponerEnPolaca(&polaca,$<vals>1); }
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
		CTE_S {ponerEnPolaca(&polaca,$<vals>1);}
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
	DO	
	{
			t_info info;
			info.nro=contadorDo++;
			ponerEnPila(&pilaDo,&info);
			ponerEnPolaca(&polaca,"ET");
			
	} 
	ID dolist ENDDO	
	{
		sacarDePila(&pilaDo);
	}  { printf("DO ID dolist ENDDO es DO\n"); }
	;
	
dolist:
	case	 { printf("case es Dolist\n"); }
	|dolist default { printf("dolist default es Dolist\n"); }
	|dolist case { printf("dolist case es Dolist\n"); }
	;
	
case:
	CASE comparacion	
	{
			ponerEnPolaca(&polaca,"CMP");
			ponerEnPolaca(&polaca,obtenerSalto(inverso));
			char aux[20];
			sprintf(aux, "%d", contadorPolaca+1);
			ponerEnPolaca(&polaca,aux);
			
	} { printf(" CASE comparacion es case\n"); }
	|CASE comparacion	
		{
				ponerEnPolaca(&polaca,"CMP");
				ponerEnPolaca(&polaca,obtenerSalto(inverso));
				topeDePila(&pilaDo)->salto1=contadorPolaca;
				ponerEnPolaca(&polaca,"");
		}
	sentencia 
		{ 
			char aux[20];
			sprintf(aux, "%d", contadorPolaca);
			ponerEnPolacaNro(&polaca, topeDePila(&pilaDo)->salto1, aux); 
		} { printf(" CASE comparacion sentencia es case\n"); }
	|CASE comparacion 		
			{
					ponerEnPolaca(&polaca,"CMP");
					ponerEnPolaca(&polaca,obtenerSalto(inverso));
					topeDePila(&pilaDo)->salto1=contadorPolaca;
					ponerEnPolaca(&polaca,"");
			}
		LA programa LC 
			{ 
				char aux[20];
				sprintf(aux, "%d", contadorPolaca);
				ponerEnPolacaNro(&polaca, topeDePila(&pilaDo)->salto1, aux); 
			} { printf(" CASE comparacion LA Programa LC es case\n"); }
	;
	
default:
	DEFAULT{ printf(" DEFAULT es default\n"); }
	|DEFAULT sentencia { printf(" DEFAULT sentencia es default\n"); }
	|DEFAULT LA programa LC { printf(" DEFAULT LA programa LC es default\n"); }
	;
	
repeat:
	REPEAT CTE_E
	{
			t_info info;
			info.nro=contadorRepeat++;
			info.cont = atoi($<vals>2);
			info.salto1=contadorPolaca;
			ponerEnPolaca(&polaca,"ET");
			ponerEnPolaca(&polaca,"CMP");
			ponerEnPolaca(&polaca,"$CONT_REPEAT");
			ponerEnPolaca(&polaca,"0");
			ponerEnPolaca(&polaca,"BLE");
			info.salto2=contadorPolaca;
			ponerEnPolaca(&polaca,"");
			ponerEnPila(&pilaRepeat,&info);
			
	}
	CORA lista_repeat CORC
	{
		char aux[20];
		sprintf(aux, "%d", topeDePila(&pilaRepeat)->salto1);
		ponerEnPolaca(&polaca,"BI");
		ponerEnPolaca(&polaca, aux);
		sprintf(aux, "%d", contadorPolaca);
		ponerEnPolacaNro(&polaca, topeDePila(&pilaRepeat)->salto2, aux);
		sacarDePila(&pilaRepeat);
		contadorRepeat--;
	}
	{ printf(" REPEAT CTE_E CORA sentencia CORC es repeat\n"); }
	;

lista_repeat:
	lista_repeat sentencia { topeDePila(&pilaRepeat)->cont--; } { printf("lista_repeat sentencia es lista_repeat\n"); }
	|sentencia	{ topeDePila(&pilaRepeat)->cont--; }  { printf("sentencia es lista_repeat\n"); }

%%



/* primitivas de polaca */


void crearPolaca(t_polaca* pp)
{
    *pp=NULL;
}

int ponerEnPolaca(t_polaca* pp, char *cadena)
{
	printf("ponerEnPolaca: cadena %s\n",cadena);
    t_nodoPolaca* pn = (t_nodoPolaca*)malloc(sizeof(t_nodoPolaca));
    if(!pn)
    {
    	printf("\nponerEnPolaca: Error al solicitar memoria\n");
        return ERROR;
    }
    t_nodoPolaca* aux;
    strcpy(pn->info.cadena,cadena);
    pn->info.nro=contadorPolaca++;
    pn->psig=NULL;
    if(!*pp)
    {
    	*pp=pn;
    	return OK;
    }
    else
    {
    	aux=*pp;
    	while(aux->psig)
        	aux=aux->psig;
        aux->psig=pn;
    	return OK;
    }
}

int ponerEnPolacaNro(t_polaca* pp,int pos, char *cadena)
{
	t_nodoPolaca* aux;
	aux=*pp;
    while(aux!=NULL && aux->info.nro<pos)
    {
    	aux=aux->psig;
    }
    if(aux->info.nro==pos)
    {
    	strcpy(aux->info.cadena,cadena);
    	return OK;
    }
    else
    {
    	printf("NO ENCONTRADO\n");
    	return ERROR;
    }
    return ERROR;
}

void guardarPolaca(t_polaca *pp)
{
	int i = 0;
	printf("GUARDANDO POLACA");
	FILE*pt=fopen("intermedia.txt","w+");
	t_nodoPolaca* pn;
	if(!pt)
	{
		printf("Error al crear el archivo intermedio.\n");
		return;
	}
	while(*pp)
    {
        pn=*pp;
		fprintf(pt , "%d - " , i);
        fprintf(pt, "%s\n",pn->info.cadena);
        *pp=(*pp)->psig;
		i++;
        free(pn);
    }
	
	fclose(pt);
}

char* obtenerSalto(enum tipoSalto tipo)
{
	switch(tipo)
	{
		case normal:
			if(strcmp(ultimoComparador,"==")==0)
				return("BEQ");
			if(strcmp(ultimoComparador,">")==0)
				return("BGT");
			if(strcmp(ultimoComparador,"<")==0)
				return("BLT");
			if(strcmp(ultimoComparador,">=")==0)
				return("BGE");
			if(strcmp(ultimoComparador,"<=")==0)
				return("BLE");
			if(strcmp(ultimoComparador,"!=")==0)
				return("BNE");
			break;

		case inverso:
			if(strcmp(ultimoComparador,"==")==0)
				return("BNE");
			if(strcmp(ultimoComparador,">")==0)
				return("BLE");
			if(strcmp(ultimoComparador,"<")==0)
				return("BGE");
			if(strcmp(ultimoComparador,">=")==0)
				return("BLT");
			if(strcmp(ultimoComparador,"<=")==0)
				return("BGT");
			if(strcmp(ultimoComparador,"!=")==0)
				return("BEQ");
			break;
	}
}
// Métodos pila
/* primitivas de pila */

void crearPila(t_pila* pp)
{
    *pp=NULL;
}

int ponerEnPila(t_pila* pp,t_info* info)
{
    t_nodoPila* pn=(t_nodoPila*)malloc(sizeof(t_nodoPila));
    if(!pn)
        return 0;
    pn->info=*info;
    pn->psig=*pp;
    *pp=pn;
    return 1;
}

t_info * sacarDePila(t_pila* pp)
{
	t_info* info = (t_info *) malloc(sizeof(t_info));
    if(!*pp){
    	return NULL;
    }
    *info=(*pp)->info;
    *pp=(*pp)->psig;
    return info;

}

void vaciarPila(t_pila* pp)
{
    t_nodoPila* pn;
    while(*pp)
    {
        pn=*pp;
        *pp=(*pp)->psig;
        free(pn);
    }
}

t_info* topeDePila(t_pila* pila)
{
	return &((*pila)->info);
}


int main(int argc, char *argv[])
{
	crearPila(&pilaIf);
	crearPila(&pilaWhile);
	crearPila(&pilaRepeat);
	crearPila(&pilaDo);
	crearPolaca(&polaca);
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
