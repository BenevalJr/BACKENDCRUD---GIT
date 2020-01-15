unit CrudExampleHorseServer.Model.Entidade.Cadastro;

interface

uses
  SimpleAttributes;

type

  TCADASTRO = class
  private
    FID: Integer;
    FNAME: string;
    FEMAIL: string;
    procedure SetID(const aValue: Integer);
    procedure SetNAME(const aValue: string);
    procedure SetEMAIL(const aValue: string);
    function GetThis: TCADASTRO;
  public
    constructor Create;
    destructor Destroy; override;
  published
    [PK]
    property ID: Integer read FID write SetID;
    property NAME: string read FNAME write SetName;
    property EMAIL: string read FEMAIL write SetEmail;
  end;

implementation

{ TCADASTRO }

constructor TCADASTRO.Create;
begin

end;

destructor TCADASTRO.Destroy;
begin

  inherited;
end;

function TCADASTRO.GetThis: TCADASTRO;
begin
  Result:=Self;
end;

procedure TCADASTRO.SetEmail(const aValue: string);
begin
  FEmail := aValue;
end;

procedure TCADASTRO.SetID(const aValue: Integer);
begin
  FID := aValue;
end;

procedure TCADASTRO.SetName(const aValue: string);
begin
  FName := aValue;
end;
{
procedure TForm9.btnFindClick(Sender: TObject);
var
  Pedidos : TList<TPEDIDO>;
  Pedido : TPEDIDO;
begin
  Pedidos := DAOPedido.SQL.OrderBy('ID').&End.Find;
  try
    for Pedido in Pedidos do
    begin
      Memo1.Lines.Add(Pedido.NOME + DateToStr(Pedido.DATA));
    end;
  finally
    Pedidos.Free;
  end;
end;

  , DataSetConverter4D
  , DataSetConverter4D.Util
  , DataSetConverter4D.Helper
  , DataSetConverter4D.Impl

}
end.
