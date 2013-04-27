unit UnitMain;

interface

uses
  UnitBuffer, UnitDraw, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Math;

type
  TFormMain = class(TForm)
    PanelCmd: TPanel;
    ImgCmd: TImage;
    PanelHat: TPanel;
    Timer_FormMove: TTimer;
    Timer_CursorUpd: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure PanelHatMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PanelHatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Timer_FormMoveTimer(Sender: TObject);
    procedure Timer_CursorUpdTimer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  //+ View params
    delta_pixw : integer = 4;
    color_bg : array[0..0] of TColor = (ClBlack);
    windowposdef_x : integer = 10;
    windowposdef_y : integer = 10;
    FontSizes : array[0..19] of integer = (1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 18, 22, 24, 32, 36, 42, 48, 60, 72);
    curfontsize : integer = 4;
  //-
  //+ Moving form
    windowpos_mdx : integer;
    windowpos_mdy : integer;
  //-
  //+ Buffers
    buff_current : integer; //����� �������� �������
  //-


implementation

{$R *.dfm}

function KeyState(key : Word) : boolean;
var
  KeyState : Word;
begin
  KeyState := GetKeyState(key);
  result := (KeyState and $8000 = $8000);
end;

//+ Moving form
  procedure MoveForm_Start;
  begin
    windowpos_mdx := FormMain.Left - Mouse.CursorPos.X;
    windowpos_mdy := FormMain.Top - Mouse.CursorPos.Y;
    FormMain.Timer_FormMove.Enabled := true;
  end;

  procedure MoveForm_Do;
  begin
    FormMain.Left := Mouse.CursorPos.X + windowpos_mdx;
    FormMain.Top := Mouse.CursorPos.Y + windowpos_mdy;
  end;

  procedure MoveForm_Stop;
  begin
    FormMain.Timer_FormMove.Enabled := false;
  end;
//-

procedure Init_1;
begin
  FormMain.Left := windowposdef_x;
  FormMain.Top := windowposdef_y;
  FormMain.ImgCmd.Left := delta_pixw;
  FormMain.ImgCmd.Top := 0;
  FormMain.ImgCmd.Width := FormMain.PanelCmd.Width - delta_pixw * 2;
  FormMain.ImgCmd.Height := FormMain.PanelCmd.Height - delta_pixw;
  //+ Color set
    FormMain.ImgCmd.Canvas.Brush.Color := color_bg[0];
    FormMain.ImgCmd.Canvas.Pen.Color := color_bg[0];
    FormMain.ImgCmd.Canvas.Rectangle(0, 0, FormMain.ImgCmd.Width, FormMain.ImgCmd.Height);
    FormMain.PanelCmd.Color := FormMain.PanelHat.Color;
  //-
  //+ Font set
    FormMain.ImgCmd.Canvas.Font := FormMain.Font;
    FormMain.ImgCmd.Canvas.Font.Size := FontSizes[curfontsize];
  //-
end;

procedure Init_2;
begin
  UnitBuffer.Buff_New(3000, 32);
  buff_current := 0;
  Cursor_Init(FormMain.ImgCmd.Canvas);
end;

procedure Init_Finish;
begin
  FormMain.Timer_CursorUpd.Enabled := true;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Init_1;
  Init_2;
  Init_Finish;
end;

procedure TFormMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  UnitBuffer.Buff_AddText(buff_current, Key);
  Cursor_SetPos(FormMain.ImgCmd.Canvas, buffs[buff_current].len_y - 1, buffs[buff_current].len_x[buffs[buff_current].len_y - 1]);
  UnitDraw.DrawBuffer(buff_current, FormMain.ImgCmd, 0, 0);
  UnitDraw.Cursor_Draw(Formmain.ImgCmd.Canvas, cur.phase);
end;

//+ Resizing text
procedure TextBigger;
begin
  if curfontsize = 0 then begin
    exit;
  end;
  dec(curfontsize);
  FormMain.ImgCmd.Canvas.Font.Size := FontSizes[curfontsize];
  Cursor_ReInit(FormMain.ImgCmd.Canvas);
  UnitDraw.DrawBuffer(buff_current, FormMain.ImgCmd, 0, 0);
  UnitDraw.Cursor_Draw(Formmain.ImgCmd.Canvas, cur.phase);
end;

procedure TextSmaller;
begin
  if curfontsize = High(FontSizes) then begin
    exit;
  end;
  inc(curfontsize);
  FormMain.ImgCmd.Canvas.Font.Size := FontSizes[curfontsize];
  Cursor_ReInit(FormMain.ImgCmd.Canvas);
  UnitDraw.DrawBuffer(buff_current, FormMain.ImgCmd, 0, 0);
  UnitDraw.Cursor_Draw(Formmain.ImgCmd.Canvas, cur.phase);
end;
//-

//+ Window AlphaBlend
procedure WindowAlphaUp;
begin
  FormMain.AlphaBlendValue := Min(255, FormMain.AlphaBlendValue + 10);
end;

procedure WindowAlphaDown;
begin
  FormMain.AlphaBlendValue := Max(10, FormMain.AlphaBlendValue - 10);
end;
//-

procedure TFormMain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if KeyState(VK_CONTROL) then begin
    TextBigger;
    exit;
  end;
  if KeyState(VK_SHIFT) then begin
    WindowAlphaDown;
    exit;
  end;
end;

procedure TFormMain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if KeyState(VK_CONTROL) then begin
    TextSmaller;
    exit;
  end;
  if KeyState(VK_SHIFT) then begin
    WindowAlphaUp;
    exit;
  end;
end;

procedure TFormMain.PanelHatMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MoveForm_Start;
end;

procedure TFormMain.PanelHatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MoveForm_Stop;
end;

procedure TFormMain.Timer_CursorUpdTimer(Sender: TObject);
begin
  UnitDraw.Cursor_Flash;
  UnitDraw.Cursor_Draw(Formmain.ImgCmd.Canvas, cur.phase);
end;

procedure TFormMain.Timer_FormMoveTimer(Sender: TObject);
begin
  MoveForm_Do;
end;

end.
