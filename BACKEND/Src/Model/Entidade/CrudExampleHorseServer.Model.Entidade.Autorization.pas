unit CrudExampleHorseServer.Model.Entidade.Autorization;

interface

uses
  System.JSON
  , JOSE.Core.JWT
  , CrudExampleHorseServer.Model.Conexao.DB
  , CrudExampleHorseServer.Model.Entidade.ConfigApp
  ;

type

  IAutorization = interface
    ['{B475F3B7-A8BB-43A5-B7B2-B464C2AA70A3}']
    function Login(aJSONParams: TJSONObject): TJSONObject;
    function ValidateToken(const aToken: string): boolean;
    function DeserializeToken(const aToken: string): TJSONObject;
    function RevalidateToken(const aToken: string): TJSONObject;
    function SetConexaoDB( const aConexaoDB: IModelConexaoDB ): IAutorization;
    function SetApplicationName( const aApplicationName: string  ): IAutorization;
    function SetConfigApp( const aConfigApp: TConfigApp ): IAutorization;
    function CheckAccessLevel( const aTokenPayload: TJSONObject; const aArrayLevels: array of integer ): boolean; overload;
  end;

  TAutorization = class(TInterfacedObject, IAutorization)
  private
    { private declarations }
    FConexaoDB: IModelConexaoDB;
    FSecretSignature: string;
    FApplicationName: string;
    FConfigApp: TConfigApp;
    //function CheckExpirationToken( const aToken: string ): boolean; overload;
    function CheckExpirationToken( const aTokenPayload: TJSONObject ): boolean; overload;
    //function CheckAccessLevel( const aToken: string ): boolean; overload;
  public
    { public declarations }
    class function New( const aSecretSignature: string ): IAutorization;
    constructor Create( const aSecretSignature: string );
    destructor Destroy; override;

    function Login(aJSONParams: TJSONObject): TJSONObject;
    function ValidateToken(const aToken: string): boolean;
    function DeserializeToken(const aToken: string): TJSONObject;
    function RevalidateToken(const aToken: string): TJSONObject;
    function SetConexaoDB( const aConexaoDB: IModelConexaoDB ): IAutorization;
    function SetApplicationName( const aApplicationName: string  ): IAutorization;
    function SetConfigApp( const aConfigApp: TConfigApp ): IAutorization;
    function CheckAccessLevel( const aTokenPayload: TJSONObject; const aArrayLevels: array of integer ): boolean; overload;
  end;

  TMyClaims = class(TJWTClaims)
  private
    function GetAppIssuer: string;
    procedure SetAppIssuer(const Value: string);

    function GetTypeUser: integer;
    procedure SetTypeUser(const Value: integer);

    function GetIdUser: integer;
    procedure SetIdUser(const Value: integer);

  public
    property AppIssuer: string read GetAppIssuer write SetAppIssuer;
    property TypeUser: integer read GetTypeUser write SetTypeUser;
    property IdUser: integer read GetIdUser write SetIdUser;
  end;

implementation

uses
  System.SysUtils
  , JOSE.Core.Builder
  , Data.DB
  , JOSE.Types.JSON
  ;

const
  TimeToExpirationToken = 0.125;

function TAutorization.ValidateToken(const aToken: string): boolean;
var
  LToken: TJWT;
  lTokenPayload: TJSONObject;
begin

  Result := False;

  try
    // Unpack and verify the token
    LToken := TJOSE.Verify(FSecretSignature, aToken, TMyClaims);

    if Assigned(LToken) then
    begin
      try
        Result := LToken.Verified;
        if Result then
        begin
          lTokenPayload:=DeserializeToken( aToken );
          Result := ( lTokenPayload is TJSONObject )
                    and not Assigned( lTokenPayload.GetValue('Erro') )
                    and not CheckExpirationToken( lTokenPayload );
        end;
      finally
        LToken.Free;
      end;
    end;

  except
    {on E: Exception do
      if E.Message = 'Malformed Compact Serialization' then
        Result:=False;}
  end;

end;

function TAutorization.DeserializeToken(const aToken: string): TJSONObject;
var
  LToken: TJWT;
begin
  Result:=TJSONObject.Create;
  try
    LToken := TJOSE.Verify(FSecretSignature, aToken, TMyClaims);
    try
      if Assigned(LToken) and LToken.Verified then
      begin
        Result :=TJSONObject(TJSONObject.ParseJSONValue(LToken.Claims.JSON.ToString));
        Result
          .AddPair( TJSONPair.Create( 'expiration', DateTimeToStr(LToken.Claims.Expiration) ) );
        Result
          .AddPair( TJSONPair.Create( 'expired', BoolToStr( StrToDateTime(Result.GetValue('expiration').Value)<Now, True ) ) );
      end
      else
        raise Exception.Create('Token inválido');
    finally
      LToken.Free;
    end;
  except
    on E: Exception do
      Result.AddPair( TJSONPair.Create( 'Erro', E.Message ) );
  end;
end;
{
function TAutorization.CheckAccessLevel(const aToken: string): boolean;
begin
  Result:=CheckAccessLevel( DeserializeToken( aToken ) );
end;
}
function TAutorization.CheckAccessLevel( const aTokenPayload: TJSONObject; const aArrayLevels: array of integer ): boolean;
var
  lTypeUser: integer;
  i: integer;
