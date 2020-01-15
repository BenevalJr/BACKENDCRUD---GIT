unit CrudExampleHorseServer.Model.Conexao.DB;

interface

uses
  Data.DB
  , TBGConnection.View.Principal
  , System.Classes
  , TBGFiredacDriver.View.Driver

  , FireDAC.UI.Intf
  , FireDAC.VCLUI.Wait
  , FireDAC.Stan.Intf
  , FireDAC.Stan.Option
  , FireDAC.Stan.Error
  , FireDAC.Phys.Intf
  , FireDAC.Stan.Def
  , FireDAC.Stan.Pool
  , FireDAC.Stan.Async
  , FireDAC.Phys
  , FireDAC.Stan.Param
  , FireDAC.DatS
  , FireDAC.DApt.Intf
  , FireDAC.DApt
  , FireDAC.Phys.FBDef
  , FireDAC.Phys.IBBase
  , FireDAC.Phys.FB
  , FireDAC.Comp.DataSet
  , FireDAC.Comp.Client
  , FireDAC.Comp.UI

  , CrudExampleHorseServer.Controller.Constants

  , TBGQuery.View.Principal
  , SimpleInterface
  ;

type

  IModelQuery = interface
    ['{5485B3BC-E154-4689-82C6-0412B5A5DABE}']
    function DataSet : TDataSet;
    function SetSQL( aSQL: string ): IModelQuery; overload;
    function SetSQL( aSQL: string; const aArgs: array of const ): IModelQuery; overload;
    function SetParameter(const aParamName: string; const aTypeParam: TFieldType): IModelQuery; overload;
    function SetParameter(const aParamName: string; const aTypeParam: TFieldType; const aValueParam: string): IModelQuery; overload;
    function SetDataSource( DataSource: TDataSource ): IModelQuery;
    function Open: IModelQuery; overload;
    function Open( aSQL: string ): IModelQuery; overload;
    function Open( aSQL: string; const Args: array of const ): IModelQuery; overload;
    function OpenDataSetCheckIsEmpty: boolean;

    function ExecSQL(aSQLText: string): IModelQuery; overload;
    function ExecSQL(aSQLText: string; const aArgs: array of const): IModelQuery; overload;
    function BooleanSQL(aSQLText: string): boolean; overload;
    function BooleanSQL(aSQLText: string; const aArgs: array of const): boolean; overload;
    function IntegerSQL(aSQLText: string): integer; overload;
    function IntegerSQL(aSQLText: string; const aArgs: array of const): integer; overload;
    function NumberSQL(aSQLText: string): double; overload;
    function NumberSQL(aSQLText: string; const Args: array of const): double; overload;
    function StringSQL(aSQLText: string): string; overload;
    function StringSQL(aSQLText: string; const Args: array of const): string; overload;
  end;

  IModelConexaoDB = interface
    ['{ACCB041A-9A2E-4E57-B36C-2B2AA063B487}']
    function Connection : TTBGConnection;
    function Query: IModelQuery;
    function FDConnection: TFDConnection;
    function GetNextID(const aField: string): integer;
  end;

  IMySimpleQuery = interface
    ['{C533B898-F63E-4B16-AD0A-D79312D5AF48}']
    function SimpleQueryFireDac: ISimpleQuery;
  end;

  TModelConexaoDB = class(TInterfacedObject, IModelConexaoDB)
  private
    FConexaoDB : TTBGConnection;
    FFDConnection: TFDConnection;
    FBGFiredacDriverConexao: TBGFiredacDriverConexao;
  public
    constructor CreateNew( aParamConnectionDB: TParamConnectionDB );
    destructor Destroy; override;
    class function New( aParamConnectionDB: TParamConnectionDB ) : IModelConexaoDB;

    function Connection : TTBGConnection;
    function Query: IModelQuery;
    function FDConnection: TFDConnection;
    function GetNextID(const aField: string): integer;
    //function Owner: TComponent;
  end;

  TModelConexaoDBQuery = class(TInterfacedObject,IModelQuery)
  private
    FQuery : TTBGQuery;
    //FInternalDataSource: TDataSource;
  public
    constructor CreateNew( aConnection : IModelConexaoDB );
    destructor Destroy; override;
    class function New( aConnection : IModelConexaoDB ): IModelQuery; overload;

    function DataSet : TDataSet;

    function SetSQL( aSQL: string ): IModelQuery; overload;
    function SetSQL( aSQL: string; const aArgs: array of const ): IModelQuery; overload;

    function SetParameter(const aParamName: string; const aTypeParam: TFieldType): IModelQuery; overload;
    function SetParameter(const aParamName: string; const aTypeParam: TFieldType; const aValueParam: string): IModelQuery; overload;

    function SetDataSource( aDataSource: TDataSource ): IModelQuery;

    function Open: IModelQuery; overload;
    function Open( aSQL: string ): IModelQuery; overload;
    function Open( aSQL: string; const aArgs: array of const ): IModelQuery; overload;
    function OpenDataSetCheckIsEmpty: boolean;

    function ExecSQL(aSQLText: string): IModelQuery; overload;
    function ExecSQL(aSQLText: string; const aArgs: array of const): IModelQuery; overload;
    function BooleanSQL(aSQLText: string): boolean; overload;
    function BooleanSQL(aSQLText: string; const aArgs: array of const): boolean; overload;
    function IntegerSQL(aSQLText: string): integer; overload;
    function IntegerSQL(aSQLText: string; const aArgs: array of const): integer; overload;
    function NumberSQL(aSQLText: string): double; overload;
    function NumberSQL(aSQLText: string; const aArgs: array of const): double; overload;
    function StringSQL(aSQLText: string): string; overload;
    function StringSQL(aSQLText: string; const aArgs: array of const): string; overload;

  end;

  TMySimpleQuery = class(TInterfacedObject, IMySimpleQuery)
  private
    FConexaoDB: IModelConexaoDB;
    { private declarations }
  public
    { public declarations }
    class function New( aConexaoDB: IModelConexaoDB ) : IMySimpleQuery;
    constructor Create( aConexaoDB: IModelConexaoDB );
    destructor Destroy; override;

    function SimpleQueryFireDac: ISimpleQuery;
  end;

