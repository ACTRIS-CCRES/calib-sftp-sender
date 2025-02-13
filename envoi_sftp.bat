@echo off
:: Configuration des paramètres
rem A renseigner
set SERVER=
set USERNAME=
rem si nécessaire
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

REM Création du dossier pour les fichiers transférés si inexistant
if not exist "%ARCHIVE_DIR%" (
    mkdir "%ARCHIVE_DIR%"
)

REM Parcours des fichiers dans le dossier local
for %%F in ("%SOURCE_DIR%\%FILENAME_MASK%") do (
    echo Envoi du fichier %%F ...
	echo sftp -b - %SFTP_COMMAND%:%DEST_DIR%
    (
        echo put "%%F"
        echo bye
    ) | sftp -b - %SFTP_COMMAND%:%DEST_DIR% >> "%LOG_FILE%" 2>&1

    REM Vérification du succès du transfert
    if errorlevel 1 (
        echo Échec de l'envoi de %%~nxF >> "%LOG_FILE%"
    ) else (
        echo Transfert réussi : %%~nxF >> "%LOG_FILE%"
        move "%%F" "%ARCHIVE_DIR%"
    )
)

echo Transfert terminé. Consultez le fichier log ici : %LOG_FILE%
