unit funcoes;

interface
  uses IniFiles, SysUtils;

function Traco ( aTamanho : integer ) : string;
function TracoDuplo ( aTamanho : integer ) : string;
function aLinhaDireita ( aTexto : string; aFinal : integer ) : string;
function alinhaCentro(numTexto : integer) : String;
function subs ( aTexto : string; aInicio, aFinal : integer ) : string;
procedure GravaIni(dados, campo, aTexto: string);
function LeIni( dados, campo : string): string;
function Alltrim(const Search: string): string;

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
  ArqIni := TIniFile.Create(caminho + 'hikkimamori.ini');
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
  ArqIni := TIniFile.Create(caminho + 'email.ini');
  try
    aTexto := ArqIni.ReadString( dados, campo, aTexto);
    Result := aTexto;
  finally
    ArqIni.Free;
  end;
end;

function Alltrim(const Search: string): string;
{Remove os espa�os em branco de ambos os lados da string}
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


end.