:: Script para windows

flex Lexico.l
bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c -o Primera.exe

Primera.exe Prueba.txt

@echo off
del Primera.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause

