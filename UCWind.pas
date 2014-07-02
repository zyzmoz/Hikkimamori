unit UCWind;

interface

uses Windows;
type
  CWind = class(TObject)
  private
    { Private declarations }
    hPorta: THandle;
    bImpressoraOnLine: Boolean;
    bTampaAberta: Boolean;
    bImpressoraComPapel: Boolean;
    bPoucoPapel: Boolean;
    bSensorGaveta: Boolean;
    iTimeOut: Integer;
  public
    { Public declarations }
    function Conectar( pcPorta: PChar; strBaudRate: String = '9600';
                       chParidade: Char = 'N'; iBitsDados: cardinal = 8;
                       iStopBit: cardinal = 1):Boolean;
    function Desconectar(): Boolean;
    function ConfigurarTimeOut( iTimeOut: Integer ): Boolean;
    function ImprimeTexto( strTexto: String ): Integer;
    function ImprimeTextoFormatado( flagFormatacao: Integer; strTexto: String ): Integer;
    function PegaStatusImpressora(): Integer;
    procedure AcionarGuilhotina();
    procedure ImprimeCodBarUPCA();
    procedure ImprimeCodBarUPCE();
    procedure ImprimeCodBarEAN13();
    procedure ImprimeCodBarEAN8();
    procedure ImprimeCodBarCode39();
    procedure ImprimeCodBarITF();
    procedure ImprimeCodBarCODABAR();
    procedure ImprimeCodBarCode93();
    procedure ImprimeCodBarCode128();
    procedure ImprimeCodBarISBN();
    procedure ImprimeCodBarMSI();
    procedure ImprimeCodBarPLESSEY();
    procedure DefineTextoCodBarTopo();
    procedure DefineTextoCodBarBase();

  end;

implementation

uses SysUtils, Classes;

Const
  // Comandos seriais
  ESC: Char = #27; // ESC - Escape
  LF : Char = #10; // Line Feed
  GS : Char = #29; // GS
  // Flags de Formatação de Texto
  TXT_SUBLINHADO: Integer     = 1;
  TXT_TAMANHO_FONTE: Integer  = 2;
  TXT_ENFATIZADO: Integer     = 4;
  TXT_ALTURA_DUPLA: Integer    = 8;
  TXT_LARGURA_DUPLA: Integer  = 16;
  TXT_ITALICO: Integer        = 32;
  TXT_SOBRESCRITO: Integer    = 64;
  TXT_SUBESCRITO: Integer     = 128;
  TXT_EXPANDIDO: Integer      = 256;
  TXT_CONDENSADO: Integer     = 512;

//****************************************************************************//
// Data: 17/11/2006                                                           //
// Desenvolvedor: Claudio Sampaio                                             //
//                                                                            //
// Destrição: Conecta e configura à porta de comunicação serial               //
// Função: Conectar( pcPorta: PChar; strBaudRate: String; chParidade: Char;   //
//                        iBitsDados: cardinal; iStopBit: cardinal):Boolean;  //
// Parametros:                                                                //
//   [IN] pcPorta: PChar - Identificação da porta serial de comunicação       //
//   [IN] strBaudRate: String - Velocidade de conexão com a porta serial      //
//   [IN] chParidade: Char - Valor da paridade de dados (P - Par, I - Impar,  //
//                           N - Sem paridade)                                //
//   [IN] iBitsDados: Cardinal - Número de bits por dados                     //
//   [IN] iStopBit: Cardinal - Número de stop bits                            //
//                                                                            //
// Retorno:                                                                   //
//   A função retorna um valor boleano, TRUE caso a conexão seja realizada com//
//   sucesso, caso contrário retorna FALSE                                    //
//                                                                            //
//****************************************************************************//
function CWind.Conectar( pcPorta: PChar; strBaudRate: String = '9600';
                       chParidade: Char = 'N'; iBitsDados: cardinal = 8;
                       iStopBit: cardinal = 1):Boolean;
const
  RxBufferSize = 256;
  TxBufferSize = 256;
var
  bSucesso: Boolean;
  DCB: TDCB;
  Config: string;

