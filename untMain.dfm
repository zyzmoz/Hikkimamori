object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Z'
  ClientHeight = 306
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 471
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Configurar'
    TabOrder = 0
    OnClick = Button1Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 0
    Width = 113
    Height = 249
    Caption = 'Venda'
    TabOrder = 1
    object Button2: TButton
      Left = 10
      Top = 16
      Width = 89
      Height = 25
      Caption = 'Inicia Venda'
      TabOrder = 0
      OnClick = Button2Click
    end
    object BitBtn1: TBitBtn
      Left = 10
      Top = 119
      Width = 89
      Height = 25
      Caption = 'Incluir Item'
      TabOrder = 1
      OnClick = BitBtn1Click
    end
    object Button3: TButton
      Left = 10
      Top = 150
      Width = 89
      Height = 25
      Caption = 'Remove Item'
      TabOrder = 2
      OnClick = Button3Click
    end
    object BitBtn2: TBitBtn
      Left = 10
      Top = 181
      Width = 89
      Height = 25
      Caption = 'Adiciona Forma'
      TabOrder = 3
      OnClick = BitBtn2Click
    end
    object Button4: TButton
      Left = 10
      Top = 212
      Width = 89
      Height = 25
      Caption = 'Fecha Impressao'
      TabOrder = 4
      OnClick = Button4Click
    end
    object Button6: TButton
      Left = 10
      Top = 47
      Width = 89
      Height = 25
      Caption = 'Informa Cliente'
      TabOrder = 5
      OnClick = Button6Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 223
    Top = 0
    Width = 114
    Height = 249
    Caption = 'Extra'
    TabOrder = 2
    object Button5: TButton
      Left = 10
      Top = 16
      Width = 89
      Height = 25
      Caption = 'Status Impressora'
      TabOrder = 0
      OnClick = Button5Click
    end
    object Button7: TButton
      Left = 10
      Top = 47
      Width = 89
      Height = 25
      Caption = 'Abre Gaveta'
      TabOrder = 1
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 10
      Top = 78
      Width = 89
      Height = 25
      Caption = 'Imprime Barras'
      TabOrder = 2
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 10
      Top = 109
      Width = 89
      Height = 25
      Caption = 'Imprime QR'
      TabOrder = 3
      OnClick = Button9Click
    end
  end
  object Button10: TButton
    Left = 408
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Button10'
    TabOrder = 3
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 408
    Top = 109
    Width = 75
    Height = 25
    Caption = 'Button11'
    TabOrder = 4
  end
end