begin
  lTypeUser:=aTokenPayload.GetValue('typeuser').Value.ToInteger;
  Result:=False;
  for i := 0 to High(aArrayLevels) do
    Result:=Result or ( lTypeUser = aArrayLevels[i] );
end;
{
function TAutorization.CheckExpirationToken( const aToken: string ): boolean;
begin
  Result:=CheckExpirationToken( DeserializeToken( aToken ) );
end;
}
function TAutorization.CheckExpirationToken(
  const aTokenPayload: TJSONObject): boolean;
begin

  if (aTokenPayload.GetValue('erro') = nil) and (aTokenPayload.GetValue('expired') <> nil) then
    Result:= StrToBool( aTokenPayload.GetValue('expired').Value )
  else
    Result:=False;

end;

constructor TAutorization.Create( const aSecretSignature: string );
begin
  FSecretSignature:=aSecretSignature;
  FApplicationName:='';
end;

destructor TAutorization.Destroy;
begin

  inherited;
end;

//function TAutorization.Login(const aUser, aPassWord: string): TJSONObject;
function TAutorization.Login(aJSONParams: TJSONObject): System.JSON.TJSONObject;
var
  LToken: TJWT;
  LClaims: TMyClaims;
  lUser
  , lPassword: string;
begin

  lUser    :=aJSONParams.GetValue('user').Value;
  lPassword:=aJSONParams.GetValue('password').Value;

  with FConexaoDB
         .Query
         .SetSQL('SELECT * FROM USUARIO WHERE (NM_EMAIL = :NM_EMAIL OR CD_LOGIN = :CD_LOGIN) AND NM_SENHA = :NM_SENHA ')
         .SetParameter('NM_EMAIL',ftString,LowerCase(lUser))
         .SetParameter('CD_LOGIN',ftString,UpperCase(lUser))
         .SetParameter('NM_SENHA',ftString,lPassWord)
         .Open do
  begin

    if DataSet.IsEmpty then
      Result:=TJSONObject.Create.AddPair( TJSONPair.Create( 'Erro','Usuário e/ou senha inválidos' ) )
    else
    begin

      LToken := TJWT.Create(TMyClaims);
      try
        LClaims := LToken.Claims as TMyClaims;

        LClaims.IssuedAt   := Now;
        LClaims.Expiration := Now + TimeToExpirationToken;
        LClaims.Issuer     := 'BAPJr Systems';
        LClaims.AppIssuer  := Format('BAPJr Systems - %s',[FApplicationName]);

        LClaims.IdUser     := DataSet.FieldByName('ID_USUARIO').AsInteger;
        LClaims.TypeUser   := DataSet.FieldByName('ID_TPUSUARIO').AsInteger;

        Result:=TJSONObject.Create.AddPair( TJSONPair.Create( 'Token',TJOSE.SHA256CompactToken(FSecretSignature, LToken) ) );

      finally
        LToken.Free;
      end;

    end;

  end;

end;

class function TAutorization.New( const aSecretSignature: string ): IAutorization;
begin
  Result := Self.Create( aSecretSignature );
end;

function TAutorization.RevalidateToken(const aToken: string): TJSONObject;
var
  LToken: TJWT;
  LClaims: TMyClaims;
begin
  if ValidateToken( aToken ) then
  begin
    LToken := TJOSE.Verify(FSecretSignature, aToken, TMyClaims);

    LClaims := LToken.Claims as TMyClaims;

    LClaims.IssuedAt   := Now;
    LClaims.Expiration := Now + TimeToExpirationToken;

    Result:=TJSONObject.Create.AddPair( TJSONPair.Create( 'Token',TJOSE.SHA256CompactToken(FSecretSignature, LToken) ) );

  end
  else
    Result:=TJSONObject.Create.AddPair( TJSONPair.Create( 'Message', 'Token inválido' ) );

end;

function TAutorization.SetApplicationName(
  const aApplicationName: string): IAutorization;
begin
  FApplicationName:=aApplicationName;
  Result:=Self;
end;

function TAutorization.SetConexaoDB( const aConexaoDB: IModelConexaoDB ): IAutorization;
begin
  FConexaoDB:=aConexaoDB;
  Result:=Self;
end;

function TAutorization.SetConfigApp(
  const aConfigApp: TConfigApp): IAutorization;
begin
  FConfigApp:=aConfigApp;
  Result:=Self;
end;

{ TMyClaims }

function TMyClaims.GetAppIssuer: string;
begin
  Result := TJSONUtils.GetJSONValue('ais', FJSON).AsString;
end;

function TMyClaims.GetIdUser: integer;
begin
  Result := TJSONUtils.GetJSONValue('iduser', FJSON).AsInteger;
end;

function TMyClaims.GetTypeUser: integer;
begin
  Result := TJSONUtils.GetJSONValue('typeuser', FJSON).AsInteger;
end;

procedure TMyClaims.SetAppIssuer(const Value: string);
begin
  TJSONUtils.SetJSONValueFrom<string>('ais', Value, FJSON);
end;

procedure TMyClaims.SetIdUser(const Value: integer);
begin
  TJSONUtils.SetJSONValueFrom<integer>('iduser', Value, FJSON);
end;

procedure TMyClaims.SetTypeUser(const Value: integer);
begin
  TJSONUtils.SetJSONValueFrom<integer>('typeuser', Value, FJSON);
end;

end.
