object Form1: TForm1
  Left = 213
  Top = 220
  Width = 617
  Height = 320
  Caption = 'Deep Black Packer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'PACK'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 40
    Width = 585
    Height = 233
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object SaveDialog1: TSaveDialog
    Left = 96
    Top = 8
  end
end
