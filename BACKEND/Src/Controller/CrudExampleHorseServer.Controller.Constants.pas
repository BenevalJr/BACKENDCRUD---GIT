unit CrudExampleHorseServer.Controller.Constants;

interface

type
  TProgressNotifyEvent = procedure(const aMaxProgressaProgress: integer; const aProgress: integer) of object;
  TCheckCancelNotifyEvent = function: boolean of object;

  TParamConnectionDB = record
    Database   : string;
    UserName   : string;
    Password   : string;
    DriverID   : string;
  end;

implementation

uses
  System.SysUtils;

initialization
  FormatSettings.ShortDateFormat:='dd/mm/yyyy';
  FormatSettings.LongDateFormat:='dddd, d'' de ''MMMM'' de ''yyyy';
  FormatSettings.ShortTimeFormat:='hh:mm';
  FormatSettings.LongTimeFormat:='hh:mm:ss';

  FormatSettings.ShortMonthNames[01] := 'Jan';
  FormatSettings.ShortMonthNames[02] := 'Fev';
  FormatSettings.ShortMonthNames[03] := 'Mar';
  FormatSettings.ShortMonthNames[04] := 'Abr';
  FormatSettings.ShortMonthNames[05] := 'Mai';
  FormatSettings.ShortMonthNames[06] := 'Jun';
  FormatSettings.ShortMonthNames[07] := 'Jul';
  FormatSettings.ShortMonthNames[08] := 'Ago';
  FormatSettings.ShortMonthNames[09] := 'Set';
  FormatSettings.ShortMonthNames[10] := 'Out';
  FormatSettings.ShortMonthNames[11] := 'Nov';
  FormatSettings.ShortMonthNames[12] := 'Dez';

  FormatSettings.LongMonthNames[01] := 'Janeiro';
  FormatSettings.LongMonthNames[02] := 'Fevereiro';
  FormatSettings.LongMonthNames[03] := 'Março';
  FormatSettings.LongMonthNames[04] := 'Abril';
  FormatSettings.LongMonthNames[05] := 'Maio';
  FormatSettings.LongMonthNames[06] := 'Junho';
  FormatSettings.LongMonthNames[07] := 'Julho';
  FormatSettings.LongMonthNames[08] := 'Agosto';
  FormatSettings.LongMonthNames[09] := 'Setembro';
  FormatSettings.LongMonthNames[10] := 'Outubro';
  FormatSettings.LongMonthNames[11] := 'Novembro';
  FormatSettings.LongMonthNames[12] := 'Dezembro';

end.
