unit impressao;
{
  Função: Impressão de Pré Venda
  Autor:  Daniel Cunha
  Data:   10/06/2014
  Funcionamento:
    Bematech   : Utiliza a DLL MP2032.dll
    Impressora Padrão : Utiliza CharPrinter com comandos ESC/POS (Impressora padrão do Windows)

  18-11-2014 > Iniciada a mudança para comandos unificados, assim fica mais facil a manutenção
      das impressoes;
  19-12-2014 > Iniciada mudança de arq TXT para record;

  23-02-2015 > [Fabio Luiz Franzini] Acerto nas variaveis de fachamento do caixa

  25-02-2015 > [Daniel Brandão da Cunha] Criada a função para imprimir detalhe da sangria

  19-08-2015 > [Daniel Brandão da Cunha] Retidado CNPJ e IE do Cabeçalho 
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
    aIP  : String;
    aTsk : THTipoImp;
  end;

  THCostumer = record
    aCod,
    aName,
    aAddr,
    aProv,
    aCPF,
    aRG, aType : String;
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

  //para setar cliente
  client : THCostumer;
  
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
procedure AbreGaveta(impressora : THImpressora; modelo : THModeloIMP; porta : THPortas; ip : String);overload;
procedure AbreGaveta(impressora, modelo, porta  : integer; ip : String);overload;

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
procedure AtivaImpressora(impressora : THImpressora; modelo: THModeloIMP; porta : THPortas ; IP : String);overload;
procedure AtivaImpressora(impressora : integer; modelo: integer; porta : integer; IP : String);overload ;

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
procedure TesteImpressora(impressora, modelo, porta, avanco :Integer; ip : String);

{$ENDREGION}

{$REGION 'IMPRESSAO'}
procedure ImpCabecalho();
procedure AdicionaItem (item, barras: String; qtde, unitario, total : Double);
procedure RemoveItem (item, barras: String; qtde, unitario : Double);
procedure ImprimeTipo (impressora : THImpressora; tipo : THTipoImp ;numeroimp, pdv : integer; data, hora, vendedor : String);

procedure InformaCliente(Ficha, Cliente, Endereco, Bairro, Tipo : String);overload;
procedure InformaCliente(Ficha : integer ; Cliente, CPF, RG, Endereco, Bairro, Tipo : String); overload ;

{Manutenção Aqui}
//Será retirado o tipo da impressao e passado para o tipo que iniciou
Procedure FechaImpressao (tipo : THTipoImp ; Desconto, Acrescimo, Total, Recebido : Double; OBS: String);
{Fim Manutencão }

procedure IniciaImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String);
procedure IniciaRImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String; data: Tdate; hora : TTime);


procedure AdicionaParcela (parcela : integer; vecto : String ; valor : Double);overload;
Procedure AdicionaParcela ( vecto : String ; valor : Double);overload;
procedure DadosTemporarios(dados, campo, valor :String);


procedure AdicionaForma (forma : String; valor : Double);

procedure DetalheSangria( Data, Hora, Operador,Descricao : String; Valor : Double );
{$ENDREGION}

{$REGION 'CODIGOS'}
procedure ImprimeBarras(aCodigo : String);
procedure ImprimeQR(aCodigo : String);
{$ENDREGION}

{$REGION 'IMPRESSOES OPERACIONAIS'}
procedure ImpSangria(caixa : integer; supervisor, operador, descricao : String; valor : Double);
procedure ImpSuprimento(caixa : integer; supervisor, operador, descricao : String; valor : Double);
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
  AtivaImpressora(device.aImp , device.aMod ,device.aPrt, device.aIP);
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
  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN001')+ ' '+ LeIni('EMPRESA','LIN002'))) + LeIni('EMPRESA','LIN001')+' ' +LeIni('EMPRESA','LIN002'));
//  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN002'))) + LeIni('EMPRESA','LIN002'));
  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN003')+ ' '+LeIni('EMPRESA','LIN005'))) + LeIni('EMPRESA','LIN003')+' '+ LeIni('EMPRESA','LIN005'));
//  hPrintNormal(alinhaCentro(Length(LeIni('EMPRESA','LIN005'))) + LeIni('EMPRESA','LIN005'));
  hPrintNormal( TracoDuplo(47));
