;--------------------------------

!include "MUI.nsh"
!include "Sections.nsh"
!include "FileAssoc.nsh"
!include "LogicLib.nsh"
!include "WordFunc.nsh"

;--------------------------------

; Define version info
!define VERSION "5.1.0"

; Installer details
VIAddVersionKey "CompanyName" "HaxeDevelop.org"
VIAddVersionKey "ProductName" "HaxeDevelop Installer"
VIAddVersionKey "LegalCopyright" "HaxeDevelop.org 2005-2015"
VIAddVersionKey "FileDescription" "HaxeDevelop Installer"
VIAddVersionKey "ProductVersion" "${VERSION}.0"
VIAddVersionKey "FileVersion" "${VERSION}.0"
VIProductVersion "${VERSION}.0"

; The name of the installer
Name "HaxeDevelop"

; The captions of the installer
Caption "HaxeDevelop ${VERSION} Setup"
UninstallCaption "HaxeDevelop ${VERSION} Uninstall"

; The file to write
OutFile "Binary\HaxeDevelop.exe"

; Default installation folder
InstallDir "$PROGRAMFILES\HaxeDevelop\"

; Define executable files
!define EXECUTABLE "$INSTDIR\HaxeDevelop.exe"
!define WIN32RES "$INSTDIR\Tools\winres\winres.exe"
!define ASDOCGEN "$INSTDIR\Tools\asdocgen\ASDocGen.exe"

; Get installation folder from registry if available
InstallDirRegKey HKLM "Software\HaxeDevelop" ""

; Vista redirects $SMPROGRAMS to all users without this
RequestExecutionLevel admin

; Use replace and version compare
!insertmacro WordReplace
!insertmacro VersionCompare

; Required props
SetFont /LANG=${LANG_ENGLISH} "Tahoma" 8
SetCompressor /SOLID lzma
CRCCheck on
XPStyle on

;--------------------------------

; Interface Configuration

!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_HEADERIMAGE_BITMAP "Graphics\Banner.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "Graphics\Wizard.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "Graphics\Wizard.bmp"
!define MUI_FINISHPAGE_SHOWREADME "http://www.haxedevelop.org/"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "See online guide to get started"

;--------------------------------

; Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

;--------------------------------

; InstallTypes

InstType "Default"
InstType "Standalone/Portable"
InstType "un.Default"
InstType "un.Full"

;--------------------------------

; Functions

Function GetIsWine
	
	Push $0
	ClearErrors
	EnumRegKey $0 HKLM "SOFTWARE\Wine" 0
	IfErrors 0 +2
	StrCpy $0 "not_found"
	Exch $0
	
FunctionEnd

Function GetDotNETVersion
	
	Push $0
	ClearErrors
	ReadRegStr $0 HKLM "Software\Microsoft\NET Framework Setup\NDP\v3.5" "Version"
	IfErrors 0 +2
	StrCpy $0 "not_found"
	Exch $0
	
FunctionEnd

Function GetFlashVersion
	
	Push $0
	ClearErrors
	ReadRegStr $0 HKLM "Software\Macromedia\FlashPlayer" "CurrentVersion"
	IfErrors 0 +5
	ClearErrors
	ReadRegStr $0 HKCU "Software\Macromedia\FlashPlayer" "FlashPlayerVersion"
	IfErrors 0 +2
	StrCpy $0 "not_found"
	${WordReplace} $0 "," "." "+" $1
	Exch $1
	
FunctionEnd

Function GetJavaVersion
	
	Push $0
	ClearErrors
	ReadRegStr $0 HKLM "Software\JavaSoft\Java Runtime Environment" "CurrentVersion"
	IfErrors 0 +2
	StrCpy $0 "not_found"
	Exch $0
	
FunctionEnd

Function GetFDVersion
	
	Push $0
	ClearErrors
	ReadRegStr $0 HKLM Software\HaxeDevelop "CurrentVersion"
	IfErrors 0 +2
	StrCpy $0 "not_found"
	Exch $0
	
FunctionEnd

Function GetFDInstDir
	
	Push $0
	ClearErrors
	ReadRegStr $0 HKLM Software\HaxeDevelop ""
	IfErrors 0 +2
	StrCpy $0 "not_found"
	Exch $0
	
FunctionEnd

