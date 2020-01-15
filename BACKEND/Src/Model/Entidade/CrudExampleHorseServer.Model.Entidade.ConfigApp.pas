unit CrudExampleHorseServer.Model.Entidade.ConfigApp;

interface

uses
  System.IniFiles
  , System.SysUtils
  , CrudExampleHorseServer.Controller.Constants
  , Winapi.Windows
  {$IFDEF DASHBOARDSEGPLUS}
  , DashBoardServerStandAloneApp.Controller.Constantes
  {$ENDIF}
  ;

type
  IConfigApp = interface
  ['{79B42310-6ED9-4B36-954B-639061331637}']
    function PhysicalPathHTML: TFileName;
    function VirtualPathHTML: string;
    function PhysicalPathLog: TFileName;
    function ParamConnectionDB: TParamConnectionDB;
    function IniFileName: TFileName;
    function ValidateToken: boolean;
    function AnoMesRef: string;
  end;

  TConfigApp = class(TInterfacedObject, IConfigApp)
  private
    { private declarations }
    FIni: TIniFile;
    FParamConnectionDB: TParamConnectionDB;
    FIniFileName: TFileName;
  protected
    { protected declarations }
  public
    { public declarations }
    class function New( const aIniFileName: TFileName ): IConfigApp;
    constructor CreateNew( const aIniFileName: TFileName );
    destructor Destroy; override;

    function PhysicalPathHTML: TFileName;
    function VirtualPathHTML: string;
    function PhysicalPathLog: TFileName;
    function ParamConnectionDB: TParamConnectionDB;
    function IniFileName: TFileName;
    function ValidateToken: boolean;
    function AnoMesRef: string;
  end;

function GetModuleFile(hModule: HINST):string;

implementation

procedure RemoveLongPath(var path:string);
begin
  if copy(path,1,8)='\\?\UNC\' then delete(path,3,6);
  if copy(path,1,4)='\\?\' then delete(path,1,4);
end;

function GetModuleFile(hModule: HINST):string;
var
  Buffer : array [0..MAX_PATH] of char;
begin
  SetString (Result, Buffer, GetModuleFileName(hModule,Buffer,MAX_PATH));
  RemoveLongPath(Result);
end;

function TConfigApp.AnoMesRef: string;
begin
  Result:=FIni.ReadString('CONFIG','AnoMesRef','');
end;

constructor TConfigApp.CreateNew( const aIniFileName: TFileName );
begin
  FIniFileName:=aIniFileName;
  if FileExists( aIniFileName ) then
    FIni:=TIniFile.Create( aIniFileName )
  else
    raise Exception.CreateFmt('Arquivo INI %s não encontrado',[ aIniFileName]);
end;

destructor TConfigApp.Destroy;
begin
  FreeAndNil(FIni);
  inherited;
end;

function TConfigApp.IniFileName: TFileName;
begin
  Result:=FIniFileName;
end;

class function TConfigApp.New( const aIniFileName: TFileName ): IConfigApp;
begin
  Result := Self.CreateNew( aIniFileName );
end;

function TConfigApp.ParamConnectionDB: TParamConnectionDB;
begin
  FParamConnectionDB.Database:=FIni.ReadString('CONFIGDB','Database','');
  FParamConnectionDB.UserName:=FIni.ReadString('CONFIGDB','UserName','');
  FParamConnectionDB.Password:=FIni.ReadString('CONFIGDB','Password','');
  FParamConnectionDB.DriverID:=FIni.ReadString('CONFIGDB','DriverID','');
  Result:=FParamConnectionDB;
end;

function TConfigApp.PhysicalPathHTML: TFileName;
begin
  Result:=FIni.ReadString('PATHS','PhysicalPathHTML','');
  if not DirectoryExists(Result) then
    CreateDir(Result);
end;

function TConfigApp.PhysicalPathLog: TFileName;
begin
  Result:=FIni.ReadString('PATHS','PhysicalPathLog','');
  if not DirectoryExists(Result) then
    CreateDir(Result);
end;

function TConfigApp.ValidateToken: boolean;
begin
  Result:=(FIni.ReadInteger('CONFIG','ValidateToken',1)=1);
end;

function TConfigApp.VirtualPathHTML: string;
begin
  Result:=FIni.ReadString('PATHS','VirtualPathHTML','/html');
end;

end.
