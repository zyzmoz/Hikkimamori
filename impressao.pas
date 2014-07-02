unit impressao;

interface
uses declaracoes,  ibquery, DB, Forms, sysutils, controls, windows;

type
  THPortas = (hCOM1,hCOM2, hCOM3, hCOM4, hLPT1, hLPT2, hEthernet, hUSB);
  THImpressora = (hBematech, hElgin, hDaruma, hEpson, hDiebold);
  THModeloIMP = ( //Bematech
                  hMP20MI   = 1,
                  hMP20TH   = 0,
                  hMP2000CI = 0,
                  hMP2000TH = 0,
                  hMP2100TH = 0,
                  hMP4000TH = 5,
                  hMP4200TH = 7,
                  hMP2500TH = 8);
  THTipoImp = (hVenda, hConsignacao, hRecibo, hCarne);


function Bematech_Pequeno(aTexto : string):integer;
function Bematech_Normal(aTexto : string):integer;
function Bematech_Grande(aTexto : string):integer;
function Bematech_lestatus(porta : THPortas; modelo : THModeloIMP):String;
Procedure IniciaImp(modelo : THModeloIMP; impressora : THImpressora; porta : THPortas);
function RetornaStrPorta(porta : THPortas): String;
Procedure AdicionaItem (impressora : THImpressora; item, barras: String; qtde, unitario , total : Double);
Procedure ImprimeTipo (impressora : THImpressora; tipo : THTipoImp ;numeroimp, pdv : integer; data, hora, vendedor : String);
Procedure InformaCliente(impressora : THImpressora; Ficha, Cliente, Endereco, Bairro : String);
Procedure FechaImpressao (impressora : THImpressora; tipo : THTipoImp ;SubTotal, Desconto, Acrescimo, Total, Recebido : Double);

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
    Bematech_grande := FormataTX(pchar(aTexto), 3, 0, 0, 0, 0);
  end;
end;


function Bematech_lestatus(porta : THPortas; modelo : THModeloIMP):String;
var
  aStatus: integer;
  s_stporta: String;
begin
// ANÁLISE DO RETORNO DE STATUS DAS IMPRESSORAS FISCAIS
  case porta of
    hCOM1: s_stporta:='serial';
    hCOM2: s_stporta:='serial';
    hCOM3: s_stporta:='serial';
    hCOM4: s_stporta:='serial';
    hLPT1: s_stporta:='lpt';
    hLPT2: s_stporta:='lpt';
    hEthernet: s_stporta:='rede';
  end;

  aStatus := Le_Status();

//******************IMPRESSORAS MP 20 CI E MI - CONEXÃO SERIAL******************

  if (modelo=1) and (s_stporta='serial') then
    Begin
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE';
    if aStatus= 32 then Bematech_lestatus :='32 - SEM PAPEL';
    End;
//******************************************************************************

//******************IMPRESSORAS MP 20 CI E MI - CONEXÃO PARALELA****************

  if (modelo=1) and (s_stporta='lpt') then
    Begin
    if aStatus= 144 then Bematech_lestatus :='144 - ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE OU IMP. SEM PAPEL';
    End;
//******************************************************************************

//******IMPRESSORAS MP 20 TH, 2000 CI 2000 TH 2100 TH - CONEXÃO SERIAL**********

  if (modelo=0) and (s_stporta='serial') then
    Begin
    if aStatus= 0 then Bematech_lestatus :='0 - OFF LINE';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE OU POUCO PAPEL';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    End;
//******************************************************************************

//******IMPRESSORAS MP 20 TH, 2000 CI 2000 TH 2100 TH - CONEXÃO PARALELA********

  if (modelo=0) and (s_stporta='lpt') then
    Begin
    if aStatus= 79 then Bematech_lestatus :='79 - OFF LINE';
    if aStatus= 144 then Bematech_lestatus :='144 - ON LINE OU POUCO PAPEL';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 0 then Bematech_lestatus :='0 - ERRO DE COMUNICAÇÃO';
    End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEXÃO PARALELA*********************

  if (modelo=5) and (s_stporta='lpt') then
    Begin
    if aStatus= 40 then Bematech_lestatus :='40 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 128 then Bematech_lestatus :='128 - IMP. SEM PAPEL';
    if aStatus= 0 then Bematech_lestatus :='0 - POUCO PAPEL';
    End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEXÃO ETHERNET*********************

  if (modelo=5) and (s_stporta='rede') then
    Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE - POUCO PAPEL';
    End;
