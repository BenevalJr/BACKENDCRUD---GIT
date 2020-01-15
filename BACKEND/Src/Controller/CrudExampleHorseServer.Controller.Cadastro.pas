unit CrudExampleHorseServer.Controller.Cadastro;

interface

uses
  CrudExampleHorseServer.Model.Conexao.DB
  , Horse.ISAPI;

type
  IControllerCadastro = interface
    ['{B5BF6E50-40B0-4805-8B29-0E6A08D0E747}']
    function DoRequestsCadastro( aReq: THorseRequest; aRes: THorseResponse ): IControllerCadastro;
  end;

  TControllerCadastro = class(TInterfacedObject, IControllerCadastro)
  private
    { private declarations }
    FConexaoDB: IModelConexaoDB;
    procedure ListCadastro(aReq: THorseRequest; aRes: THorseResponse);
    procedure InsertCadastro(aReq: THorseRequest; aRes: THorseResponse);
    procedure UpdateCadastro(aReq: THorseRequest; aRes: THorseResponse);
    procedure DeleteCadastro(aReq: THorseRequest; aRes: THorseResponse);
  public
    { public declarations }
    class function New( const aConexaoDB: IModelConexaoDB ): IControllerCadastro;
    constructor Create( const aConexaoDB: IModelConexaoDB );
    destructor Destroy; override;

    function DoRequestsCadastro( aReq: THorseRequest; aRes: THorseResponse ): IControllerCadastro;

  end;

implementation

uses
  JOSE.Types.JSON
  , CrudExampleHorseServer.Model.DAO.Cadastro
  , Horse.Commons
  , Web.HTTPApp
  , System.JSON
  ;

const
  RestResource = '/user';

constructor TControllerCadastro.Create( const aConexaoDB: IModelConexaoDB );
begin
  FConexaoDB:=aConexaoDB;
end;

destructor TControllerCadastro.Destroy;
begin

  inherited;
end;

function TControllerCadastro.DoRequestsCadastro( aReq: THorseRequest; aRes: THorseResponse ): IControllerCadastro;
begin
  case aReq.MethodType of
    mtGet    : ListCadastro( aReq, aRes );
    mtPost   : InsertCadastro( aReq, aRes );
    mtPut    : UpdateCadastro( aReq, aRes );
    mtDelete : DeleteCadastro( aReq, aRes );
  end
end;

class function TControllerCadastro.New( const aConexaoDB: IModelConexaoDB ): IControllerCadastro;
begin
  Result := Self.Create( aConexaoDB );
end;

procedure TControllerCadastro.ListCadastro(aReq: THorseRequest; aRes: THorseResponse);
var
  lResultArray: TJSONArray;
  lResultObject: TJSONObject;
  lCountObjects: integer;
begin
  if aReq.Params.Count=0 then
  begin
    lResultArray:=TDAOCadastro.New(FConexaoDB).Find;
    lCountObjects:=lResultArray.Count;
    aRes.Send<TJSONArray>( lResultArray );
  end
  else
  begin
    lResultObject:=TDAOCadastro.New(FConexaoDB).Find( aReq.Params.Items['id'] );
    lCountObjects:=lResultObject.Count;
    aRes.Send<TJSONObject>( lResultObject );
  end;
  if lCountObjects=0 then
    aRes.Status(THTTPStatus.NotFound)
end;

procedure TControllerCadastro.InsertCadastro(aReq: THorseRequest; aRes: THorseResponse);
var
  lResult: TJSONObject;
begin
  lResult:=TDAOCadastro.New(FConexaoDB).Insert( aReq.Body<TJSONObject> );
  aRes.Send<TJSONObject>( lResult );
  if lResult.Count>0 then
    aRes.Status(THTTPStatus.Created);
end;

procedure TControllerCadastro.UpdateCadastro(aReq: THorseRequest; aRes: THorseResponse);
var
  lResult: TJSONObject;
  lStatus: THTTPStatus;
begin
  lStatus:=THTTPStatus.OK;
  lResult:=TDAOCadastro.New(FConexaoDB).Find( aReq.Body<TJSONObject>.GetValue('id').Value  );
  if lResult.Count=0 then
    lStatus:=THTTPStatus.NotFound
  else
    lResult:=TDAOCadastro.New(FConexaoDB).Update( aReq.Body<TJSONObject> );
  aRes.Send<TJSONObject>( lResult );
  aRes.Status(lStatus);
end;

procedure TControllerCadastro.DeleteCadastro(aReq: THorseRequest; aRes: THorseResponse);
var
  lResult: TJSONObject;
  lStatus: THTTPStatus;
begin
  lStatus:=THTTPStatus.OK;
  lResult:=TDAOCadastro.New(FConexaoDB).Find( aReq.Params.Items['id'] );
  if lResult.Count=0 then
    lStatus:=THTTPStatus.NotFound
  else
    lResult:=TDAOCadastro.New(FConexaoDB).Delete( aReq.Params.Items['id'] );
  aRes.Send<TJSONObject>( lResult );
  aRes.Status(lStatus);
end;

end.