implementation

uses
  System.SysUtils, System.TypInfo, SimpleQueryFiredac;

{ TModelConexaoDB }

function TModelConexaoDB.Connection: TTBGConnection;
begin
  Result := FConexaoDB;
end;

constructor TModelConexaoDB.CreateNew( aParamConnectionDB: TParamConnectionDB );
begin
  FConexaoDB := TTBGConnection.Create;
  FBGFiredacDriverConexao := TBGFiredacDriverConexao.Create;
  FFDConnection := TFDConnection.Create(Nil);

  with FFDConnection do
  begin
    Params.Database   := aParamConnectionDB.Database;
    Params.UserName   := aParamConnectionDB.UserName;
    Params.Password   := aParamConnectionDB.Password;
    Params.DriverID   := aParamConnectionDB.DriverID;
  end;

  FBGFiredacDriverConexao.FConnection := FFDConnection;
  FConexaoDB.Driver := FBGFiredacDriverConexao;

end;

destructor TModelConexaoDB.Destroy;
begin
  inherited;
end;

function TModelConexaoDB.FDConnection: TFDConnection;
begin
  Result:=FFDConnection;
end;

function TModelConexaoDB.GetNextID(const aField: string): integer;
begin
  if FDConnection.Params.DriverID='FB' then
    Result:=Query.IntegerSQL(Format('SELECT GEN_ID(GEN_%s,1) FROM RDB$DATABASE',[aField]))
  else
    raise Exception.Create(Format('Erro ao recuperar NextID: %s',[aField]));
end;

class function TModelConexaoDB.New( aParamConnectionDB: TParamConnectionDB ): IModelConexaoDB;
begin
  Result := Self.CreateNew( aParamConnectionDB );
end;

function TModelConexaoDB.Query: IModelQuery;
begin
  Result:=TModelConexaoDBQuery.New( Self )
end;

{ TModelConexaoDBQuery }

function TModelConexaoDBQuery.BooleanSQL(aSQLText: string): boolean;
begin

  FQuery.Query.Open(aSQLText);
  Result:=Not (FQuery.Query.DataSet.IsEmpty);
  FQuery.Query.Close;

end;

function TModelConexaoDBQuery.BooleanSQL(aSQLText: string;
  const aArgs: array of const): boolean;
begin
  Result:=BooleanSQL(Format(aSQLText, aArgs));
end;

constructor TModelConexaoDBQuery.CreateNew(aConnection: IModelConexaoDB);
begin
  FQuery             :=TTBGQuery.Create;
  FQuery.Connection  :=aConnection.Connection;
  FQuery.DataSource  :=TDataSource.Create( Nil );
end;

destructor TModelConexaoDBQuery.Destroy;
begin
  FQuery.Query.Close;
  if Assigned( FQuery ) then
    FreeAndNil(FQuery);
  inherited;
end;

function TModelConexaoDBQuery.IntegerSQL(aSQLText: string): integer;
begin

  FQuery.Query.Open(aSQLText);
  if ( not (FQuery.Query.DataSet.IsEmpty) ) and ( not FQuery.Query.DataSet.Fields[0].IsNull ) then
    Result:=FQuery.Query.DataSet.Fields[0].AsInteger
  else
    Result:=-999999999;
  FQuery.Query.Close;

end;

function TModelConexaoDBQuery.IntegerSQL(aSQLText: string;
  const aArgs: array of const): integer;
