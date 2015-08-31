unit funcoes;
{ Função: Funções para Unit impressão
  Autor:  Daniel Cunha
  Data:   10/06/2014
  Funcionamento: -

  18-11-2014 > Iniciada mudança para setar impressora padrao
}

interface
  uses IniFiles, SysUtils,Variants, Classes, Graphics, Controls, Forms,StdCtrls,
  ExtCtrls, Dialogs, idtcpclient, Printers, Messages, Windows, TLHelp32;

function Traco ( aTamanho : integer ) : string;
function TracoDuplo ( aTamanho : integer ) : string;
function aLinhaDireita ( aTexto : string; aFinal : integer ) : string;
function alinhaCentro(numTexto : integer) : String;
function subs ( aTexto : string; aInicio, aFinal : integer ) : string;
procedure GravaIni(dados, campo, aTexto: string);
function LeIni( dados, campo : string): string;
procedure GeraIniTemp(dados, campo, aTexto: string);
function LeIniTemp( dados, campo : string): string;
function Alltrim(const Search: string): string;
function RoundSemArredondar(valor : Double):Double;
procedure Configurar;
function serverisrunning(AHost: String; Aport:Integer) : Boolean;
{$region 'http://www.swissdelphicenter.com/torry/showcode.php?id=660'}
function GetDefaultPrinter: string;
procedure SetDefaultPrinter1(NewDefPrinter: string);
procedure SetDefaultPrinter2(PrinterName: string);
{$endregion}
function KillTask(ExeFileName: string): Integer;

implementation

function Traco ( aTamanho : integer ) : string;
var aTexto : string;
    I : integer;
begin
  aTexto := '';
  for I := 1 to aTamanho do aTexto := aTexto + '-';
  Result := aTexto;
end;

function TracoDuplo ( aTamanho : integer ) : string;
var aTexto : string;
    I : integer;
begin
  aTexto := '';
  for I := 1 to aTamanho do aTexto := aTexto + '=';
  Result := aTexto;
end;

function aLinhaDireita ( aTexto : string; aFinal : integer ) : string;
var aRet : string;
begin
  aRet := copy (aTexto , 1, aFinal );
  while Length(aRet ) < aFinal do
    aRet := ' ' + aRet;
  Result := aRet;
end;

function alinhaCentro(numTexto : integer) : String;
var
  x,y, total : integer;
  espaco : String;
begin
  total := StrToInt(LeIni('IMPRESSORA','COLUNAS'));// default 80 reduzido 44
  
  espaco := '';
  y := total-numTexto;
  if y <= 0 then
    y := 0;
  for x := 0 to y div 2 do
    espaco := espaco + ' ';
  Result := espaco;
  y := 0;
end;

function subs ( aTexto : string; aInicio, aFinal : integer ) : string;
var aRet : string;
    I    : integer;
begin
   aRet := '';
   for I := aInicio to aInicio + aFinal do
   begin
      if Copy ( aTexto, I, 1 ) = '' then
         aRet := aRet + ' '
      else
         aRet := aRet + Copy ( aTexto, I, 1 );
   end;
   Result := aRet;
end;

procedure GravaIni(dados, campo, aTexto: string);
var
  ArqIni: TIniFile;
  caminho : String;
begin
  caminho := ExtractFilePath(ParamStr(0));
  ArqIni := TIniFile.Create(caminho + 'NaoFiscal.ini');
  try
    ArqIni.WriteString( dados, campo, aTexto);
  finally
    ArqIni.Free;
  end;
end;

function LeIni( dados, campo : string): string;
var
  ArqIni: TIniFile;
  aTexto,caminho : string;
begin
  caminho := ExtractFilePath(ParamStr(0));
  ArqIni := TIniFile.Create(caminho + 'NaoFiscal.ini');
  try
    aTexto := ArqIni.ReadString( dados, campo, aTexto);
    Result := aTexto;
  finally
    ArqIni.Free;
  end;
end;

