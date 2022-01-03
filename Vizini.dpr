program Vizini;

uses
  Vcl.Forms,
  Vizini_code in 'Vizini_code.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