end;

Procedure AdicionaItem (item, barras: String; qtde, unitario, total : Double);
var
  aLinha : String;
begin
  aLinha := #18 + subs( alltrim( item ), 1, 47 ) +
            #$12 + '   ' + subs( barras, 1, 13 ) +
            #$12 + '   ' + FormatFloat('#,###0.000',qtde) +
            #$12 + '   ' + FormatFloat('#,##0.00',unitario) +
            #$12 + '   ' + FormatFloat('#,##0.00',RoundSemArredondar(unitario * qtde));
  aSubTotal := aSubTotal + total;//(unitario * qtde);
  hPrintNormal( copy ( aLinha, 1, Length(aLinha)));

end;

Procedure RemoveItem (item, barras: String; qtde, unitario : Double);
var
  aLinha : String;
begin
  aLinha := #18 + subs( alltrim( item ), 1, 47 )+
            #$12 + '   ' + subs( barras, 1, 13 )+
            #$12 + '  -' + FormatFloat('#,###0.000',qtde)+
            #$12 + '  -' + FormatFloat('#,##0.00',unitario)+
            #$12 + '   ' + FormatFloat('#,##0.00',RoundSemArredondar(unitario * qtde));
  aSubTotal := aSubTotal - (unitario * qtde);
  hPrintNormal( copy ( aLinha, 1, Length(aLinha)));
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
    hEthernet: RetornaStrPorta := device.aIP ;
    hUSB:      RetornaStrPorta := 'USB';
  end;
end;

Procedure ImprimeTipo (impressora : THImpressora; tipo : THTipoImp ;numeroimp, pdv : integer; data, hora, vendedor  : String);
var
  Arq : TextFile;
  aLinha : String;
begin
  case device.aTsk of
    hVenda:begin
      hPrintNormal('Num:' +IntToStr(numeroimp) + ' PDV:' + IntToStr(pdv) + ' Data:' +  Trim(data) + ' ' + copy(hora,0,5));
      if client.aName <> '' then
        hPrintNormal('Cliente:' + client.aName);

      
//      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      if length(vendedor) > 0 then
        hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));

      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hRVenda:begin
      hPrintNormal('Num:' +IntToStr(numeroimp) + ' PDV:' + IntToStr(pdv) + ' Data:' +  Trim(data) + ' ' + copy(hora,0,5));

//      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      if length(vendedor) > 0 then
        hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hVendaCliente:begin
      hPrintNormal('Num:' +IntToStr(numeroimp) + ' PDV:' + IntToStr(pdv) + ' Data:' +  Trim(data) + ' ' + copy(hora,0,5));

//      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      if length(vendedor) > 0 then
        hPrintNormal('Vendedor.: ' +  Trim(vendedor) );

      hPrintNormal(Traco(47));
      if client.aName <> '' then
      begin
        if client.aType = 'F' then
        begin
          hPrintNormal('Matricula:' + client.aCod);
          hPrintNormal('Funcionario..:' + client.aName);
        end
        else
        begin
          hPrintNormal('Codigo...:' + client.aCod);
          hPrintNormal('Cliente..:' + client.aName);
        end;
        if client.aCPF <> '' then
          hPrintNormal('CPF......:' + client.aCPF);
        if client.aRG <> '' then
          hPrintNormal('RG.......:' + client.aRG);
        hPrintNormal('Endereco.:' + client.aAddr);
        hPrintNormal('Bairro...:' + client.aProv);
      end;

      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hRVendaCliente:begin
      hPrintNormal('Num:' +IntToStr(numeroimp) + ' PDV:' + IntToStr(pdv) + ' Data:' +  Trim(data) + ' ' + copy(hora,0,5));

