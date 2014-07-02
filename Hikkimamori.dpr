program Hikkimamori;

uses
  Forms,
  untMain in 'untMain.pas' {Form1},
  impressao in 'impressao.pas',
  declaracoes in 'declaracoes.pas',
  funcoes in 'funcoes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
