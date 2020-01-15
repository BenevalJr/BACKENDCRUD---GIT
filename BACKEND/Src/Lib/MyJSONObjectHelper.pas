unit MyJSONObjectHelper;

interface

uses
  System.JSON;

type
  TMyJSONObjectFunctions = class
  public
   class function AsLowerCasePath( const aJSONObject: TJSONObject ): TJSONObject; overload;
   class function AsLowerCasePath( const aJSONArray: TJSONArray ): TJSONArray; overload;
   class function AsUpperCasePath( const aJSONObject: TJSONObject ): TJSONObject; overload;
   class function AsUpperCasePath( const aJSONArray: TJSONArray ): TJSONArray; overload;
  end;


implementation

uses
  System.SysUtils
  , System.Generics.Collections
  ;

{ TMyJSONObjectFunctions }

class function TMyJSONObjectFunctions.AsLowerCasePath(
  const aJSONArray: TJSONArray): TJSONArray;
var
  i: Integer;
begin
  Result:=TJSONArray.Create;
  for i := 0 to aJSONArray.Count-1 do
    Result.AddElement( AsLowerCasePath( TJSONObject( aJSONArray.Items[i] ) ) );
end;

class function TMyJSONObjectFunctions.AsUpperCasePath(
  const aJSONArray: TJSONArray): TJSONArray;
var
  i: Integer;
begin
  Result:=TJSONArray.Create;
  for i := 0 to aJSONArray.Count-1 do
    Result.AddElement( AsLowerCasePath( TJSONObject( aJSONArray.Items[i] ) ) );
end;

class function TMyJSONObjectFunctions.AsUpperCasePath(
  const aJSONObject: TJSONObject): TJSONObject;
var
  i: Integer;
begin
  Result:=TJSONObject.Create;
  for i := 0 to aJSONObject.Count-1 do
    Result.AddPair( UpperCase( aJSONObject.Pairs[i].JsonString.Value ), aJSONObject.Pairs[i].JsonValue.Value );
end;

class function TMyJSONObjectFunctions.AsLowerCasePath(
  const aJSONObject: TJSONObject): TJSONObject;
var
  i: Integer;
begin
  Result:=TJSONObject.Create;
  for i := 0 to aJSONObject.Count-1 do
    Result.AddPair( LowerCase( aJSONObject.Pairs[i].JsonString.Value ), aJSONObject.Pairs[i].JsonValue.Value );
end;

end.
