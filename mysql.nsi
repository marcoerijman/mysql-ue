; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "MariaDB Simplified Installer"
!define PRODUCT_VERSION "10.1.18"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_DIR "$PROGRAMFILES\MariaDB"
!include x64.nsh

; MUI 1.67 compatible ------
!include "MUI.nsh"



; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Language Selection Dialog Settings
;!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
;!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
;!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
;!insertmacro MUI_PAGE_WELCOME

; Directory page
;!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
;!define MUI_FINISHPAGE_RUN 'msiexec /p "$INSTDIR\mysql-5.5.28-win32.msi"'
;!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
;!insertmacro MUI_UNPAGE_INSTFILES

; Language files
;!insertmacro MUI_LANGUAGE "English"
;!insertmacro MUI_LANGUAGE "Spanish"

; MUI end ------

!define MULTIUSER_EXECUTIONLEVEL Admin
!include MultiUser.nsh

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "build/MariaDB-UE.exe"
InstallDir "$PROGRAMFILES\MariaDB"
ShowInstDetails show
;ShowUnInstDetails show
Caption "MariaDB Simplified Installer"
Function .onInit
         
         !insertmacro MULTIUSER_INIT


         !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "MariaDB 10.1.18" SEC01
  SetOutPath "$PROGRAMFILES\MariaDB\"
  SetOverwrite ifnewer
  File "mariadb-10.1.18-win32.msi"
  File "mariadb-10.1.18-winx64.msi"
SectionEnd


Section -Post
${If} ${RunningX64}
    ExecWait "msiexec /i $\"$PROGRAMFILES\MariaDB\mariadb-10.1.18-winx64.msi$\" /qn SERVICENAME=MariaDB PASSWORD=root"
${Else}
    ExecWait "msiexec /i $\"$PROGRAMFILES\MariaDB\mariadb-10.1.18-win32.msi$\" /qn SERVICENAME=MariaDB PASSWORD=root"
${EndIf} 
  
SectionEnd

