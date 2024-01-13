@echo off

echo Create or update German translations file:
pyside6-lupdate ..\src\main.py ..\src\app\database.py ..\src\ui\ -ts ..\src\lang\odm_de.ts -noobsolete