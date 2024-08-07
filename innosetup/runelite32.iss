[Setup]
AppName=Eldritch Launcher
AppPublisher=Eldritch
UninstallDisplayName=Eldritch
AppVersion=${project.version}
AppSupportURL=https://discord.gg/v3emmHDWRV
DefaultDirName={localappdata}\Eldritch

; ~30 mb for the repo the launcher downloads
ExtraDiskSpaceRequired=30000000
ArchitecturesAllowed=x86 x64
PrivilegesRequired=lowest

WizardSmallImageFile=${basedir}/innosetup/runelite_small.bmp
SetupIconFile=${basedir}/innosetup/runelite.ico
UninstallDisplayIcon={app}\Eldritch.exe

Compression=lzma2
SolidCompression=yes

OutputDir=${basedir}
OutputBaseFilename=EldritchSetup32

[Tasks]
Name: DesktopIcon; Description: "Create a &desktop icon";

[Files]
Source: "${basedir}\build\win-x86\Eldritch.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "${basedir}\build\win-x86\Eldritch.jar"; DestDir: "{app}"
Source: "${basedir}\build\win-x86\launcher_x86.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "${basedir}\build\win-x86\config.json"; DestDir: "{app}"
Source: "${basedir}\build\win-x86\jre\*"; DestDir: "{app}\jre"; Flags: recursesubdirs

[Icons]
; start menu
Name: "{userprograms}\Eldritch\Eldritch"; Filename: "{app}\Eldritch.exe"
Name: "{userprograms}\Eldritch\Eldritch (configure)"; Filename: "{app}\Eldritch.exe"; Parameters: "--configure"
Name: "{userprograms}\Eldritch\Eldritch (safe mode)"; Filename: "{app}\Eldritch.exe"; Parameters: "--safe-mode"
Name: "{userdesktop}\Eldritch"; Filename: "{app}\Eldritch.exe"; Tasks: DesktopIcon

[Run]
Filename: "{app}\Eldritch.exe"; Parameters: "--postinstall"; Flags: nowait
Filename: "{app}\Eldritch.exe"; Description: "&Open Eldritch"; Flags: postinstall skipifsilent nowait

[InstallDelete]
; Delete the old jvm so it doesn't try to load old stuff with the new vm and crash
Type: filesandordirs; Name: "{app}\jre"
; previous shortcut
Type: files; Name: "{userprograms}\Eldritch.lnk"

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\.eldritch\repository2"
; includes install_id, settings, etc
Type: filesandordirs; Name: "{app}"

[Code]
#include "upgrade.pas"
#include "usernamecheck.pas"
#include "dircheck.pas"