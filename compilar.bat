:: Script para windows

flex Lexico.l

gcc.exe lex.yy.c -o Primera.exe

Primera.exe Prueba.txt

@echo off
del Primera.exe
del lex.yy.c

pause