begin
  bSucesso := TRUE;
  hPorta := CreateFile(pcPorta,
                GENERIC_WRITE,
                0,
                nil,
                OPEN_EXISTING,
                FILE_ATTRIBUTE_NORMAL,
                0);
  if ( hPorta = INVALID_HANDLE_VALUE ) then
  begin
    bSucesso := FALSE;
  end
  else begin
    if ( StrComp(pcPorta,'LPT') < 0 ) then // Se não for LPT configura a porta
    begin
      // Configura o tamanho do buffer
      if not SetupComm(hPorta, RxBufferSize, TxBufferSize) then
        bSucesso := False;

      // Lê o estado da porta serial
      if not GetCommState(hPorta, DCB) then
        bSucesso := False;


      //Config := 'baud=9600 parity=n data=8 stop=1';
      Config := 'baud=' + '9600' + 'parity=' + 'N' + 'data=' +
                IntToStr(iBitsDados) + 'stop=' + IntToStr(iStopBit);

      // Constroi arquivo de configuração da porta serial
      if not BuildCommDCB(@Config[1], DCB) then
        bSucesso := FALSE;

      // Configura o estado da porta serial
      if not SetCommState(hPorta, DCB) then
        bSucesso := FALSE;

      // Configura TimeOut
      if not ConfigurarTimeOut(6) then
        bSucesso := FALSE;

      // Pega Status da Impressora
      PegaStatusImpressora();
    end;

  end;

  Conectar:= bSucesso;
end;

//****************************************************************************//
// Data: 17/11/2006                                                           //
// Desenvolvedor: Claudio Sampaio                                             //
//                                                                            //
// Destrição: Configura TimeOut da porta serial                               //
// Função: ConfigurarTimeOut( iTimeOut: Integer ): Boolean;                   //
// Parametros:                                                                //
//   [IN] iTimeOut: integer - TimeOut da porta de comunicação
//                                                                            //
// Retorno:                                                                   //
//   A função retorna um valor boleano, TRUE caso a conexão seja realizada com//
//   sucesso, caso contrário retorna FALSE                                    //
//                                                                            //
//****************************************************************************//
function CWind.ConfigurarTimeOut( iTimeOut: Integer ): Boolean;
var
  CommTimeouts: TCommTimeouts;
  bSucesso: Boolean;
begin
  bSucesso := TRUE;
  with CommTimeouts do
  begin
    ReadIntervalTimeout         := 1;
    ReadTotalTimeoutMultiplier  := 0;
    ReadTotalTimeoutConstant    := iTimeOut * 1000;
    WriteTotalTimeoutMultiplier := 0;
    WriteTotalTimeoutConstant   := 1000;
  end;

  if not SetCommTimeouts(hPorta, CommTimeouts) then
    bSucesso := FALSE;

  ConfigurarTimeOut := bSucesso;
end;
//****************************************************************************//
// Data: 20/11/2006                                                           //
// Desenvolvedor: Claudio Sampaio                                             //
//                                                                            //
// Destrição: Fecha conexão com a porta serial                                //
// Função: Desconectar(): Boolean;                                            //
// Parametros:                                                                //
//   Nenhum                                                                   //
//                                                                            //
// Retorno:                                                                   //
//   A função retorna um valor boleano, TRUE caso a conexão seja realizada    //
//   com sucesso, caso contrário retorna FALSE                                //
//                                                                            //
//****************************************************************************//
function CWind.Desconectar(): Boolean;
var bSucesso: Boolean;
begin
  bSucesso := CloseHandle(hPorta);
  Desconectar := bSucesso;
end;

//****************************************************************************//
// Data: 20/11/2006                                                           //
// Desenvolvedor: Claudio Sampaio                                             //
//                                                                            //
// Destrição: Imprime texto sem formatação na impressora                      //
// Função: ImprimeTexto( strTexto: String ): Integer;                         //
// Parametros:                                                                //
//   [IN] strTexto: String - buffer contento o texto que será impresso na     //
//                           impressora.                                      //
//                                                                            //
// Retorno:                                                                   //
//   Número de caracteres escritos na impressora, em caso de falha a função   //
//   retorna -1.                                                              //
//                                                                            //
//****************************************************************************//
function CWind.ImprimeTexto( strTexto: String ): Integer;
var
  i, iNumCaracteresEscritos: integer;
  iNumCaracteres: Cardinal;
  dwBytesWritten: DWORD;
  bSucesso: Boolean;
begin
  bSucesso := WriteFile( hPorta, Pchar(strTexto)[0], Cardinal(Length(strTexto)) , dwBytesWritten, nil);

  {for i:= 1 to Length(strTexto) do
  begin
    bSucesso := WriteFile(hPorta,
              strTexto[i],
              1,
              iNumCaracteres,
              nil);
    if (bSucesso) then
      iNumCaracteresEscritos := iNumCaracteresEscritos + 1
    else begin
      iNumCaracteresEscritos := -1;
      ImprimeTexto := iNumCaracteresEscritos;
    end;

  end;}

  if ( bSucesso ) then
    // Avança uma linha
    bSucesso := WriteFile(hPorta,
                LF,
                1,
                iNumCaracteres,
                nil);

end;

