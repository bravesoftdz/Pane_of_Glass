unit paneGlass;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Buttons, StdCtrls, ExtCtrls;

type
  Tpanefrm = class(TForm)
    PopupMenu1: TPopupMenu;
    exit1: TMenuItem;
    Ontop1: TMenuItem;
    Resize1: TMenuItem;
    Settings1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    ClickThrough1: TMenuItem;
    click1: TMenuItem;
    a1: TMenuItem;
    b1: TMenuItem;
    c1: TMenuItem;
    d1: TMenuItem;
    DClickMode: TMenuItem;
    e1: TMenuItem;
    f_b: TMenuItem;
    FSmode: TMenuItem;
    f1: TMenuItem;
    procedure FormDblClick(Sender: TObject);
    procedure exit1Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Ontop1Click(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ClickThrough1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    //procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WMMove(var Message: TMessage) ; message WM_MOVE;
    procedure resizepanefrm();
    procedure panefrmsize();
    procedure ResizePaneForScreen(mode : integer);
    procedure a1Click(Sender: TObject);
    procedure b1Click(Sender: TObject);
    procedure c1Click(Sender: TObject);
    procedure d1Click(Sender: TObject);
    procedure ClickThroughMode_ED(Sender: TObject);
    procedure VHPopupMenuItems(value: boolean);
    procedure DClickModeClick(Sender: TObject);
    procedure e1Click(Sender: TObject);
    procedure SetBottom();
    procedure SetTop();
    procedure f_bClick(Sender: TObject);
    procedure HideAltTab(mode: integer);
    procedure FSmodeClick(Sender: TObject);
    procedure f1Click(Sender: TObject);
  private
     { Private declarations }
     posT,posL,posW,posH : integer;
     ClickWindowT,ClickWindowL : integer;
     Rpane, OntopNow,ResizedDone,MultiMon : boolean;
     windowStyle : integer;
 public
    ClickThrough,onTop_CT : boolean;
    { Public declarations }
  end;
const
  f_txt = 'Bring Pane to Front';
  b_txt = 'Send Pane to Back';
var
  panefrm: Tpanefrm;

implementation

uses painGlassop;

{$R *.dfm}

procedure Tpanefrm.HideAltTab(mode: integer);
begin
if mode = 1 then
 begin
  windowStyle := GetWindowLong(Handle, GWL_EXSTYLE);
  SetWindowLong(Handle, GWL_EXSTYLE, windowStyle or WS_EX_TOOLWINDOW);
 end;
 if mode = 2 then
  SetWindowLong(Handle, GWL_EXSTYLE, windowStyle);
end;

procedure Tpanefrm.SetBottom();
begin
SetWindowPos(Handle,HWND_BOTTOM,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
onTop_CT := false;
f_b.Caption := f_txt;
end;

procedure Tpanefrm.SetTop();
begin
SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
onTop_CT := true;
f_b.Caption := b_txt;
end;

procedure Tpanefrm.FormCreate(Sender: TObject);
begin
MultiMon:=false;
f1.Visible := false;
SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_LAYERED);
ClickThrough := false;
onTop_CT := false;
ResizedDone := false;
settings1.ShortCut := ShortCut(Word('S'), [ssAlt, ssShift]);
if screen.MonitorCount > 1 then
  begin
    MultiMon := true;
    f1.Visible := true;
    f1.ShortCut := ShortCut(Word('A'), [ssCtrl]);
  end;
end;

procedure paneresizeable();
begin
panefrm.BorderStyle := bsnone;
panefrm.resize1.Checked := false;
form1.resize_cb.Checked := false;
end;

procedure Tpanefrm.FormDblClick(Sender: TObject);
begin
if not clickthrough then
begin
 if panefrm.BorderStyle = bssizeable then
     paneresizeable()
 else
  begin
   panefrm.BorderStyle := bssizeable;
   resize1.Checked := true;
   form1.resize_cb.Checked := true;
  end;
 end;
end;

procedure Tpanefrm.exit1Click(Sender: TObject);
begin
if ClickThrough then
   DClickModeClick(panefrm.DClickMode);
form1.Button1Click(Sender);
end;

procedure Tpanefrm.resizepanefrm();
begin
   panefrm.Constraints.MinHeight:= 100;
   panefrm.Constraints.MinWidth := 100;
   panefrm.Top := panefrm.posT;
   panefrm.Left := panefrm.posL;
   panefrm.Width := panefrm.posW;
   panefrm.Height := panefrm.posH;
end;

procedure Tpanefrm.panefrmsize();
begin
   posT := panefrm.Top;
   posL := panefrm.Left;
   posW := panefrm.Width;
   posH := panefrm.Height;
end;

procedure moveform();
const
SL_DRAGMOVE=$F012;
begin
ReleaseCapture;
panefrm.Perform(WM_SYSCOMMAND, SL_DRAGMOVE,0);
end;

procedure Tpanefrm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if not clickthrough then
 begin
   if BUTTON = mbleft then
      moveform();
 end;
end;

procedure Tpanefrm.Ontop1Click(Sender: TObject);
begin
 if ontop1.Checked then
  begin
    ontop1.Checked := false;
    panefrm.FormStyle := fsNormal;
  end
 else
  begin
    ontop1.Checked := true;
    panefrm.FormStyle := fsStayOnTop;
    panefrm.BringToFront;
  end;
end;

procedure Tpanefrm.Settings1Click(Sender: TObject);
begin
form1.Show;
end;


procedure Tpanefrm.FormShow(Sender: TObject);
begin
form1.BringToFront
end;

procedure ClickThroughMode(Sender: TObject);
begin
panefrm.Rpane := false;
panefrm.OntopNow := false;
if panefrm.Ontop1.checked then
  begin
    panefrm.OntopNow := true;
    panefrm.Ontop1Click(panefrm.Ontop1);
  end;
if panefrm.BorderStyle = bssizeable then
  begin
    paneresizeable();
    panefrm.Rpane := true;
  end;
end;

procedure Tpanefrm.VHPopupMenuItems(value: boolean);
begin
ontop1.Visible := value;
resize1.Visible := value;
ClickThrough1.Visible := value;
DClickMode.Visible := not value;
f_b.Visible := not value;
click1.Visible := value;
e1.Visible := value;
form1.resize_cb.Enabled := value;
form1.SpeedClick.Enabled := value;
FSmode.Visible := value;
if MultiMon then
  f1.Visible := value;

if value then
  exit1.ShortCut := ShortCut(Word('X'), [ssAlt])
else
    exit1.ShortCut := 0;
end;

procedure Tpanefrm.ClickThroughMode_ED(Sender: TObject);
begin
if ClickThrough then
    begin //enable clicktrhough mode

       ClickThroughMode(sender); //sets pane to none resizeable and on ontop
       // sets click throughable
       SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_TRANSPARENT or WS_EX_LAYERED);
       ShowWindow(Application.Handle, SW_HIDE);
       //hides popup menu functions menu function
       VHPopupMenuItems(false);
       if form1.Visible then
         form1.Hide;
       //sets window as top screen mode
       SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
       form1.SetTop();
       onTop_CT := true;
       HideAltTab(1);
    end
