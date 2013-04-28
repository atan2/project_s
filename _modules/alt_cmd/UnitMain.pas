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
    imgScrollY: TImage;
    imgScrollX: TImage;
    Timer_FormResize: TTimer;
    ShapeResizeForm: TShape;
    procedure FormCreate(Sender: TObject);
    procedure PanelHatMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PanelHatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Timer_FormMoveTimer(Sender: TObject);
    procedure Timer_CursorUpdTimer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure Timer_FormResizeTimer(Sender: TObject);
    procedure ShapeResizeFormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShapeResizeFormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PanelHatDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  //+ View params
    color_bg : array[0..0] of TColor = (ClBlack);
    windowposdef_x : integer = 10;
    windowposdef_y : integer = 10;
    FontSizes : array[0..19] of integer = (1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 18, 22, 24, 32, 36, 42, 48, 60, 72);
    curfontsize : integer = 4;
  //-
  //+ Moving & resizing form
    windowpos_mdx : integer;
    windowpos_mdy : integer;
    window_oldx, window_oldy, window_oldw, window_oldh : integer;
    window_minw : integer = 120;
    window_minh : integer = 80;
    window_state : integer = 0; //0 - windowed, 1 - allclient, 2 - fullscreen
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
    if window_state <> 0 then begin
      exit;
    end;
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

//+ Resizing form
  procedure ResizeComplete;
  begin
    FormMain.ImgCmd.Picture.Graphic.Width := FormMain.ImgCmd.Width;
    FormMain.ImgCmd.Picture.Graphic.Height := FormMain.ImgCmd.Height;
    UnitDraw.DrawBuffer(buff_current, FormMain.ImgCmd, 0, 0);
    UnitDraw.Cursor_Draw(Formmain.ImgCmd.Canvas, cur.phase);
  end;

  procedure ResizeForm_AlClient;
  begin
    window_state := 1;
    FormMain.ShapeResizeForm.Hide;
    window_oldx := FormMain.Left;
    window_oldy := FormMain.Top;
    window_oldw := FormMain.Width;
    window_oldh := FormMain.Height;
    Application.ProcessMessages;
    FormMain.Align := alClient;
    FormMain.ShapeResizeForm.Show;
    ResizeComplete;
  end;

  procedure ResizeForm_AlFullScreen;
  begin
    window_state := 2;
    FormMain.ShapeResizeForm.Hide;
    FormMain.Align := alNone;
    window_oldx := FormMain.Left;
    window_oldy := FormMain.Top;
    window_oldw := FormMain.Width;
    window_oldh := FormMain.Height;
    FormMain.Left := 0;
    FormMain.Top := 0;
    FormMain.Width := Screen.Width;
    FormMain.Height := Screen.Height;
    FormMain.ShapeResizeForm.Show;
    ResizeComplete;
  end;

  procedure ResizeForm_AlWindow;
  begin
    window_state := 0;
    FormMain.ShapeResizeForm.Hide;
    FormMain.Align := alNone;
    FormMain.Left := window_oldx;
    FormMain.Top := window_oldy;
    FormMain.Width := window_oldw;
    FormMain.Height := window_oldh;
    FormMain.ShapeResizeForm.Show;
    ResizeComplete;
  end;

  procedure ResizeForm_Start;
  begin
    windowpos_mdx := FormMain.Left + FormMain.Width - Mouse.CursorPos.X;
    windowpos_mdy := FormMain.Top + FormMain.height - Mouse.CursorPos.Y;
    FormMain.Timer_FormResize.Enabled := true;
  end;

  procedure ResizeForm_Do;
  begin
    if (Mouse.CursorPos.X + windowpos_mdx - FormMain.Left > window_minw) then begin
      FormMain.Width := Mouse.CursorPos.X + windowpos_mdx - FormMain.Left;
    end else begin
      FormMain.Width := window_minw;
    end;
    if (Mouse.CursorPos.Y + windowpos_mdy - FormMain.Top > window_minh) then begin
      FormMain.Height := Mouse.CursorPos.Y + windowpos_mdy - FormMain.Top;
    end else begin
      FormMain.Height := window_minh;
    end;
  end;

  procedure ResizeForm_Stop;
  begin
    FormMain.Timer_FormResize.Enabled := false;
    ResizeComplete;
  end;
//-

procedure Init_1;
begin
  randomize;
  FormMain.Left := windowposdef_x;
  FormMain.Top := windowposdef_y;
  //+ Color set
    FormMain.ImgCmd.Canvas.Brush.Color := color_bg[0];
    FormMain.ImgCmd.Canvas.Pen.Color := color_bg[0];
    FormMain.ImgCmd.Canvas.Rectangle(0, 0, FormMain.ImgCmd.Width, FormMain.ImgCmd.Height);
    FormMain.PanelCmd.Color := color_bg[0];
  //-
  //+ Font set
    FormMain.ImgCmd.Canvas.Font := FormMain.Font;
    FormMain.ImgCmd.Canvas.Font.Size := FontSizes[curfontsize];
    window_oldx := FormMain.Left;
    window_oldy := FormMain.Top;
    window_oldw := FormMain.Width;
    window_oldh := FormMain.Height;
    //FormMain.DoubleBuffered := true;
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
  if FormMain.AlphaBlendValue = 255 then begin
    FormMain.AlphaBlend := false;
  end else begin
    FormMain.AlphaBlend := true;
  end;
end;

procedure WindowAlphaDown;
begin
  FormMain.AlphaBlend := true;
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

procedure TFormMain.PanelHatDblClick(Sender: TObject);
begin
  if window_state = 0 then begin
    ResizeForm_AlClient;
  end else begin
    ResizeForm_AlWindow;
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

procedure TFormMain.ShapeResizeFormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ResizeForm_Start;
end;

procedure TFormMain.ShapeResizeFormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ResizeForm_Stop;
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

procedure TFormMain.Timer_FormResizeTimer(Sender: TObject);
begin
  ResizeForm_Do;
end;

end.
