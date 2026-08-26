program InspectorDemo;

uses
  Vcl.Forms,
  Main in 'Main.pas',
  Inspector in '..\..\Inspector.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
