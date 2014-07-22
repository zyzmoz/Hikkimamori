unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Printers, WinSpool;

type
  TForm1 = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Button2: TButton;
    BitBtn1: TBitBtn;
    Button3: TButton;
    BitBtn2: TBitBtn;
    Button4: TButton;
    GroupBox2: TGroupBox;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    procedure Button10Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  HPrinter : THandle;

implementation

uses impressao, funcoes;

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  AdicionaItem('TESTE','7897897897899',1,3);
  
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  AdicionaForma('DINHEIRO', 3);
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
ShowMessage(#120);//+#0+#60+#120);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Configurar;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  AtivaImpressora(hImpPadrao,hGenericText,hUSB);
  IniciaImp(hVenda,1,1,'TESTE');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  RemoveItem('TESTE','7897897897899',1,3);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  FechaImpressao(hvenda,0,0,10,3);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  AtivaImpressora(hBematech,hMP4200TH,hUSB);
  ShowMessage(Bematech_lestatus);
  
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  InformaCliente('1','TESTE','Rua 1 Nr 48','Bairro');
end;

procedure TForm1.Button7Click(Sender: TObject);

begin
  AbreGaveta(hImpPadrao,hGenericText,hUSB);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  AtivaImpressora(hImpPadrao,hGenericText,hUSB);
  ImprimeBarras('789789789789');
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  AtivaImpressora(hImpPadrao,hGenericText,hUSB);
  ImprimeQR('123ABC');
end;

end.
