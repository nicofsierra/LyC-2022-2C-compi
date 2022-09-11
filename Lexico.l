%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include "y.tab.h"

/*struct struct_tablaSimbolos{
	char nombre[100];
	char tipo[100];
	char valor[50];
	int longitud;
};

int guardar_TS( char*, char*);
int crear_TS();
int contarChar( char* a );
int puntero_array = 0;

char* str_cpy(char* destino, const char* origen);
int str_cmp(const char * str1, const char * str2);

struct struct_tablaSimbolos tablaSimbolos[1000];*/

FILE  *yyin;
int yylval;
char *yyltext;

int yyerror(void);
/*int eval_int( char *n );
int eval_float( char *n );
int eval_string( char *s );*/


%}

%option noyywrap  
%option yylineno 

CORA			"["
CORC			"]"

DIGITO			[0-9]
LETRA			[aA-zZ]
SIMBOLO			[:>!]
A_COMENTARIO	"/*"
C_COMENTARIO	"*/"

CTE_E	        ("-")*{DIGITO}+
CTE_R			("-")*{DIGITO}*"."{DIGITO}*
ID				{LETRA}({LETRA}|{DIGITO}|_)*
CTE_S 			"\""({LETRA}|{DIGITO}|{SIMBOLO}|.)+"\""
COMENTARIO		{A_COMENTARIO}({LETRA}|{DIGITO}|.)+{C_COMENTARIO}
DP				":"
PC				";"
OP_ASIG   		"="
OP_SUM		    "+"
OP_MUL          "*"
OP_RES		    "-"
OP_DIV          "/"
COMA			","
LA              "{"
LC				"}"
PARA			"("
PARC			")"
PUNTO			"."
AND 			"&"
OR				"||"
CO_IGUAL		"=="
CO_DIST			"!="
CO_MENI			"<="
CO_MEN			"<"
CO_MAYI			">="
CO_MAY			">"
INIT			"init"
INT				"Int"
FLOAT			"Float"
STRING			"String"
IF				"if"
ELSE			"else"
WHILE			"while"
READ			"read"
WRITE			"write"
DO				"DO"
CASE			"CASE"	
DEFAULT			"DEFAULT"
ENDDO			"ENDDO"
REPEAT			"REPEAT"

%%

{CORA}          {printf("\nCorAbre: %s", yytext);}/*return CORA;}*/
{CORC}			{printf("\nCorCierra: %s", yytext);}/*return CORC;}*/

{INIT}			{printf("\nP_Reservada_INIT: %s", yytext);}/*return INIT; }	*/
{INT}			{printf("\nP_Reservada_INT: %s", yytext);}/*return INT; }	*/											
{FLOAT}			{printf("\nP_Reservada_FLOAT: %s", yytext);}/*return FLOAT;}*/
{STRING}		{printf("\nP_Reservada_STRING: %s", yytext);}/*return STRING;}*/
{IF}			{printf("\nP_Reservada_IF: %s", yytext);}/*return IF;}*/
{ELSE}			{printf("\nP_Reservada_ELSE: %s", yytext);}/*return ELSE;}*/
{WHILE}			{printf("\nP_Reservada_WHILE: %s", yytext);}/*return WHILE;}*/
{READ}			{printf("\nP_Reservada_READ: %s", yytext);}/*return READ;}*/
{WRITE}			{printf("\nP_Reservada_WRITE: %s", yytext);}/*return WRITE;}*/
{DO}			{printf("\nP_Reservada_DO: %s", yytext);}/*return DO;}*/
{CASE}			{printf("\nP_Reservada_CASE: %s", yytext);}/*return CASE;}	*/
{DEFAULT}		{printf("\nP_Reservada_DEFAULT: %s", yytext);}/*return DEFAULT;}*/
{ENDDO}			{printf("\nP_Reservada_ENDDO: %s", yytext);}/*return ENDDO;}*/
{REPEAT}		{printf("\nP_Reservada_REPEAT: %s", yytext);}/*return REPEAT;}*/



