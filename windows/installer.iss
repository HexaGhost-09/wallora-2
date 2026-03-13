; Inno Setup script for Wallora
[Setup]
AppId={{com.wallora.app}}
AppName=Wallora
AppVersion={#AppVersion}
DefaultDirName={autopf}\Wallora
DefaultGroupName=Wallora
OutputDir=..\..\
OutputBaseFilename=Wallora-v{#AppVersion}-setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\wallora.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Add more files if needed

[Icons]
Name: "{group}\Wallora"; Filename: "{app}\wallora.exe"
Name: "{autodesktop}\Wallora"; Filename: "{app}\wallora.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\wallora.exe"; Description: "{cm:LaunchProgram,Wallora}"; Flags: nowait postinstall skipifsilent
