@echo OFF

rem VERSION INFO
set "Version=V1.0.1"
set "Date=2024-06-05"
rem About this version:
rem - Improved search speed (v1.0.0 attempt was not working).

rem Save the original encoding:
for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
rem Change the encoding (for accented characters):
chcp 1252>nul
rem Enable additional features:
setlocal enableextensions enabledelayedexpansion

rem Adjust the current directory (useful in admin context):
cd /d "%~dp0"

rem Variables for text formatting:
set "Bold=[1m"
set "Normal=[0m"
set "Red=[91m"
set "Green=[92m"
set "RedBackground=[1;41m"
set "RedBackgroundNormal=[41m"
set "GreenBackground=[42;1m"
set "Separator=************************************************************************************************************************"
set "GreenSeparator=%GreenBackground%%Separator%%Normal%"
set "RedSeparator=%RedBackground%%Separator%%Normal%"

rem Variables for finding Library folders:
set "SceneFile=LastSceneManagerSetup.txt"
set "BuildSettingsFile=EditorUserBuildSettings.asset"
set "LibraryFolder=Library"

echo %GreenSeparator%
echo.
echo %Bold% UNITY LIBRARIES CLEANER %Normal%- %Version% (%Date%)
echo  https://github.com/JonathanTremblay/UnityLibrariesCleaner (CC0 license)
echo.
echo %GreenSeparator%
echo.
echo  This script frees up disk space by emptying the Library folders of your Unity projects.
echo  (When you open a project, Unity can rebuild the content of the Library folder.)
echo.
echo  Usage and warnings:
echo  - The .bat file must be placed in a folder that contains one or more Unity projects.
echo  - The script first finds all valid Library folders and then offers Manual or Automatic mode.
echo  - The folder contents are permanently deleted (not placed in the recycle bin).
echo  - The "Library/LastSceneManagerSetup.txt" and "Library/EditorUserBuildSettings.asset" files are preserved 
echo    (these files are keeping the last opened scene of projects and their BuildSettings). 
echo.
echo %GreenSeparator%
echo.
echo  Searching for folders that can be %Bold%emptied%Normal%:

rem Find Library folders containing files to delete:
set /a counter=0

rem Create an array named "folders" to store the folders to process:
set "folders="
set "lastFolder=###"

for /f "tokens=* delims=" %%d in ('dir /ad /b /s "%LibraryFolder%"') do (
    set "currentFolder=%%~d"
	echo "!currentFolder!" | findstr /b "!lastFolder!" >nul && (
        rem currentFolder is in lastFolder, skip it
    ) || (
        rem currentFolder is not in lastFolder, it will be verified
		if exist "%%d\%SceneFile%" (
			cd %%d
			set /a fileCount=0
			for /r %%f in (*) do set /a fileCount+=1
			if !fileCount! geq 3 (
				set "lastFolder=%%~d"
				echo  • %Red%%%~d%Normal%
				rem Add currentFolder to the folders array, then increment the counter:
				set "folders=!folders! "%%~d""
				set /a counter+=1
			)
		)
	)
)

set "foldersToDelete=!folders!"
cd /d "%~dp0"
echo.
if %counter% == 0 goto NOTHING
echo %Normal%%GreenSeparator%
echo.
set "plural="
set "pronoun=this"
if %counter% geq 2 (
	set "plural=s"
	set "pronoun=these"
)

:QUESTION
echo  AVAILABLE MODES:
echo  %Bold%[1]%Normal% - MANUAL (choose for each folder, one by one)
echo   2  - AUTOMATIC (delete all folders)
echo   3  - CANCEL (do not delete anything)
echo.
set /p mode= Which mode do you want to use to delete the contents of %pronoun% folder%plural%? (%Bold%[1]%Normal%, 2, or 3) 

if "%mode%" == "2" (
    echo   2: AUTOMATIC MODE
    echo.
	goto AUTOMATIC
)
if "%mode%" == "3" (
    echo   3: CANCEL MODE
    echo.
	goto STOP
)

rem Default mode:
echo   1: MANUAL MODE
echo.
goto CHOOSE

:CHOOSE
rem For loop to prompt the user for each folder:
set "foldersToDelete="
set /a counter=0
for %%d in (%folders%) do (
	set "DeleteFolder=N"
	set /p "DeleteFolder= Delete the folder %Red%%%~d%Normal% ? (Y/%Bold%[N]%Normal%) "
	if /i "!DeleteFolder!"=="Y" (
		rem echo %%~d will be deleted
		set "foldersToDelete=!foldersToDelete! "%%~d""
		set /a counter+=1
	)
)
echo.

set "plural="
if %counter% geq 2 set "plural=s"
set "number=%counter%"

if %counter% geq 1 goto AUTOMATIC

:NOTHING
echo %RedSeparator%
echo.
echo  %Bold%NOTHING TO CLEAN ^^! %Normal%
echo  No Library folder to empty, so the script is done.
echo.
echo %RedSeparator%
goto END

:STOP
echo %RedSeparator%
echo.
echo  %Bold%INTERRUPTION ^^! %Normal%
echo  Script stopped. No files deleted.
echo.
echo %RedSeparator%
goto END


:AUTOMATIC
echo %GreenSeparator%
echo.
echo  %counter% deletion%plural% to perform (each deletion may take a few seconds...)
echo.
set /a counter = 0
rem Clean the Library folders:
for %%d in (%foldersToDelete%) do (
	if exist "%%~d\%SceneFile%" (
		cd "%%~d"
		set /a fileCount=0
		for /r %%f in (*) do if %%f neq "%%~d\%SceneFile%" set /a fileCount+=1
		if !fileCount! geq 1 (
			cd /d "%~dp0"
			if exist "%%~d\%SceneFile%" (
				rem Backup the last opened scene file:
				mkdir "%%~d_Temp"
				move "%%~d\%SceneFile%" "%%~d_Temp" >nul
				
				rem Also check and copy BuildSettingsFile if it exists:
				if exist "%%~d\%BuildSettingsFile%" (
					copy "%%~d\%BuildSettingsFile%" "%%~d_Temp" >nul
				)
			)
			rd /s /q "%%~d"
			rem The following condition moves the file or renames the temp folder
			if exist "%%~d_Temp" (
				if exist "%%~d" (
					move "%%~d_Temp\%SceneFile%" "%%~d" >nul
					rd /s /q "%%~d_Temp"
				) else ( ren "%%~d_Temp" %LibraryFolder%)
			)
			echo %Red% %%~d%Normal% has been emptied
			set /a counter+=1
		)
	)
)
echo.
echo %GreenSeparator%
echo.
set "plural="
if %counter% geq 2 set "plural=S"
echo  %Bold%SUCCESS: %counter% FOLDER%plural% EMPTIED %Normal%
echo  Thank you for using Unity Libraries Cleaner ^^!
echo.
echo %GreenSeparator%

:END
echo.
chcp %cp%>nul
pause