{CTE_E}			{printf("\nConstEntera: %s", yytext); }/*guardar_TS("CTE_E", yytext); eval_int(yytext);} return CTE_E;}*/ 
{CTE_R}			{printf("\nConstReal: %s", yytext); }/*guardar_TS("CTE_R", yytext); eval_float(yytext);} return CTE_R;} */
{ID}			{printf("\nIdentificador: %s", yytext); }/*guardar_TS("ID", yytext);} return ID;}*/
{CTE_S} 		{printf("\nConstString: %s", yytext); }/*guardar_TS("CTE_S", yytext); eval_string(yytext);} return CTE_S;} */
{COMENTARIO}
{DP}			{printf("\nDosPuntos: %s", yytext);}/*return DP;}*/
{PC}			{printf("\nPuntoComa: %s", yytext);}/*return PC;}*/
{OP_SUM}		{printf("\nSuma: %s", yytext);}/*return OP_SUM;}*/
{OP_ASIG}		{printf("\nAsignacion: %s", yytext);}/*return OP_ASIG;}*/
{OP_MUL}		{printf("\nMultiplicacion: %s", yytext);}/*return OP_MUL;}*/
{OP_RES}		{printf("\nResta: %s", yytext);}/*return OP_RES;}*/
{OP_DIV}		{printf("\nDivision: %s", yytext);}/*return OP_DIV;}*/
{COMA}			{printf("\nComa: %s", yytext);}/*return COMA;}*/
{LA}            {printf("\nLlAbre: %s", yytext);}/*return LA;}*/
{LC}			{printf("\nLlCierra: %s", yytext);}/*return LC;}*/
{PARA}			{printf("\nParAbre: %s", yytext);}/*return PARA;}*/
{PARC}			{printf("\nParCierra: %s", yytext);}/*return PARC;}*/
{PUNTO}			{printf("\nPunto: %s", yytext);}/*return PUNTO;}*/
{AND}			{printf("\nAnd: %s", yytext);}/*return AND;}*/
{OR}			{printf("\nOr: %s", yytext);}/*return OR;}*/
{CO_IGUAL}		{printf("\nIgual: %s", yytext);}/*return CO_IGUAL;}*/
{CO_DIST}		{printf("\nNoIgual: %s", yytext);}/*return CO_DIST;}*/
{CO_MENI}		{printf("\nMenIgual: %s", yytext);}/*return CO_MENI;}*/
{CO_MEN}		{printf("\nMenor: %s", yytext);}/*return CO_MEN;}*/
{CO_MAYI}		{printf("\nMayIgual: %s", yytext);}/*return CO_MAYI;}*/
{CO_MAY}		{printf("\nMayor: %s", yytext);}/*return CO_MAY;}*/


"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
"@"			 { printf( "\nERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}
.			 { printf( "\nERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%

int main(int argc,char *argv[])
{
	
	if ((yyin = fopen(argv[1], "r")) == NULL)
	{
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	else
	{
		yylex();
	}
	
	fclose(yyin);

}
/*
int eval_int( char* n ){
	int entero = atoi(n);
	if( entero  < -65535 || entero > 65535 ){
		printf( "\nERROR LEXICO : Rango entero Invalido (16 bits): %s\n", yytext ); 
		exit (0);
	}
	return 0;
}
int eval_float( char* n ){
	char *ptr;
	long ret;
	ret = strtol(n, &ptr,10);	
	long cota_i = 2147483648*(-1);
	long cota_s = 2147483647;
	if( ret  <= cota_i || ret >= cota_s ){
		printf( "\nERROR LEXICO : Rango reales Invalido (32 bits): %s\n", yytext ); 
		exit (0);
	} 
	return 0;
}

int eval_string( char* s ){
	int cadena = strlen(s);
	if( cadena > 30 ){
		printf( "\nERROR LEXICO : Longitud String Invalido ( 30 caracteres ): %s\n", yytext ); exit (0);}
	return 0;
}

int guardar_TS(char* tipo, char* nombre){
	
	int i;
	int retornar;
	char *buffer;
	for(i = 0; i < puntero_array; i++){
		if(str_cmp(tablaSimbolos[i].nombre, nombre) == 0){
			return i;
		}
	}
	str_cpy(tablaSimbolos[puntero_array].tipo, tipo);
	str_cpy(tablaSimbolos[puntero_array].nombre, nombre);
	str_cpy(tablaSimbolos[puntero_array].valor, "");
	if(tipo == "CTE_S"){
		int longitud = strlen(nombre);
		printf("\nLongitud: %d", longitud);
		tablaSimbolos[puntero_array].longitud = longitud;
	}
	retornar = puntero_array;
	puntero_array++;
	return retornar;
}

int crear_TS(){
	FILE *pf; 
	int i;
	pf = fopen("ts.txt","w"); 

	if (!pf){
		return 0;
	}

	fprintf(pf, "%-32s|\t%-15s|\t%-32s|\t%-13s\n\n","ID", "Nombre","Tipo","Valor","Longitud");
	for (i = 0; i < puntero_array; i++){
		if (str_cmp(tablaSimbolos[i].tipo, "ID") == 0 || str_cmp(tablaSimbolos[i].tipo, "CTE_E") == 0 || 
			str_cmp(tablaSimbolos[i].tipo, "CTE_R") == 0 || str_cmp(tablaSimbolos[i].tipo, "CTE_S") == 0){  
			fprintf(pf, "%-32s|\t%-15s|\t%-32s|\t%-13d\n\n", tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
		}
		else{ 
			fprintf(pf, "_%-32s|\t%-15s|\t%-32s|\t%-13d\n\n",tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
		}
	}
	fclose(pf); 
	
	return 1;
}

char* str_cpy(char* destino, const char* origen)
{
    
    if (destino == NULL) {
        return NULL;
    }
    
    char *ptr = destino;
    
    while (*origen != '\0')
    {
        *destino = *origen;
        destino++;
        origen++;
    }
    
    *destino = '\0';
    
    return ptr;
}

int str_cmp(const char * str1, const char * str2)
{
	while (*str1 == *str2) {
		if (*str1 == '\0' || *str2 == '\0')
			break;
		str1++;
		str2++;
	}
	if (*str1 == '\0' && *str2 == '\0')
      return 0;
   	else
      return -1;
}

int contarChar( char* a ){
	int i, cont = 0;
	for( i = 0 ; i < 32 ; i++ ){	
		if( a[i] != '\n' )
			cont++;
	}
	return cont;
}*/