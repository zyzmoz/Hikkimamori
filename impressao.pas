unit impressao;
{
  Fun��o: Impress�o de Pr� Venda
  Autor:  Daniel Cunha
  Data:   10/06/2014
  Funcionamento:
    Bematech : Utiliza a DLL MP2032.dll
    Impressora Padr�o : Utiliza CharPrinter com comandos ESC/POS (Impressora padr�o do Windows)
    
}
interface
uses declaracoes,  ibquery, DB, Forms, sysutils, controls, windows, CharPrinter;

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
  THTipoImp = (hVenda, hRVenda, hConsignacao, hRecibo, hRRecibo, hCarne, hVendaCliente, hRVendaCliente,
            hPromissoria, hRpromissoria);

  THDevice = record
    aImp : THImpressora;
    aMod : THModeloIMP;
    aPrt : THPortas;
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
  //aux cupom
  aSubTotal :Double;
  //dados caixa
  aDinheiro, aCartao, aCheque, aSuprimento, aSangria : Double;
  //informativo de Venda
  aTDinheiro, aTCheque, aTCartao, aTCliente, aTDesconto, aTRecebido : Double;
  //Totais
  aCancelados, aVlrCancelados, aItmCancelados, aVlrItmCancelados : Double;
  //configura��es
  aImpressora : THImpressora;
  aModelo     : THModeloIMP;
  aPorta      : THPortas;

{$REGION 'Comandos Base'}
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
procedure AvancaLinhas(linhas : integer);
//procedure SetLinguagem();
//procedure huAbreGaveta;
//procedure CortaPapel;

{$endregion}

{$REGION 'CONFIGURA�AO'}

function  Bematech_lestatus():String;
function  RetornaStrPorta(porta : THPortas): String;
function  setImpressora(imp : integer) : THImpressora;
function  setModelo(modelo : integer) : THModeloIMP;
function  setPorta(porta : integer) : THPortas;
function  RetornaModelo(modelo : THModeloIMP):integer;
procedure TesteImpressora(impressora, modelo, porta, avanco :Integer);

{$ENDREGION}

Procedure ImpCabecalho(modelo : THModeloIMP; impressora : THImpressora; porta : THPortas);
Procedure AdicionaItem (item, barras: String; qtde, unitario : Double);
Procedure RemoveItem (item, barras: String; qtde, unitario : Double);
Procedure ImprimeTipo (impressora : THImpressora; tipo : THTipoImp ;numeroimp, pdv : integer; data, hora, vendedor : String);
Procedure InformaCliente(Ficha, Cliente, Endereco, Bairro : String);overload;
Procedure InformaCliente(Ficha : integer ; Cliente, CPF, RG, Endereco, Bairro : String); overload ;
Procedure FechaImpressao (tipo : THTipoImp ; Desconto, Acrescimo, Total, Recebido : Double);
procedure AtivaImpressora(impressora : THImpressora; modelo: THModeloIMP; porta : THPortas);overload;
procedure AtivaImpressora(impressora : integer; modelo: integer; porta : integer);overload ;
procedure IniciaImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String);
procedure IniciaRImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String; data: Tdate; hora : TTime);
Procedure AdicionaForma (forma : String; valor : Double);
procedure ImprimeBarras(aCodigo : String);
procedure ImprimeQR(aCodigo : String);
procedure ImpSangria(caixa : integer; supervisor, operador : String; valor : Double);
procedure ImpSuprimento(caixa : integer; supervisor, operador : String; valor : Double);
procedure CancelaCupom(caixa, cupom : integer; operador : String ; datahoravenda: TDateTime ;subtotal, desconto, total : Double);
procedure ImpAbertura(caixa : integer; supervisor, operador : String; valor : Double);
{$REGION 'FECHAMENTO'}
procedure ImpFechamento(caixa, controle : integer; supervisorab,supervisorf, operador : String; aData: TDate; aHora : TTime; valor, valorinformado : Double);
procedure informaDadosCaixa(Dinheiro, Cheque, Cartao, Suprimento, Sangria : Double);
procedure informaDadosVenda(TDinheiro, TCheque, TCartao, TCliente, TDesconto, TRecebido : Double);
procedure informaTotais(Cancelados, VlrCancelados, ItmCancelados, VlrItmCancelados : Double);
procedure zeraVariaveis();
{$ENDREGION}

Procedure AdicionaParcela (parcela : integer; vecto : String ; valor : Double);overload;
Procedure AdicionaParcela ( vecto : String ; valor : Double);overload;
procedure DadosTemporarios(dados, campo, valor :String);

implementation

uses funcoes;


function Bematech_Pequeno ( aTexto : string):integer;
begin
  if trim(atexto) <> '' then
  begin
    aTexto := aTexto + #13 + #10;
    Bematech_Pequeno := FormataTX(pchar(aTexto), 1, 0, 0, 0, 0);
  end;
end;

function Bematech_Normal ( aTexto : string):integer;
begin
  if trim( atexto ) <> '' then
  begin
    aTexto := aTexto + #13 + #10;
    Bematech_normal := FormataTX(pchar(aTexto), 2, 0, 0, 0, 0);
  end;
end;


function Bematech_Grande ( aTexto : string): integer;
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
// AN�LISE DO RETORNO DE STATUS DAS IMPRESSORAS FISCAIS
  case aPorta of
    hCOM1: s_stporta:='serial';
    hCOM2: s_stporta:='serial';
    hCOM3: s_stporta:='serial';
    hCOM4: s_stporta:='serial';
    hLPT1: s_stporta:='lpt';
    hLPT2: s_stporta:='lpt';
    hEthernet: s_stporta:='rede';
  end;
  AtivaImpressora(aImpressora , aModelo ,aPorta);
  aStatus := Le_Status();

//******************IMPRESSORAS MP 20 CI E MI - CONEX�O SERIAL******************

  if (aModelo=hMP20MI) and (s_stporta='serial') then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE';
    if aStatus= 32 then Bematech_lestatus :='32 - SEM PAPEL';
  End;
//******************************************************************************

//******************IMPRESSORAS MP 20 CI E MI - CONEX�O PARALELA****************

  if (aModelo=hMP20MI) and (s_stporta='lpt') then
  Begin
    if aStatus= 144 then Bematech_lestatus :='144 - ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE OU IMP. SEM PAPEL';
  End;
//******************************************************************************

//******IMPRESSORAS MP 20 TH, 2000 CI 2000 TH 2100 TH - CONEX�O SERIAL**********

  if (aModelo=hMP20TH) and (s_stporta='serial') then
  Begin
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE OU POUCO PAPEL';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
  End;
//******************************************************************************

//******IMPRESSORAS MP 20 TH, 2000 CI 2000 TH 2100 TH - CONEX�O PARALELA********

  if (aModelo=hMP20TH) and (s_stporta='lpt') then
  Begin
    if aStatus= 79 then Bematech_lestatus :='79 - OFF LINE';
    if aStatus= 144 then Bematech_lestatus :='144 - ON LINE OU POUCO PAPEL';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 0 then Bematech_lestatus :='0 - ERRO DE COMUNICA��O';
  End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEX�O PARALELA*********************

  if (aModelo=hMP4000TH) and (s_stporta='lpt') then
  Begin
    if aStatus= 40 then Bematech_lestatus :='40 - IMP. OFF LINE/SEM COMUNICA��O';
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 128 then Bematech_lestatus :='128 - IMP. SEM PAPEL';
    if aStatus= 0 then Bematech_lestatus :='0 - POUCO PAPEL';
  End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEX�O ETHERNET*********************

  if (aModelo=hMP4000TH) and (s_stporta='rede') then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICA��O';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE - POUCO PAPEL';
  End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEX�O SERIAL***********************

  if (aModelo=hMP4000TH) and (s_stporta='serial') then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICA��O';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 5 then Bematech_lestatus :='5 - ON LINE - POUCO PAPEL';
  End;
