@echo off

:: Configuration des paramètres
rem Informations se trouvant dans le fichier confidentiel.txt
rem chaque ligne du fichier a la forme : variable=valeur
set SERVER=
set USERNAME=
rem	Doit être placée dans le sous-dossier .ssh\ du répertoire d'accueil de la session en cours
set SSH_KEY=
::
set SCRIPT_DIR=%cd%
set CONFIDENTIEL="%SCRIPT_DIR%\confidentiel.txt"
set SOURCE_DIR="%SCRIPT_DIR%\data"
set DEST_DIR=data

if not exist %CONFIDENTIEL% (
    echo Le fichier %CONFIDENTIEL% n'existe pas
    exit /b 1
)

rem Lecture des données confidentielles
:: usebackq permet d'avoir des espaces dans le nom (chemin) du fichier
for /f "usebackq tokens=1,* delims==" %%A in (%CONFIDENTIEL%) do (
    set "%%A=%%B"
)

set SFTP_COMMAND=%USERNAME%@%SERVER%

setlocal enabledelayedexpansion

if not exist %SOURCE_DIR% (
    echo Le dossier source '%SOURCE_DIR%' n'existe pas
	exit /b 1
)

REM Test d'envoi d'un fichier
set NOM_FICH_TEST=test.txt
set FICH_TEST=%SOURCE_DIR%\%NOM_FICH_TEST%

echo Contenu > %FICH_TEST%
echo Envoi du fichier %FICH_TEST% ...
echo sftp -b - %SFTP_COMMAND%:%DEST_DIR%

(
    echo put %FICH_TEST%
    echo bye
) | sftp -b - %SFTP_COMMAND%:%DEST_DIR%

REM Vérification du succès du transfert
if errorlevel 1 (
    echo Echec de l'envoi
) else (
    echo Transfert reussi
)

del %FICH_TEST%
echo rm %DEST_DIR%/%NOM_FICH_TEST% | sftp -b - %SFTP_COMMAND%

pause