//****************************************************************************//
// Data: 04/12/2006                                                           //
// Desenvolvedor: Claudio Sampaio                                             //
//                                                                            //
// Destrição: Imprime texto com formatação informada na impressora            //
// Função: ImprimeTextoFormatado( flagFormatacao: Integer,                    //
//                                strTexto: String ): Integer;                //
// Parametros:                                                                //
//   [IN] flagFormatacao: Integer - flags de formatação do texto:             //
//                              FLAGS                  DESCRIÇÃO              //
//                        TXT_SUBLINHADO      -     Texto sublinhado          //
//                        TXT_TAMANHO_FONTE   -     Tamanho da Fonte (A ou B) //
//                        TXT_ENFATIZADO      -     Texto enfatizado          //
//                        TXT_ALTURA_DUPLA     -    Texto com altura dupla    //
//                        TXT_LARGURA_DUPLA   -     Texto com largura dupla   //
//                        TXT_ITALICO         -     Texto Italico             //
//                        TXT_SOBRESCRITO     -     Texto sobre escrito       //
//                        TXT_SUBESCRITO      -     Texto subscrito           //
//                        TXT_EXPANDIDO       -     Texto Expandido           //
//                        TXT_CONDENSADO      -     Texto Condensado          //
//                                                                            //
//   [IN] strTexto: String - buffer contento o texto que será impresso na     //
//                           impressora.                                      //
//                                                                            //
// Retorno:                                                                   //
//   Número de caracteres escritos na impressora, em caso de falha a função   //
//   retorna -1.                                                              //
//                                                                            //
//****************************************************************************//
function CWind.ImprimeTextoFormatado( flagFormatacao: Integer; strTexto: String ): Integer;
var
  strAbreFormatacao, strFechaFormatacao, strTextoFormatado: String;
  iNumCaracteresEscritos: Integer;
begin
  strAbreFormatacao := '';
  strFechaFormatacao := '';

  if ( (flagFormatacao and TXT_SUBLINHADO) = 1 ) then
  begin
    strAbreFormatacao := strAbreFormatacao + ESC + '-' + Chr(1);
    strFechaFormatacao := strFechaFormatacao + ESC + '-' + Chr(0);
  end;
  if ( (flagFormatacao and TXT_TAMANHO_FONTE) = 1 ) then
  begin
    strAbreFormatacao := strAbreFormatacao + ESC + 'M' + Chr(1);
    strFechaFormatacao := strFechaFormatacao + ESC + 'M' + Chr(0);
  end;
  if ( (flagFormatacao and TXT_ENFATIZADO) = 1 ) then
  begin
    strAbreFormatacao := strAbreFormatacao + ESC + 'E';
    strFechaFormatacao := strFechaFormatacao + ESC + 'F';
  end;
  if ( (flagFormatacao and TXT_ALTURA_DUPLA) = 1 ) then
  begin
    strAbreFormatacao := strAbreFormatacao + ESC + 'd' + Chr(1);
    strFechaFormatacao := strFechaFormatacao + ESC + 'd' + Chr(0);
  end;
  if ( (flagFormatacao and TXT_LARGURA_DUPLA) = 1 ) then
  begin
    strAbreFormatacao := strAbreFormatacao + ESC + '!' + Chr(32); // TODO: Rever
    strFechaFormatacao := strFechaFormatacao + ESC + '!' + Chr(0);
  end;
  if ( (flagFormatacao and TXT_ITALICO) = 1 ) then
  begin
    strAbreFormatacao := strAbreFormatacao + ESC + Chr(4);
    strFechaFormatacao := strFechaFormatacao + ESC + Chr(5);
  end;
  if ( (flagFormatacao and TXT_SOBRESCRITO) = 1 ) then
  begin
    strAbreFormatacao := strAbreFormatacao + ESC + 'S' + Chr(1);
    strFechaFormatacao := strFechaFormatacao + ESC + 'T';
  end;
  if ( (flagFormatacao and TXT_SUBESCRITO) = 1 ) then
  begin
    strAbreFormatacao := strAbreFormatacao + ESC + 'S' + Chr(0);
    strFechaFormatacao := strFechaFormatacao + ESC + 'T';
  end;
  if ( (flagFormatacao and TXT_EXPANDIDO) = 1 ) then
  begin
    //strAbreFormatacao := strAbreFormatacao + ESC + 'S' + Chr(0);
    //strFechaFormatacao := strFechaFormatacao + ESC + 'T';
  end;
  if ( (flagFormatacao and TXT_CONDENSADO) = 1 ) then
  begin
    //strAbreFormatacao := strAbreFormatacao + ESC + 'S' + Chr(0);
    //strFechaFormatacao := strFechaFormatacao + ESC + 'T';
  end;

  strTextoFormatado := strAbreFormatacao + strTexto + strFechaFormatacao;
  iNumCaracteresEscritos := ImprimeTexto(strTextoFormatado);