Function NotifyInstall
	
	SetOverwrite on
	IfFileExists "$INSTDIR\.local" Local 0
	IfFileExists "$LOCALAPPDATA\HaxeDevelop\*.*" User Done
	Local:
	SetOutPath "$INSTDIR"
	File "/oname=.update" "..\Bin\Debug\.local"
	User:
	SetOutPath "$LOCALAPPDATA\HaxeDevelop"
	File "/oname=.update" "..\Bin\Debug\.local"
	Done:
	
FunctionEnd

Function GetNeedsReset
	
	Call GetFDVersion
	Pop $1
	Push $2
	${VersionCompare} $1 "5.0.0" $3
	${If} $1 == "not_found"
	StrCpy $2 "do_reset"
	${ElseIf} $3 == 2
	StrCpy $2 "do_reset"
	${Else}
	StrCpy $2 "is_ok"
	${EndIf}
	Exch $2
	
FunctionEnd

;--------------------------------

; Install Sections

Section "HaxeDevelop" Main
	
	SectionIn 1 2 RO
	SetOverwrite on
	
	SetOutPath "$INSTDIR"
	
	; Clean library
	RMDir /r "$INSTDIR\Library"

	; Clean old Flex PMD
	IfFileExists "$INSTDIR\Tools\flexpmd\flex-pmd-command-line-1.1.jar" 0 +2
	RMDir /r "$INSTDIR\Tools\flexpmd"
	
	; Copy all files
	File /r /x .svn /x .empty /x *.db /x Exceptions.log /x .local /x .multi /x *.pdb /x *.vshost.exe /x *.vshost.exe.config /x *.vshost.exe.manifest /x "..\Bin\Debug\Data\" /x "..\Bin\Debug\Settings\" /x "..\Bin\Debug\Snippets\" /x "..\Bin\Debug\Templates\" "..\Bin\Debug\*.*"
	
	SetOverwrite off
	
	IfFileExists "$INSTDIR\.local" +6 0
	RMDir /r "$INSTDIR\Data"
	RMDir /r "$INSTDIR\Settings"
	RMDir /r "$INSTDIR\Snippets"
	RMDir /r "$INSTDIR\Templates"
	RMDir /r "$INSTDIR\Projects"
	
	SetOutPath "$INSTDIR\Settings"
	File /r /x .svn /x .empty /x *.db /x LayoutData.fdl /x SessionData.fdb /x SettingData.fdb "..\Bin\Debug\Settings\*.*"
	
	SetOutPath "$INSTDIR\Snippets"
	File /r /x .svn /x .empty /x *.db "..\Bin\Debug\Snippets\*.*"
	
	SetOutPath "$INSTDIR\Templates"
	File /r /x .svn /x .empty /x *.db "..\Bin\Debug\Templates\*.*"

	SetOutPath "$INSTDIR\Projects"
	File /r /x .svn /x .empty /x *.db "..\Bin\Debug\Projects\*.*"

	; Remove PluginCore from plugins...
	Delete "$INSTDIR\Plugins\PluginCore.dll"
	
	; Patch CrossOver/Wine files
	SetOverwrite on
	SetOutPath "$INSTDIR"
	Call GetIsWine
	Pop $0
	${If} $0 != "not_found"
	SetOutPath "$INSTDIR"
	File /r /x .svn /x .empty /x *.db "CrossOver\*.*"
	${EndIf}
	
	; Write update flag file...
	Call NotifyInstall
	
SectionEnd

Section "Desktop Shortcut" DesktopShortcut
	
	SetOverwrite on
	SetShellVarContext all
	
	CreateShortCut "$DESKTOP\HaxeDevelop.lnk" "${EXECUTABLE}" "" "${EXECUTABLE}" 0
	
SectionEnd

Section "Quick Launch Item" QuickShortcut
	
	SetOverwrite on
	SetShellVarContext all
	
	CreateShortCut "$QUICKLAUNCH\HaxeDevelop.lnk" "${EXECUTABLE}" "" "${EXECUTABLE}" 0
	
SectionEnd

SectionGroup "Language" LanguageGroup

Section "No changes" NoChangesLocale
	
	; Don't change the locale
	
SectionEnd

Section "English" EnglishLocale
	
	SetOverwrite on
	IfFileExists "$INSTDIR\.local" Local 0
	IfFileExists "$LOCALAPPDATA\HaxeDevelop\*.*" User Done
	Local:
	ClearErrors
	FileOpen $1 "$INSTDIR\.locale" w
	IfErrors Done
	FileWrite $1 "en_US"
	FileClose $1
	User:
	ClearErrors
	FileOpen $1 "$LOCALAPPDATA\HaxeDevelop\.locale" w
	IfErrors Done
	FileWrite $1 "en_US"
	FileClose $1
	Done:
	
