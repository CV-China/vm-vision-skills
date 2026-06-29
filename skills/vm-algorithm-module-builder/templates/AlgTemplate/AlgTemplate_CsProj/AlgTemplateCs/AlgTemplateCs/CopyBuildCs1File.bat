@echo off
echo ---------------------------------
rem 获取模块名称
echo %~dp0
cd /d %~dp0
for %%i in (%cd%) do set prjName=%%~ni
echo prjName:%prjName%
set moduName=%prjName:~0,-2%
echo moduName:%moduName%

cd..
cd..
cd..

set xmlpath=%cd%\%moduName%\
echo xmlPath:%xmlpath%

if not exist "%xmlpath%" mkdir "%xmlpath%"

echo xcopy "%~dp0bin\Release\%prjName%.dll" "%xmlpath%" /y /i
xcopy "%~dp0bin\Release\%prjName%.dll" "%xmlpath%" /y /i

echo xcopy "%~dp0bin\Release\%prjName%.pdb" "%xmlpath%" /y /i
xcopy "%~dp0bin\Release\%prjName%.pdb" "%xmlpath%" /y /i
@echo ---------------------------------
rem 不要加 pause —— PostBuildEvent 是 MSBuild 非交互子进程,pause 会让 VS IDE 编译卡死
exit /b 0 