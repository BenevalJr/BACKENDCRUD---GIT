unit CrudExampleHorseServer.Controller;

interface

uses
  CrudExampleHorseServer.Model.Entidade.ConfigApp
  , CrudExampleHorseServer.Model.Conexao.DB
  , System.SysUtils
  , System.JSON
  {$IFDEF CONSOLE}
  , Horse
  {$ELSE}
  , Horse.ISAPI
  {$ENDIF}
  ;

type
  IController = interface
  ['{AF9ADF59-AD07-4B09-955C-3F997312AC99}']
    function ConfigApp: IConfigApp;
    function ConexaoDB: IModelConexaoDB;
    function Query: IModelQuery;

    procedure AppRegister( aApp: THorse );

    procedure Status(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure Autorization(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure DeserializeToken(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure RevalidateToken(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);

    //function CheckToken( const aToken: string ): boolean; overload;
    //function CheckToken( const aReq: THorseRequest ): boolean; overload;
    //function CheckToken( const aReq: THorseRequest; const aArrayLevels: array of integer ): boolean; overload;
    //function Token(const aReq: THorseRequest): string;

    {procedure ListCadastro(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure ListCadastroByID(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure InsertCadastro(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure UpdateCadastro(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure DeleteCadastro(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);}

    procedure DoRequestsCadastro(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
  end;

  TController = class(TInterfacedObject, IController)
  strict private
    class var FController: IController;
  private
    { private declarations }
    FConfigApp: IConfigApp;
    FConexaoDB: IModelConexaoDB;

    //function CheckToken( const aToken: string ): boolean; overload;
    //function CheckToken( const aReq: THorseRequest ): boolean; overload;
    //function CheckToken( const aReq: THorseRequest; const aArrayLevels: array of integer ): boolean; overload;

    function ValidateToken( const aReq: THorseRequest ): boolean; overload;
    function ValidateToken( const aReq: THorseRequest; const aArrayLevels: array of integer ): boolean; overload;

    function Token(const aReq: THorseRequest): string;
  public
    { public declarations }
    class function New: IController;
    constructor Create;
    destructor Destroy; override;

    function ConfigApp: IConfigApp;
    function ConexaoDB: IModelConexaoDB;
    function Query: IModelQuery;

    procedure AppRegister( aApp: THorse );

    procedure Status(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure Autorization(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure DeserializeToken(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
    procedure RevalidateToken(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);

    procedure DoRequestsCadastro(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
  end;

implementation

uses
  CrudExampleHorseServer.Model.Entidade.Autorization
  {$IFDEF CONSOLE}
  , VCL.Forms
  {$ENDIF}
  , Web.HTTPApp
  , CrudExampleHorseServer.Model.DAO.Cadastro
  , Horse.Commons, CrudExampleHorseServer.Controller.Cadastro
  ;

const
  SECRETSIGNATURE = 'XXXXXXXXXXXXXXXXXXXXXX';

procedure TController.AppRegister(aApp: THorse);
begin
  aApp.Get('/api/v1/status',                             Status);
  aApp.Get('/api/v1/dashboard/verifytoken',              DeserializeToken);
  aApp.Get('/api/v1/dashboard/revalidatetoken',          RevalidateToken);
  aApp.Post('/api/v1/dashboard/auth',                    Autorization);

  aApp.Get('/user',                           DoRequestsCadastro);
  aApp.Get('/user/:id',                       DoRequestsCadastro);
  aApp.Post('/user',                          DoRequestsCadastro); // 201
  aApp.Put('/user',                           DoRequestsCadastro); // 200
  aApp.Delete('/user/:id',                    DoRequestsCadastro); // 200
end;

procedure TController.DeserializeToken(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
begin
  aRes.Send<TJSONObject>( TAutorization.New( SECRETSIGNATURE ).DeserializeToken( Token ( aReq ) ) )
end;

procedure TController.Autorization(aReq: THorseRequest; aRes: THorseResponse;
  aNext: TProc);
begin
  aRes.Send<TJSONObject>( TAutorization.New( SECRETSIGNATURE ).SetApplicationName('DashBoard').SetConexaoDB( ConexaoDB ).Login( aReq.Body<TJSONObject> ) );
end;

function TController.ConexaoDB: IModelConexaoDB;
begin
  if not Assigned(FConexaoDB) then
    FConexaoDB:=TModelConexaoDB.New(ConfigApp.ParamConnectionDB);
  Result:=FConexaoDB;
end;

function TController.ConfigApp: IConfigApp;
begin
  if not Assigned(FConfigApp) then
  {$IFDEF CONSOLE}
    FConfigApp:=TConfigApp.New( ChangeFileExt(Application.ExeName,'.INI') );
  {$ELSE}
    FConfigApp:=TConfigApp.New( ChangeFileExt(GetModuleFile(hInstance),'.INI') );
  {$ENDIF}
  Result:=FConfigApp;
end;

constructor TController.Create;
begin
end;

destructor TController.Destroy;
begin
  inherited;
end;

class function TController.New: IController;
begin
  if not Assigned(FController) then
    FController:=Self.Create;
  Result := FController;
end;

function TController.Query: IModelQuery;
begin
  Result:=ConexaoDB.Query;
end;

procedure TController.DoRequestsCadastro(aReq: THorseRequest;
  aRes: THorseResponse; aNext: TProc);
begin
  if ValidateToken( aReq ) then
    TControllerCadastro.New(ConexaoDB).DoRequestsCadastro( aReq, aRes );
end;

procedure TController.RevalidateToken(aReq: THorseRequest; aRes: THorseResponse;
  aNext: TProc);
begin
  if ValidateToken( aReq ) then
    aRes.Send<TJSONObject>( TAutorization.New( SECRETSIGNATURE ).RevalidateToken( Token ( aReq ) ) )
  else
    aRes.Send<TJSONObject>( TJSONObject.Create
                              .AddPair( TJSONPair.Create( 'Erro', 'Token inválido' ) ) );
end;

procedure TController.Status(aReq: THorseRequest; aRes: THorseResponse; aNext: TProc);
begin
  aRes.Send('Status: Ok ');
end;

function TController.Token(const aReq: THorseRequest): string;
begin
  Result:=aReq.Headers['TOKEN'];
  if Result='' then
    Result:=aReq.CookieFields.Values['TOKEN'];
end;

function TController.ValidateToken(const aReq: THorseRequest;
  const aArrayLevels: array of integer): boolean;
begin
  if ConfigApp.ValidateToken then
    with TAutorization.New( SECRETSIGNATURE ) do
      Result:=Self.ValidateToken(aReq) and CheckAccessLevel( DeserializeToken( Token( aReq ) ), aArrayLevels )
  else
    Result:=True;
end;

function TController.ValidateToken(const aReq: THorseRequest): boolean;
begin
  Result:=not ( ConfigApp.ValidateToken ) or TAutorization.New( SECRETSIGNATURE ).ValidateToken( Token ( aReq ) );
end;

end.
