unit funcoes;
{ Função: Funções para Unit impressão
  Autor:  Daniel Cunha
  Data:   10/06/2014
  Funcionamento: -
}

interface
  uses IniFiles, SysUtils,Variants, Classes, Graphics, Controls, Forms,StdCtrls,
  ExtCtrls, Dialogs;

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
  RoundSemArredondar := StrToFloat(reais) + StrToFloat(Centavos);

end;


end.
