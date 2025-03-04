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
set SEP=,
rem liste des dossiers séparés par des ',', où trouver les fichiers de données.
set SOURCES_LIST=e:\basta\sirta_TR\,e:\basta\supervisor_alim_fixe\data\L0\12m5\,e:\basta\supervisor_alim_fixe\data\L0\25m\,e:\basta\supervisor_alim_fixe\data\L0\100m_18km\
set DEST_DIR=data
set FILENAME_MASK=*.nc
set LOG_FILE="%SCRIPT_DIR%\sftp_transfer.log"
rem Si SIMUL est vide ou non déclarée, le code s'exécute totalement sinon les actions principales ne sont pas exécutées
set SIMUL=simul

rem pour test. A commenter pour la production
set SOURCES_LIST=%SCRIPT_DIR%\data
set FILENAME_MASK=*.txt

if not exist %CONFIDENTIEL% (
    echo Le fichier %CONFIDENTIEL% n'existe pas
    exit /b 1
)

rem Lecture des données confidentielles
:: usebackq permet d'avoir des espaces dans le nom (chemin) du fichier
for /f "usebackq tokens=1* delims==" %%A in (%CONFIDENTIEL%) do (
    set "%%A=%%B"
)

set SFTP_COMMAND=%USERNAME%@%SERVER%

setlocal enabledelayedexpansion

:: Parcours des dossiers et des fichiers de chaque dossier

:: La syntaxe du for ne permet pas de parcourir une liste
:: dont le séparateur est <> d'un espace. Ici le for permet de
:: découper la liste des dossiers suivant un séparateur choisi
:: et de récupérer le premier élément dans %%D et les autres
:: dans %%E qui devient la nouvelle liste. Le for s'arrête là.
:: Pour traiter la suite de la liste il faut relancer la
:: boucle for sur la liste mise à jour sans son premier élément.
:: La boucle est relancée par le goto :next_folder.
:next_folder
for /f "tokens=1,* delims=%SEP%" %%D IN ("%SOURCES_LIST%") do (
    set SOURCES_LIST="%%E"
    set source_dir=
    if not exist "%%D" (
        if %%D=="" goto :fin
        call :echo_log Le dossier source '%%D' n'existe pas
        source_dir=%%D
    )
    :: boucle sur les fichiers du dossier %source_dir%
    for %%F in ("%%D\%FILENAME_MASK%") do (
        call :echo_log Envoi du fichier %%F ...
        if not defined SIMUL (
            call :echo_log Execution de la commande sftp
            (
                echo put "%%F"
                echo bye
            ) | sftp -b - %SFTP_COMMAND%:%DEST_DIR% >> %LOG_FILE% 2>&1
        ) 
        :: Vérification du succès du transfert
        if errorlevel 1 (
            call :echo_log Echec de l'envoi de '%%~nxF' >> %LOG_FILE%
        ) else (
            call :echo_log Transfert réussi : %%~nxF >> %LOG_FILE%
            set archive_dir="%source_dir%\archives"
            if not exist !archive_dir! if not defined SIMUL mkdir !archive_dir!
            call :echo_log Archivage du fichier %%~nxF dans !archive_dir!
            if not defined SIMUL move "%%F" !archive_dir!
        )
    )
    goto :next_folder
)
:fin

call :echo_log Transfert termine. Consultez le fichier log ici : %LOG_FILE%

endlocal

exit /b 0

:echo_log
echo %*
echo %DATE% %TIME% : %* >> %LOG_FILE%
exit /b