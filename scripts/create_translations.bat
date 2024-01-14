@echo off

echo Create or update German translations file:
pyside6-lupdate ..\src\main.py ..\src\app\database.py ..\src\app\settings.py ..\src\ui\ -ts ..\src\lang\de_DE.ts -noobsolete