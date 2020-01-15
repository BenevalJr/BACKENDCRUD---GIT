unit CrudExampleHorseServer.Model.DAO.Cadastro;

interface

uses
  System.JSON
  , SimpleInterface
  , CrudExampleHorseServer.Model.Entidade.Cadastro
  , Data.DB
  , CrudExampleHorseServer.Model.Conexao.DB
  ;

type
  IDAOCadastro = interface
    ['{A2BF087C-8466-4413-94D0-56B2ECC25217}']
    function Find: TJsonArray; overload;
    function Find( const aID: string ): TJSONObject; overload;
    function Insert( const aJSONParams: TJSONObject ): TJSONObject;
    function Update( const aJSONParams: TJSONObject ): TJSONObject;
    function Delete( const aID: string ): TJSONObject;
  end;

  TDAOCadastro = class(TInterfacedObject, IDAOCadastro)
  private
    { private declarations }
    FDataSourceInternal: TDataSource;
    FDAOCadastro: iSimpleDAO<TCADASTRO>;
    FConexaoDB: IModelConexaoDB;
  protected
    { protected declarations }
  public
    { public declarations }
    class function New( const aConexaoDB: IModelConexaoDB ): IDAOCadastro;
    constructor Create( const aConexaoDB: IModelConexaoDB );
    destructor Destroy; override;

    function Find: TJsonArray; overload;
    function Find( const aID: string ): TJSONObject; overload;
    function Insert( const aJSONParams: TJSONObject ): TJSONObject;
    function Update( const aJSONParams: TJSONObject ): TJSONObject;
    function Delete( const aID: string ): TJSONObject;

  end;

implementation

uses
  SimpleDAO
  , DataSetConverter4D
  , DataSetConverter4D.Util
  , DataSetConverter4D.Helper
  , DataSetConverter4D.Impl
  , Rest.Json
  , System.SysUtils
  , MyJSONObjectHelper
  ;

constructor TDAOCadastro.Create( const aConexaoDB: IModelConexaoDB );
begin
  FDataSourceInternal:=TDataSource.Create(Nil);
  FConexaoDB         :=aConexaoDB;
  FDAOCadastro       := TSimpleDAO<TCADASTRO>
                          .New( TMySimpleQuery.New( FConexaoDB ).SimpleQueryFireDac )
                          .DataSource( FDataSourceInternal );
end;

destructor TDAOCadastro.Destroy;
begin
  if Assigned(FDataSourceInternal) then
    FreeAndNil(FDataSourceInternal);
  inherited;
end;

function TDAOCadastro.Find: TJsonArray;
begin
  FDAOCadastro.SQL.OrderBy('Name').&End.Find;
  if FDataSourceInternal.DataSet.IsEmpty then
  begin
    Result:=TJSONArray.Create;
    Result.AddElement( TJSONObject.Create )
  end
  else
    Result:=TMyJSONObjectFunctions.AsLowerCasePath( FDataSourceInternal.DataSet.AsJSONArray );
end;

function TDAOCadastro.Find(const aID: string): TJSONObject;
begin
  FDAOCadastro.Find( aID.ToInteger );
  if FDataSourceInternal.DataSet.IsEmpty then
    Result:=TJSONObject.Create
  else
    Result:=TMyJSONObjectFunctions.AsLowerCasePath( FDataSourceInternal.DataSet.AsJSONObject );
end;

function TDAOCadastro.Insert(const aJSONParams: TJSONObject): TJSONObject;
var
  lCadastro: TCADASTRO;
begin
  lCadastro:=TCADASTRO.Create;
  try
    lCadastro:=TJson.JsonToObject<TCADASTRO>( TMyJSONObjectFunctions.AsUpperCasePath( aJSONParams ) );
    lCadastro.ID:=FConexaoDB.GetNextID('ID_CADASTRO');
    FDAOCadastro.Insert( lCadastro );
    Result:=TMyJSONObjectFunctions.AsLowerCasePath( Self.Find( lCadastro.ID.ToString ) );
  finally
    FreeAndNil(lCadastro);
  end;
end;

function TDAOCadastro.Update( const aJSONParams: TJSONObject ): TJSONObject;
var
  lCadastro: TCADASTRO;
begin
  lCadastro:=TCADASTRO.Create;
  try
    lCadastro:=TJson.JsonToObject<TCADASTRO>( TMyJSONObjectFunctions.AsUpperCasePath( aJSONParams ) );
    FDAOCadastro.Update( lCadastro );
    Result:=TMyJSONObjectFunctions.AsLowerCasePath( Self.Find( lCadastro.ID.ToString ) );
  finally
    FreeAndNil(lCadastro);
  end;
end;

function TDAOCadastro.Delete(const aID: string): TJSONObject;
var
  lCadastro: TCADASTRO;
begin
  lCadastro:=TCADASTRO.Create;
  try
    lCadastro.ID:=aID.ToInteger;
    FDAOCadastro.Delete(lCadastro);
    Result:=TJSONObject.Create;
  finally
    FreeAndNil(lCadastro);
  end;
end;

class function TDAOCadastro.New( const aConexaoDB: IModelConexaoDB ): IDAOCadastro;
begin
  Result := Self.Create( aConexaoDB );
end;

end.