//      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      if length(vendedor) > 0 then
        hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');

      if client.aName <> '' then
      begin
        hPrintNormal(Traco(47));
        hPrintNormal('Codigo...:' + client.aCod);
        if client.aType = 'F' then
          hPrintNormal('Funcionario..:' + client.aName)
        else
          hPrintNormal('Cliente..:' + client.aName);
        if client.aCPF <> '' then
          hPrintNormal('CPF......:' + client.aCPF);
        if client.aRG <> '' then
          hPrintNormal('RG.......:' + client.aRG);
        hPrintNormal('Endereco.:' + client.aAddr);
        hPrintNormal('Bairro...:' + client.aProv);
      end;

      hPrintNormal(Traco(47));
      hPrintNormal('Descricao');
      hPrintNormal('   Cod. Barras        Qtd     Unit.    Total');
      hPrintNormal(Traco(47));
    end;
    hPromissoria:begin
      hPrintNormal('Num:' +IntToStr(numeroimp) + ' PDV:' + IntToStr(pdv) + ' Data:' +  Trim(data) + ' ' + copy(hora,0,5));
//      hPrintNormal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
      if length(vendedor) > 0 then
        hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
      hPrintNormal('N   Vencimento       Valor');
      if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
      begin
        AssignFile(Arq, 'hparcelas.txt');
        try
          Reset(Arq);
        except

        end;
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
      if Length(Trim(LeIniTemp('CLIENTE','CPF'))) <= 14  then
      begin
        hPrintPequeno('CPF.: ' + LeIniTemp('CLIENTE','CPF'));
        hPrintPequeno('RG.: ' + LeIniTemp('CLIENTE','RG'));
      end
      else
      begin
        hPrintPequeno('CNPJ.: ' + LeIniTemp('CLIENTE','CPF'));
        hPrintPequeno('IE.: ' + LeIniTemp('CLIENTE','RG'));
      end;

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
      if length(vendedor) > 0 then
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
      if length(vendedor) > 0 then
        hPrintNormal('Vendedor.: ' +  Trim(vendedor) );
    end;
    hRRecibo:begin
      hPrintNormal(alinhaCentro(length('REIMPRESSAO RECIBO')) + 'REIMPRESSAO RECIBO');
      hPrintNormal(Traco(47));
      hPrintNormal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      hPrintNormal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
      if length(vendedor) > 0 then
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
end;

Procedure InformaCliente(Ficha, Cliente, Endereco, Bairro, Tipo  : String); overload ;
begin                                                     {C = Cliente, F = Funcionário}
  client.aCod   := Ficha;
  client.aName  := Cliente;
  client.aAddr  := Endereco;
  client.aProv  := Bairro;
  client.aType  := Tipo;

end;

Procedure InformaCliente(Ficha : integer ; Cliente, CPF, RG, Endereco, Bairro, Tipo : String); overload ;
begin                                                                         {C = Cliente, F = Funcionário}
  client.aCod   := IntToStr(Ficha);
  client.aName  := Cliente;
  client.aAddr  := Endereco;
  client.aProv  := Bairro;
  client.aCPF   := CPF;
  client.aRG    := RG;
  client.aType  := Tipo;
end;

Procedure FechaImpressao (tipo : THTipoImp ; Desconto, Acrescimo, Total, Recebido : Double; OBS: String);
var
  Arq   : TextFile;
  aLinha : String;
