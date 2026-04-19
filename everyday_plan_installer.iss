; Inno Setup script for Everyday Plan
; Usage:
; 1. Build the Release target.
; 2. Run windeployqt on the release executable directory.
; 3. Ensure all runtime files are under SourceDir below.
; 4. Open this file in Inno Setup Compiler and build.

#define MyAppName "Everyday Plan"
#define MyAppVersion "1.1"
#define MyAppPublisher "F-qiang"
#define MyAppExeName "appeveryday_plan.exe"
#define MyAppId "{{B6D5631A-7D3F-4A5B-A2D8-7A8A6A1D1101}"
#define SourceDir "build\\Desktop_Qt_6_8_3_llvm_mingw_64_bit-Release"

[Setup]
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=
InfoBeforeFile=
InfoAfterFile=
OutputDir=dist
OutputBaseFilename=everyday_plan_setup_v1.1
SetupIconFile=assets\ep_app_icon.ico
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
ChangesAssociations=no
DisableProgramGroupPage=yes
CloseApplications=yes
CloseApplicationsFilter=appeveryday_plan.exe
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "init_database.sql"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\data.db-shm"
Type: files; Name: "{app}\data.db-wal"
