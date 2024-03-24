@echo off

echo Create output folder if it doesn't exist yet
set "folder_path=..\src\lang\build"
if not exist "%folder_path%" (
  mkdir "%folder_path%"
)

echo Compile German translations:
pyside6-lrelease ..\src\lang\de_DE.ts -qm ..\src\lang\build\de_DE.qm