begin
  hPrintNormal(Traco(47));
  case tipo of
    hVenda:begin
      hPrintNormal('Valor da Venda  '+ FormatFloat('#,##0.00',Total));
      if Desconto > 0 then
      begin
        hPrintNormal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
        hPrintNormal('Valor Total     '+ FormatFloat('#,##0.00',Total - desconto ));
      end;
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
                                             { DONE : Acertar tipos de impressão }
      hPrintNormal('Valor Total Recebido  '+ FormatFloat('#,##0.00',Recebido));
      if Recebido > Total then
        hPrintNormal('Troco  '+ FormatFloat('#,##0.00',(Recebido-(Total-desconto))));

      if client.aName <> '' then
      begin
        hPrintNormal(Traco(47));
        if client.aType = 'C' then
        begin
          hPrintNormal('Codigo...:' + client.aCod);
          hPrintNormal('Cliente..:' + client.aName);
        end
        else
        begin
          hPrintNormal('Matricula:' + client.aCod);
          hPrintNormal('Funcionario:' + client.aName);
        end;
        if client.aCPF <> '' then
          hPrintNormal('CPF......:' + client.aCPF);
        if client.aRG <> '' then
          hPrintNormal('RG.......:' + client.aRG);
        hPrintNormal('Endereco.:' + client.aAddr);
        hPrintNormal('Bairro...:' + client.aProv);
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
      if Length(OBS) > 0 then
      begin
        hPrintNormal(Traco(47));
        hPrintNormal(' Observações');
        hPrintNormal(OBS);
        hPrintNormal(Traco(47));
      end;
      AvancaLinhas(2);
      hPrintNormal(alinhaCentro(length('____________________________'))+ '____________________________');
      hPrintNormal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
    end;
    hVendaCliente:begin
      hPrintNormal('Valor da Venda  '+ FormatFloat('#,##0.00',Total));
      if Desconto > 0 then
      begin
        hPrintNormal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
        hPrintNormal('Valor Total     '+ FormatFloat('#,##0.00',Total - desconto ));
      end;
      hPrintNormal(Traco(47));
      hPrintNormal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
      hPrintNormal('N   Vencimento       Valor');
      if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
      begin
        AssignFile(Arq, ExtractFilePath(Application.ExeName)+'hparcelas.txt');
        try
          Reset(Arq);
        except
        end;
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') do
          DeleteFile('hparcelas.txt');
      end;
      AvancaLinhas(1);
      hPrintNormal(Traco(47));
      if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
      begin
        AssignFile(Arq, ExtractFilePath(Application.ExeName)+'hFormas.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          hPrintNormal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') do
          DeleteFile('hFormas.txt');
      end;

      if Recebido > Total then
        hPrintNormal('Troco  '+ FormatFloat('#,##0.00',(Recebido-Total)));

{aqui havia uma reimpressao de cliente sendo que o mesmo´já  é impresso no imptipo}
    end;
    hCarne:begin
//            hPrintNormal('Valor da Venda'+ FormatFloat('#,##0.00',SubTotal));
    end;
    hComanda:begin
      hPrintNormal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
      if Desconto > 0 then
      begin
        hPrintNormal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
        hPrintNormal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
      end;
    end;
  end;
  while FileExists('temp.txt') do
    DeleteFile('temp.txt');
  while FileExists('Temp.ini') do
    DeleteFile('Temp.ini');
  aSubTotal := 0;
  ZeroMemory(@client,SizeOf(client)); // limpa record
  hPrintFechar;
end;

procedure AbreGaveta(impressora : THImpressora; modelo : THModeloIMP; porta : THPortas; IP : String); overload ;
var
  Arq : TextFile;
  aLinha : String;
  aComando : String;
begin
  aComando := #27+#118+#140;
  case impressora of
    hBematech:begin
      AtivaImpressora(impressora,modelo,porta, ip );
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

procedure AbreGaveta(impressora, modelo, porta  : integer; ip : String);overload;
var
  Arq : TextFile;
  aLinha : String;
  aComando : String;
begin
  aComando := #27+#118+#140;
  case setImpressora(impressora) of
    hBematech:begin
      AtivaImpressora(impressora,modelo,porta, ip);
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

procedure AtivaImpressora(impressora : THImpressora; modelo: THModeloIMP; porta : THPortas; ip : String); overload ;
var
  teste : String;