SectionEnd

Section "Chinese" ChineseLocale
	
	SetOverwrite on
	IfFileExists "$INSTDIR\.local" Local 0
	IfFileExists "$LOCALAPPDATA\HaxeDevelop\*.*" User Done
	Local:
	ClearErrors
	FileOpen $1 "$INSTDIR\.locale" w
	IfErrors Done
	FileWrite $1 "zh_CN"
	FileClose $1
	User:
	ClearErrors
	FileOpen $1 "$LOCALAPPDATA\HaxeDevelop\.locale" w
	IfErrors Done
	FileWrite $1 "zh_CN"
	FileClose $1
	Done:
	
SectionEnd

Section "Japanese" JapaneseLocale
	
	SetOverwrite on
	IfFileExists "$INSTDIR\.local" Local 0
	IfFileExists "$LOCALAPPDATA\HaxeDevelop\*.*" User Done
	Local:
	ClearErrors
	FileOpen $1 "$INSTDIR\.locale" w
	IfErrors Done
	FileWrite $1 "ja_JP"
	FileClose $1
	User:
	ClearErrors
	FileOpen $1 "$LOCALAPPDATA\HaxeDevelop\.locale" w
	IfErrors Done
	FileWrite $1 "ja_JP"
	FileClose $1
	Done:
	
SectionEnd

Section "German" GermanLocale
	
	SetOverwrite on
	IfFileExists "$INSTDIR\.local" Local 0
	IfFileExists "$LOCALAPPDATA\HaxeDevelop\*.*" User Done
	Local:
	ClearErrors
	FileOpen $1 "$INSTDIR\.locale" w
	IfErrors Done
	FileWrite $1 "de_DE"
	FileClose $1
	User:
	ClearErrors
	FileOpen $1 "$LOCALAPPDATA\HaxeDevelop\.locale" w
	IfErrors Done
	FileWrite $1 "de_DE"
	FileClose $1
	Done:
	
SectionEnd

Section "Basque" BasqueLocale
	
	SetOverwrite on
	IfFileExists "$INSTDIR\.local" Local 0
	IfFileExists "$LOCALAPPDATA\HaxeDevelop\*.*" User Done
	Local:
	ClearErrors
	FileOpen $1 "$INSTDIR\.locale" w
	IfErrors Done
	FileWrite $1 "eu_ES"
	FileClose $1
	User:
	ClearErrors
	FileOpen $1 "$LOCALAPPDATA\HaxeDevelop\.locale" w
	IfErrors Done
	FileWrite $1 "eu_ES"
	FileClose $1
	Done:
	
SectionEnd

SectionGroupEnd

SectionGroup "Advanced"

Section "Start Menu Group" StartMenuGroup
	
	SectionIn 1	
	SetOverwrite on
	SetShellVarContext all
	
	CreateDirectory "$SMPROGRAMS\HaxeDevelop"
	CreateShortCut "$SMPROGRAMS\HaxeDevelop\HaxeDevelop.lnk" "${EXECUTABLE}" "" "${EXECUTABLE}" 0
	WriteINIStr "$SMPROGRAMS\HaxeDevelop\Documentation.url" "InternetShortcut" "URL" "http://www.flashdevelop.org/wikidocs/"
	WriteINIStr "$SMPROGRAMS\HaxeDevelop\Community.url" "InternetShortcut" "URL" "http://www.flashdevelop.org/community/"
	CreateShortCut "$SMPROGRAMS\HaxeDevelop\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
	
SectionEnd