//******************************************************************************

//*********************IMPRESSORAS MP 4000 TH CONEX�O USB***********************

  if (aModelo=hMP4000TH) and (s_stporta='serial') then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 68 then Bematech_lestatus :='68 - IMP. OFF LINE/SEM COMUNICA��O';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE - POUCO PAPEL';
  End;
//******************************************************************************

//*******************IMPRESSORAS MP 4200 TH CONEX�O TODAS***********************

  if (aModelo=hMP4200TH) then
  Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICA��O';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 5 then Bematech_lestatus :='5 - ON LINE - POUCO PAPEL';
    if aStatus= 9 then Bematech_lestatus :='9 - TAMPA ABERTA';
  End;
//******************************************************************************
  FechaPorta;

end;

Procedure ImpCabecalho (modelo : THModeloIMP; impressora : THImpressora; porta : THPortas);
var
  Arq : TextFile;
begin
  case impressora of
    hBematech:begin
      ConfiguraModeloImpressora(RetornaModelo(modelo));
      if (IniciaPorta(RetornaStrPorta(porta)) <> 1)  then
      begin
        Application.MessageBox('Sem conex�o com a impressora','Aviso!', MB_OK + MB_ICONWARNING);
        Exit;
      end;

//      if LeIni('IMG','IMAGEM') <> '' then
//      begin
//        ImprimeBmpEspecial( pchar(LeIni('IMG','IMAGEM')),
//                                  strtoint(LeIni('IMPRESSORA','IMG_X')),
//                                  strtoint(LeIni('IMPRESSORA','IMG_Y')),
//                                  strtoint(LeIni('IMPRESSORA','IMG_A')));
//      end;
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN000'))) + LeIni('EMPRESA','LIN000'));
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN001'))) + LeIni('EMPRESA', 'LIN001'));
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN002'))) + LeIni('EMPRESA','LIN002'));
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN003'))) + LeIni('EMPRESA','LIN003'));
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN004'))) + LeIni('EMPRESA','LIN004'));
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN004'))) + LeIni('EMPRESA','LIN005'));
      Bematech_Normal( TracoDuplo(47));
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao, hDiebold:begin
      Prn_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN000'))) + LeIni('EMPRESA','LIN000'));
      Prn_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN001'))) + LeIni('EMPRESA', 'LIN001'));
      Prn_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN002'))) + LeIni('EMPRESA','LIN002'));
      Prn_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN003'))) + LeIni('EMPRESA','LIN003'));
      Prn_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN004'))) + LeIni('EMPRESA','LIN004'));
      Prn_Normal(alinhaCentro(Length(LeIni('EMPRESA','LIN005'))) + LeIni('EMPRESA','LIN005'));

      Prn_Normal(TracoDuplo(47));
    end;
  end;


end;

Procedure AdicionaItem (item, barras: String; qtde, unitario : Double);
var
  Arq : TextFile;
  aLinha : String;
begin
  case aImpressora of
    hBematech:begin
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
          Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('item.txt') do
          DeleteFile('item.txt');
      end;
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao, hDiebold:begin
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
        prn.OpenDoc('Itens');
        while not Eof(Arq) do
        begin
          Readln(Arq, aLinha);
          Prn_Normal( copy ( aLinha, 1, Length(aLinha)));
        end;
        prn.CloseDoc;
        CloseFile(Arq);
        while FileExists('item.txt') do
          DeleteFile('item.txt');
      end;
    end;
  end;
end;

Procedure RemoveItem (item, barras: String; qtde, unitario : Double);
var
  Arq : TextFile;
  aLinha : String;
