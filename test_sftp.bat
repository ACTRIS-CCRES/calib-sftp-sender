@echo off
:: Configuration des paramètres
rem A renseigner
set SERVER=
set USERNAME=
set PASS=
set SCRIPT_DIR=%cd%
set SOURCE_DIR=e:\basta\sirta_TR\
set DEST_DIR=data
set ARCHIVE_DIR=C:\chemin\vers\archive
set FILENAME_MASK=*.txt
set LOG_FILE=%SCRIPT_DIR%\sftp_transfer.log
set SSH_KEY=

rem pour test. A commenter pour la production
set SOURCE_DIR=%SCRIPT_DIR%\data
set ARCHIVE_DIR=%SCRIPT_DIR%\data\archive

rem set SFTP_COMMAND=-i "%SSH_KEY%" %USERNAME%@%SERVER%
set SFTP_COMMAND=%USERNAME%@%SERVER%

REM Vérification que la clé existe
rem if not exist "%SSH_KEY%" (
rem    echo La clé SSH spécifiée n'existe pas : %SSH_KEY%
rem	echo Elle doit être placée dans le sous-dossier .ssh du répertoire d'accueil de la session en cours
rem    exit /b 1
rem )

if not exist "%SOURCE_DIR%" (
    echo Le dossier source '%SOURCE_DIR%' n'existe pas
	exit /b 1
)

REM Test d'envoi d'un fichier
set FICH_TEST=test.txt

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

echo rm %DEST_DIR%/%FICH_TEST% | sftp -b - %SFTP_COMMAND%

pause