//******************************************************************************

//******************IMPRESSORAS MP 4000 TH CONEXÃO SERIAL***********************

  if (modelo=5) and (s_stporta='serial') then
    Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 5 then Bematech_lestatus :='5 - ON LINE - POUCO PAPEL';
    End;
//******************************************************************************

//*********************IMPRESSORAS MP 4000 TH CONEXÃO USB***********************

  if (modelo=5) and (s_stporta='serial') then
    Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 68 then Bematech_lestatus :='68 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 24 then Bematech_lestatus :='24 - ON LINE - POUCO PAPEL';
    End;
//******************************************************************************

//*******************IMPRESSORAS MP 4200 TH CONEXÃO TODAS***********************

  if (modelo=7) then
    Begin
    if aStatus= 24 then Bematech_lestatus :='24 - IMPRESSORA ON LINE';
    if aStatus= 0 then Bematech_lestatus :='0 - IMP. OFF LINE/SEM COMUNICAÇÃO';
    if aStatus= 32 then Bematech_lestatus :='32 - IMP. SEM PAPEL';
    if aStatus= 5 then Bematech_lestatus :='5 - ON LINE - POUCO PAPEL';
    if aStatus= 9 then Bematech_lestatus :='9 - TAMPA ABERTA';
    End;
//******************************************************************************


end;

Procedure IniciaImp(modelo : THModeloIMP; impressora : THImpressora; porta : THPortas);
var
  Arq : TextFile;
begin
  case impressora of
    hBematech:begin
      ConfiguraModeloImpressora(modelo);
      if IniciaPorta(RetornaStrPorta(porta)) <> 1 then
      begin
        Application.MessageBox('Sem conexão com a impressora','Aviso!', MB_OK + MB_ICONWARNING);
        Exit;
      end;
      Bematech_lestatus;
      if LeIni('IMPRESSORA','IMG') <> '' then
      begin
        ImprimeBmpEspecial( pchar(LeIni('IMPRESSORA','IMG')),
                                  strtoint(LeIni('IMPRESSORA','IMG_X')),
                                  strtoint(LeIni('IMPRESSORA','IMG_Y')),
                                  strtoint(LeIni('IMPRESSORA','IMG_A')));
      end;
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','FANTASIA'))) + LeIni('EMPRESA','FANTASIA'));
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','ENDERECO') + ', ' +LeIni('EMPRESA','NUMERO'))) +
                      LeIni('EMPRESA','ENDERECO') + ', ' +LeIni('EMPRESA','NUMERO') );
      Bematech_Normal(alinhaCentro(Length(LeIni('EMPRESA','BAIRRO')+' - '+LeIni('EMPRESA','CIDADE')+' - '+LeIni('EMPRESA','UF'))) +
                      LeIni('EMPRESA','BAIRRO')+' - '+LeIni('EMPRESA','CIDADE')+' - '+LeIni('EMPRESA','UF'));
      Bematech_Normal( alinhaCentro(Length(' Telefone: '+LeIni('EMPRESA','TELEFONE'))) +
                                           ' Telefone: '+LeIni('EMPRESA','TELEFONE'));
      Bematech_Normal( alinhaCentro(Length(LeIni('EMPRESA','EMAIL'))) + trim(LeIni('EMPRESA','EMAIL')));
      Bematech_Normal( alinhaCentro(Length(LeIni('EMPRESA','SITE'))) + trim(LeIni('EMPRESA','SITE')));
      Bematech_Normal( TracoDuplo(47));
      AssignFile(Arq,'hikki.txt');
      Rewrite(Arq);
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

Procedure AdicionaItem (impressora : THImpressora; item, barras: String; qtde, unitario , total : Double);
var
  Arq : TextFile;
