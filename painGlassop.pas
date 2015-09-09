unit painGlassop;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Menus, shellapi, Buttons;

  const
  WM_ICONTRAY = WM_USER + 1;

  type
  TForm1 = class(TForm)
    ColorDialog1: TColorDialog;
    GroupBox1: TGroupBox;
    Trans_track: TTrackBar;
    Trans_level: TEdit;
    Label1: TLabel;
    Panel2: TPanel;
    colour_box: TGroupBox;
    colourbox: TPanel;
    pickcolour: TButton;
    setColour: TButton;
    Panel1: TPanel;
    resize_cb: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    SpeedClick: TSpeedButton;
    Panecolour_shape: TShape;
    procedure pickcolourClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Trans_trackChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure setColourClick(Sender: TObject);
    procedure resize_cbClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ShowForm1Click(Sender: TObject);
    procedure HideForm1Click(Sender: TObject);
    procedure Trans_levelEnter(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure clickthrough(Sender: TObject);
    procedure SetTop();
    procedure OffTop();
  private
  loadfile : boolean;
  TrayIconData: TNotifyIconData;
  id1, id2, id3, id4: Integer;
  procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
    { Private declarations }
  public
    panecolour : TColor;
    procedure TrayMessage(var Msg: TMessage); message WM_ICONTRAY;
    { Public declarations }
  end;

type
   SettingsPane = Record
     colour : Tcolor;
     sizeW  : Integer;
     sizeH : Integer;
     BlendValue : integer;
     CustomColors: TStrings;
     resize : boolean;
  end;

var
  Form1: TForm1;

implementation

uses paneGlass;

{$R *.dfm}

function GetAveCharSizeCst(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of Char;
begin
  for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

function ShowMessageCst(ACaption: string): Boolean;
var
  Form: TForm;
  Prompt: TLabel;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight, X: Integer;
begin
  Result := False;
  Form := TForm.Create(Application);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSizeCst(Canvas);
      BorderStyle := bsDialog;
      Caption := Application.Title;
      Position := poScreenCenter;
      Prompt := TLabel.Create(Form);
      SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
      with Prompt do
      begin
        Parent := Form;
        Caption := ACaption;
        Left := MulDiv(8, DialogUnits.X, 4);
        Top := MulDiv(8, DialogUnits.Y, 8);
        Constraints.MaxWidth := MulDiv(164, DialogUnits.X, 4);
        WordWrap := False;
      end;
      ClientWidth := Prompt.Width + 16;
      X := Prompt.Width + 16;
      X := X div 2;
      ButtonTop := Prompt.Top + Prompt.Height + 15;
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := 'Ok';
        ModalResult := mrOk;
        Default := True;
        SetBounds(X , ButtonTop, ButtonWidth,ButtonHeight);
        Left := X - (Width div 2);
      end;
      ClientHeight:= 76;
      if ShowModal = mrOk then
         Result := True;
    finally
      Form.Free;
    end;
end;

function InputQueryCst(const ACaption, APrompt: string;
  var Value: string): Boolean;
var
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
begin
  Result := False;
  Form := TForm.Create(Application);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSizeCst(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      Position := poScreenCenter;
      Prompt := TLabel.Create(Form);
      SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
      with Prompt do
      begin
        Parent := Form;
        Caption := APrompt;
        Left := MulDiv(8, DialogUnits.X, 4);
        Top := MulDiv(8, DialogUnits.Y, 8);
        Constraints.MaxWidth := MulDiv(164, DialogUnits.X, 4);
        WordWrap := True;
      end;
      Edit := TEdit.Create(Form);
      with Edit do
      begin
        Parent := Form;
        Left := Prompt.Left;
        Top := Prompt.Top + Prompt.Height + 5;
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 255;
        Text := Value;
        SelectAll;
      end;
      ButtonTop := Edit.Top + Edit.Height + 15;
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := 'Ok';
        ModalResult := mrOk;
        Default := True;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := 'Cancel';
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(MulDiv(92, DialogUnits.X, 4), Edit.Top + Edit.Height + 15,
          ButtonWidth, ButtonHeight);
        Form.ClientHeight := Top + Height + 13;
      end;
      if ShowModal = mrOk then
      begin
        Value := Edit.Text;
        Result := True;
      end;
    finally
      Form.Free;
    end;
end;

function InputBoxCst(const ACaption, APrompt, ADefault: string): string;
begin
  Result := ADefault;
  InputQueryCst(ACaption, APrompt, Result);
end;

function IsStrANumber(const S: string): Boolean;
var
  P: PChar;
begin
  P      := PChar(S);
  Result := False;
  while P^ <> #0 do
  begin
    if not (P^ in ['0'..'9']) then Exit;
    Inc(P);
  end;
  Result := True;
end;

procedure TForm1.WMHotKey(var Msg: TWMHotKey);
begin
  if Msg.HotKey = id1 then
    if panefrm.ClickThrough then
      panefrm.DClickModeClick(panefrm.DClickMode)
    else
      panefrm.ClickThrough1Click(panefrm.ClickThrough1);
  if Msg.HotKey = id2 then
    if not form1.Visible and panefrm.ClickThrough then
     form1.Show;
  if Msg.HotKey = id3 then
    if panefrm.ClickThrough then
       if panefrm.onTop_CT then
         begin//set bottom
           panefrm.SetBottom();
           Offtop();
         end
       else//set top
         begin
           panefrm.SetTop();
           SetTop();
         end;

   if Msg.HotKey = id4 then
     if panefrm.ClickThrough then
       panefrm.exit1Click(panefrm.exit1);
end;

procedure TForm1.TrayMessage(var Msg: TMessage);
var
  p : TPoint;
begin
  case Msg.lParam of
    WM_LBUTTONDBLCLK :
    begin
       form1.Show;
    end;
    WM_LBUTTONDOWN:
    begin
      if not panefrm.ClickThrough then
      begin
        panefrm.Show;
        panefrm.BringToFront;
        Application.BringToFront;
      end
      else
       if not panefrm.onTop_CT then
         panefrm.SetTop();
    end;
    WM_RBUTTONDOWN:
    begin
       SetForegroundWindow(Handle);
       GetCursorPos(p);
       panefrm.PopupMenu1.Popup(p.x, p.y);
       PostMessage(Handle, WM_NULL, 0, 0);
    end;
  end;
end;

procedure TForm1.pickcolourClick(Sender: TObject);
begin
if colordialog1.Execute then
 begin
  panel1.Color := colordialog1.Color ;
  panecolour := colordialog1.Color;
  Panecolour_shape.Brush.Color := colordialog1.Color;
  Panecolour_shape.Pen.Color:=colordialog1.Color;
 { with panecolour_b.Canvas do
  begin
    Brush.Color := colordialog1.Color;
    FillRect(rect(0, 0, panecolour_b.Width, panecolour_b.Height));
  end;}
 end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
   settingFile : File of SettingsPane;
   settings : SettingsPane;
begin
assignfile(settingfile,'panesconfig.cfg');
ReWrite(settingFile);
settings.colour:= panefrm.Color;
settings.sizeW := panefrm.Width;
settings.sizeH := panefrm.Height;
settings.BlendValue := panefrm.AlphaBlendValue;
settings.CustomColors := ColorDialog1.CustomColors;
settings.resize := resize_cb.Checked;
colordialog1.CustomColors.SaveToFile('panecolours.cfg');
Write(settingFile, settings);
Closefile(settingfile);      
end;

procedure TForm1.Trans_trackChange(Sender: TObject);
begin
 Trans_level.Text:= inttostr(trans_track.position);
 panefrm.AlphaBlendValue:= trans_track.Position;
end;

procedure TForm1.FormCreate(Sender: TObject);
const
  MOD_ALT = 1;
  MOD_CONTROL = 2;
  MOD_SHIFT = 4;
  MOD_WIN = 8;
  VK_F4 = $73;
  VK_F1 = $70;
  VK_F2 = $71;
  VK_F3 = $72;
  VK_S = 83;
  VK_A = 65;
  VK_X = 88;
begin
  // Register Hotkey Ctrl + Shift + F1
  id1 := GlobalAddAtom('PoG_Hotkey1');
  if not RegisterHotKey(Handle, id1, MOD_SHIFT + MOD_CONTROL, VK_F1) then
    ShowMessage('Unable to assign Ctrl-Shift-F1 as hotkey.') ;
  id2 := GlobalAddAtom('PoG_Hotkey2');
  if not RegisterHotKey(Handle, id2, MOD_CONTROL+ MOD_ALT, VK_S) then
    ShowMessage('Unable to assign Ctrl-Alt-S as hotkey.') ;
    // Register Hotkey Win + F4
  id3 := GlobalAddAtom('PoG_Hotkey3');
  if not RegisterHotKey(Handle, id3, MOD_SHIFT + MOD_CONTROL, VK_F2) then
     ShowMessage ('Unable to assign Ctrl-Shift-F2 as hotkey.');
  id4 := GlobalAddAtom('PoG_Hotkey4');
  if not RegisterHotKey(Handle, id4, MOD_SHIFT + MOD_CONTROL + MOD_ALT, VK_X) then
     ShowMessage ('Unable to assign Ctrl-Shift-Alt-X as hotkey.');
  loadfile := true;
  with TrayIconData do
  begin
    cbSize := SizeOf(TrayIconData);
    Wnd := Handle;
    uID := 0;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := Application.Icon.Handle;
    StrPCopy(szTip, Application.Title);
  end;
  Shell_NotifyIcon(NIM_ADD, @TrayIconData);
end;

procedure TForm1.FormShow(Sender: TObject);
var
   settingFile : File of SettingsPane;
   settings : SettingsPane;
   size : integer;
begin
if loadfile then
  begin
  panefrm.AlphaBlend := true;
   if FileExists('panesconfig.cfg') then
    begin
       assignfile(settingfile,'panesconfig.cfg');
       Reset(settingfile);
       size := FileSize(settingfile);
       trans_level.Text := inttostr(size);
      while not Eof(settingfile) do
         begin
             Read(settingFile, settings);
             panefrm.Color:= settings.colour;
             panecolour := settings.colour;
             Panecolour_shape.Brush.Color := settings.colour;
             Panecolour_shape.Pen.Color := settings.colour;
             panel1.Color := settings.colour;
             panefrm.Width:= settings.sizeW;
             panefrm.Height:= settings.sizeH;
             panefrm.AlphaBlendValue:= settings.BlendValue;
             trans_track.Position := settings.blendvalue;
             trans_level.Text := inttostr(settings.blendvalue);
             resize_cb.Checked := settings.resize;
          end;
    CloseFile(settingFile);
    loadfile := false;
    end;
    if FileExists('panecolours.cfg') then
       ColorDialog1.CustomColors.LoadFromFile('panecolours.cfg');
    ShowWindow(Application.Handle, SW_HIDE);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
if panefrm.ClickThrough then
   panefrm.DClickModeClick(panefrm.DClickMode);
form1.Close;
halt;
end;

procedure TForm1.setColourClick(Sender: TObject);
begin
panefrm.Color:=panel1.Color;
end;

procedure TForm1.resize_cbClick(Sender: TObject);
begin
if resize_cb.Checked then
 begin
  panefrm.BorderStyle := bsSizeable;
  panefrm.Resize1.Checked := true;
 end
else
 begin
  panefrm.BorderStyle := bsNone;
  panefrm.Resize1.Checked := false;
 end;
if form1.Visible then
    form1.SetFocus;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
UnRegisterHotKey(Handle, id1);
GlobalDeleteAtom(id1);
UnRegisterHotKey(Handle, id2);
GlobalDeleteAtom(id2);
UnRegisterHotKey(Handle, id3);
GlobalDeleteAtom(id3);
UnRegisterHotKey(Handle, id4);
  GlobalDeleteAtom(id4);
end;

procedure TForm1.ShowForm1Click(Sender: TObject);
begin
form1.Show
end;

procedure TForm1.HideForm1Click(Sender: TObject);
begin
form1.Hide;
panefrm.BringToFront;
//if
end;

procedure TForm1.Trans_levelEnter(Sender: TObject);
var new_Trans_level : integer;
begin
if IsStrANumber(Trans_level.Text) then
   begin
     new_Trans_level := strtoint(trans_level.Text);
     if (new_Trans_level < 64) or (new_Trans_level > 255) then
        ShowMessageCst('New Transparency Level not valid number.')
     else
        Trans_track.Position := new_Trans_level;
    end
else
   ShowMessageCst('New Transparency Level not valid number.')
end;

procedure TForm1.Button3Click(Sender: TObject);
var
value: string;
new_Trans_level : integer;
begin
value := InputBoxCst('New Transparency Level', 'Please enter the new Transparency Value from 64-255.', Trans_level.Text);
if  Length(value) < 5 then
 begin
  if IsStrANumber(value) then
     begin
         new_Trans_level := strtoint(value);
         if (new_Trans_level < 64) or (new_Trans_level > 255) then
             ShowMessageCst('New Transparency Level not valid number.')
         else
           begin
              Trans_track.Position := new_Trans_level;
              trans_level.Text := value;
           end;
       end
  else
     ShowMessageCst('New Transparency Level not a number.');
 end
else
  ShowMessageCst('Too many characters entered.')
end;

procedure TForm1.clickthrough(Sender: TObject);
begin
panefrm.ResizePaneForScreen(panefrm.ClickThrough1.Tag);
end;

procedure TForm1.SetTop();
begin
SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TForm1.OffTop();
begin
SetWindowPos(Handle,HWND_BOTTOM,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

end.
