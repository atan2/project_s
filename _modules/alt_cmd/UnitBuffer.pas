unit UnitBuffer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

const
  _LastColorInScheme = 0;

type
  TCmdSymbol = record
    symb : Char;
    color_fg : byte;
    color_bg : byte;
  end;

  TCmdBuffer = record
    symbols : array of array of TCmdSymbol;
    len_x : array of int64;
    len_y : int64;
  end;

var
  buffs : array of TCmdBuffer;

  procedure Buff_New(size_y, size_x : integer);
  procedure Buff_AddText(buff_num : integer; text : String; color_fg : byte = 0; color_bg : byte = 0);

implementation

//+ Buffers manager
  procedure Buff_New(size_y, size_x : integer);
  var
    i : integer;
  begin
    SetLength(buffs, length(buffs) + 1);
    SetLength(buffs[High(buffs)].symbols, size_y, size_x);
    SetLength(buffs[high(buffs)].len_x, size_y);
    for i := 0 to size_y - 1 do begin
      buffs[high(buffs)].len_x[i] := 0;
    end;
    buffs[High(buffs)].len_y := 1;
  end;
//-

//+ Buffer editing
  procedure Buff_AddText(buff_num : integer; text : String; color_fg : byte = 0; color_bg : byte = 0);
  var
    k : integer;
    i, j : integer;
  begin
    for k := 1 to Length(text) do begin
      if (text[k] = #10) or (buffs[buff_num].len_x[buffs[buff_num].len_y - 1] >= Length(buffs[buff_num].symbols[buffs[buff_num].len_y - 1])) then begin
        inc(buffs[buff_num].len_y);
      end;
      if (text[k] <> #13) and (text[k] <> #10) then begin
        inc(buffs[buff_num].len_x[buffs[buff_num].len_y - 1]);
        buffs[buff_num].symbols[buffs[buff_num].len_y - 1, buffs[buff_num].len_x[buffs[buff_num].len_y - 1] - 1].symb := text[k];
        buffs[buff_num].symbols[buffs[buff_num].len_y - 1, buffs[buff_num].len_x[buffs[buff_num].len_y - 1] - 1].color_fg := color_fg;
        buffs[buff_num].symbols[buffs[buff_num].len_y - 1, buffs[buff_num].len_x[buffs[buff_num].len_y - 1] - 1].color_bg := color_bg;
      end;
    end;
  end;
//-

end.