begin
  case impressora of
    hBematech:begin
      AssignFile(Arq,'hikki.txt');
      Write(Arq,  #18 + subs( alltrim( item ), 1, 50 ));
      Write(Arq,  #$12 + '  ' + subs( barras, 1, 13 ) );
      Write(Arq,  #$12 + '' + FormatFloat('#,##0.00',qtde));
      Write(Arq,  #$12 + '' + FormatFloat('#,##0.00',unitario));
      Writeln(Arq,#$12 + '' + FormatFloat('#,##0.00',unitario * qtde));
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

function RetornaStrPorta(porta : THPortas): String;
begin
  case porta of
    hCOM1: RetornaStrPorta = 'COM1' ;
    hCOM2: RetornaStrPorta = 'COM2' ;
    hCOM3: RetornaStrPorta = 'COM3' ;
    hCOM4: RetornaStrPorta = 'COM4' ;
    hLPT1: RetornaStrPorta = 'LPT1' ;
    hLPT2: RetornaStrPorta = 'LPT2' ;
//    hEthernet: ;
//    hUSB: ;
  end;
end;

Procedure ImprimeTipo (impressora : THImpressora; tipo : THTipoImp ;numeroimp, pdv : integer; data, hora, vendedor : String);
begin
  case impressora of
    hBematech:begin
      Bematech_Normal(TracoDuplo(47));
      case tipo of
        hVenda: Bematech_Normal('Numero...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv)) ;
        hConsignacao:begin
          Bematech_Normal(alinhaCentro(length('CONSIGNACAO') + 'CONSIGNACAO'));
          Bematech_Normal(TracoDuplo(47));
          Bematech_Normal('Consignacao...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
        end;
        hRecibo: Bematech_Normal('Recibo...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
        hCarne: Bematech_Normal('Carne...:' +IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      end;
      Bematech_Normal('Numero...: ' + IntToStr(numeroimp) + '      PDV : ' + IntToStr(pdv));
      Bematech_Normal('Data.....: ' +  Trim(data) + ' Hora.: ' + hora );
      Bematech_Normal('Vendedor.: ' +  Trim(vendedor) );
      Bematech_Normal(Traco(47));
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

Procedure InformaCliente(impressora : THImpressora; Ficha, Cliente, Endereco, Bairro : String);
begin
  case impressora of
    hBematech:begin
      Bematech_Normal('Ficha....:' + Ficha   );
      Bematech_Normal('Cliente..:' + Cliente );
      Bematech_Normal('Endereco.:' + Endereco);
      Bematech_Normal('Bairro...:' + Bairro  );
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

Procedure FechaImpressao (impressora : THImpressora; tipo : THTipoImp ;SubTotal, Desconto, Acrescimo, Total, Recebido : Double);
var
  Arq   : TextFile;
  Valor : String;
begin
  case impressora of
    hBematech:begin
      AssignFile(Arq, 'hikki.txt');
      Reset(Arq);
      while not Eof(Arq) do
      begin
        Readln(Arq, Valor);
        Bematech_Normal ( copy ( Valor, 1, Length(Valor)));
      end;
        Bematech_Normal(Traco(47));
        case tipo of
          hVenda:begin
            Bematech_Normal('Valor da Venda'+ FormatFloat('#,##0.00',SubTotal));
            Bematech_Normal('Valor Desconto'+ FormatFloat('#,##0.00',Desconto));
            Bematech_Normal('Valor Total'+ FormatFloat('#,##0.00',Total));
            Bematech_Normal(Traco(47));
            Bematech_Normal('Valor Total Recebido'+ FormatFloat('#,##0.00',Recebido));
            if Recebido > Total then            
              Bematech_Normal('Troco'+ FormatFloat('#,##0.00',(Recebido-Total)));
          end;
          hConsignacao:begin
            Bematech_Normal('Valor da Total'+ FormatFloat('#,##0.00',Total)) ;
          end;
          hRecibo:begin
//            Bematech_Normal('Valor da Venda'+ FormatFloat('#,##0.00',SubTotal));
          end;
          hCarne:begin
//            Bematech_Normal('Valor da Venda'+ FormatFloat('#,##0.00',SubTotal));
          end;
        end;

      CloseFile(Arq);

      while FileExists('hikki.txt') do
        DeleteFile('hikki.txt');
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










end.
