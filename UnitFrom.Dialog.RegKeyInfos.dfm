object dlgRegKeyInfos: TdlgRegKeyInfos
  Left = 0
  Top = 0
  Caption = 'dlgRegKeyInfos'
  ClientHeight = 262
  ClientWidth = 460
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 460
    Height = 262
    Align = alClient
    Columns = <
      item
        Caption = 'Key'
        Width = 100
      end
      item
        AutoSize = True
        Caption = 'Value'
      end>
    TabOrder = 0
    ViewStyle = vsReport
  end
end
