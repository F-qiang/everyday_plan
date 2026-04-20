; Inno Setup script for Everyday Plan

#define MyAppName "Everyday Plan"
#define MyAppVersion "1.1"
#define MyAppPublisher "F-qiang"
#define MyAppExeName "appeveryday_plan.exe"
#define MyAppId "{{B6D5631A-7D3F-4A5B-A2D8-7A8A6A1D1101}"
#define SourceDir "deploy"

[Setup]
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL=""
AppSupportURL=""
AppUpdatesURL=""
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=dist
OutputBaseFilename=everyday_plan_setup_v1.1
SetupIconFile=assets\ep_app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible
ChangesAssociations=no
DisableProgramGroupPage=yes
CloseApplications=yes
CloseApplicationsFilter=appeveryday_plan.exe
RestartApplications=no
UsePreviousAppDir=yes
UsePreviousGroup=yes
DisableDirPage=no
DisableReadyMemo=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; 打包 deploy 目录下全部文件和子目录
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; 如需额外带上初始化脚本，可保留
Source: "init_database.sql"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\卸载 {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "启动 {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; 清理 SQLite 临时文件
Type: files; Name: "{app}\data.db-shm"
Type: files; Name: "{app}\data.db-wal"
; 如果你希望卸载时连数据库一起删，取消下面这行注释
; Type: files; Name: "{app}\data.db"