begin
  case aImpressora of
    hBematech:begin
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
          Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('item.txt') do
          DeleteFile('item.txt');
      end;
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    //impressorapadrao
    hImpPadrao,hDiebold:begin
      AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'item.txt');
      Rewrite(Arq);
      Write(Arq,  #18 + subs( alltrim( item ), 1, 50 ));
      Write(Arq,  #$12 + '    ' + subs( barras, 1, 13 ) );
      Write(Arq,  #$12 + '   -' + FormatFloat('#,##0.00',qtde));
      Write(Arq,  #$12 + '   -' + FormatFloat('#,##0.00',unitario));
      Write(Arq,#$12 + '    ' + FormatFloat('#,##0.00',RoundSemArredondar(unitario * qtde)*-1));
      aSubTotal := aSubTotal - (unitario * qtde);
      CloseFile(Arq);
      if FileExists('item.txt') then
      begin
        AssignFile(Arq, 'item.txt');
        Reset(Arq);
        while not Eof(Arq) do
        begin

          Readln(Arq, aLinha);
          Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
        end;
        CloseFile(Arq);
        while FileExists('item.txt') do
          DeleteFile('item.txt');
      end;
    end;
  end;


end;

function RetornaStrPorta(porta : THPortas): String;
begin
  case porta of
    hCOM1: RetornaStrPorta := 'COM1' ;
    hCOM2: RetornaStrPorta := 'COM2' ;
    hCOM3: RetornaStrPorta := 'COM3' ;
    hCOM4: RetornaStrPorta := 'COM4' ;
    hLPT1: RetornaStrPorta := 'LPT1' ;
    hLPT2: RetornaStrPorta := 'LPT2' ;
    hEthernet: ;
    hUSB:  RetornaStrPorta := 'USB';
  end;
end;

Procedure ImprimeTipo (impressora : THImpressora; tipo : THTipoImp ;numeroimp, pdv : integer; data, hora, vendedor : String);
var
  Arq : TextFile;
  aLinha : String;
begin
  case impressora of
    hBematech:begin
      case tipo of
        hVenda:begin
          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
          Bematech_Normal(Traco(47));
          Bematech_normal('Descricao');
          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
          Bematech_Normal(Traco(47));
        end;
        hRVenda:begin
          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
          Bematech_Normal(Traco(47));
          Bematech_Normal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
          Bematech_Normal(Traco(47));
          Bematech_normal('Descricao');
          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
          Bematech_Normal(Traco(47));

        end;
        hVendaCliente:begin
          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
          Bematech_Normal(Traco(47));
          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
          begin
            AssignFile(Arq, 'hCliente.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hCliente.txt') do
              DeleteFile('hCliente.txt');
          end;
          Bematech_Normal(Traco(47));
          Bematech_normal('Descricao');
          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
          Bematech_Normal(Traco(47));
        end;
        hRVendaCliente:begin
          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
          Bematech_Normal(Traco(47));
          Bematech_Normal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
          Bematech_Normal(Traco(47));
          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
          begin
            AssignFile(Arq, 'hCliente.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hCliente.txt') do
              DeleteFile('hCliente.txt');
          end;
          Bematech_Normal(Traco(47));
          Bematech_normal('Descricao');
          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
          Bematech_Normal(Traco(47));
        end;
        hPromissoria:begin
          Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
          Bematech_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
          Bematech_Normal(Traco(47));
          Bematech_Normal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
          Bematech_Normal('N   Vencimento       Valor');
          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
          begin
            AssignFile(Arq, 'hparcelas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hparcelas.txt') do
              DeleteFile('hparcelas.txt');
          end;

          Bematech_Normal(Traco(47));
          Bematech_Pequeno('No pagamento em atraso, sera cobrado multa de 2% e juros de ');
          Bematech_Pequeno(' 0,33% ao dia');
          Bematech_Normal(Traco(47));
          Bematech_Normal(alinhaCentro(Length('*NOTA PROMISSORIA*'))+ '*NOTA PROMISSORIA*');
          Bematech_Normal(Traco(47));
          Bematech_Normal('Vencimento em '+ LeIniTemp('PARCELAS','VECTO'));
          Bematech_Normal('Valor em R$ '+ LeIniTemp('PARCELAS','TOTAL'));
          ComandoTX(#13#10,Length(#13#10));
          Bematech_Pequeno( 'A ' +LeIniTemp('PARCELAS','VECTOEXT'));
          Bematech_Pequeno('Pagarei esta NOTA PROMISSORIA a : ' + LeIniTemp('EMPRESA','RAZAO'));
          Bematech_Pequeno('CNPJ: ' +LeIniTemp('EMPRESA','CNPJ') + ' ou a sua ordem,');
          Bematech_Pequeno('em moeda corrente deste pais a quantia de');
          Bematech_Pequeno(  LeIniTemp('PARCELAS', 'TOTALEXT'));
          Bematech_Pequeno('Pagavel em ' + LeIniTemp('EMPRESA','CIDADEUF'));
          ComandoTX(#13#10,Length(#13#10));
          Bematech_Pequeno(LeIniTemp('PARCELAS','DATAEXT'));
          ComandoTX(#13#10,Length(#13#10));
          Bematech_Pequeno('Cod.: ' + LeIniTemp('CLIENTE','CODIGO'));
          Bematech_Pequeno('Nome.: ' + LeIniTemp('CLIENTE','NOME  '));
          Bematech_Pequeno('CPF.: ' + LeIniTemp('CLIENTE','CPF'));
          Bematech_Pequeno('RG.: ' + LeIniTemp('CLIENTE','RG'));
          Bematech_Pequeno('Endereco.: ' + LeIniTemp('CLIENTE','END'));
          Bematech_Pequeno('Bairro.: ' + LeIniTemp('CLIENTE','BAIRRO'));
          Bematech_Pequeno('Cidade.: ' + LeIniTemp('CLIENTE','CCIDADEUF'));
          while FileExists('Temp.ini') do
              DeleteFile('Temp.ini');

        end;
        hConsignacao:begin
          Bematech_Normal(alinhaCentro(length('CONSIGNACAO')) + 'CONSIGNACAO');
          Bematech_Normal(Traco(47));
          Bematech_Normal('Consignacao.:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
          Bematech_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
          Bematech_Normal(Traco(47));
          Bematech_normal('Descricao');
          Bematech_normal('   Cod. Barras        Qtd     Unit.    Total');
          Bematech_Normal(Traco(47));
        end;
        hRecibo:begin
          Bematech_Normal(alinhaCentro(length('RECIBO')) + 'RECIBO');
          Bematech_Normal(Traco(47));
          Bematech_Normal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
          Bematech_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
        end;
        hRRecibo:begin
          Bematech_Normal(alinhaCentro(length('REIMPRESSAO RECIBO')) + 'REIMPRESSAO RECIBO');
          Bematech_Normal(Traco(47));
          Bematech_Normal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
          Bematech_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
          Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
        end;
        hCarne: Bematech_Normal('Carne...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      end;
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao, hDiebold:begin/////////
      case tipo of
        hVenda:begin
          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
          Prn_Normal(Traco(47));
          Prn_Normal('Descricao');
          Prn_Normal('   Cod. Barras        Qtd     Unit.    Total');
          Prn_Normal(Traco(47));
        end;
        hRVenda:begin
          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
          Prn_Normal(Traco(47));
          Prn_Normal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
          Prn_Normal(Traco(47));
          Prn_Normal('Descricao');
          Prn_Normal('   Cod. Barras        Qtd     Unit.    Total');
          Prn_Normal(Traco(47));

        end;
        hVendaCliente:begin
          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
          Prn_Normal(Traco(47));
          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
          begin
            AssignFile(Arq, 'hCliente.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hCliente.txt') do
              DeleteFile('hCliente.txt');
          end;
          Prn_Normal(Traco(47));
          Prn_Normal('Descricao');
          Prn_Normal('   Cod. Barras        Qtd     Unit.    Total');
          Prn_Normal(Traco(47));
        end;
        hRVendaCliente:begin
          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));

          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
          Prn_Normal(Traco(47));
          Prn_Normal(alinhaCentro(Length('***REIMPRESSAO***'))+'***REIMPRESSAO***');
          Prn_Normal(Traco(47));
          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
          begin
            AssignFile(Arq, 'hCliente.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hCliente.txt') do
              DeleteFile('hCliente.txt');
          end;
          Prn_Normal(Traco(47));
          Prn_Normal('Descricao');
          Prn_Normal('   Cod. Barras        Qtd     Unit.    Total');
          Prn_Normal(Traco(47));
        end;
        hPromissoria:begin
          Prn_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
          Prn_Normal('Data.....: ' +  Trim(data) + '   Hora.: ' + hora );
          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
          Prn_Normal(Traco(47));
          Prn_Normal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
          Prn_Normal('N   Vencimento       Valor');
          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
          begin
            AssignFile(Arq, 'hparcelas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hparcelas.txt') do
              DeleteFile('hparcelas.txt');
          end;

          Prn_Normal(Traco(47));
          Prn_Pequeno('No pagamento em atraso, sera cobrado multa de 2% e juros de ');
          Prn_Pequeno(' 0,33% ao dia');
          Prn_Normal(Traco(47));
          Prn_Normal(alinhaCentro(Length('*NOTA PROMISSORIA*'))+ '*NOTA PROMISSORIA*');
          Prn_Normal(Traco(47));
          Prn_Normal('Vencimento em '+ LeIniTemp('PARCELAS','VECTO'));
          Prn_Normal('Valor em R$ '+ LeIniTemp('PARCELAS','TOTAL'));
          Prn_Normal('');
          Prn_Pequeno( 'A ' +LeIniTemp('PARCELAS','VECTOEXT'));
          Prn_Pequeno('Pagarei esta NOTA PROMISSORIA a : ' + LeIniTemp('EMPRESA','RAZAO'));
          Prn_Pequeno('CNPJ: ' +LeIniTemp('EMPRESA','CNPJ') + ' ou a sua ordem,');
          Prn_Pequeno('em moeda corrente deste pais a quantia de');
          Prn_Pequeno(  LeIniTemp('PARCELAS', 'TOTALEXT'));
          Prn_Pequeno('Pagavel em ' + LeIniTemp('EMPRESA','CIDADEUF'));
          Prn_Normal('');
          Prn_Pequeno(LeIniTemp('PARCELAS','DATAEXT'));
          Prn_Normal('');
          Prn_Pequeno('Cod.: ' + LeIniTemp('CLIENTE','CODIGO'));
          Prn_Pequeno('Nome.: ' + LeIniTemp('CLIENTE','NOME  '));
          Prn_Pequeno('CPF.: ' + LeIniTemp('CLIENTE','CPF'));
          Prn_Pequeno('RG.: ' + LeIniTemp('CLIENTE','RG'));
          Prn_Pequeno('Endereco.: ' + LeIniTemp('CLIENTE','END'));
          Prn_Pequeno('Bairro.: ' + LeIniTemp('CLIENTE','BAIRRO'));
          Prn_Pequeno('Cidade.: ' + LeIniTemp('CLIENTE','CCIDADEUF'));
          while FileExists('Temp.ini') do
              DeleteFile('Temp.ini');

        end;
        hConsignacao:begin
          Prn_Normal(alinhaCentro(length('CONSIGNACAO')) + 'CONSIGNACAO');
          Prn_Normal(TracoDuplo(47));
          Prn_Normal('Consignacao...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
        end;
        hRecibo:begin
          Prn_Normal(alinhaCentro(length('RECIBO')) + 'RECIBO');
          Prn_Normal(Traco(47));
          Prn_Normal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
          Prn_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
        end;
        hRRecibo:begin
          Prn_Normal(alinhaCentro(length('REIMPRESSAO RECIBO')) + 'REIMPRESSAO RECIBO');
          Prn_Normal(Traco(47));
          Prn_Normal('Recibo Nr  .:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
          Prn_Normal('Data.....   : ' +  Trim(data) + '        Hora.: ' + hora );
          Prn_Normal('Vendedor.: ' +  Trim(vendedor) );
        end;
//        hRecibo: Prn_Normal('Recibo...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
        hCarne: Prn_Normal('Carne...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      end;
      prn.CloseDoc;
    end;
  end;
end;

Procedure InformaCliente(Ficha, Cliente, Endereco, Bairro : String); overload ;
var
  Arq : TextFile;
begin
  case aImpressora of
    hBematech:begin
      AssignFile(Arq, 'hCliente.txt');
      Rewrite(Arq);
      Writeln(Arq,'Codigo...:' + Ficha   );
      WriteLn(Arq,'Cliente..:' + Cliente );
      WriteLn(Arq,'Endereco.:' + Endereco);
      WriteLn(Arq,'Bairro...:' + Bairro  );
      CloseFile(Arq);
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;
    hImpPadrao, hDiebold:begin
      AssignFile(Arq, 'hCliente.txt');
      Rewrite(Arq);
      Writeln(Arq,'Codigo...:' + Ficha   );
      WriteLn(Arq,'Cliente..:' + Cliente );
      WriteLn(Arq,'Endereco.:' + Endereco);
      WriteLn(Arq,'Bairro...:' + Bairro  );
      CloseFile(Arq);
    end;
  end;
end;

Procedure InformaCliente(Ficha : integer ; Cliente, CPF, RG, Endereco, Bairro : String); overload ;
var
  Arq : TextFile;
begin
  case aImpressora of
    hBematech:begin
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
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;

    hImpPadrao, hDiebold:begin
      AssignFile(Arq, 'hCliente.txt');
      Rewrite(Arq);
      Writeln(Arq,'Codigo...:' + IntToStr(Ficha  ) );
      WriteLn(Arq,'Cliente..:' + Cliente );
      WriteLn(Arq,'Endereco.:' + Endereco);
      WriteLn(Arq,'Bairro...:' + Bairro  );
      CloseFile(Arq);
    end;
  end;
end;

Procedure FechaImpressao (tipo : THTipoImp ; Desconto, Acrescimo, Total, Recebido : Double);
var
  Arq   : TextFile;
  aLinha : String;
begin
  case aImpressora of
    hBematech:begin
      Bematech_Normal(Traco(47));
      case tipo of
        hVenda:begin
          Bematech_Normal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
          Bematech_Normal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
          Bematech_Normal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
          Bematech_Normal(Traco(47));
          if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
          begin
            AssignFile(Arq, 'hFormas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hFormas.txt') do
              DeleteFile('hFormas.txt');
          end;

          Bematech_Normal('Valor Total Recebido  '+ FormatFloat('#,##0.00',Recebido));
          if Recebido > Total then
            Bematech_Normal('Troco  '+ FormatFloat('#,##0.00',(Recebido-(Total-desconto))));

          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
          begin
            Bematech_Normal(Traco(47));
            AssignFile(Arq, 'hCliente.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hCliente.txt') do
              DeleteFile('hCliente.txt');
          end;
        end;
        hConsignacao:begin
          Bematech_Normal('Total Consignado.:     '+ aLinhaDireita(FormatFloat('#,##0.00',Total),20)) ;
          Bematech_Normal(Traco(47));
          Bematech_Normal('Consignado em nome de ' + LeIniTemp('CLIENTE','NOME'));
          Bematech_Normal('CPF/CNPJ.: '+ LeIniTemp('CLIENTE','CNPJCPF')+ '  RG/IE: ' + LeIniTemp('CLIENTE', 'IERG'));
          if LeIniTemp('IMP','NUMERO') = '1' then
          begin
            ComandoTX(#13#10#13#10#13#10, length(#13#10#13#10#13#10));
            Bematech_Normal(alinhaCentro(length('____________________________'))+ '____________________________');
            Bematech_Normal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
          end;
        end;
        hRecibo:begin
          Bematech_Normal('Recebemos de:' + LeIniTemp('CLIENTE', 'NOME'));
          Bematech_Normal('O valor de ' + FormatFloat('#,##0.00',Total));
          Bematech_Normal(LeIniTemp('PARCELAS', 'TOTALEXT'));
          if Desconto > 0 then
            Bematech_Normal('C/ desconto de :' + FormatFloat('#,##0.00',Desconto));
          Bematech_Normal(Traco(47));
          Bematech_Normal('Referente a:');
          Bematech_Normal('Venda    Vencimento       Valor');
          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
          begin
            AssignFile(Arq, 'hparcelas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hparcelas.txt') do
              DeleteFile('hparcelas.txt');
          end;
          Bematech_Normal(Traco(47));
          Bematech_Normal('Forma de Pagamento: ' + LeIniTemp('PARCELAS','FORMA'));
          ComandoTX(#13#10#13#10, Length(#13#10#13#10));
          Bematech_Normal(alinhaCentro(length('____________________________'))+ '____________________________');
          Bematech_Normal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
        end;
        hVendaCliente:begin
          Bematech_Normal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
          Bematech_Normal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
          Bematech_Normal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
          Bematech_Normal(Traco(47));
          Bematech_Normal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
          Bematech_Normal('N   Vencimento       Valor');
          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
          begin
            AssignFile(Arq, 'hparcelas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hparcelas.txt') do
              DeleteFile('hparcelas.txt');
          end;
          ComandoTx(#13#10,Length(#13#10));
          if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
          begin
            AssignFile(Arq, 'hFormas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hFormas.txt') do
              DeleteFile('hFormas.txt');
          end;

          Bematech_Normal(Traco(47));

          if Recebido > Total then
            Bematech_Normal('Troco  '+ FormatFloat('#,##0.00',(Recebido-Total)));

          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
          begin
            Bematech_Normal(Traco(47));
            AssignFile(Arq, 'hCliente.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Bematech_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hCliente.txt') do
              DeleteFile('hCliente.txt');
          end;
        end;
        hCarne:begin
//            Bematech_Normal('Valor da Venda'+ FormatFloat('#,##0.00',SubTotal));
        end;
      end;
      while FileExists('temp.txt') do
        DeleteFile('temp.txt');
      while FileExists('Temp.ini') do
            DeleteFile('Temp.ini');
      aSubTotal := 0;
      FechaPorta;
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;

    hImpPadrao, hDiebold:begin
      prn.OpenDoc('Fim');
      Prn_Normal(Traco(47));
      case tipo of
        hVenda:begin
          Prn_Normal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
          Prn_Normal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
          Prn_Normal('Valor Total     '+ FormatFloat('#,##0.00',Total));
          Prn_Normal(Traco(47));
          if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
          begin
            AssignFile(Arq, 'hFormas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hFormas.txt') do
              DeleteFile('hFormas.txt');
          end;

          Prn_Normal('Valor Total Recebido  '+ FormatFloat('#,##0.00',Recebido));
          if Recebido > Total then
            Prn_Normal('Troco  '+ FormatFloat('#,##0.00',(Recebido-(Total-Desconto))));

          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
          begin
            Prn_Normal(Traco(47));
            AssignFile(Arq, 'hCliente.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hCliente.txt') do
              DeleteFile('hCliente.txt');
          end;
        end;
        hConsignacao:begin
          Prn_Normal('Total Consignado.:     '+ aLinhaDireita(FormatFloat('#,##0.00',Total),20)) ;
          Prn_Normal(Traco(47));
          Prn_Normal('Consignado em nome de ' + LeIniTemp('CLIENTE','NOME'));
          Prn_Normal('CPF/CNPJ.: '+ LeIniTemp('CLIENTE','CNPJCPF')+ '  RG/IE: ' + LeIniTemp('CLIENTE', 'IERG'));
          if LeIniTemp('IMP','NUMERO') = '1' then
          begin
            prn_normal('');
            prn_normal('');
            prn_normal('');
            Prn_Normal(alinhaCentro(length('____________________________'))+ '____________________________');
            Prn_Normal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
          end;
        end;
        hRecibo:begin
          Prn_Normal('Recebemos de:' + LeIniTemp('CLIENTE', 'NOME'));
          Prn_Normal('O valor de ' + FormatFloat('#,##0.00',Total));
          Prn_Normal(LeIniTemp('PARCELAS', 'TOTALEXT'));
          if Desconto > 0 then
            Prn_Normal('C/ desconto de :' + FormatFloat('#,##0.00',Desconto));
          Prn_Normal(Traco(47));
          Prn_Normal('Referente a:');
          Prn_Normal('Venda    Vencimento       Valor');
          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
          begin
            AssignFile(Arq, 'hparcelas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hparcelas.txt') do
              DeleteFile('hparcelas.txt');
          end;
          Prn_Normal(Traco(47));
          Prn_Normal('Forma de Pagamento: ' + LeIniTemp('PARCELAS','FORMA'));
          prn_normal('');
          prn_normal('');
          Prn_Normal(alinhaCentro(length('____________________________'))+ '____________________________');
          Prn_Normal(alinhaCentro(length('        Responsavel         '))+ '        Responsavel         ');
        end;
        hVendaCliente:begin
          Prn_Normal('Valor da Venda  '+ FormatFloat('#,##0.00',aSubTotal));
          Prn_Normal('Valor Desconto  '+ FormatFloat('#,##0.00',Desconto));
          Prn_Normal('Valor Total     '+ FormatFloat('#,##0.00',aSubTotal - desconto ));
          Prn_Normal(Traco(47));
          Prn_Normal(alinhaCentro(Length('***PRESTACOES***'))+ '***PRESTACOES***');
          Prn_Normal('N   Vencimento       Valor');
          if FileExists(ExtractFilePath(Application.ExeName)+'hparcelas.txt') then
          begin
            AssignFile(Arq, 'hparcelas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hparcelas.txt') do
              DeleteFile('hparcelas.txt');
          end;
          prn_normal('');
          if FileExists(ExtractFilePath(Application.ExeName)+'hFormas.txt') then
          begin
            AssignFile(Arq, 'hFormas.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hFormas.txt') do
              DeleteFile('hFormas.txt');
          end;

          Prn_Normal(Traco(47));

          if Recebido > Total then
            Prn_Normal('Troco  '+ FormatFloat('#,##0.00',(Recebido-Total)));

          if FileExists(ExtractFilePath(Application.ExeName)+'hCliente.txt') then
          begin
            Prn_Normal(Traco(47));
            AssignFile(Arq, 'hCliente.txt');
            Reset(Arq);
            while not Eof(Arq) do
            begin
              Readln(Arq, aLinha);
              Prn_Normal ( copy ( aLinha, 1, Length(aLinha)));
            end;
            CloseFile(Arq);
            while FileExists('hCliente.txt') do
              DeleteFile('hCliente.txt');
          end;
        end;
        hCarne:begin
//            Prn_Normal('Valor da Venda'+ FormatFloat('#,##0.00',SubTotal));
        end;
      end;
      while FileExists('temp.txt') do
        DeleteFile('temp.txt');
      while FileExists('Temp.ini') do
            DeleteFile('Temp.ini');
      aSubTotal := 0;
      prn.CloseDoc;
    end;
  end;

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
  case impressora of
    hBematech:begin
      aSubTotal := 0;
      aImpressora := impressora;
      aModelo := modelo;
      aPorta := porta;
      ConfiguraModeloImpressora(RetornaModelo(modelo));
      if (IniciaPorta(RetornaStrPorta(porta)) <> 1)  then
      begin
        Application.MessageBox('Sem conex�o com a impressora','Aviso!', MB_OK + MB_ICONWARNING);
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
      aImpressora := impressora;
      aModelo := modelo;
      aPorta := porta;
      prn := TAdvancedPrinter.Create;
      prn.OpenDoc('Impress�o Documentos');
    end;
  end;
end;

procedure AtivaImpressora(impressora : integer; modelo: integer; porta : integer);overload ;
begin
  case setImpressora(impressora) of
    hBematech:begin
      aSubTotal := 0;
      aImpressora := setImpressora(impressora);
      aModelo := setModelo(modelo);
      aPorta := setPorta(porta);
      ConfiguraModeloImpressora(RetornaModelo(aModelo));
      if (IniciaPorta(RetornaStrPorta(aPorta)) <> 1)  then
      begin
        Application.MessageBox('Sem conex�o com a impressora','Aviso!', MB_OK + MB_ICONWARNING);
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
      aImpressora := setImpressora(impressora);
      aModelo := setModelo(modelo);
      aPorta := setPorta(porta);
      prn := TAdvancedPrinter.Create;
      prn.OpenDoc('Impress�o Documentos');
    end;
  end;
end;

procedure IniciaImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String);
begin
  ImpCabecalho(aModelo,aImpressora,aPorta);
  ImprimeTipo(aImpressora, tipo,numeroimp,pdv,DateToStr(now),TimeToStr(now),vendedor);
end;

procedure IniciaRImp(tipo : THTipoImp; numeroimp, pdv :integer; vendedor : String; data: Tdate; hora : TTime);
begin
  ImpCabecalho(aModelo,aImpressora,aPorta);
  ImprimeTipo(aImpressora, tipo,numeroimp,pdv,DateToStr(Data),TimeToStr(Hora),vendedor);
end;                                                                                                           

Procedure AdicionaForma (forma : String; valor : Double);
var
  Arq : TextFile;
  aLinha : String;
begin
  case aImpressora of
    hBematech:begin
      AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hFormas.txt');
      if not FileExists(ExtractFilePath(Application.ExeName)+ 'hFormas.txt') then
        Rewrite(Arq)
      else
        Append(Arq);
      Writeln(Arq,'Total em ' + forma +'  '+FormatFloat('#,##0.00',valor));
      CloseFile(Arq);
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;

    hImpPadrao, hDiebold:begin
      AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hFormas.txt');
      if not FileExists(ExtractFilePath(Application.ExeName)+ 'hFormas.txt') then
        Rewrite(Arq)
      else
        Append(Arq);
      Writeln(Arq,'Total em ' + forma +'  '+FormatFloat('#,##0.00',valor));
      CloseFile(Arq);
    end;
  end;


end;

procedure ImprimeBarras(aCodigo : String);
begin
  case aImpressora of
    hBematech:begin
      ConfiguraCodigoBarras(StrToInt(LeIni('IMPRESSORA','ALTURA_BARRAS')),
                StrToInt(LeIni('IMPRESSORA','LARGURA_BARRAS')),
                StrToInt(LeIni('IMPRESSORA','IMPRIME_COD')),0,80);
      ImprimeCodigoBarrasEAN13(Pchar(aCodigo));

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

procedure ImprimeQR(aCodigo : String);
begin
  case aImpressora of
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
    case aImpressora of
      hBematech:begin
        AtivaImpressora(aImpressora,aModelo, aPorta);
        AcionaGuilhotina(0);
        FechaPorta;
      end;
      hImpPadrao,hDiebold:begin
        AtivaImpressora(aImpressora,aModelo, aPorta);
        prn_comando(#27+#109);
      end;
    end;
  end;
end;

procedure ImpSangria(caixa : integer; supervisor, operador : String; valor : Double);
begin
  case aImpressora of
    hBematech:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);
      Bematech_Normal(alinhaCentro(Length('SANGRIA '))+'SANGRIA ');
      Bematech_Normal(TracoDuplo(47));
      Bematech_Normal('Caixa :' + IntToStr(caixa));
      Bematech_Normal('Supervisor :' + supervisor);
      Bematech_Normal('Operador :' + operador);
      Bematech_Normal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
      Bematech_Normal(Traco(47));
      Bematech_Normal('Valor da Retirada:  ' + FormatFloat('#,##0.00',valor));
      ComandoTX(#13#10#13#10, Length(#13#10#13#10));
      Bematech_Normal(Alinhacentro(LengTh('__________________________'))+'__________________________');
      Bematech_Normal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
      FechaPorta;
    end;
    hImpPadrao, hDiebold:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);
      Prn_Normal(alinhaCentro(Length('SANGRIA '))+'SANGRIA ');
      Prn_Normal(TracoDuplo(47));
      Prn_Normal('Caixa :' + IntToStr(caixa));
      Prn_Normal('Supervisor :' + supervisor);
      Prn_Normal('Operador :' + operador);
      Prn_Normal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
      Prn_Normal(Traco(47));
      Prn_Normal('Valor da Retirada:  ' + FormatFloat('#,##0.00',valor));
      Prn_Normal('');
      Prn_Normal('');
      Prn_Normal(Alinhacentro(LengTh('__________________________'))+'__________________________');
      Prn_Normal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
      prn.CloseDoc;
    end;
  end;
end;

procedure ImpSuprimento(caixa : integer; supervisor, operador : String; valor : Double);
begin
  case aImpressora of
    hBematech:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);
      Bematech_Normal(alinhaCentro(Length('SUPRIMENTO '))+'SUPRIMENTO ');
      Bematech_Normal(TracoDuplo(47));
      Bematech_Normal('Caixa :' + IntToStr(caixa));
      Bematech_Normal('Supervisor :' + supervisor);
      Bematech_Normal('Operador :' + operador);
      Bematech_Normal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
      Bematech_Normal(Traco(47));
      Bematech_Normal('Valor do Suprimento:  ' + FormatFloat('#,##0.00',valor));
      ComandoTX(#13#10#13#10, Length(#13#10#13#10));
      Bematech_Normal(Alinhacentro(LengTh('__________________________'))+'__________________________');
      Bematech_Normal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
      FechaPorta;
    end;
    hImpPadrao, hDiebold:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);
      Prn_Normal(alinhaCentro(Length('SUPRIMENTO '))+'SUPRIMENTO ');
      Prn_Normal(TracoDuplo(47));
      Prn_Normal('Caixa :' + IntToStr(caixa));
      Prn_Normal('Supervisor :' + supervisor);
      Prn_Normal('Operador :' + operador);
      Prn_Normal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
      Prn_Normal(Traco(47));
      Prn_Normal('Valor do Suprimento:  ' + FormatFloat('#,##0.00',valor));
      Prn_Normal('');
      Prn_Normal('');
      Prn_Normal(Alinhacentro(LengTh('__________________________'))+'__________________________');
      Prn_Normal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
      prn.CloseDoc;
    end;
  end;
end;

procedure CancelaCupom(caixa, cupom : integer; operador : String ; datahoravenda: TDateTime ;subtotal, desconto, total : Double);
begin
  case aImpressora of
    hBematech:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);
      Bematech_Normal(alinhaCentro(Length('CANCELAMENTO '))+'CANCELAMENTO ');
      Bematech_Normal(TracoDuplo(47));
      Bematech_Normal('Caixa.........:' + IntToStr(caixa));
      Bematech_Normal('Nr. Cancelado :' + IntToStr(cupom));
      Bematech_Normal(Traco(47));
      Bematech_Normal('Sub Total....:     ' + FormatFloat('#,##0.00',subtotal));
      Bematech_Normal('Desconto.....:     ' + FormatFloat('#,##0.00',desconto));
      Bematech_Normal('Valor Total..:     ' + FormatFloat('#,##0.00',total));
      Bematech_Normal('Data da Venda:     ' + FormatDateTime('DD/MM/YYYY',datahoravenda));
      Bematech_Normal('Data da Venda:     ' + FormatDateTime('DD/MM/YYYY',now));
      Bematech_Normal('Operador.....:' + operador);
      Bematech_Normal(Traco(47));
      FechaPorta;
    end;
    //impressora padrao
    hImpPadrao, hDiebold:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);
      prn_Normal(alinhaCentro(Length('CANCELAMENTO '))+'CANCELAMENTO ');
      prn_Normal(TracoDuplo(47));
      prn_Normal('Caixa.........:' + IntToStr(caixa));
      prn_Normal('Nr. Cancelado :' + IntToStr(cupom));
      prn_Normal(Traco(47));
      prn_Normal('Sub Total....:     ' + FormatFloat('#,##0.00',subtotal));
      prn_Normal('Desconto.....:     ' + FormatFloat('#,##0.00',desconto));
      prn_Normal('Valor Total..:     ' + FormatFloat('#,##0.00',total));
      prn_Normal('Data da Venda:     ' + FormatDateTime('DD/MM/YYYY',datahoravenda));
      prn_Normal('Data da Venda:     ' + FormatDateTime('DD/MM/YYYY',now));
      prn_Normal('Operador.....:' + operador);
      prn_Normal(Traco(47));
      prn.CloseDoc;
    end;
  end;
end;

procedure ImpAbertura(caixa : integer; supervisor, operador : String; valor : Double);
begin
  case aImpressora of
    hBematech:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);

      Bematech_Normal(alinhaCentro(Length('ABERTURA'))+'ABERTURA');
      Bematech_Normal(TracoDuplo(47));
      Bematech_Normal('Caixa : ' + IntToStr(caixa));
      Bematech_Normal('Supervisor : ' + supervisor);
      Bematech_Normal('Operador : ' + operador);
      Bematech_Normal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
      Bematech_Normal(Traco(47));
      Bematech_Normal('Valor Abertura:  ' + FormatFloat('#,##0.00',valor));
      ComandoTX(#13#10#13#10, Length(#13#10#13#10));
      Bematech_Normal(Alinhacentro(LengTh('__________________________'))+'__________________________');
      Bematech_Normal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
      FechaPorta;
    end;
    //impressora padr�o
    hImpPadrao, hDiebold:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);

      prn_Normal(alinhaCentro(Length('ABERTURA'))+'ABERTURA');
      prn_Normal(TracoDuplo(47));
      prn_Normal('Caixa : ' + IntToStr(caixa));
      prn_Normal('Supervisor : ' + supervisor);
      prn_Normal('Operador : ' + operador);
      prn_Normal('Data: '+ DateToStr(Date)+ '    ' + 'Hora: '+ TimeToStr(Time));
      prn_Normal(Traco(47));
      prn_Normal('Valor Abertura:  ' + FormatFloat('#,##0.00',valor));
      Prn_Normal('');
      Prn_Normal('');
      prn_Normal(Alinhacentro(LengTh('__________________________'))+'__________________________');
      prn_Normal(Alinhacentro(LengTh('       Responsavel        '))+'       Responsavel        ');
      prn.CloseDoc;
    end;
  end;
end;

procedure ImpFechamento(caixa, controle : integer; supervisorab,supervisorf, operador : String; aData: TDate; aHora: TTime; valor, valorinformado : Double);
var
  aTotalCaixa, aTotalVendas, aValorFinal, aDiferenca : Double;
begin
  case aImpressora of
    hBematech:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);
      Bematech_Normal(alinhaCentro(Length('FECHAMENTO DO CAIXA'))+'FECHAMENTO DO CAIXA');
      Bematech_Normal(TracoDuplo(47));
      Bematech_Normal('Caixa : ' + IntToStr(caixa)+ '  Controle : ' + IntToStr(controle));
      Bematech_Normal('Superv. Abertura  : ' + supervisorab);
      Bematech_Normal('Data/Hora Abertura : '+ DateToStr(aData) +' as '+TimeToStr(aHora));
      Bematech_Normal('Superv. Fechamento: ' + supervisorf);
      Bematech_Normal('Data/Hora Fechamento : '+ DateToStr(Date) +' as '+TimeToStr(Time));
      Bematech_Normal('Operador : ' + operador);
      Bematech_Normal(Traco(47));
      Bematech_Normal(alinhaCentro(Length('Dados do Caixa'))+ 'Dados do Caixa');
      Bematech_Normal(Traco(47));
      Bematech_Normal('+ Valor Inicial do caixa..:' + aLinhaDireita(FormatFloat('#,##0.00',valor),20));
      Bematech_Normal('+ Dinheiro................:'+ aLinhaDireita(FormatFloat('#,##0.00',aDinheiro),20));
      Bematech_Normal('+ Cheque..................:'+ aLinhaDireita(FormatFloat('#,##0.00',aCheque),20));
      Bematech_Normal('+ Cartao..................:'+ aLinhaDireita(FormatFloat('#,##0.00',aCartao),20));
      Bematech_Normal('+ Suprimento..............:'+ aLinhaDireita(FormatFloat('#,##0.00',aSuprimento),20));
      Bematech_Normal('- Sangria.................:'+ aLinhaDireita(FormatFloat('#,##0.00',aSangria),20));

      aTotalCaixa := (valor + aDinheiro + aCartao + aCheque + aSuprimento) - aSangria;

      Bematech_Normal('= Valor Final em Caixa....:'+ aLinhaDireita(FormatFloat('#,##0.00',aTotalCaixa),20));

      if valorinformado <> 0  then
      begin
       // ComandoTX(#13#10, Length(#13#10));
        aValorFinal := (valor + aSuprimento + aTotalVendas + aTRecebido) - aSangria;
        Bematech_Normal('Valor Informado...........:'+ aLinhaDireita(FormatFloat('#,##0.00',valorinformado),20));

        aDiferenca := valorinformado - aValorFinal;

        Bematech_Normal('Valor Diferenca...........:'+ aLinhaDireita(FormatFloat('#,##0.00',aDiferenca),20));
      end;

      Bematech_Normal(Traco(47));
      Bematech_Normal(alinhaCentro(Length('Informativo de Vendas'))+ 'Informativo de Vendas');
      Bematech_Normal(Traco(47));


      Bematech_Normal('+ Vendas em Dinheiro......:'+ aLinhaDireita(FormatFloat('#,##0.00',aTDinheiro),20));
      Bematech_Normal('+ Vendas em Cheque........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCheque),20));
      Bematech_Normal('+ Vendas em Cartao........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCartao),20));
      Bematech_Normal('+ Vendas para Cliente.....:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCliente),20));

      aTotalVendas := aTDinheiro + aTCheque + aTCartao + aTCliente;

      Bematech_Normal('= Total de Vendas.........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTotalVendas),20));
      Bematech_Normal(Traco(47));
      Bematech_Normal('= Total em Descontos......:'+ aLinhaDireita(FormatFloat('#,##0.00',aTDesconto),20));
      Bematech_Normal('= Recebimento de Clientes.:'+ aLinhaDireita(FormatFloat('#,##0.00',aTRecebido),20));
      Bematech_Normal(TracoDuplo(47));
      Bematech_Normal('Cupuns Cancelados.........:'+ aLinhaDireita(FormatFloat('###,#0',aCancelados),20));
      Bematech_Normal('Valor Cupons Cancelados...:'+ aLinhaDireita(FormatFloat('#,##0.00',aVlrCancelados),20));
      Bematech_Normal('Itens Cancelados..........:'+ aLinhaDireita(FormatFloat('###,#0',aItmCancelados),20));
      Bematech_Normal('Valor Itens Cancelados....:'+ aLinhaDireita(FormatFloat('#,##0.00',aVlrItmCancelados),20));
      Bematech_Normal(Traco(47));
      zeraVariaveis();
      FechaPorta;
    end;
    //impressora padrao
    hImpPadrao, hDiebold:begin
      ImpCabecalho(aModelo,aImpressora,aPorta);
      Prn_Normal(alinhaCentro(Length('FECHAMENTO DO CAIXA'))+'FECHAMENTO DO CAIXA');
      Prn_Normal(TracoDuplo(47));
      Prn_Normal('Caixa : ' + IntToStr(caixa)+ '  Controle : ' + IntToStr(controle));
      Prn_Normal('Superv. Abertura  : ' + supervisorab);
      Prn_Normal('Data/Hora Abertura : '+ DateToStr(aData) +' as '+TimeToStr(aHora));
      Prn_Normal('Superv. Fechamento: ' + supervisorf);
      Prn_Normal('Data/Hora Fechamento : '+ DateToStr(Date) +' as '+TimeToStr(Time));
      Prn_Normal('Operador : ' + operador);
      Prn_Normal(Traco(47));
      Prn_Normal(alinhaCentro(Length('Dados do Caixa'))+ 'Dados do Caixa');
      Prn_Normal(Traco(47));
      Prn_Normal('+ Valor Inicial do caixa..:' + aLinhaDireita(FormatFloat('#,##0.00',valor),20));
      Prn_Normal('+ Dinheiro................:'+ aLinhaDireita(FormatFloat('#,##0.00',aDinheiro),20));
      Prn_Normal('+ Cheque..................:'+ aLinhaDireita(FormatFloat('#,##0.00',aCheque),20));
      Prn_Normal('+ Cartao..................:'+ aLinhaDireita(FormatFloat('#,##0.00',aCartao),20));
      Prn_Normal('+ Suprimento..............:'+ aLinhaDireita(FormatFloat('#,##0.00',aSuprimento),20));
      Prn_Normal('- Sangria.................:'+ aLinhaDireita(FormatFloat('#,##0.00',aSangria),20));

      aTotalCaixa := (valor + aDinheiro + aCartao + aCheque + aSuprimento) - aSangria;

      Prn_Normal('= Valor Final em Caixa....:'+ aLinhaDireita(FormatFloat('#,##0.00',aTotalCaixa),20));

      if valorinformado <> 0  then
      begin
     //  Prn_Normal('');
        aValorFinal := (valor + aSuprimento + aTotalVendas + aTRecebido) - aSangria;
        Prn_Normal('Valor Informado...........:'+ aLinhaDireita(FormatFloat('#,##0.00',valorinformado),20));

        aDiferenca := valorinformado - aValorFinal;

        Prn_Normal('Valor Diferenca...........:'+ aLinhaDireita(FormatFloat('#,##0.00',aDiferenca),20));
      end;

      Prn_Normal(Traco(47));
      Prn_Normal(alinhaCentro(Length('Informativo de Vendas'))+ 'Informativo de Vendas');
      Prn_Normal(Traco(47));


      Prn_Normal('+ Vendas em Dinheiro......:'+ aLinhaDireita(FormatFloat('#,##0.00',aTDinheiro),20));
      Prn_Normal('+ Vendas em Cheque........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCheque),20));
      Prn_Normal('+ Vendas em Cartao........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCartao),20));
      Prn_Normal('+ Vendas para Cliente.....:'+ aLinhaDireita(FormatFloat('#,##0.00',aTCliente),20));

      aTotalVendas := aTDinheiro + aTCheque + aTCartao + aTCliente;

      Prn_Normal('= Total de Vendas.........:'+ aLinhaDireita(FormatFloat('#,##0.00',aTotalVendas),20));
      Prn_Normal(Traco(47));
      Prn_Normal('= Total em Descontos......:'+ aLinhaDireita(FormatFloat('#,##0.00',aTDesconto),20));
      Prn_Normal('= Recebimento de Clientes.:'+ aLinhaDireita(FormatFloat('#,##0.00',aTRecebido),20));
      Prn_Normal(TracoDuplo(47));
      Prn_Normal('Cupuns Cancelados.........:'+ aLinhaDireita(FormatFloat('###,#0',aCancelados),20));
      Prn_Normal('Valor Cupons Cancelados...:'+ aLinhaDireita(FormatFloat('#,##0.00',aVlrCancelados),20));
      Prn_Normal('Itens Cancelados..........:'+ aLinhaDireita(FormatFloat('###,#0',aItmCancelados),20));
      Prn_Normal('Valor Itens Cancelados....:'+ aLinhaDireita(FormatFloat('#,##0.00',aVlrItmCancelados),20));
      Prn_Normal(Traco(47));
      zeraVariaveis();
      prn.CloseDoc;
    end;
  end;
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

Procedure AdicionaParcela ({parcela : integer;} vecto : String ; valor : Double);overload;
var
  Arq : TextFile;
  aLinha : String;
begin
  case aImpressora of
    hBematech:begin
      AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hparcelas.txt');
      if not FileExists(ExtractFilePath(Application.ExeName)+ 'hparcelas.txt') then
        Rewrite(Arq)
      else
        Append(Arq);
      Writeln(Arq,{IntToStr(parcela)+ }'    ' + vecto +'       '+FormatFloat('#,##0.00',valor));
      CloseFile(Arq);
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;

    hImpPadrao, hDiebold:begin
      AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hparcelas.txt');
      if not FileExists(ExtractFilePath(Application.ExeName)+ 'hparcelas.txt') then
        Rewrite(Arq)
      else
        Append(Arq);
      Writeln(Arq,{IntToStr(parcela)+ }'    ' + vecto +'       '+FormatFloat('#,##0.00',valor));
      CloseFile(Arq);
    end;

  end;



end;

Procedure AdicionaParcela (parcela : integer; vecto : String ; valor : Double); overload;
var
  Arq : TextFile;
  aLinha : String;
begin
  case aImpressora of
    hBematech:begin
      AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hparcelas.txt');
      if not FileExists(ExtractFilePath(Application.ExeName)+ 'hparcelas.txt') then
        Rewrite(Arq)
      else
        Append(Arq);
      Writeln(Arq,IntToStr(parcela)+ '    ' + vecto +'       '+FormatFloat('#,##0.00',valor));
      CloseFile(Arq);
    end;
    hElgin:begin

    end;
    hDaruma:begin

    end;
    hEpson:begin

    end;

    hImpPadrao, hDiebold:begin
      AssignFile(Arq,ExtractFilePath(Application.ExeName)+ 'hparcelas.txt');
      if not FileExists(ExtractFilePath(Application.ExeName)+ 'hparcelas.txt') then
        Rewrite(Arq)
      else
        Append(Arq);
      Writeln(Arq,IntToStr(parcela)+ '    ' + vecto +'       '+FormatFloat('#,##0.00',valor));
      CloseFile(Arq);
    end;
  end;


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
  case aImpressora of
    hBematech :begin
      AtivaImpressora(aImpressora,aModelo,aPorta);
      for I := 0 to linhas - 1 do
        ComandoTX(#13#10, Length(#13#10));
      fechaporta;
    end;
    hImpPadrao, hDiebold:begin
      for I := 0 to linhas - 1 do
        Prn_Comando(#10);
    end;
  end;
end;

procedure TesteImpressora(impressora, modelo, porta, avanco :Integer);
var
  I : integer;
begin
  case setImpressora(impressora) of
    hBematech: begin
      AtivaImpressora(impressora,modelo,porta);
      Bematech_Pequeno('Fonte Pequena');
      Bematech_Normal('Fonte Normal');
      Bematech_Grande('Fonte Grande');
      Bematech_Normal('Fim Teste');
      for I := 0 to avanco - 1 do
        ComandoTX(#13#10,Length(#13#10));
      FechaPorta;
    end;
    hImpPadrao, hDiebold: begin
      AtivaImpressora(impressora,modelo,porta);
      prn_Pequeno('Fonte Pequena');
      prn_Normal('Fonte Normal');
      prn_Grande('Fonte grande');
      prn_Normal('Fim Teste');
      for I := 0 to avanco - 1 do
        prn_normal('');
      prn.CloseDoc;

    end;
  end;

end;

{$REGION 'COMANDOS UNIFICADOS'}

procedure hPrintPequeno(aTexto : String);
begin
  case aImpressora of
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

procedure hPrintNormal(aTexto : String);
begin
  case aImpressora of
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

procedure hPrintGrande(aTexto : String);
begin
  case aImpressora of
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

procedure hPrintComando(aTexto : String);
begin
  case aImpressora of
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
{$ENDREGION}


end.