function Alltrim(const Search: string): string;
{Remove os espaços em branco de ambos os lados da string}
const
  BlackSpace = [#33..#126];
var
  Index: byte;
begin
  Index:=1;
  while (Index <= Length(Search)) and not (Search[Index] in BlackSpace) do
    Index:=Index + 1;
  Result:=Copy(Search, Index, 255);
  Index := Length(Result);
  while (Index > 0) and not (Result[Index] in BlackSpace) do
    Index:=Index - 1;
  Result := Copy(Result, 1, Index);
end;

procedure Configurar;
var
  Dlg : TOpenDialog;
begin
  Dlg :=  TOpenDialog.Create(nil);
  Dlg.InitialDir := GetCurrentDir;
  dlg.Filter:= '*.bmp';
  dlg.Execute;
  GravaIni('IMPRESSORA','IMG', Dlg.FileName );
  Gravaini('IMPRESSORA','IMG_X', InputBox('Configuração','Digite a Largura da Imagem',''));
  Gravaini('IMPRESSORA','IMG_Y', InputBox('Configuração','Digite a Altura da Imagem',''));
  Gravaini('IMPRESSORA','IMG_A', InputBox('Configuração','Digite o Angulo da Imagem',''));
  Gravaini('IMPRESSORA','COLUNAS', InputBox('Configuração','Digite o tamanho da impressão (Default = 45)','45'));
  Gravaini('IMPRESSORA','GUILHOTINA', UpperCase(InputBox('Configuração','Impressora possui guilhotina?','N')));
  Gravaini('IMPRESSORA','GAVETA', UpperCase(InputBox('Configuração','Impressora Utiliza Gaveta?','N')));

  Gravaini('EMPRESA','FANTASIA', InputBox('Configuração','Fantasia da Empresa','Empresa'));
  Gravaini('EMPRESA','ENDERECO', InputBox('Configuração','Endereço','Endereço'));
  Gravaini('EMPRESA','NUMERO', InputBox('Configuração','Numero','1234'));
  Gravaini('EMPRESA','BAIRRO', InputBox('Configuração','Bairro','Bairro'));
  Gravaini('EMPRESA','CIDADE', InputBox('Configuração','Cidade','Cidade'));
  Gravaini('EMPRESA','UF', InputBox('Configuração','Estado','UF'));
  Gravaini('EMPRESA','TELEFONE', InputBox('Configuração','Telefone','3535-3535'));
  Gravaini('EMPRESA','EMAIL', InputBox('Configuração','Email','email@mail.com'));
  Gravaini('EMPRESA','SITE', InputBox('Configuração','Site','www.site.com'));
  ShowMessage('Configuração Realizada com sucesso!');

end;

procedure GeraIniTemp(dados, campo, aTexto: string);
var
  ArqIni: TIniFile;
  caminho : String;
begin
  caminho := ExtractFilePath(ParamStr(0));
  ArqIni := TIniFile.Create(caminho + 'Temp.ini');
  try
    ArqIni.WriteString( dados, campo, aTexto);
  finally
    ArqIni.Free;
  end;
end;

function LeIniTemp( dados, campo : string): string;
var
  ArqIni: TIniFile;
  aTexto,caminho : string;
begin
  caminho := ExtractFilePath(ParamStr(0));
  ArqIni := TIniFile.Create(caminho + 'Temp.ini');
  try
    aTexto := ArqIni.ReadString( dados, campo, aTexto);
    Result := aTexto;
  finally
    ArqIni.Free;
  end;
end;

function RoundSemArredondar(valor : Double):Double;
var
  reais, centavos : String;
begin
  if Pos(',',FloatToStr(valor)) >0 then
    reais := copy(FloatToStr(valor),1, Pos(',',FloatToStr(valor))-1)
  else
    reais := copy(FloatToStr(valor),1,Length(FloatToStr(valor)));

  if Pos(',',FloatToStr(valor)) >0  then
    centavos := '0' + copy(FloatToStr(valor),Pos(',',FloatToStr(valor)),3)
  else
    centavos := '0,00';
  if copy(FloatToStr(valor),1, 1) = '-' then
    RoundSemArredondar := StrToFloat(reais) - StrToFloat(Centavos)
  else
    RoundSemArredondar := StrToFloat(reais) + StrToFloat(Centavos);

end;

function serverisrunning(AHost: String; Aport:Integer) : Boolean;
Begin
  with tidtcpclient.create(nil) do begin
    Host:=AHost;
    Port:=Aport;
    Result:=True;
    Try
      Connect;
      Disconnect;
    Except
      Result:=False;
    end;
    Free;
  end;
end;

function GetDefaultPrinter: string; // pega impressora padrão
var
  ResStr: array[0..255] of Char;
begin
  GetProfileString('Windows', 'device', '', ResStr, 255);
  Result := StrPas(ResStr);
end;

procedure SetDefaultPrinter1(NewDefPrinter: string);
var
  ResStr: array[0..255] of Char;
begin
  StrPCopy(ResStr, NewdefPrinter);
  WriteProfileString('windows', 'device', ResStr);
  StrCopy(ResStr, 'windows');
  SendMessage(HWND_BROADCAST, WM_WININICHANGE, 0, Longint(@ResStr));
end;

procedure SetDefaultPrinter2(PrinterName: string);  // seta impressora padrao
var
  I: Integer;
  Device: PChar;
  Driver: PChar;
  Port: PChar;
  HdeviceMode: THandle;
  aPrinter: TPrinter;
begin
  Printer.PrinterIndex := -1;
  GetMem(Device, 255);
  GetMem(Driver, 255);
  GetMem(Port, 255);
  aPrinter := TPrinter.Create;
  try
    for I := 0 to Printer.Printers.Count - 1 do
    begin
      if Printer.Printers.Text = PrinterName then
      begin
        aprinter.PrinterIndex := i;
        aPrinter.getprinter(device, driver, port, HdeviceMode);
        StrCat(Device, ',');
        StrCat(Device, Driver);
        StrCat(Device, Port);
        WriteProfileString('windows', 'device', Device);
        StrCopy(Device, 'windows');
        SendMessage(HWND_BROADCAST, WM_WININICHANGE,
          0, Longint(@Device));
      end;
    end;
  finally
    aPrinter.Free;
  end;
  FreeMem(Device, 255);
  FreeMem(Driver, 255);
  FreeMem(Port, 255);
end;

function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;



end.
