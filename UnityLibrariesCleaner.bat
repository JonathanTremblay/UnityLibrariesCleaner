@echo OFF

rem VERSION INFO
set "Version=V1.0.3"
set "Date=2024-11-22"
rem About this version:
rem - Added total folder path length validation to prevent processing errors.
rem - Added folder numbering to make the script easier to use.
rem - Added a note about exclamation marks in paths.

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
set "Yellow=[93m"
set "Green=[92m"
set "RedBackground=[1;41m"
set "YellowBackground=[1;43m"
set "GreenBackground=[42;1m"
set "Separator=************************************************************************************************************************"
set "GreenSeparator=%GreenBackground%%Separator%%Normal%"
set "RedSeparator=%RedBackground%%Separator%%Normal%"
set "YellowSeparator=%YellowBackground%%Separator%%Normal%"
set /a maxPathLength=256
set /a maxTotalPathLength=8192

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
echo  - The script cannot process paths if they contain exclamation marks.
echo.
echo %GreenSeparator%
echo.
echo  Searching for folders that can be %Bold%emptied%Normal%:

rem Find Library folders containing files to delete:
set /a counter=0

rem Find Library folders with invalid paths:
set /a impossibleCounter=0

rem Create an array named "folders" to store the folders to process:
set "folders="
set "impossibleFolders="
set "lastFolder=###"
set /a lastLength=0
set /a currentTotalLength=0

for /f "tokens=* delims=" %%d in ('dir /ad /b /s "%LibraryFolder%"') do (
    set "currentFolder=%%~d"
	call set "currentFolderSub=%%currentFolder:~0,!lastLength!%%
	if "!currentFolderSub!" equ "!lastFolder!" (
		rem currentFolder is in lastFolder, skip it
	) else (
        rem currentFolder is not in lastFolder, it will be verified
		set "folderPath=%%~d"
		set "s=#!folderPath!"
		set "currentLength=0"
		for %%N in (1024 512 256 128 64 32 16 8 4 2 1) do (
			if "!s:~%%N,1!" neq "" (
				set /a "currentLength+=%%N"
				set "s=!s:~%%N!"
			)
		)
		rem adding characters to take into account a space and quotes:
		set /a "currentLength+=3"
		if exist "%%d\%SceneFile%" (
			cd %%d
			set /a fileCount=0
			for /r %%f in (*) do set /a fileCount+=1
			if !fileCount! geq 3 (
				if !currentLength! gtr !maxPathLength! (
					set "impossibleFolders=!impossibleFolders! "%%~d""
					set /a impossibleCounter+=1
				) else (
					set /a currentTotalLength += currentLength
					if !currentTotalLength! gtr !maxTotalPathLength! (
						echo %Red% There is at least one more folder, but the maximum total path length has been reached.
						echo %Yellow% Please delete the identified folders, and rerun the script to delete the remaining ones. %Normal%
						goto :QUESTION
					) else (
						set "lastFolder=%%~d"
						set /a lastLength=currentLength-3
						set /a counter+=1
						echo  !counter!: %Yellow%%%~d%Normal%
						rem Add currentFolder to the folders array:
						set "folders=!folders! "%%~d""
					)
				)
			)
		)
	)
)

:QUESTION
set "foldersToDelete=!folders!"
cd /d "%~dp0"
echo.
if %counter% == 0 goto :NOTHING
echo %Normal%%GreenSeparator%
echo.
set "plural="
set "pronoun=this"
if %counter% geq 2 (
	set "plural=s"
	set "pronoun=these %counter%"
)
echo  AVAILABLE MODES:
echo  %Bold%[1]%Normal% - MANUAL (choose for each folder, one by one)
echo   2  - AUTOMATIC (delete all folders)
echo   3  - CANCEL (do not delete anything)
echo.
set /p mode= Which mode do you want to use to delete the contents of %pronoun% folder%plural%? (%Bold%[1]%Normal%, 2, or 3) 

if "%mode%" == "2" (
    echo   2: AUTOMATIC MODE
    echo.
	goto :AUTOMATIC
)
if "%mode%" == "3" (
    echo   3: CANCEL MODE
    echo.
	goto :STOP
)

rem Default mode:
echo   1: MANUAL MODE
echo.
goto :CHOOSE

:CHOOSE
rem For loop to prompt the user for each folder:
set "foldersToDelete="
set /a total=counter
set /a counter=0
set /a displayCounter=0
for %%d in (%folders%) do (
	set "DeleteFolder=N"
	set /a displayCounter+=1
	set /p "DeleteFolder= !displayCounter!/%total% Delete the folder %Yellow%%%~d%Normal% ? (Y/%Bold%[N]%Normal%) "
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

if %counter% geq 1 goto :AUTOMATIC

:NOTHING
echo %GreenSeparator%
echo.
echo  %Bold%NOTHING TO CLEAN ^^! %Normal%
echo  No Library folder to empty, so the script is done.
echo.
echo %GreenSeparator%
goto :ENDCHECK

:STOP
echo %YellowSeparator%
echo.
echo  %Bold%INTERRUPTION ^^! %Normal%
echo  Script stopped. No files deleted.
echo.
echo %YellowSeparator%
goto :ENDCHECK

:AUTOMATIC
echo %GreenSeparator%
echo.
echo  %counter% deletion%plural% to perform (each deletion may take a few seconds...)
echo.
set /a total=counter
set /a counter=0
rem Clean the Library folders:
for %%d in (%foldersToDelete%) do (
	if exist "%%~d\%SceneFile%" (
		cd "%%~d"
		set /a fileCount=0
		for /r %%f in (*) do if %%f neq "%%~d\%SceneFile%" set /a fileCount+=1
		if !fileCount! geq 1 (
			cd /d "%~dp0"
			if exist "%%~d\%SceneFile%" (
				rem Create a temp folder to backup the desired files:
				mkdir "%%~d_T"
				rem Move the file to the temp folder:
				move "%%~d\%SceneFile%" "%%~d_T" >nul
				rem Also check if BuildSettingsFile exists:
				if exist "%%~d\%BuildSettingsFile%" (
					rem Move the file to the temp folder:
					move "%%~d\%BuildSettingsFile%" "%%~d_T" >nul
				)
			)
			rd /s /q "%%~d"
			rem The following condition moves the file or renames the temp folder
			if exist "%%~d_T" (
				if exist "%%~d" (
					for %%f in ("%%~d_T\*.*") do move "%%f" "%%~d" >nul
					rd /s /q "%%~d_T"
				) else ( ren "%%~d_T" %LibraryFolder%)
			)
			set /a counter+=1
			echo  !counter!/%total% %Yellow% %%~d%Normal% has been emptied
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

:ENDCHECK
if %impossibleCounter% equ 0 goto :END
timeout 2
set "plural="
set "pronoun=it"
set "pronoun2=it"
set "verb=has"
set "verb2=is"
if %impossibleCounter% geq 2 (
	set "plural=s"
	set "pronoun=they"
	set "pronoun2=them"
	set "verb=have"
	set "verb2=are"
)
echo.
echo %RedSeparator%
echo.
echo  %Bold%WARNING ^^! %Normal%
echo  The following folder path%plural% %verb% been detected but %verb2% exceeding %maxPathLength% characters, so %pronoun% cannot be deleted.
echo  To resolve this issue, move or rename %pronoun2%. Then run the script again^^!
for %%d in (%impossibleFolders%) do echo  • %Red%%%~d%Normal%
echo.
echo %RedSeparator%

:END
echo.
chcp %cp%>nul
pause
