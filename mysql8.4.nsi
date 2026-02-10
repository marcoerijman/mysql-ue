!include "LogicLib.nsh"

Name "MySQL 8.4.8 Setup"
OutFile "Instalador_MySQL_Final.exe"
RequestExecutionLevel admin
Unicode True

; Usamos !define para constantes globales
!define BIN_DIR "$PROGRAMFILES64\MySQL\MySQL Server 8.4\bin"
!define SERVICE_NAME "MySQL"

Section "Install"
    ; Obtener ProgramData dinámicamente
    ReadEnvStr $0 "ProgramData"

    ; Variables para rutas de configuración
    Var /GLOBAL CONF_DIR
    Var /GLOBAL DATA_DIR
    StrCpy $CONF_DIR "$0\MySQL\MySQL Server 8.4"
    StrCpy $DATA_DIR "$0\MySQL\MySQL Server 8.4\Data"

    DetailPrint "1. Instalando dependencias y MSI..."
    SetOutPath "$PLUGINSDIR"
    File "vcredist_x64.exe"
    ExecWait '"$PLUGINSDIR\vcredist_x64.exe" /quiet /norestart'

    File "mysql-8.4.8-winx64.msi"
    ExecWait 'msiexec.exe /i "$PLUGINSDIR\mysql-8.4.8-winx64.msi" /qn /norestart'

    DetailPrint "2. Limpieza de instalaciones previas..."
    nsExec::Exec 'net stop ${SERVICE_NAME}'
    nsExec::Exec 'sc delete ${SERVICE_NAME}'
    Sleep 2000

    DetailPrint "3. Creando directorios..."
    CreateDirectory "$CONF_DIR"
    CreateDirectory "$DATA_DIR"

    DetailPrint "4. Generando archivo my.ini..."
    FileOpen $1 "$CONF_DIR\my.ini" w
    FileWrite $1 "[mysqld]$\r$\n"
    FileWrite $1 "port=3306$\r$\n"
    ; Importante: MySQL prefiere "/" en las rutas del .ini
    FileWrite $1 "datadir=$0/MySQL/MySQL Server 8.4/Data$\r$\n"
    FileWrite $1 "bind-address=0.0.0.0$\r$\n"
    FileWrite $1 "character-set-server=utf8mb4$\r$\n"
    FileClose $1

    DetailPrint "5. Inicializando motor de base de datos..."
    SetOutPath "${BIN_DIR}"
    nsExec::ExecToLog '"${BIN_DIR}\mysqld.exe" --defaults-file="$CONF_DIR\my.ini" --initialize-insecure --console'

    DetailPrint "6. Registrando Servicio de Windows..."
    ; Registramos el servicio vinculado al my.ini
    nsExec::ExecToLog '"${BIN_DIR}\mysqld.exe" --install ${SERVICE_NAME} --defaults-file="$CONF_DIR\my.ini"'

    DetailPrint "7. Iniciando Servicio..."
    nsExec::Exec 'net start ${SERVICE_NAME}'

    DetailPrint "8. Configurando Firewall..."
    nsExec::Exec 'netsh advfirewall firewall add rule name="MySQL Port 3306" dir=in action=allow protocol=TCP localport=3306'

    Sleep 5000
    nsExec::Exec '"${BIN_DIR}\mysqladmin.exe" -u root password root'

    ; Verificación final
    IfFileExists "$DATA_DIR\ibdata1" success failed

failed:
    MessageBox MB_OK "Error: Service activation could not be completed."
    Quit

success:
    MessageBox MB_OK "¡MySQL 8.4.8 successfully installed!"
SectionEnd