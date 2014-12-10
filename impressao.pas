unit impressao;
{
  Função: Impressão de Pré Venda
  Autor:  Daniel Cunha
  Data:   10/06/2014
  Funcionamento:
    Bematech : Utiliza a DLL MP2032.dll
    Impressora Padrão : Utiliza CharPrinter com comandos ESC/POS (Impressora padrão do Windows)

  18-11-2014 > Iniciada a mudança para comandos unificados, assim fica mais facil a manutenção
      das impressoes;
    
}
interface
uses declaracoes, DB, Forms, sysutils, controls, windows, CharPrinter;

type
  THPortas = (hCOM1,hCOM2, hCOM3, hCOM4, hLPT1, hLPT2, hEthernet, hUSB);
  THImpressora = (hBematech, hElgin, hDaruma, hEpson, hDiebold, hMatricial, hImpPadrao);
  THModeloIMP = ( //Bematech    //              //                    //
                  hMP20MI   = 1,
                  hMP20CI   = 0,
                  hMP20TH   = 0,
                  hMP2000CI = 0,
                  hMP2000TH = 0,
                  hMP2100TH = 0,
                  hMP4000TH = 5,
                  hMP4200TH = 7,
                  hMP2500TH = 8,
                  //Matricial
                  hGenericText);
  THTipoImp = (hVenda,
               hRVenda,
               hConsignacao,
               hRecibo,
               hRRecibo,
               hCarne,
               hVendaCliente,
               hRVendaCliente,
               hPromissoria,
               hRpromissoria,
               hComanda);

  THDevice = record
    aImp : THImpressora;
    aMod : THModeloIMP;
    aPrt : THPortas;
    aTsk : THTipoImp;
  end;

  THDadosCaixa = record
    aDinheiro,
    aCartao,
    aCheque,
    aSuprimento,
    aSangria : Double;
  end;

  THInformativoVendas = record
    aTDinheiro,
    aTCheque,
    aTCartao,
    aTCliente,
    aTDesconto,
    aTRecebido : Double;
  end;

  THTotais = record
    aCancelados,
    aVlrCancelados,
    aItmCancelados,
    aVlrItmCancelados : Double;
  end;  


var
  //para uso de imppadrao
  prn : TAdvancedPrinter;

  //Para organizar as variaveis foi criado o record
  device : THDevice;
  
  //aux cupom
  aSubTotal :Double;

  //dados caixa
  aDinheiro, aCartao, aCheque, aSuprimento, aSangria : Double;

  //informativo de Venda
  aTDinheiro, aTCheque, aTCartao, aTCliente, aTDesconto, aTRecebido : Double;

  //Totais
  aCancelados, aVlrCancelados, aItmCancelados, aVlrItmCancelados : Double;

{$REGION 'COMANDOS BASE'}
function  Bematech_Pequeno(aTexto : string):integer;
function  Bematech_Normal(aTexto : string):integer;
function  Bematech_Grande(aTexto : string):integer;
procedure Prn_Pequeno(aTexto : String);
procedure Prn_Normal(aTexto : String);
procedure Prn_Grande(aTexto : String);
procedure Prn_Comando(aTexto : String);

//gaveta
procedure AbreGaveta(impressora : THImpressora; modelo : THModeloIMP; porta : THPortas);overload;
procedure AbreGaveta(impressora, modelo, porta  : integer);overload;

//Guilhotina
procedure Guilhotina(corta : boolean);

//comandos unificados

procedure hPrintPequeno(aTexto : String);
procedure hPrintNormal(aTexto : String);
procedure hPrintGrande(aTexto : String);
procedure hPrintComando(aTexto : String);
procedure hPrintFechar();
procedure hAbregaveta();
procedure AvancaLinhas(linhas : integer);

//Ativação
procedure AtivaImpressora(impressora : THImpressora; modelo: THModeloIMP; porta : THPortas);overload;
procedure AtivaImpressora(impressora : integer; modelo: integer; porta : integer);overload ;

//Zera Variaveis
procedure zeraVariaveis();
{$endregion}

{$REGION 'CONFIGURAÇAO'}

function  Bematech_lestatus():String;
function  RetornaStrPorta(porta : THPortas): String;
function  setImpressora(imp : integer) : THImpressora;
function  setModelo(modelo : integer) : THModeloIMP;
function  setPorta(porta : integer) : THPortas;
function  RetornaModelo(modelo : THModeloIMP):integer;
procedure TesteImpressora(impressora, modelo, porta, avanco :Integer);

{$ENDREGION}

{$REGION 'IMPRESSAO'}
procedure ImpCabecalho();
procedure AdicionaItem (item, barras: String; qtde, unitario : Double);
procedure RemoveItem (item, barras: String; qtde, unitario : Double);
procedure ImprimeTipo (impressora : THImpressora; tipo : THTipoImp ;numeroimp, pdv : integer; data, hora, vendedor : String);

procedure InformaCliente(Ficha, Cliente, Endereco, Bairro : String);overload;
procedure InformaCliente(Ficha : integer ; Cliente, CPF, RG, Endereco, Bairro : String); overload ;

{Manutenção Aqui}
//Será retirado o tipo da impressao e passado para o tipo que iniciou
procedure FechaImpressao (tipo : THTipoImp ; Desconto, Acrescimo, Total, Recebido : Double);
{Fim Manutencão }

procedure IniciaImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String);
procedure IniciaRImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String; data: Tdate; hora : TTime);


procedure AdicionaParcela (parcela : integer; vecto : String ; valor : Double);overload;
Procedure AdicionaParcela ( vecto : String ; valor : Double);overload;
procedure DadosTemporarios(dados, campo, valor :String);


procedure AdicionaForma (forma : String; valor : Double);
{$ENDREGION}

{$REGION 'CODIGOS'}
procedure ImprimeBarras(aCodigo : String);
procedure ImprimeQR(aCodigo : String);
{$ENDREGION}

{$REGION 'IMPRESSOES OPERACIONAIS'}
procedure ImpSangria(caixa : integer; supervisor, operador : String; valor : Double);
procedure ImpSuprimento(caixa : integer; supervisor, operador : String; valor : Double);
procedure ImpAbertura(caixa : integer; supervisor, operador : String; valor : Double);
procedure CancelaCupom(caixa, cupom : integer; operador : String ; datahoravenda: TDateTime ;subtotal, desconto, total : Double);
procedure ImpFechamento(caixa, controle : integer; supervisorab,supervisorf, operador : String; aData: TDate; aHora : TTime; valor, valorinformado : Double);
procedure informaDadosCaixa(Dinheiro, Cheque, Cartao, Suprimento, Sangria : Double);
procedure informaDadosVenda(TDinheiro, TCheque, TCartao, TCliente, TDesconto, TRecebido : Double);
procedure informaTotais(Cancelados, VlrCancelados, ItmCancelados, VlrItmCancelados : Double);
{$ENDREGION}


implementation

uses funcoes;


function Bematech_Pequeno (aTexto : string):integer;
begin
  if trim(atexto) <> '' then
  begin
    aTexto := aTexto + #13 + #10;
    Bematech_Pequeno := FormataTX(pchar(aTexto), 1, 0, 0, 0, 0);
  end;
end;

function Bematech_Normal  (aTexto : string):integer;
begin
  if trim( atexto ) <> '' then
  begin
    aTexto := aTexto + #13 + #10;
    Bematech_normal := FormataTX(pchar(aTexto), 2, 0, 0, 0, 0);
  end;
end;

function Bematech_Grande  (aTexto : string): integer;
begin
  if trim( atexto ) <> '' then
  begin
    aTexto := aTexto + #13 + #10;
    Bematech_grande := FormataTX(pchar(aTexto), 3, 0, 0, 1, 0);
  end;
end;

function Bematech_lestatus():String;
var
  aStatus: integer;
  s_stporta: String;