Section "Registry Modifications" RegistryMods
	
	SectionIn 1
	SetOverwrite on
	SetShellVarContext all
	
	Delete "$INSTDIR\.multi"
	Delete "$INSTDIR\.local"
	
	DeleteRegKey /ifempty HKCR "Applications\HaxeDevelop.exe"	
	DeleteRegKey /ifempty HKLM "Software\Classes\Applications\HaxeDevelop.exe"
	DeleteRegKey /ifempty HKCU "Software\Classes\Applications\HaxeDevelop.exe"
	
	!insertmacro APP_ASSOCIATE "fdp" "HaxeDevelop.Project" "HaxeDevelop Project" "${WIN32RES},2" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "fdproj" "HaxeDevelop.GenericProject" "HaxeDevelop Generic Project" "${WIN32RES},2" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "hxproj" "HaxeDevelop.HaXeProject" "HaxeDevelop Haxe Project" "${WIN32RES},2" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "as2proj" "HaxeDevelop.AS2Project" "HaxeDevelop AS2 Project" "${WIN32RES},2" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "as3proj" "HaxeDevelop.AS3Project" "HaxeDevelop AS3 Project" "${WIN32RES},2" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "docproj" "HaxeDevelop.DocProject" "HaxeDevelop Docs Project" "${WIN32RES},2" "" "${ASDOCGEN}"
	!insertmacro APP_ASSOCIATE "lsproj" "HaxeDevelop.LoomProject" "HaxeDevelop Loom Project" "${WIN32RES},2" "" "${EXECUTABLE}"

	!insertmacro APP_ASSOCIATE "fdi" "HaxeDevelop.Theme" "HaxeDevelop Theme File" "${WIN32RES},1" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "fdm" "HaxeDevelop.Macros" "HaxeDevelop Macros File" "${WIN32RES},1" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "fdt" "HaxeDevelop.Template" "HaxeDevelop Template File" "${WIN32RES},1" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "fda" "HaxeDevelop.Arguments" "HaxeDevelop Arguments File" "${WIN32RES},1" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "fds" "HaxeDevelop.Snippet" "HaxeDevelop Snippet File" "${WIN32RES},1" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "fdb" "HaxeDevelop.Binary" "HaxeDevelop Binary File" "${WIN32RES},1" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "fdl" "HaxeDevelop.Layout" "HaxeDevelop Layout File" "${WIN32RES},1" "" "${EXECUTABLE}"
	!insertmacro APP_ASSOCIATE "fdz" "HaxeDevelop.Zip" "HaxeDevelop Zip File" "${WIN32RES},1" "" "${EXECUTABLE}"
	
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Project" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.GenericProject" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.HaXeProject" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.AS2Project" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.AS3Project" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.DocProject" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.LoomProject" "ShellNew"

	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Theme" "ShellNew"	
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Macros" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Template" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Arguments" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Snippet" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Binary" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Layout" "ShellNew"
	!insertmacro APP_ASSOCIATE_REMOVEVERB "HaxeDevelop.Zip" "ShellNew"
	
	; Write uninstall section keys
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "InstallLocation" "$INSTDIR"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "Publisher" "HaxeDevelop.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "DisplayVersion" "${VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "DisplayName" "HaxeDevelop"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "Comments" "Thank you for using HaxeDevelop."
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "HelpLink" "http://www.flashdevelop.org/community/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "UninstallString" "$INSTDIR\Uninstall.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "DisplayIcon" "${EXECUTABLE}"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop" "NoRepair" 1
	WriteRegStr HKLM "Software\HaxeDevelop" "CurrentVersion" ${VERSION}
	WriteRegStr HKLM "Software\HaxeDevelop" "" $INSTDIR
	WriteUninstaller "$INSTDIR\Uninstall.exe"
	
	!insertmacro UPDATEFILEASSOC
	
SectionEnd

Section "Standalone/Portable" StandaloneMode
	
	SectionIn 2
	SetOverwrite on
	
	SetOutPath "$INSTDIR"
	File ..\Bin\Debug\.local
	
SectionEnd

Section "Multi Instance Mode" MultiInstanceMode
	
	SetOverwrite on
	
	SetOutPath "$INSTDIR"
	File ..\Bin\Debug\.multi
	
SectionEnd

SectionGroupEnd

;--------------------------------

; Install section strings

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${Main} "Installs the main program and other required files."
!insertmacro MUI_DESCRIPTION_TEXT ${RegistryMods} "Associates integral file types and adds the required uninstall configuration."
!insertmacro MUI_DESCRIPTION_TEXT ${StandaloneMode} "Runs as standalone using only local setting files. NOTE: Not for standard users and manual upgrade only."
!insertmacro MUI_DESCRIPTION_TEXT ${MultiInstanceMode} "Allows multiple instances of HaxeDevelop to be executed. NOTE: There are some open issues with this."
!insertmacro MUI_DESCRIPTION_TEXT ${NoChangesLocale} "Keeps the current language on update and defaults to English on clean install."
!insertmacro MUI_DESCRIPTION_TEXT ${EnglishLocale} "Changes HaxeDevelop's display language to English on next restart."
!insertmacro MUI_DESCRIPTION_TEXT ${ChineseLocale} "Changes HaxeDevelop's display language to Chinese on next restart."
!insertmacro MUI_DESCRIPTION_TEXT ${JapaneseLocale} "Changes HaxeDevelop's display language to Japanese on next restart."
!insertmacro MUI_DESCRIPTION_TEXT ${GermanLocale} "Changes HaxeDevelop's display language to German on next restart."
!insertmacro MUI_DESCRIPTION_TEXT ${BasqueLocale} "Changes HaxeDevelop's display language to Basque on next restart."
!insertmacro MUI_DESCRIPTION_TEXT ${StartMenuGroup} "Creates a start menu group and adds default HaxeDevelop links to the group."
!insertmacro MUI_DESCRIPTION_TEXT ${QuickShortcut} "Installs a HaxeDevelop shortcut to the Quick Launch bar."
!insertmacro MUI_DESCRIPTION_TEXT ${DesktopShortcut} "Installs a HaxeDevelop shortcut to the desktop."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------

; Uninstall Sections

Section "un.HaxeDevelop" UninstMain
	
	SectionIn 1 2 RO
	SetShellVarContext all
	
	Delete "$DESKTOP\HaxeDevelop.lnk"
	Delete "$QUICKLAUNCH\HaxeDevelop.lnk"
	Delete "$SMPROGRAMS\HaxeDevelop\HaxeDevelop.lnk"
	Delete "$SMPROGRAMS\HaxeDevelop\Documentation.url"
	Delete "$SMPROGRAMS\HaxeDevelop\Community.url"
	Delete "$SMPROGRAMS\HaxeDevelop\Uninstall.lnk"
	RMDir "$SMPROGRAMS\HaxeDevelop"
	
	RMDir /r "$INSTDIR\Docs"
	RMDir /r "$INSTDIR\Library"
	RMDir /r "$INSTDIR\Plugins"
	RMDir /r "$INSTDIR\StartPage"
	RMDir /r "$INSTDIR\Projects"
	RMDir /r "$INSTDIR\Tools"
	
	IfFileExists "$INSTDIR\.local" +5 0
	RMDir /r "$INSTDIR\Data"
	RMDir /r "$INSTDIR\Settings"
	RMDir /r "$INSTDIR\Snippets"
	RMDir /r "$INSTDIR\Templates"
	
	Delete "$INSTDIR\FDMT.cmd"
	Delete "$INSTDIR\README.txt"
	Delete "$INSTDIR\FirstRun.fdb"
	Delete "$INSTDIR\Exceptions.log"
	Delete "$INSTDIR\HaxeDevelop.exe"
	Delete "$INSTDIR\HaxeDevelop.exe.config"
	Delete "$INSTDIR\PluginCore.dll"
	Delete "$INSTDIR\SciLexer.dll"
	Delete "$INSTDIR\Scripting.dll"
	Delete "$INSTDIR\Antlr3.dll"
	Delete "$INSTDIR\SwfOp.dll"
	Delete "$INSTDIR\Aga.dll"
	
	Delete "$INSTDIR\Uninstall.exe"
	RMDir "$INSTDIR"
	
	!insertmacro APP_UNASSOCIATE "fdp" "HaxeDevelop.Project"
	!insertmacro APP_UNASSOCIATE "fdproj" "HaxeDevelop.GenericProject"
	!insertmacro APP_UNASSOCIATE "hxproj" "HaxeDevelop.HaXeProject"
	!insertmacro APP_UNASSOCIATE "as2proj" "HaxeDevelop.AS2Project"
	!insertmacro APP_UNASSOCIATE "as3proj" "HaxeDevelop.AS3Project"
	!insertmacro APP_UNASSOCIATE "docproj" "HaxeDevelop.DocProject"
	!insertmacro APP_UNASSOCIATE "lsproj" "HaxeDevelop.LoomProject"
	
	!insertmacro APP_UNASSOCIATE "fdi" "HaxeDevelop.Theme"
	!insertmacro APP_UNASSOCIATE "fdm" "HaxeDevelop.Macros"
	!insertmacro APP_UNASSOCIATE "fdt" "HaxeDevelop.Template"
	!insertmacro APP_UNASSOCIATE "fda" "HaxeDevelop.Arguments"
	!insertmacro APP_UNASSOCIATE "fds" "HaxeDevelop.Snippet"
	!insertmacro APP_UNASSOCIATE "fdb" "HaxeDevelop.Binary"
	!insertmacro APP_UNASSOCIATE "fdl" "HaxeDevelop.Layout"
	!insertmacro APP_UNASSOCIATE "fdz" "HaxeDevelop.Zip"
	
	DeleteRegKey /ifempty HKLM "Software\HaxeDevelop"
	DeleteRegKey /ifempty HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaxeDevelop"
	
	DeleteRegKey /ifempty HKCR "Applications\HaxeDevelop.exe"	
	DeleteRegKey /ifempty HKLM "Software\Classes\Applications\HaxeDevelop.exe"
	DeleteRegKey /ifempty HKCU "Software\Classes\Applications\HaxeDevelop.exe"
	
	!insertmacro UPDATEFILEASSOC
	
SectionEnd

Section /o "un.Settings" UninstSettings
	
	SectionIn 2
	
	Delete "$INSTDIR\.multi"
	Delete "$INSTDIR\.local"
	Delete "$INSTDIR\.locale"
	
	RMDir /r "$INSTDIR\Data"
	RMDir /r "$INSTDIR\Settings"
	RMDir /r "$INSTDIR\Snippets"
	RMDir /r "$INSTDIR\Templates"
	RMDir /r "$LOCALAPPDATA\HaxeDevelop"
	RMDir "$INSTDIR"
	
SectionEnd

;--------------------------------

; Uninstall section strings

!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${UninstMain} "Uninstalls the main program, other required files and registry modifications."
!insertmacro MUI_DESCRIPTION_TEXT ${UninstSettings} "Uninstalls all settings and snippets from the install directory and user's application data directory."
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END

;--------------------------------

; Event functions

Function .onInit
	
	; Check if the installer is already running
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "HaxeDevelop ${VERSION}") i .r1 ?e'
	Pop $0
	StrCmp $0 0 +3
	MessageBox MB_OK|MB_ICONSTOP "The HaxeDevelop ${VERSION} installer is already running."
	Abort
	
	Call GetDotNETVersion
	Pop $0
	${If} $0 == "not_found"
	MessageBox MB_OK|MB_ICONSTOP "You need to install Microsoft.NET 3.5 runtime before installing HaxeDevelop."
	${Else}
	${VersionCompare} $0 "3.5" $1
	${If} $1 == 2
	MessageBox MB_OK|MB_ICONSTOP "You need to install Microsoft.NET 3.5 runtime before installing HaxeDevelop. You have $0."
	${EndIf}
	${EndIf}
	
	Call GetFDInstDir
	Pop $0
	Call GetNeedsReset
	Pop $2
	${If} $2 == "do_reset"
	${If} $0 != "not_found"
	MessageBox MB_OK|MB_ICONEXCLAMATION "You have a version of HaxeDevelop installed that may make HaxeDevelop unstable or you may miss new features if updated. You should backup you custom setting files and do a full uninstall before installing this one. After install customize the new setting files."
	${EndIf}
	${EndIf}
	
	Call GetFlashVersion
	Pop $0
	${If} $0 == "not_found"
	MessageBox MB_OK|MB_ICONEXCLAMATION "You should install Flash Player (ActiveX for IE) before installing HaxeDevelop."
	${Else}
	${VersionCompare} $0 "9.0" $1
	${If} $1 == 2
	MessageBox MB_OK|MB_ICONEXCLAMATION "You should install Flash Player (ActiveX for IE) before installing HaxeDevelop. You have $0."
	${EndIf}
	${EndIf}
	
	Call GetJavaVersion
	Pop $0
	${If} $0 == "not_found"
	MessageBox MB_OK|MB_ICONEXCLAMATION "You should install 32-bit Java Runtime (1.6 or later) before installing HaxeDevelop."
	${Else}
	${VersionCompare} $0 "1.6" $1
	${If} $1 == 2
	MessageBox MB_OK|MB_ICONEXCLAMATION "You should install 32-bit Java Runtime (1.6 or later) before installing HaxeDevelop. You have $0."
	${EndIf}
	${EndIf}
	
	; Default to English
	StrCpy $1 ${NoChangesLocale}
	call .onSelChange
	
FunctionEnd

Function .onSelChange

	${If} ${SectionIsSelected} ${LanguageGroup}
	!insertmacro UnSelectSection ${LanguageGroup}
	!insertmacro SelectSection $1
	${Else}
	!insertmacro StartRadioButtons $1
	!insertmacro RadioButton ${NoChangesLocale}
	!insertmacro RadioButton ${EnglishLocale}
	!insertmacro RadioButton ${ChineseLocale}
	!insertmacro RadioButton ${JapaneseLocale}
	!insertmacro RadioButton ${GermanLocale}
	!insertmacro RadioButton ${BasqueLocale}
	!insertmacro EndRadioButtons
	${EndIf}
	
FunctionEnd

;--------------------------------