else
    begin //disable click through
     //disable top most window.
     HideAltTab(2);
     SetWindowPos(Handle,HWND_BOTTOM,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
     form1.OffTop();
     //stops click throught mode
     SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_LAYERED);
     //ShowWindow(Application.Handle, SW_SHOW);
     panefrm.WindowState := wsNormal;
     VHPopupMenuItems(true);
     resizepanefrm();
     onTop_CT := false;
    end;
end;

procedure Tpanefrm.ClickThrough1Click(Sender: TObject);
begin
ResizePaneForScreen(ClickThrough1.Tag);
end;


{*procedure Tpanefrm.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
     msg.MinMaxInfo.ptMaxSize.X := Screen.WorkAreaWidth;
     msg.MinMaxInfo.ptMaxSize.Y := Screen.WorkAreaHeight;
   // msg.MinMaxInfo.ptMaxSize.X :=     * 1440 div Screen.PixelsPerInch;
   inherited
end;*}


procedure Tpanefrm.WMMove(var Message: TMessage) ;
begin
if ClickThrough and ResizedDone then
   begin
     panefrm.Top  := ClickWindowT;
     panefrm.Left := ClickWindowL;
 end;
end; (*WMMove*)

procedure Tpanefrm.ResizePaneForScreen(mode : integer);
var Mver,Mhor : integer;
    Mwidth, Mheight, Mtop, Mleft : integer;
    i : integer;
    MontInfo : TMonitor;