begin
// ANÁLISE DO RETORNO DE STATUS DAS IMPRESSORAS FISCAIS
  case device.aPrt of
    hCOM1: s_stporta:='serial';
    hCOM2: s_stporta:='serial';
    hCOM3: s_stporta:='serial';
    hCOM4: s_stporta:='serial';
    hLPT1: s_stporta:='lpt';
    hLPT2: s_stporta:='lpt';
    hEthernet: s_stporta:='rede';
  end;
  AtivaImpressora(device.aImp , device.aMod ,device.aPrt);
  aStatus := Le_Status();

//******************IMPRESSORAS MP 20 CI E MI - CONEXÃO SERIAL******************

  if (device.aMod = hMP20MI) and (s_stporta='serial') then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE';
    if aStatus= 32 then Bematech_lestatus :='32 - SEM PAPEL';
  End;
//******************************************************************************

//******************IMPRESSORAS MP 20 CI E MI - CONEXÃO PARALELA****************

  if (device.aMod = hMP20MI) and (s_stporta='lpt') then
  Begin
    if aStatus= 144 then Bematech_lestatus :='144 - ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE OU IMP. SEM PAPEL';
  End;
//******************************************************************************

//******IMPRESSORAS MP 20 TH, 2000 CI 2000 TH 2100 TH - CONEXÃO SERIAL**********

  if (device.aMod=hMP20TH) and (s_stporta='serial') then
  Begin
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE OU POUCO PAPEL';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
  End;
//******************************************************************************

//******IMPRESSORAS MP 20 TH, 2000 CI 2000 TH 2100 TH - CONEXÃO PARALELA********

  if (device.aMod=hMP20TH) and (s_stporta='lpt') then
  Begin
    if aStatus= 79 then Bematech_lestatus :='79 - OFF LINE';
    if aStatus= 144 then Bematech_lestatus :='144 - ON LINE OU POUCO PAPEL';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 0 then Bematech_lestatus :='0 - ERRO DE COMUNICAÇÃO';
  End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEXÃO PARALELA*********************

  if (device.aMod=hMP4000TH) and (s_stporta='lpt') then
  Begin
    if aStatus= 40 then Bematech_lestatus :='40 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 128 then Bematech_lestatus :='128 - IMP. SEM PAPEL';
    if aStatus= 0 then Bematech_lestatus :='0 - POUCO PAPEL';
  End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEXÃO ETHERNET*********************

  if (device.aMod=hMP4000TH) and (s_stporta='rede') then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE - POUCO PAPEL';
  End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEXÃO SERIAL***********************

  if (device.aMod=hMP4000TH) and (s_stporta='serial') then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 5 then Bematech_lestatus :='5 - ON LINE - POUCO PAPEL';
  End;
//******************************************************************************

//*********************IMPRESSORAS MP 4000 TH CONEXÃO USB***********************

  if (device.aMod=hMP4000TH) and (s_stporta='serial') then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 68 then Bematech_lestatus :='68 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE - POUCO PAPEL';
  End;
//******************************************************************************

//*******************IMPRESSORAS MP 4200 TH CONEXÃO TODAS***********************

  if (device.aMod=hMP4200TH) then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 5 then Bematech_lestatus :='5 - ON LINE - POUCO PAPEL';
    if aStatus= 9 then Bematech_lestatus :='9 - TAMPA ABERTA';
  End;
//******************************************************************************
  FechaPorta;

end;

procedure ImpCabecalho ();
begin
  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN000'))) + LeIni('EMPRESA','LIN000'));
  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN001'))) + LeIni('EMPRESA','LIN001'));
  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN002'))) + LeIni('EMPRESA','LIN002'));
  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN003'))) + LeIni('EMPRESA','LIN003'));
  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN004'))) + LeIni('EMPRESA','LIN004'));
  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN004'))) + LeIni('EMPRESA','LIN005'));
  hPrintNormal( TracoDuplo(47));
end;

Procedure AdicionaItem (item, barras: String; qtde, unitario : Double);
var
  Arq : TextFile;
  aLinha : String;
