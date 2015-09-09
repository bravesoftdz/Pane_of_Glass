program Pane_of_Glass;

uses
  Forms,
  painGlassop in 'painGlassop.pas' {Form1},
  paneGlass in 'paneGlass.pas' {panefrm},
  CheckPrevious in 'CheckPrevious.pas';

//{$D-,L-,O+,Q-,R-,Y-,S-}
  {$R *.res}

begin
if not CheckPrevious.RestoreIfRunning(Application.Handle) then
  begin
  Application.Initialize;
  Application.Title := 'Pane of Glass';
  Application.CreateForm(Tpanefrm, panefrm);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
  end;
end.