begin
//0 horizonal left
//1 horizonal right
//2 vertical top
//3 vertical bottom
//4 full work area
//5 click through mode
//6 Full screen
//7 Full screens, all displays.

//even number base at (0,0)

MontInfo := Screen.MonitorFromWindow(Self.Handle);
{Mheight :=  Screen.Height;
Mheight := Screen.WorkAreaHeight;
Mwidth := Screen.WorkAreaWidth;
Mtop := Screen.WorkAreaTop;
Mleft := Screen.WorkAreaLeft;

if Screen.MonitorCount > 1 then
  begin  //multi mointor set up}
    Mwidth := MontInfo.WorkareaRect.Right - MontInfo.WorkareaRect.Left;
    Mheight:= MontInfo.WorkareaRect.Bottom - MontInfo.WorkareaRect.Top;
    Mtop := MontInfo.WorkareaRect.Top;
    Mleft := MontInfo.WorkareaRect.Left;
//  end;
Mhor := Mwidth div 2;
Mver := Mheight div 2;

//saves current size
panefrmsize();
//ClickWindowT := Screen.WorkAreaTop;
ClickWindowT := Mtop;
ClickWindowL := Mleft;
ClickThrough := true;

case mode of
0: begin
     panefrm.Width := Mhor;
     panefrm.Height := Mheight;
     panefrm.Top := Mtop;
     panefrm.Left := Mleft;
   end;
1: begin
     panefrm.Width := Mhor;
     panefrm.Height := Mheight;
     panefrm.Top := Mtop;
     panefrm.Left := Mhor + Mleft;
     ClickWindowL := panefrm.Left;
   end;
2: begin
     panefrm.Width := Mwidth;
     panefrm.Height := Mver;
     panefrm.Top := MTop;
     panefrm.Left := MLeft;
   end;
3: begin
    panefrm.Width :=Mwidth;
    panefrm.Height := Mver;
    panefrm.Top := Mver + Mtop;
    panefrm.Left := Mleft;
    ClickWindowT := panefrm.Top;
   end;
4: begin
      panefrm.Width := Mwidth;
      panefrm.Height := MHeight;
      panefrm.Top := MTop;
      panefrm.Left := Mleft;
   end;
5: begin
    ClickWindowT := panefrm.Top;
    ClickWindowL := panefrm.Left;
   end;
6: begin
     panefrm.Width := MontInfo.Width;
     panefrm.Height := MontInfo.Height;
     panefrm.Top := MontInfo.Top;
     panefrm.Left := MontInfo.left;
   end;
7: begin
     panefrm.Width := Screen.DesktopWidth;
     panefrm.Height := Screen.DesktopHeight;
     panefrm.Top := Screen.DesktopTop;
     panefrm.Left := Screen.DesktopLeft;
   end;
else null;
end;//case
ClickThroughMode_ED(panefrm);
panefrm.Constraints.MinHeight := panefrm.Height;
panefrm.Constraints.MinWidth := panefrm.Width;
ResizedDone := true;
end;

procedure Tpanefrm.a1Click(Sender: TObject);
begin
ResizePaneForScreen(a1.Tag);
end;

procedure Tpanefrm.b1Click(Sender: TObject);
begin
ResizePaneForScreen(b1.Tag);
end;

procedure Tpanefrm.c1Click(Sender: TObject);
begin
ResizePaneForScreen(c1.Tag);
end;

procedure Tpanefrm.d1Click(Sender: TObject);
begin
ResizePaneForScreen(d1.Tag);
end;

procedure Tpanefrm.DClickModeClick(Sender: TObject);
begin
ClickThrough := false;
ResizedDone := false;
ClickThroughMode_ED(Sender);
if Rpane then
   FormDblClick(panefrm.Resize1);
if OntopNow then
   Ontop1Click(panefrm.Ontop1);
end;

procedure Tpanefrm.e1Click(Sender: TObject);
begin
ResizePaneForScreen(e1.Tag);
end;

procedure Tpanefrm.f_bClick(Sender: TObject);
begin
if onTop_CT then
  SetBottom()
else
 SetTop();
end;



procedure Tpanefrm.FSmodeClick(Sender: TObject);
begin
ResizePaneForScreen(FSmode.Tag);
end;

procedure Tpanefrm.f1Click(Sender: TObject);
begin
ResizePaneForScreen(f1.Tag);
end;

end.