begin
  AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'item.txt');
  Rewrite(Arq);
  Write(Arq,  #18 + subs( alltrim( item ), 1, 50 ));
  Write(Arq,  #$12 + '    ' + subs( barras, 1, 13 ) );
  Write(Arq,  #$12 + '    ' + FormatFloat('#,##0.00',qtde));
  Write(Arq,  #$12 + '    ' + FormatFloat('#,##0.00',unitario));
  Write(Arq,#$12 + '    ' + FormatFloat('#,##0.00',RoundSemArredondar(unitario * qtde)));
  aSubTotal := aSubTotal + RoundSemArredondar(unitario * qtde);
  CloseFile(Arq);
  if FileExists('item.txt') then
  begin
    AssignFile(Arq, 'item.txt');
    Reset(Arq);
    while not Eof(Arq) do
    begin
      Readln(Arq, aLinha);
      hPrintNormal( copy ( aLinha, 1, Length(aLinha)));
    end;
    CloseFile(Arq);
    while FileExists('item.txt') do
      DeleteFile('item.txt');
  end;
end;

Procedure RemoveItem (item, barras: String; qtde, unitario : Double);
var
  Arq : TextFile;
  aLinha : String;
begin
  AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'item.txt');
  Rewrite(Arq);
  Write(Arq,  #18 + subs( alltrim( item ), 1, 50 ));
  Write(Arq,  #$12 + '    ' + subs( barras, 1, 13 ) );
  Write(Arq,  #$12 + '   -' + FormatFloat('#,##0.00',qtde));
  Write(Arq,  #$12 + '   -' + FormatFloat('#,##0.00',unitario));
  Write(Arq,  #$12 + '    ' + FormatFloat('#,##0.00',RoundSemArredondar(unitario * qtde)));
  aSubTotal := aSubTotal - (unitario * qtde);
  CloseFile(Arq);
  if FileExists('item.txt') then
  begin
    AssignFile(Arq, 'item.txt');
    Reset(Arq);
    while not Eof(Arq) do
    begin
      Readln(Arq, aLinha);
      hPrintNormal( copy ( aLinha, 1, Length(aLinha)));
    end;
    CloseFile(Arq);
    while FileExists('item.txt') do
      DeleteFile('item.txt');
  end;
end;

function RetornaStrPorta(porta : THPortas): String;
begin
  case porta of
    hCOM1:     RetornaStrPorta := 'COM1' ;
    hCOM2:     RetornaStrPorta := 'COM2' ;
    hCOM3:     RetornaStrPorta := 'COM3' ;
    hCOM4:     RetornaStrPorta := 'COM4' ;
    hLPT1:     RetornaStrPorta := 'LPT1' ;
    hLPT2:     RetornaStrPorta := 'LPT2' ;
    hEthernet: RetornaStrPorta := 'rede' ;
    hUSB:      RetornaStrPorta := 'USB';
  end;
end;

Procedure ImprimeTipo (impressora : THImpressora; tipo : THTipoImp ;numeroimp, pdv : integer; data, hora, vendedor : String);
var
  Arq : TextFile;
  aLinha : String;
begin
  case device.aTsk of
    hVenda:begin
      hPrintNormal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hRVenda:begin
      hPrintNormal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hVendaCliente:begin
      hPrintNormal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
      begin
        AssignFile(Arq, 'hCliente.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hCliente.txt') do
          DeleteFile('hCliente.txt');
      end;
      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hRVendaCliente:begin
      hPrintNormal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
      hPrintNormal(Traco(47));
      if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
      begin
        AssignFile(Arq, 'hCliente.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hCliente.txt') do
          DeleteFile('hCliente.txt');
      end;
      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hPromissoria:begin
      hPrintNormal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
      hPrintNormal('N   Vencimento       Valor');
      if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
      begin
        AssignFile(Arq, 'hparcelas.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hparcelas.txt') do
          DeleteFile('hparcelas.txt');
      end;

      hPrintNormal(Traco(47));
      hPrintPequeno('No pagamento em atraso, sera cobrado multa de 2% e juros de ');
      hPrintPequeno(' 0,33% ao dia');
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('*NOTA PROMISSORIA*'))+ '*NOTA PROMISSORIA*');
      hPrintNormal(Traco(47));
      hPrintNormal('Vencimento em '+ LeIniTemp('PARCELAS','VECTO'));
      hPrintNormal('Valor em R$ '+ LeIniTemp('PARCELAS','TOTAL'));
      AvancaLinhas(1);
      hPrintPequeno( 'A ' +LeIniTemp('PARCELAS','VECTOEXT'));
      hPrintPequeno('Pagarei esta NOTA PROMISSORIA a : ' + LeIniTemp('EMPRESA','RAZAO'));
      hPrintPequeno('CNPJ: ' +LeIniTemp('EMPRESA','CNPJ') + ' ou a sua ordem,');
      hPrintPequeno('em moeda corrente deste pais a quantia de');
      hPrintPequeno(  LeIniTemp('PARCELAS', 'TOTALEXT'));
      hPrintPequeno('Pagavel em ' + LeIniTemp('EMPRESA','CIDADEUF'));
      AvancaLinhas(1);
      hPrintPequeno(LeIniTemp('PARCELAS','DATAEXT'));
      AvancaLinhas(1);
      hPrintPequeno('Cod.: ' + LeIniTemp('CLIENTE','CODIGO'));
      hPrintPequeno('Nome.: ' + LeIniTemp('CLIENTE','NOME  '));
      hPrintPequeno('CPF.: ' + LeIniTemp('CLIENTE','CPF'));
      hPrintPequeno('RG.: ' + LeIniTemp('CLIENTE','RG'));
      hPrintPequeno('Endereco.: ' + LeIniTemp('CLIENTE','END'));
      hPrintPequeno('Bairro.: ' + LeIniTemp('CLIENTE','BAIRRO'));
      hPrintPequeno('Cidade.: ' + LeIniTemp('CLIENTE','CCIDADEUF'));
      while FileExists('Temp.ini') do
        DeleteFile('Temp.ini');

    end;
    hConsignacao:begin
      hPrintNormal(alinhaCentro(length('CONSIGNACAO')) + 'CONSIGNACAO');
      hPrintNormal(Traco(47));
      hPrintNormal('Consignacao.:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      hPrintNormal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
      hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hRecibo:begin
      hPrintNormal(alinhaCentro(length('RECIBO')) + 'RECIBO');
      hPrintNormal(Traco(47));
      hPrintNormal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      hPrintNormal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
      hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
    end;
    hRRecibo:begin
      hPrintNormal(alinhaCentro(length('REIMPRESSAO RECIBO')) + 'REIMPRESSAO RECIBO');
      hPrintNormal(Traco(47));
      hPrintNormal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      hPrintNormal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
      hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
    end;
    hCarne: hPrintNormal('Carne...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

    hComanda:begin
      hPrintNormal(alinhaCentro(length('CONFERENCIA')) + 'CONFERENCIA');
      hPrintNormal(Traco(47));
      hPrintNormal('Comanda.:' +IntToStr(numeroimp) );
      hPrintNormal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
  end;
{$REGION}
//  case impressora of
//    hBematech:begin
//      case tipo of
//        hVenda:begin
//          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//
//          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Bematech_Normal(Traco(47));
//          Bematech_normal('Descricao');
//          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
//          Bematech_Normal(Traco(47));
//        end;
//        hRVenda:begin
//          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//
//          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Bematech_Normal(Traco(47));
//          Bematech_Normal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
//          Bematech_Normal(Traco(47));
//          Bematech_normal('Descricao');
//          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
//          Bematech_Normal(Traco(47));
//
//        end;
//        hVendaCliente:begin
//          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//
//          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Bematech_Normal(Traco(47));
//          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
//          begin
//            AssignFile(Arq, 'hCliente.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hCliente.txt') do
//              DeleteFile('hCliente.txt');
//          end;
//          Bematech_Normal(Traco(47));
//          Bematech_normal('Descricao');
//          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
//          Bematech_Normal(Traco(47));
//        end;
//        hRVendaCliente:begin
//          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//
//          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Bematech_Normal(Traco(47));
//          Bematech_Normal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
//          Bematech_Normal(Traco(47));
//          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
//          begin
//            AssignFile(Arq, 'hCliente.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hCliente.txt') do
//              DeleteFile('hCliente.txt');
//          end;
//          Bematech_Normal(Traco(47));
//          Bematech_normal('Descricao');
//          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
//          Bematech_Normal(Traco(47));
//        end;
//        hPromissoria:begin
//          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Bematech_Normal(Traco(47));
//          Bematech_Normal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
//          Bematech_Normal('N   Vencimento       Valor');
//          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
//          begin
//            AssignFile(Arq, 'hparcelas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hparcelas.txt') do
//              DeleteFile('hparcelas.txt');
//          end;
//
//          Bematech_Normal(Traco(47));
//          Bematech_Pequeno('No pagamento em atraso, sera cobrado multa de 2% e juros de ');
//          Bematech_Pequeno(' 0,33% ao dia');
//          Bematech_Normal(Traco(47));
//          Bematech_Normal(alinhaCentro(Length('*NOTA PROMISSORIA*'))+ '*NOTA PROMISSORIA*');
//          Bematech_Normal(Traco(47));
//          Bematech_Normal('Vencimento em '+ LeIniTemp('PARCELAS','VECTO'));
//          Bematech_Normal('Valor em R$ '+ LeIniTemp('PARCELAS','TOTAL'));
//          ComandoTX(#13#10,Length(#13#10));
//          Bematech_Pequeno( 'A ' +LeIniTemp('PARCELAS','VECTOEXT'));
//          Bematech_Pequeno('Pagarei esta NOTA PROMISSORIA a : ' + LeIniTemp('EMPRESA','RAZAO'));
//          Bematech_Pequeno('CNPJ: ' +LeIniTemp('EMPRESA','CNPJ') + ' ou a sua ordem,');
//          Bematech_Pequeno('em moeda corrente deste pais a quantia de');
//          Bematech_Pequeno(  LeIniTemp('PARCELAS', 'TOTALEXT'));
//          Bematech_Pequeno('Pagavel em ' + LeIniTemp('EMPRESA','CIDADEUF'));
//          ComandoTX(#13#10,Length(#13#10));
//          Bematech_Pequeno(LeIniTemp('PARCELAS','DATAEXT'));
//          ComandoTX(#13#10,Length(#13#10));
//          Bematech_Pequeno('Cod.: ' + LeIniTemp('CLIENTE','CODIGO'));
//          Bematech_Pequeno('Nome.: ' + LeIniTemp('CLIENTE','NOME  '));
//          Bematech_Pequeno('CPF.: ' + LeIniTemp('CLIENTE','CPF'));
//          Bematech_Pequeno('RG.: ' + LeIniTemp('CLIENTE','RG'));
//          Bematech_Pequeno('Endereco.: ' + LeIniTemp('CLIENTE','END'));
//          Bematech_Pequeno('Bairro.: ' + LeIniTemp('CLIENTE','BAIRRO'));
//          Bematech_Pequeno('Cidade.: ' + LeIniTemp('CLIENTE','CCIDADEUF'));
//          while FileExists('Temp.ini') do
//              DeleteFile('Temp.ini');
//
//        end;
//        hConsignacao:begin
//          Bematech_Normal(alinhaCentro(length('CONSIGNACAO')) + 'CONSIGNACAO');
//          Bematech_Normal(Traco(47));
//          Bematech_Normal('Consignacao.:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//          Bematech_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
//          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Bematech_Normal(Traco(47));
//          Bematech_normal('Descricao');
//          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
//          Bematech_Normal(Traco(47));
//        end;
//        hRecibo:begin
//          Bematech_Normal(alinhaCentro(length('RECIBO')) + 'RECIBO');
//          Bematech_Normal(Traco(47));
//          Bematech_Normal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//          Bematech_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
//          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
//        end;
//        hRRecibo:begin
//          Bematech_Normal(alinhaCentro(length('REIMPRESSAO RECIBO')) + 'REIMPRESSAO RECIBO');
//          Bematech_Normal(Traco(47));
//          Bematech_Normal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//          Bematech_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
//          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
//        end;
//        hCarne: Bematech_Normal('Carne...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//      end;
//    end;
//    hElgin:begin
//
//    end;
//    hDaruma:begin
//
//    end;
//    hEpson:begin
//
//    end;
//    hImpPadrao, hDiebold:begin/////////
//      case tipo of
//        hVenda:begin
//          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//
//          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Prn_Normal(Traco(47));
//          Prn_Normal('Descricao');
//          Prn_Normal('   Cod. Barras        Qtd     Unit.    Total');
//          Prn_Normal(Traco(47));
//        end;
//        hRVenda:begin
//          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//
//          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Prn_Normal(Traco(47));
//          Prn_Normal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
//          Prn_Normal(Traco(47));
//          Prn_Normal('Descricao');
//          Prn_Normal('   Cod. Barras        Qtd     Unit.    Total');
//          Prn_Normal(Traco(47));
//
//        end;
//        hVendaCliente:begin
//          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//
//          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Prn_Normal(Traco(47));
//          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
//          begin
//            AssignFile(Arq, 'hCliente.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hCliente.txt') do
//              DeleteFile('hCliente.txt');
//          end;
//          Prn_Normal(Traco(47));
//          Prn_Normal('Descricao');
//          Prn_Normal('   Cod. Barras        Qtd     Unit.    Total');
//          Prn_Normal(Traco(47));
//        end;
//        hRVendaCliente:begin
//          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//
//          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Prn_Normal(Traco(47));
//          Prn_Normal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
//          Prn_Normal(Traco(47));
//          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
//          begin
//            AssignFile(Arq, 'hCliente.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hCliente.txt') do
//              DeleteFile('hCliente.txt');
//          end;
//          Prn_Normal(Traco(47));
//          Prn_Normal('Descricao');
//          Prn_Normal('   Cod. Barras        Qtd     Unit.    Total');
//          Prn_Normal(Traco(47));
//        end;
//        hPromissoria:begin
//          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
//          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
//          Prn_Normal(Traco(47));
//          Prn_Normal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
//          Prn_Normal('N   Vencimento       Valor');
//          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
//          begin
//            AssignFile(Arq, 'hparcelas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hparcelas.txt') do
//              DeleteFile('hparcelas.txt');
//          end;
//
//          Prn_Normal(Traco(47));
//          Prn_Pequeno('No pagamento em atraso, sera cobrado multa de 2% e juros de ');
//          Prn_Pequeno(' 0,33% ao dia');
//          Prn_Normal(Traco(47));
//          Prn_Normal(alinhaCentro(Length('*NOTA PROMISSORIA*'))+ '*NOTA PROMISSORIA*');
//          Prn_Normal(Traco(47));
//          Prn_Normal('Vencimento em '+ LeIniTemp('PARCELAS','VECTO'));
//          Prn_Normal('Valor em R$ '+ LeIniTemp('PARCELAS','TOTAL'));
//          Prn_Normal('');
//          Prn_Pequeno( 'A ' +LeIniTemp('PARCELAS','VECTOEXT'));
//          Prn_Pequeno('Pagarei esta NOTA PROMISSORIA a : ' + LeIniTemp('EMPRESA','RAZAO'));
//          Prn_Pequeno('CNPJ: ' +LeIniTemp('EMPRESA','CNPJ') + ' ou a sua ordem,');
//          Prn_Pequeno('em moeda corrente deste pais a quantia de');
//          Prn_Pequeno(  LeIniTemp('PARCELAS', 'TOTALEXT'));
//          Prn_Pequeno('Pagavel em ' + LeIniTemp('EMPRESA','CIDADEUF'));
//          Prn_Normal('');
//          Prn_Pequeno(LeIniTemp('PARCELAS','DATAEXT'));
//          Prn_Normal('');
//          Prn_Pequeno('Cod.: ' + LeIniTemp('CLIENTE','CODIGO'));
//          Prn_Pequeno('Nome.: ' + LeIniTemp('CLIENTE','NOME  '));
//          Prn_Pequeno('CPF.: ' + LeIniTemp('CLIENTE','CPF'));
//          Prn_Pequeno('RG.: ' + LeIniTemp('CLIENTE','RG'));
//          Prn_Pequeno('Endereco.: ' + LeIniTemp('CLIENTE','END'));
//          Prn_Pequeno('Bairro.: ' + LeIniTemp('CLIENTE','BAIRRO'));
//          Prn_Pequeno('Cidade.: ' + LeIniTemp('CLIENTE','CCIDADEUF'));
//          while FileExists('Temp.ini') do
//              DeleteFile('Temp.ini');
//
//        end;
//        hConsignacao:begin
//          Prn_Normal(alinhaCentro(length('CONSIGNACAO')) + 'CONSIGNACAO');
//          Prn_Normal(TracoDuplo(47));
//          Prn_Normal('Consignacao...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//        end;
//        hRecibo:begin
//          Prn_Normal(alinhaCentro(length('RECIBO')) + 'RECIBO');
//          Prn_Normal(Traco(47));
//          Prn_Normal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//          Prn_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
//          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
//        end;
//        hRRecibo:begin
//          Prn_Normal(alinhaCentro(length('REIMPRESSAO RECIBO')) + 'REIMPRESSAO RECIBO');
//          Prn_Normal(Traco(47));
//          Prn_Normal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//          Prn_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
//          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
//        end;
////        hRecibo: Prn_Normal('Recibo...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//        hCarne: Prn_Normal('Carne...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
//      end;
//      prn.CloseDoc;
//    end;
//  end;
{$ENDREGION}
end;

Procedure InformaCliente(Ficha, Cliente, Endereco, Bairro : String); overload ;
var
  Arq : TextFile;
begin
   AssignFile(Arq, 'hCliente.txt');
   Rewrite(Arq);
   Writeln(Arq,'Codigo...:' + Ficha   );
   WriteLn(Arq,'Cliente..:' + Cliente );
   WriteLn(Arq,'Endereco.:' + Endereco);
   WriteLn(Arq,'Bairro...:' + Bairro  );
   CloseFile(Arq);
end;

Procedure InformaCliente(Ficha : integer ; Cliente, CPF, RG, Endereco, Bairro : String); overload ;
var
  Arq : TextFile;
begin
  AssignFile(Arq, 'hCliente.txt');
  Rewrite(Arq);
  Writeln(Arq,'Codigo...:' + IntToStr(Ficha)   );
  WriteLn(Arq,'Cliente..:' + Cliente );
  WriteLn(Arq,'CPF......:' + CPF );
  WriteLn(Arq,'RG.......:' + RG );
  WriteLn(Arq,'Endereco.:' + Endereco);
  WriteLn(Arq,'Bairro...:' + Bairro  );
  CloseFile(Arq);
end;

Procedure FechaImpressao (tipo : THTipoImp ; Desconto, Acrescimo, Total, Recebido : Double);
var
  Arq   : TextFile;
  aLinha : String;
begin
  hPrintNormal(Traco(47));
  case tipo of
    hVenda:begin
      hPrintNormal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
      hPrintNormal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
      hPrintNormal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
      hPrintNormal(Traco(47));
      if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
      begin
        AssignFile(Arq, 'hFormas.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hFormas.txt') do
          DeleteFile('hFormas.txt');
      end;
      hPrintNormal('Valor Total Recebido  '+ FormatFloat('#,##0.00',Recebido));
      if Recebido > Total then
        hPrintNormal('Troco  '+ FormatFloat('#,##0.00',(Recebido-(Total-desconto))));
      if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
      begin
        hPrintNormal(Traco(47));
        AssignFile(Arq, 'hCliente.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hCliente.txt') do
          DeleteFile('hCliente.txt');
      end;
    end;
    hConsignacao:begin
      hPrintNormal('Total Consignado.:     '+ aLinhaDireita(FormatFloat('#,##0.00',Total),20)) ;
      hPrintNormal(Traco(47));
      hPrintNormal('Consignado em nome de ' + LeIniTemp('CLIENTE','NOME'));
      hPrintNormal('CPF/CNPJ.: '+ LeIniTemp('CLIENTE','CNPJCPF')+ '  RG/IE: ' + LeIniTemp('CLIENTE', 'IERG'));
      if LeIniTemp('IMP','NUMERO') = '1' then
      begin
        AvancaLinhas(3);
        hPrintNormal(alinhaCentro(length('____________________________'))+ '____________________________');
        hPrintNormal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
      end;
    end;
    hRecibo:begin
      hPrintNormal('Recebemos de:' + LeIniTemp('CLIENTE', 'NOME'));
      hPrintNormal('O valor de ' + FormatFloat('#,##0.00',Total));
      hPrintNormal(LeIniTemp('PARCELAS', 'TOTALEXT'));
      if Desconto > 0 then
        hPrintNormal('C/ desconto de :' + FormatFloat('#,##0.00',Desconto));
      hPrintNormal(Traco(47));
      hPrintNormal('Referente a:');
      hPrintNormal('Venda    Vencimento       Valor');
      if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
      begin
        AssignFile(Arq, 'hparcelas.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hparcelas.txt') do
          DeleteFile('hparcelas.txt');
      end;
      hPrintNormal(Traco(47));
      hPrintNormal('Forma de Pagamento: ' + LeIniTemp('PARCELAS','FORMA'));
      AvancaLinhas(2);
      hPrintNormal(alinhaCentro(length('____________________________'))+ '____________________________');
      hPrintNormal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
    end;
    hVendaCliente:begin
      hPrintNormal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
      hPrintNormal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
      hPrintNormal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
      hPrintNormal('N   Vencimento       Valor');
      if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
      begin
        AssignFile(Arq, 'hparcelas.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hparcelas.txt') do
          DeleteFile('hparcelas.txt');
      end;
      AvancaLinhas(1);
      if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
      begin
        AssignFile(Arq, 'hFormas.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hFormas.txt') do
          DeleteFile('hFormas.txt');
      end;
      hPrintNormal(Traco(47));

      if Recebido > Total then
        hPrintNormal('Troco  '+ FormatFloat('#,##0.00',(Recebido-Total)));

      if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
      begin
        hPrintNormal(Traco(47));
        AssignFile(Arq, 'hCliente.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('hCliente.txt') do
          DeleteFile('hCliente.txt');
      end;
    end;
    hCarne:begin
//            hPrintNormal('Valor da Venda'+ FormatFloat('#,##0.00',SubTotal));
    end;
    hComanda:begin
      hPrintNormal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
      hPrintNormal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
      hPrintNormal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
    end;
  end;
  while FileExists('temp.txt') do
    DeleteFile('temp.txt');
  while FileExists('Temp.ini') do
    DeleteFile('Temp.ini');
  aSubTotal := 0;
  hPrintFechar;
{$REGION}
//  case device.aImp of
//    hBematech:begin
//      Bematech_Normal(Traco(47));
//      case tipo of
//        hVenda:begin
//          Bematech_Normal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
//          Bematech_Normal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
//          Bematech_Normal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
//          Bematech_Normal(Traco(47));
//          if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
//          begin
//            AssignFile(Arq, 'hFormas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hFormas.txt') do
//              DeleteFile('hFormas.txt');
//          end;
//
//          Bematech_Normal('Valor Total Recebido  '+ FormatFloat('#,##0.00',Recebido));
//          if Recebido > Total then
//            Bematech_Normal('Troco  '+ FormatFloat('#,##0.00',(Recebido-(Total-desconto))));
//
//          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
//          begin
//            Bematech_Normal(Traco(47));
//            AssignFile(Arq, 'hCliente.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hCliente.txt') do
//              DeleteFile('hCliente.txt');
//          end;
//        end;
//        hConsignacao:begin
//          Bematech_Normal('Total Consignado.:     '+ aLinhaDireita(FormatFloat('#,##0.00',Total),20)) ;
//          Bematech_Normal(Traco(47));
//          Bematech_Normal('Consignado em nome de ' + LeIniTemp('CLIENTE','NOME'));
//          Bematech_Normal('CPF/CNPJ.: '+ LeIniTemp('CLIENTE','CNPJCPF')+ '  RG/IE: ' + LeIniTemp('CLIENTE', 'IERG'));
//          if LeIniTemp('IMP','NUMERO') = '1' then
//          begin
//            ComandoTX(#13#10#13#10#13#10, length(#13#10#13#10#13#10));
//            Bematech_Normal(alinhaCentro(length('____________________________'))+ '____________________________');
//            Bematech_Normal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
//          end;
//        end;
//        hRecibo:begin
//          Bematech_Normal('Recebemos de:' + LeIniTemp('CLIENTE', 'NOME'));
//          Bematech_Normal('O valor de ' + FormatFloat('#,##0.00',Total));
//          Bematech_Normal(LeIniTemp('PARCELAS', 'TOTALEXT'));
//          if Desconto > 0 then
//            Bematech_Normal('C/ desconto de :' + FormatFloat('#,##0.00',Desconto));
//          Bematech_Normal(Traco(47));
//          Bematech_Normal('Referente a:');
//          Bematech_Normal('Venda    Vencimento       Valor');
//          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
//          begin
//            AssignFile(Arq, 'hparcelas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hparcelas.txt') do
//              DeleteFile('hparcelas.txt');
//          end;
//          Bematech_Normal(Traco(47));
//          Bematech_Normal('Forma de Pagamento: ' + LeIniTemp('PARCELAS','FORMA'));
//          ComandoTX(#13#10#13#10, Length(#13#10#13#10));
//          Bematech_Normal(alinhaCentro(length('____________________________'))+ '____________________________');
//          Bematech_Normal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
//        end;
//        hVendaCliente:begin
//          Bematech_Normal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
//          Bematech_Normal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
//          Bematech_Normal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
//          Bematech_Normal(Traco(47));
//          Bematech_Normal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
//          Bematech_Normal('N   Vencimento       Valor');
//          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
//          begin
//            AssignFile(Arq, 'hparcelas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hparcelas.txt') do
//              DeleteFile('hparcelas.txt');
//          end;
//          ComandoTx(#13#10,Length(#13#10));
//          if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
//          begin
//            AssignFile(Arq, 'hFormas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hFormas.txt') do
//              DeleteFile('hFormas.txt');
//          end;
//
//          Bematech_Normal(Traco(47));
//
//          if Recebido > Total then
//            Bematech_Normal('Troco  '+ FormatFloat('#,##0.00',(Recebido-Total)));
//
//          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
//          begin
//            Bematech_Normal(Traco(47));
//            AssignFile(Arq, 'hCliente.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hCliente.txt') do
//              DeleteFile('hCliente.txt');
//          end;
//        end;
//        hCarne:begin
////            Bematech_Normal('Valor da Venda'+ FormatFloat('#,##0.00',SubTotal));
//        end;
//      end;
//      while FileExists('temp.txt') do
//        DeleteFile('temp.txt');
//      while FileExists('Temp.ini') do
//            DeleteFile('Temp.ini');
//      aSubTotal := 0;
//      FechaPorta;
//    end;
//    hElgin:begin
//
//    end;
//    hDaruma:begin
//
//    end;
//    hEpson:begin
//
//    end;
//
//    hImpPadrao, hDiebold:begin
//      prn.OpenDoc('Fim');
//      Prn_Normal(Traco(47));
//      case tipo of
//        hVenda:begin
//          Prn_Normal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
//          Prn_Normal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
//          Prn_Normal('Valor Total     '+ FormatFloat('#,##0.00',Total));
//          Prn_Normal(Traco(47));
//          if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
//          begin
//            AssignFile(Arq, 'hFormas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hFormas.txt') do
//              DeleteFile('hFormas.txt');
//          end;
//
//          Prn_Normal('Valor Total Recebido  '+ FormatFloat('#,##0.00',Recebido));
//          if Recebido > Total then
//            Prn_Normal('Troco  '+ FormatFloat('#,##0.00',(Recebido-(Total-Desconto))));
//
//          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
//          begin
//            Prn_Normal(Traco(47));
//            AssignFile(Arq, 'hCliente.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hCliente.txt') do
//              DeleteFile('hCliente.txt');
//          end;
//        end;
//        hConsignacao:begin
//          Prn_Normal('Total Consignado.:     '+ aLinhaDireita(FormatFloat('#,##0.00',Total),20)) ;
//          Prn_Normal(Traco(47));
//          Prn_Normal('Consignado em nome de ' + LeIniTemp('CLIENTE','NOME'));
//          Prn_Normal('CPF/CNPJ.: '+ LeIniTemp('CLIENTE','CNPJCPF')+ '  RG/IE: ' + LeIniTemp('CLIENTE', 'IERG'));
//          if LeIniTemp('IMP','NUMERO') = '1' then
//          begin
//            prn_normal('');
//            prn_normal('');
//            prn_normal('');
//            Prn_Normal(alinhaCentro(length('____________________________'))+ '____________________________');
//            Prn_Normal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
//          end;
//        end;
//        hRecibo:begin
//          Prn_Normal('Recebemos de:' + LeIniTemp('CLIENTE', 'NOME'));
//          Prn_Normal('O valor de ' + FormatFloat('#,##0.00',Total));
//          Prn_Normal(LeIniTemp('PARCELAS', 'TOTALEXT'));
//          if Desconto > 0 then
//            Prn_Normal('C/ desconto de :' + FormatFloat('#,##0.00',Desconto));
//          Prn_Normal(Traco(47));
//          Prn_Normal('Referente a:');
//          Prn_Normal('Venda    Vencimento       Valor');
//          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
//          begin
//            AssignFile(Arq, 'hparcelas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hparcelas.txt') do
//              DeleteFile('hparcelas.txt');
//          end;
//          Prn_Normal(Traco(47));
//          Prn_Normal('Forma de Pagamento: ' + LeIniTemp('PARCELAS','FORMA'));
//          prn_normal('');
//          prn_normal('');
//          Prn_Normal(alinhaCentro(length('____________________________'))+ '____________________________');
//          Prn_Normal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
//        end;
//        hVendaCliente:begin
//          Prn_Normal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
//          Prn_Normal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
//          Prn_Normal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
//          Prn_Normal(Traco(47));
//          Prn_Normal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
//          Prn_Normal('N   Vencimento       Valor');
//          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
//          begin
//            AssignFile(Arq, 'hparcelas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hparcelas.txt') do
//              DeleteFile('hparcelas.txt');
//          end;
//          prn_normal('');
//          if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
//          begin
//            AssignFile(Arq, 'hFormas.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hFormas.txt') do
//              DeleteFile('hFormas.txt');
//          end;
//
//          Prn_Normal(Traco(47));
//
//          if Recebido > Total then
//            Prn_Normal('Troco  '+ FormatFloat('#,##0.00',(Recebido-Total)));
//
//          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
//          begin
//            Prn_Normal(Traco(47));
//            AssignFile(Arq, 'hCliente.txt');
//            Reset(Arq);
//            while not Eof(Arq) do
//            begin
//              Readln(Arq, aLinha);
//              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
//            end;
//            CloseFile(Arq);
//            while FileExists('hCliente.txt') do
//              DeleteFile('hCliente.txt');
//          end;
//        end;
//        hCarne:begin
//
//        end;
//      end;
//      while FileExists('temp.txt') do
//        DeleteFile('temp.txt');
//      while FileExists('Temp.ini') do
//            DeleteFile('Temp.ini');
//      aSubTotal := 0;
//      prn.CloseDoc;
//     // FreeAndNil(prn);   Adicionar para minimizar o uso de memória, pois toda  vez que usa o CharPrinter pega a que iniciou
//    end;
//  end;
{$ENDREGION}
end;

procedure AbreGaveta(impressora : THImpressora; modelo : THModeloIMP; porta : THPortas); overload ;
var
  Arq : TextFile;
  aLinha : String;
  aComando : String;
begin
  aComando := #27+#118+#140;
  case impressora of
    hBematech:begin
      AtivaImpressora(impressora,modelo,porta);
      ComandoTX(aComando,Length(aComando));
      FechaPorta;
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hDiebold:begin
      prn_comando(#27+'&0'+#12 +#48);
    end;
    hImpPadrao:begin
//      prn_comando(#27+#112+#0+#60+#120);
      prn_comando(#27+#118+#140);

    end;

  end;
end;

procedure AbreGaveta(impressora, modelo, porta  : integer);overload;
var
  Arq : TextFile;
  aLinha : String;
  aComando : String;
begin
  aComando := #27+#118+#140;
  case setImpressora(impressora) of
    hBematech:begin
      AtivaImpressora(impressora,modelo,porta);
      ComandoTX(aComando,Length(aComando));
      FechaPorta;
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hDiebold:begin
      prn_comando(#27+'&0'+#12 +#48);
    end;
    hImpPadrao:begin
//      prn_comando(#27+#112+#0+#60+#120);
      prn_comando(#27+#118+#140);
    end;

  end;
end;

function RetornaModelo(modelo : THModeloIMP):integer;
begin
  case modelo of
    hMP20MI: RetornaModelo := 1 ;
    hMP4000TH: RetornaModelo := 5 ;
    hMP4200TH:RetornaModelo := 7 ;
    hMP2500TH: RetornaModelo := 8 ;
  end;
  if modelo = hMP20CI   then RetornaModelo := 0;
  if modelo = hMP20TH   then RetornaModelo := 0;
  if modelo = hMP2000CI then RetornaModelo := 0;
  if modelo = hMP2000TH then RetornaModelo := 0;
  if modelo = hMP2100TH then RetornaModelo := 0;
end;

procedure AtivaImpressora(impressora : THImpressora; modelo: THModeloIMP; porta : THPortas); overload ;
begin
  device.aImp := impressora;
  device.aMod := modelo;
  device.aPrt := porta;

  case impressora of
    hBematech:begin
      aSubTotal := 0;

      ConfiguraModeloImpressora(RetornaModelo(device.aMod));
      if (IniciaPorta(RetornaStrPorta(device.aPrt)) <> 1)  then
      begin
        Application.MessageBox('Sem conexão com a impressora','Aviso!', MB_OK + MB_ICONWARNING);
        Exit;
      end;
      ComandoTX(#29#249#32#0#27#116#8,Length(#29#249#32#0#27#116#8) );
    end;
    hElgin: ;
    hDaruma: ;
    hEpson: ;
    hMatricial: ;
    hImpPadrao, hDiebold:begin
      aSubTotal := 0;

      prn := TAdvancedPrinter.Create;
      prn.OpenDoc('Impressão Documentos');
    end;
  end;
end;

procedure AtivaImpressora(impressora : integer; modelo: integer; porta : integer);overload ;
begin
  device.aImp := setImpressora(impressora);
  device.aMod := setModelo(modelo);
  device.aPrt := setPorta(porta);

  case setImpressora(impressora) of
    hBematech:begin
      aSubTotal := 0;
      ConfiguraModeloImpressora(RetornaModelo(device.aMod));
      if (IniciaPorta(RetornaStrPorta(device.aPrt)) <> 1)  then
      begin
        Application.MessageBox('Sem conexão com a impressora','Aviso!', MB_OK + MB_ICONWARNING);
        Exit;
      end;
      ComandoTX(#29#249#32#0#27#116#8,Length(#29#249#32#0#27#116#8) );
    end;
    hElgin: ;
    hDaruma: ;
    hEpson: ;
    hMatricial: ;
    hImpPadrao, hDiebold:begin
      aSubTotal := 0;
      prn := TAdvancedPrinter.Create;
      prn.OpenDoc('Impressão Documentos');
    end;
  end;
end;

procedure IniciaImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String);
begin
  device.aTsk := tipo;
  ImpCabecalho;
  ImprimeTipo(device.aImp, tipo,numeroimp,pdv,DateToStr(now),TimeToStr(now),vendedor);
end;

procedure IniciaRImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String; data: Tdate; hora : TTime);
begin
  device.aTsk := tipo;
  ImpCabecalho;
  ImprimeTipo(device.aImp, tipo,numeroimp,pdv,DateToStr(Data),TimeToStr(Hora),vendedor);
end;                                                                                                           

Procedure AdicionaForma (forma : String; valor : Double);
var
  Arq : TextFile;
  aLinha : String;
begin
  AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hFormas.txt');
  if not FileExists(ExtractFilePath(Application.ExeName)+ 'hFormas.txt') then
    Rewrite(Arq)
  else
    Append(Arq);
  Writeln(Arq,'Total em ' + forma +'  '+FormatFloat('#,##0.00',valor));
  CloseFile(Arq);
end;

procedure ImprimeBarras(aCodigo : String);
begin
  case device.aImp of
    hBematech:begin

    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hDiebold:begin

    end;
  end;
end;

procedure ImprimeQR(aCodigo : String);
begin
  case device.aImp of
    hBematech:begin

      FechaPorta;
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hDiebold:begin

    end;
  end;
end;

procedure Guilhotina(corta : boolean);
begin
  if corta  = True then
  begin
    case device.aImp of
      hBematech:begin
        AtivaImpressora(device.aImp,device.aMod, device.aPrt);
        AcionaGuilhotina(0);
        FechaPorta;
      end;
      hImpPadrao,hDiebold:begin
        AtivaImpressora(device.aImp,device.aMod, device.aPrt);
        prn_comando(#27+#109);
      end;
    end;
  end;
end;

procedure ImpSangria(caixa : integer; supervisor, operador : String; valor : Double);
begin
  ImpCabecalho;
  hPrintNormal(alinhaCentro(Length('SANGRIA '))+'SANGRIA ');
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('Caixa :' + IntToStr(caixa));
  hPrintNormal('Supervisor :' + supervisor);
  hPrintNormal('Operador :' + operador);
  hPrintNormal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
  hPrintNormal(Traco(47));
  hPrintNormal('Valor da Retirada:  ' + FormatFloat('#,##0.00',valor));
  AvancaLinhas(2);
  hPrintNormal(Alinhacentro(LengTh('__________________________'))+'__________________________');
  hPrintNormal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
  hPrintFechar;
end;

procedure ImpSuprimento(caixa : integer; supervisor, operador : String; valor : Double);
begin
  ImpCabecalho;
  hPrintNormal(alinhaCentro(Length('SUPRIMENTO '))+'SUPRIMENTO ');
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('Caixa :' + IntToStr(caixa));
  hPrintNormal('Supervisor :' + supervisor);
  hPrintNormal('Operador :' + operador);
  hPrintNormal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
  hPrintNormal(Traco(47));
  hPrintNormal('Valor do Suprimento:  ' + FormatFloat('#,##0.00',valor));
  AvancaLinhas(2);
  hPrintNormal(Alinhacentro(LengTh('__________________________'))+'__________________________');
  hPrintNormal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
  hPrintFechar;
end;

procedure CancelaCupom(caixa, cupom : integer; operador : String ; datahoravenda: TDateTime ;subtotal, desconto, total : Double);
begin
  ImpCabecalho;
  hPrintNormal(alinhaCentro(Length('CANCELAMENTO '))+'CANCELAMENTO ');
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('Caixa.........:' + IntToStr(caixa));
  hPrintNormal('Nr. Cancelado :' + IntToStr(cupom));
  hPrintNormal(Traco(47));
  hPrintNormal('Sub Total....:     ' + FormatFloat('#,##0.00',subtotal));
  hPrintNormal('Desconto.....:     ' + FormatFloat('#,##0.00',desconto));
  hPrintNormal('Valor Total..:     ' + FormatFloat('#,##0.00',total));
  hPrintNormal('Data da Venda:     ' + FormatDateTime('DD/MM/YYYY',datahoravenda));
  hPrintNormal('Data da Venda:     ' + FormatDateTime('DD/MM/YYYY',now));
  hPrintNormal('Operador.....:' + operador);
  hPrintNormal(Traco(47));
  hPrintFechar;

end;

procedure ImpAbertura(caixa : integer; supervisor, operador : String; valor : Double);
begin
  ImpCabecalho;
  hPrintNormal(alinhaCentro(Length('ABERTURA'))+'ABERTURA');
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('Caixa : ' + IntToStr(caixa));
  hPrintNormal('Supervisor : ' + supervisor);
  hPrintNormal('Operador : ' + operador);
  hPrintNormal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
  hPrintNormal(Traco(47));
  hPrintNormal('Valor Abertura:  ' + FormatFloat('#,##0.00',valor));
  AvancaLinhas(2);
  hPrintNormal(Alinhacentro(LengTh('__________________________'))+'__________________________');
  hPrintNormal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
  hPrintFechar;

end;

procedure ImpFechamento(caixa, controle : integer; supervisorab,supervisorf, operador : String; aData: TDate; aHora: TTime; valor, valorinformado : Double);
var
  aTotalCaixa, aTotalVendas, aValorFinal, aDiferenca : Double;
begin
  ImpCabecalho;
  hPrintNormal(alinhaCentro(Length('FECHAMENTO DO CAIXA'))+'FECHAMENTO DO CAIXA');
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('Caixa : ' + IntToStr(caixa)+ '  Controle : ' + IntToStr(controle));
  hPrintNormal('Superv. Abertura  : ' + supervisorab);
  hPrintNormal('Data/Hora Abertura : '+ DateToStr(aData) +' as '+TimeToStr(aHora));
  hPrintNormal('Superv. Fechamento: ' + supervisorf);
  hPrintNormal('Data/Hora Fechamento : '+ DateToStr(Date) +' as '+TimeToStr(Time));
  hPrintNormal('Operador : ' + operador);
  hPrintNormal(Traco(47));
  hPrintNormal(alinhaCentro(Length('Dados do Caixa'))+ 'Dados do Caixa');
  hPrintNormal(Traco(47));
  hPrintNormal('+ Valor Inicial do caixa..:' + aLinhaDireita(FormatFloat('#,##0.00',valor),20));
  hPrintNormal('+ Dinheiro................:'+ aLinhaDireita(FormatFloat('#,##0.00',aDinheiro),20));
  hPrintNormal('+ Cheque..................:'+ aLinhaDireita(FormatFloat('#,##0.00',aCheque),20));
  hPrintNormal('+ Cartao..................:'+ aLinhaDireita(FormatFloat('#,##0.00',aCartao),20));
  hPrintNormal('+ Suprimento..............:'+ aLinhaDireita(FormatFloat('#,##0.00',aSuprimento),20));
  hPrintNormal('- Sangria.................:'+ aLinhaDireita(FormatFloat('#,##0.00',aSangria),20));

  aTotalCaixa := (valor + aDinheiro + aCartao + aCheque + aSuprimento) - aSangria;

  hPrintNormal('= Valor Final em Caixa....:'+ aLinhaDireita(FormatFloat('#,##0.00',aTotalCaixa),20));

  if valorinformado <> 0  then
  begin
    aValorFinal := (valor + aSuprimento + aTotalVendas + aTRecebido) - aSangria;
    hPrintNormal('Valor Informado...........:'+ aLinhaDireita(FormatFloat('#,##0.00',valorinformado),20));

    aDiferenca := valorinformado - aValorFinal;

    hPrintNormal('Valor Diferenca...........:'+ aLinhaDireita(FormatFloat('#,##0.00',aDiferenca),20));
  end;

  hPrintNormal(Traco(47));
  hPrintNormal(alinhaCentro(Length('Informativo de Vendas'))+ 'Informativo de Vendas');
  hPrintNormal(Traco(47));

  hPrintNormal('+ Vendas em Dinheiro......:'+ aLinhaDireita(FormatFloat('#,##0.00',aTDinheiro),20));
  hPrintNormal('+ Vendas em Cheque........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCheque),20));
  hPrintNormal('+ Vendas em Cartao........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCartao),20));
  hPrintNormal('+ Vendas para Cliente.....:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCliente),20));

  aTotalVendas := aTDinheiro + aTCheque + aTCartao + aTCliente;

  hPrintNormal('= Total de Vendas.........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTotalVendas),20));
  hPrintNormal(Traco(47));
  hPrintNormal('= Total em Descontos......:'+ aLinhaDireita(FormatFloat('#,##0.00',aTDesconto),20));
  hPrintNormal('= Recebimento de Clientes.:'+ aLinhaDireita(FormatFloat('#,##0.00',aTRecebido),20));
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('Cupuns Cancelados.........:'+ aLinhaDireita(FormatFloat('###,#0',aCancelados),20));
  hPrintNormal('Valor Cupons Cancelados...:'+ aLinhaDireita(FormatFloat('#,##0.00',aVlrCancelados),20));
  hPrintNormal('Itens Cancelados..........:'+ aLinhaDireita(FormatFloat('###,#0',aItmCancelados),20));
  hPrintNormal('Valor Itens Cancelados....:'+ aLinhaDireita(FormatFloat('#,##0.00',aVlrItmCancelados),20));
  hPrintNormal(Traco(47));
  zeraVariaveis();
  hPrintFechar;
end;

procedure informaDadosCaixa(Dinheiro, Cheque, Cartao, Suprimento, Sangria : Double);
begin
  aDinheiro   := Dinheiro;
  aCartao     := Cartao;
  aCheque     := Cheque;
  aSuprimento := Suprimento;
  aSangria    := Sangria;
end;

procedure informaDadosVenda(TDinheiro, TCheque, TCartao, TCliente, TDesconto, TRecebido : Double);
begin
  aTDinheiro  := TDinheiro;
  aTCheque    := TCheque;
  aTCartao    := TCartao;
  aTCliente   := TCliente;
  aTDesconto  := TDesconto;
  aTRecebido  := TRecebido;
end;

procedure informaTotais(Cancelados, VlrCancelados, ItmCancelados, VlrItmCancelados : Double);
begin
  aCancelados       := Cancelados;
  aVlrCancelados    := VlrCancelados;
  aItmCancelados    := ItmCancelados;
  aVlrItmCancelados := VlrItmCancelados;
end;

procedure zeraVariaveis();
begin
  aDinheiro         := 0;
  aCartao           := 0;
  aCheque           := 0;
  aSuprimento       := 0;
  aSangria          := 0;
  aTDinheiro        := 0;
  aTCheque          := 0;
  aTCartao          := 0;
  aTCliente         := 0;
  aTDesconto        := 0;
  aTRecebido        := 0;
  aCancelados       := 0;
  aVlrCancelados    := 0;
  aItmCancelados    := 0;
  aVlrItmCancelados := 0;
end;

function setImpressora(imp : integer) : THImpressora;
//hBematech, hElgin, hDaruma, hEpson, hDiebold, hMatricial, hImpPadrao;
begin
  case imp of
    0: setImpressora := hBematech;
    1: setImpressora := hElgin;
    2: setImpressora := hDaruma;
    3: setImpressora := hEpson;
    4: setImpressora := hDiebold;
    5: setImpressora := hMatricial;
    6: setImpressora := hImpPadrao;
  end;

end;

function setModelo(modelo : integer) : THModeloIMP;
//Bematech
//hMP20MI   = 0,
//hMP20CI   = 1,
//hMP20TH   = 2,
//hMP2000CI = 3,
//hMP2000TH = 4,
//hMP2100TH = 5,
//hMP4000TH = 6,
//hMP4200TH = 7,
//hMP2500TH = 8,
//Matricial
//hGenericText = 9
begin
  case modelo of
    0: setModelo := hMP20MI;
    1: setModelo := hMP20CI;
    2: setModelo := hMP20TH;
    3: setModelo := hMP2000CI;
    4: setModelo := hMP2000TH;
    5: setModelo := hMP2100TH;
    6: setModelo := hMP4000TH;
    7: setModelo := hMP4200TH;
    8: setModelo := hMP2500TH;
    9: setModelo := hGenericText;
  end;

end;

function setPorta(porta : integer) : THPortas;
// 0 - hCOM1, 1 - hCOM2, 2 - hCOM3, 3 - hCOM4,
// 4 - hLPT1, 5 - hLPT2, 6 - hEthernet, 7 - hUSB
begin
  case porta of
    0: setPorta := hCOM1;
    1: setPorta := hCOM2;
    2: setPorta := hCOM3;
    3: setPorta := hCOM4;
    4: setPorta := hLPT1;
    5: setPorta := hLPT2;
    6: setPorta := hEthernet;
    7: setPorta := hUSB;
  end;
end;


procedure DadosTemporarios(dados, campo, valor :String);
begin
  GeraIniTemp(dados,campo,valor);
end;

Procedure AdicionaParcela (vecto : String ; valor : Double);overload;
var
  Arq : TextFile;
  aLinha : String;
begin
  AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hparcelas.txt');
  if not FileExists(ExtractFilePath(Application.ExeName)+ 'hparcelas.txt') then
    Rewrite(Arq)
  else
    Append(Arq);
  Writeln(Arq,{IntToStr(parcela)+ }'    ' + vecto +'       '+FormatFloat('#,##0.00',valor));
end;

Procedure AdicionaParcela (parcela : integer; vecto : String ; valor : Double); overload;
var
  Arq : TextFile;
  aLinha : String;
begin
  AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hparcelas.txt');
  if not FileExists(ExtractFilePath(Application.ExeName)+ 'hparcelas.txt') then
    Rewrite(Arq)
  else
    Append(Arq);
  Writeln(Arq,IntToStr(parcela)+ '    ' + vecto +'       '+FormatFloat('#,##0.00',valor));
  CloseFile(Arq);
end;

procedure Prn_Pequeno(aTexto : String);
begin
  prn.SendData(#15 + aTexto + #10);
end;

procedure Prn_Normal(aTexto : String);
begin
  prn.SendData(#18 + aTexto + #10);
end;

procedure Prn_Grande(aTexto : String);
begin
  prn.SendData(#14 + aTexto + #10);
end;

procedure Prn_Comando(aTexto : String);
var
  cmd : TAdvancedPrinter;
begin
  cmd := TAdvancedPrinter.Create;
  cmd.OpenDoc('CMD');
  cmd.SendData(aTexto);
  cmd.CloseDoc;
end;

procedure AvancaLinhas(linhas : integer);
var
 I : integer;
begin
  case device.aImp of
    hBematech :begin
      AtivaImpressora(device.aImp,device.aMod,device.aPrt);
      for I := 0 to linhas - 1 do
        ComandoTX(#13#10, Length(#13#10));
    end;
    hImpPadrao, hDiebold:begin
      for I := 0 to linhas - 1 do
        Prn_Comando(#10);
    end;
  end;
end;

procedure TesteImpressora(impressora, modelo, porta, avanco :Integer);
begin
  AtivaImpressora(impressora,modelo,porta);
  hPrintPequeno('Fonte Pequena');
  hPrintNormal('Fonte Normal');
  hPrintGrande('Fonte Grande');
  hPrintNormal('Fim Teste');
  AvancaLinhas(avanco);
  hPrintFechar();

end;

{$REGION 'COMANDOS UNIFICADOS'}

procedure hPrintPequeno(aTexto : String);
begin
  case device.aImp of
    hBematech:begin
      Bematech_Pequeno(aTexto);
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao,hDiebold:begin
      Prn_Pequeno(aTexto);
    end;
  end;
end;

procedure hPrintNormal(aTexto : String);
begin
  case device.aImp of
    hBematech:begin
      Bematech_Normal(aTexto);
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao,hDiebold:begin
      Prn_Normal(aTexto);
    end;
  end;
end;

procedure hPrintGrande(aTexto : String);
begin
  case device.aImp of
    hBematech:begin
      Bematech_Grande(aTexto);
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao,hDiebold:begin
      Prn_Grande(aTexto);
    end;
  end;
end;

procedure hPrintComando(aTexto : String);
begin
  case device.aImp of
    hBematech:begin
      ComandoTX(aTexto,Length(aTexto));
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao,hDiebold:begin
      Prn_Comando(aTexto);
    end;
  end;
end;

procedure hPrintFechar();
begin
  case device.aImp of
    hBematech:begin
      FechaPorta;
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao,hDiebold:begin
      prn.CloseDoc;
      FreeAndNil(prn);
    end;
  end;
end;

procedure hAbregaveta();
begin
  AbreGaveta(device.aImp,device.aMod,device.aPrt);
end;
{$ENDREGION}


end.