begin
  device.aImp := impressora;
  device.aMod := modelo;
  device.aPrt := porta;
  device.aIP  := ip;

  teste :=  GetDefaultPrinter;
  
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
      ComandoTX(#27#51#18, Length(#27#51#18));
    end;
    hElgin: ;
    hDaruma: ;
    hEpson: ;
    hMatricial: ;
    hImpPadrao, hDiebold:begin
      aSubTotal := 0;

      prn := TAdvancedPrinter.Create;
      prn.OpenDoc('Impressão Documentos');
      prn_Comando(#27+#51+#18);
    end;
  end;
end;

procedure AtivaImpressora(impressora : integer; modelo: integer; porta : integer; ip : String);overload ;
var
  teste : String;
begin
  device.aImp := setImpressora(impressora);
  device.aMod := setModelo(modelo);
  device.aPrt := setPorta(porta);
  device.aIP  := ip;

  

  teste :=  GetDefaultPrinter;
  
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
      ComandoTX(#27#51#18, Length(#27#51#18));
    end;
    hElgin: ;
    hDaruma: ;
    hEpson: ;
    hMatricial: ;
    hImpPadrao, hDiebold:begin
      aSubTotal := 0;
      prn := TAdvancedPrinter.Create;
      prn.OpenDoc('Impressão Documentos');
      prn_Comando(#27+#51+#18);
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
        AtivaImpressora(device.aImp,device.aMod, device.aPrt, device.aIP);
        AcionaGuilhotina(0);
        FechaPorta;
      end;
      hImpPadrao,hDiebold:begin
        AtivaImpressora(device.aImp,device.aMod, device.aPrt, device.aIP);
        prn_comando(#27+#109);
      end;
    end;
  end;
end;

procedure ImpSangria(caixa : integer; supervisor, operador, descricao : String; valor : Double);
begin
  ImpCabecalho;
  hPrintNormal(alinhaCentro(Length('SANGRIA '))+'SANGRIA ');
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('PDV :' + IntToStr(caixa));
  hPrintNormal('Supervisor.: ' + supervisor);
  hPrintNormal('Operador...: ' + operador);
  hPrintNormal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
  hPrintNormal(Traco(47));
  hPrintNormal('Valor da Retirada....:  ' + FormatFloat('#,##0.00',valor));
  if Length(trim(descricao)) > 0 then
    hPrintNormal('Descricao da Retirada:  ' + descricao);
  hPrintNormal(Traco(47));
  AvancaLinhas(2);
  hPrintNormal(Alinhacentro(LengTh('__________________________'))+'__________________________');
  hPrintNormal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
  hPrintFechar;
end;

procedure ImpSuprimento(caixa : integer; supervisor, operador, descricao : String; valor : Double);
begin
  ImpCabecalho;
  hPrintNormal(alinhaCentro(Length('SUPRIMENTO '))+'SUPRIMENTO ');
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('PDV :' + IntToStr(caixa));
  hPrintNormal('Supervisor.: ' + supervisor);
  hPrintNormal('Operador...: ' + operador);
  hPrintNormal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
  hPrintNormal(Traco(47));
  hPrintNormal('Valor do Suprimento....:  ' + FormatFloat('#,##0.00',valor));
  if Length(trim(descricao)) > 0 then
    hPrintNormal('Descricao do Suprimento:  ' + descricao);
  hPrintNormal(Traco(47));
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
  hPrintNormal('PDV..........:' + IntToStr(caixa));
  hPrintNormal('Nr. Cancelado :' + IntToStr(cupom));
  hPrintNormal(Traco(47));
  if Desconto > 0 then
  begin
    hPrintNormal('Sub Total....:     ' + FormatFloat('#,##0.00',subtotal));
    hPrintNormal('Desconto.....:     ' + FormatFloat('#,##0.00',desconto));
    hPrintNormal('Valor Total..:     ' + FormatFloat('#,##0.00',total));
  end
  else
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
  hPrintNormal('PDV : ' + IntToStr(caixa));
  hPrintNormal('Supervisor.: ' + supervisor);
  hPrintNormal('Operador...: ' + operador);
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
  Arq : TextFile;
  aTexto : String;
begin
  ImpCabecalho;
  hPrintNormal(alinhaCentro(Length('FECHAMENTO DO PDV'))+'FECHAMENTO DO PDV');
  hPrintNormal(TracoDuplo(47));
  hPrintNormal('PDV : ' + IntToStr(caixa)+ '  Controle : ' + IntToStr(controle));
  hPrintNormal('Superv. Abertura  : ' + supervisorab);
  hPrintNormal('Data/Hora Abertura : '+ DateToStr(aData) +' as '+TimeToStr(aHora));
  hPrintNormal('Superv. Fechamento: ' + supervisorf);
  hPrintNormal('Data/Hora Fechamento : '+ DateToStr(Date) +' as '+TimeToStr(Time));
  hPrintNormal('Operador : ' + operador);
  hPrintNormal(Traco(47));
  hPrintNormal(alinhaCentro(Length('Dados do PDV'))+ 'Dados do PDV');
  hPrintNormal(Traco(47));
  hPrintNormal('+ Valor Inicial do PDV....:' + aLinhaDireita(FormatFloat('#,##0.00',valor),20));
  hPrintNormal('+ Dinheiro................:'+ aLinhaDireita(FormatFloat('#,##0.00',aDinheiro),20));
  hPrintNormal('+ Cheque..................:'+ aLinhaDireita(FormatFloat('#,##0.00',aCheque),20));
  hPrintNormal('+ Cartao..................:'+ aLinhaDireita(FormatFloat('#,##0.00',aCartao),20));
  hPrintNormal('+ Suprimento..............:'+ aLinhaDireita(FormatFloat('#,##0.00',aSuprimento),20));
  hPrintNormal('- Sangria.................:'+ aLinhaDireita(FormatFloat('#,##0.00',aSangria),20));
  if FileExists(ExtractFilePath(Application.ExeName)+ 'hdetsangria.txt') then
  begin
    AssignFile(Arq, ExtractFilePath(Application.ExeName)+ 'hdetsangria.txt');
    Reset(arq);
    while not Eof(Arq) do
    begin
      Readln(Arq, aTexto);
      hPrintNormal(aTexto);
    end;
    CloseFile(Arq);
    DeleteFile('hdetsangria.txt');
    hPrintNormal(TracoDuplo(47));
  end;
 

  aTotalCaixa := (valor + aDinheiro + aCartao + aCheque + aSuprimento) - aSangria;

  hPrintNormal('= Valor Final em Caixa....:'+ aLinhaDireita(FormatFloat('#,##0.00',aTotalCaixa),20));

  if valorinformado <> 0  then
  begin
    hPrintNormal('Valor Informado...........:'+ aLinhaDireita(FormatFloat('#,##0.00',valorinformado),20));

    aDiferenca := valorinformado - aTotalCaixa;

    hPrintNormal('Valor Diferenca...........:'+ aLinhaDireita(FormatFloat('#,##0.00',aDiferenca),20));
  end;

  hPrintNormal(Traco(47));
  hPrintNormal(alinhaCentro(Length('Informativo de Vendas'))+ 'Informativo de Vendas');
  hPrintNormal(Traco(47));

  hPrintNormal('+ Vendas em Dinheiro......:'+ aLinhaDireita(FormatFloat('#,##0.00',aTDinheiro),20));
  hPrintNormal('+ Vendas em Cheque........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCheque),20));
  hPrintNormal('+ Vendas em Cartao........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCartao),20));
  hPrintNormal('+ Vendas para Cliente/Func:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCliente),20));  //<<

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
  Writeln(Arq,'    ' + vecto +'       '+FormatFloat('#,##0.00',valor));
  CloseFile(Arq);
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
      AtivaImpressora(device.aImp,device.aMod,device.aPrt,device.aIP);
      for I := 0 to linhas - 1 do
        ComandoTX(#13#10, Length(#13#10));
    end;
    hImpPadrao, hDiebold:begin
      for I := 0 to linhas - 1 do
        Prn_Comando(#10);
    end;
  end;
end;

procedure TesteImpressora(impressora, modelo, porta, avanco :Integer; ip : String);
begin
  AtivaImpressora(impressora,modelo,porta, ip);
  hPrintPequeno('Fonte Pequena');
  hPrintNormal('Fonte Normal');
  hPrintGrande('Fonte Grande');
  hPrintNormal('Fim Teste');
  AvancaLinhas(avanco);
  hPrintFechar();

end;

procedure DetalheSangria( Data, Hora, Operador, Descricao : String; Valor : Double );
var
  Arq : TextFile;
begin
  AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hdetsangria.txt');
  if not FileExists(ExtractFilePath(Application.ExeName)+ 'hdetsangria.txt') then
    Rewrite(Arq)
  else
    Append(Arq);
  WriteLn(Arq, Data + '  ' + Hora + '  ' + copy(operador, 0, 15)+ '  R$ ' + FormatFloat('#,##0.00',Valor) + ' ' + Descricao );
  CloseFile(Arq);
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
  AbreGaveta(device.aImp,device.aMod,device.aPrt, device.aIP);
end;
{$ENDREGION}


end.