end;

//****************************************************************************//
// Data: 20/11/2006                                                           //
// Desenvolvedor: Claudio Sampaio                                             //
//                                                                            //
// Destrição: Pega o status atual da impressora                               //
// Função:  PegaStatusImpressora(): Integer;                                  //
// Parametros:                                                                //
//   Nenhum                                                                   //
//                                                                            //
// Retorno:                                                                   //
//   Retorna uma byte com o status atual da impressora:                       //
//    Bit 0 - [0]Impressora off-line | [1]Impressora on-line                  //
//    Bit 1 - [0]Impressora com Papel | [1]Impressora sem Papel               //
//    Bit 2 - [0]Sensor de gaveta baixo | [1]Sensor de gaveta alto            //
//    Bit 3 - [0]Tampa fechada | [1]Tampa aberta                              //
//    Bit 4 - [0]Impre. com papel suficiente | [1]Impre. com pouco papel      //
//    Bit 5 - [0]Gilhotinha funcionando corretamente | [1]Falha na Gilhotinha //
//    Bit 6-7 - sem utilização(nível lógico sempre "0")                       //
//                                                                            //
//****************************************************************************//
function CWind.PegaStatusImpressora(): Integer;
const
  ENQ: Char = #05;
begin
  Result := 0;
end;

//****************************************************************************//
// Data: 22/02/2010                                                           //
// Desenvolvedor: Oscar Menezes                                               //
//                                                                            //
// Descrição: Aciona a Guilhotina da Impressora                               //
// Função:  AcionarGuilhotina();                                              //
// Parametros:                                                                //
//   Nenhum                                                                   //
//                                                                            //
// Retorno:                                                                   //
//   Nenhum                                                                   //
//                                                                            //
//****************************************************************************//
procedure CWind.AcionarGuilhotina();
var
  strTextoComando: String;
begin
  strTextoComando:= ESC + 'w';
  ImprimeTexto(strTextoComando);
end;

//****************************************************************************//
// Data: 24/02/2010                                                           //
// Desenvolvedor: Oscar Menezes                                               //
//                                                                            //
// Descrição: Imprime um Código de Barras UPC-A                               //
// Função:  ImprimeCodBarUPCA()                                               //
// Parametros:                                                                //
//   Nenhum                                                                   //
//                                                                            //
// Retorno:                                                                   //
//   Nenhum                                                                   //
//                                                                            //
//****************************************************************************//
procedure CWind.ImprimeCodBarUPCA();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode UPCA:' + LF);
  strTextoComando:= GS + chr(107) + chr(0) + '01234567890' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarUPCE();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode UPCE:' + LF);
  strTextoComando:= GS + chr(107) + chr(1) + '123456' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarEAN13();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode EAN13:' + LF);
  strTextoComando:= GS + chr(107) + chr(2) + '012345678912' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarEAN8();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode EAN8:' + LF);
  strTextoComando:= GS + chr(107) + chr(3) + '1234567' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarCode39();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode Code39:' + LF);
  strTextoComando:= GS + chr(107) + chr(4) + '01234567890' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarITF();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode ITF:' + LF);
  strTextoComando:= GS + chr(107) + chr(5) + '01234567890' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarCODABAR();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode CODABAR:' + LF);
  strTextoComando:= GS + chr(107) + chr(6) + '01234567890' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarCode93();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode Code93:' + LF);
  strTextoComando:= GS + chr(107) + chr(72) + '10' + '0123456789' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarCode128();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode Code128:' + LF);
  strTextoComando:= GS + chr(107) + chr(73) + chr(10) + '0123456789' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarISBN();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode ISBN:' + LF);
  strTextoComando:= GS + chr(107) + chr(21) + '1123456789' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarMSI();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode MSI:' + LF);
  strTextoComando:= GS + chr(107) + chr(22) + '0123456789' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

procedure CWind.ImprimeCodBarPLESSEY();
var
  strTextoComando: String;
begin
  ImprimeTexto('Barcode PLESSEY:' + LF);
  strTextoComando:= GS + chr(107) + chr(23) + '0123456789' + chr(0) ;
  ImprimeTexto(strTextoComando);
end;

// Falta o PDF-417 devido a complexidade das regras

procedure CWind.DefineTextoCodBarTopo();
var
  strTextoComando: String;
begin
  strTextoComando:= GS + chr(72) + chr(1);
  ImprimeTexto(strTextoComando);
end;

procedure CWind.DefineTextoCodBarBase();
var
  strTextoComando: String;
begin
  strTextoComando:= GS + chr(72) + chr(2);
  ImprimeTexto(strTextoComando);
end;

end.