begin
  Result:=IntegerSQL(Format(aSQLText,aArgs));
end;

class function TModelConexaoDBQuery.New( aConnection: IModelConexaoDB): IModelQuery;
begin
  Result := Self.CreateNew(aConnection);
end;

function TModelConexaoDBQuery.NumberSQL(aSQLText: string): double;
begin

  FQuery.Query.Open(aSQLText);
  if ( not (FQuery.Query.DataSet.IsEmpty) ) and ( not FQuery.Query.DataSet.Fields[0].IsNull ) then
    Result:=FQuery.Query.DataSet.Fields[0].AsFloat
  else
    Result:=-999999999999999999;
  FQuery.Query.Close;

end;

function TModelConexaoDBQuery.NumberSQL(aSQLText: string;
  const aArgs: array of const): double;
begin

  Result:=NumberSQL(Format(aSQLText,aArgs));

end;

function TModelConexaoDBQuery.Open: IModelQuery;
begin
  Result := Self;
  FQuery.Query.DataSet.Open;
end;

function TModelConexaoDBQuery.Open(aSQL: string): IModelQuery;
begin
  Result := Self;
  FQuery.Query.Open(aSQL);
end;

function TModelConexaoDBQuery.Open(aSQL: string;
  const aArgs: array of const): IModelQuery;
begin
  FQuery.Query.Open(Format(aSQL, aArgs));
  Result := Self;
end;

function TModelConexaoDBQuery.OpenDataSetCheckIsEmpty: boolean;
begin
  Open;
  Result := FQuery.Query.DataSet.IsEmpty;
end;

function TModelConexaoDBQuery.DataSet : TDataSet;
begin
  Result := FQuery.Query.DataSet;
end;

function TModelConexaoDBQuery.SetDataSource(
  aDataSource: TDataSource): IModelQuery;
begin
  Result := Self;
  aDataSource.DataSet:=FQuery.Query.DataSet;
end;

function TModelConexaoDBQuery.SetSQL(aSQL: String): IModelQuery;
begin
  Result := Self;
  FQuery.Query.SQL.Text:=aSQL;
end;

function TModelConexaoDBQuery.SetSQL(aSQL: String;
  const aArgs: array of const): IModelQuery;
begin
  Result := Self;
  SetSQL(Format(aSQL,aArgs));
end;

function TModelConexaoDBQuery.StringSQL(aSQLText: string): string;
begin

  FQuery.Query.Open(aSQLText);
  if ( not (FQuery.Query.DataSet.IsEmpty) ) and ( not FQuery.Query.DataSet.Fields[0].IsNull ) then
     Result:=FQuery.Query.DataSet.Fields[0].AsString;
  FQuery.Query.Close;

end;

function TModelConexaoDBQuery.StringSQL(aSQLText: string;
  const aArgs: array of const): string;
begin
  Result:=StringSQL(Format(aSQLText,aArgs));
end;

function TModelConexaoDBQuery.ExecSQL(aSQLText: string): IModelQuery;
begin
  Result:=Self;
  FQuery.Query.ExecSQL(aSQLText);
end;

function TModelConexaoDBQuery.ExecSQL(aSQLText: String;
  const aArgs: array of const): IModelQuery;
begin
  Result:=Self;
  ExecSQL(Format(aSQLText,aArgs));
end;

function TModelConexaoDBQuery.SetParameter(const aParamName: string;
  const aTypeParam: TFieldType): IModelQuery;
begin
  Result:=Self;
  if GetPropInfo(DataSet,'Params') = nil then
    raise Exception.CreateFmt('Erro Dataset %s não tem propriedade Params',[DataSet.Name])
  else if TFDQuery(DataSet).Params.FindParam(aParamName) = nil then
    TFDQuery(DataSet).Params.CreateParam(aTypePAram,aParamName,ptInput);

end;

function TModelConexaoDBQuery.SetParameter(const aParamName: string;
  const aTypeParam: TFieldType; const aValueParam: string): IModelQuery;
begin
  Result:=Self;
  SetParameter(aParamName,aTypeParam);
  TFDQuery(DataSet).ParamByName(aParamName).AsString:=aValueParam;
end;

{ TMySimpleQuery }

constructor TMySimpleQuery.Create( aConexaoDB: IModelConexaoDB );
begin
  FConexaoDB:=aConexaoDB;
end;

destructor TMySimpleQuery.Destroy;
begin

  inherited;
end;

class function TMySimpleQuery.New( aConexaoDB: IModelConexaoDB ) : IMySimpleQuery;
begin
  Result := Self.Create( aConexaoDB );
end;

function TMySimpleQuery.SimpleQueryFireDac: ISimpleQuery;
begin
  if FConexaoDB.FDConnection.Params.DriverID='FB' then
    Result:=TSimpleQueryFiredac.New( FConexaoDB.FDConnection );
end;

end.
