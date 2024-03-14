object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 491
  ClientWidth = 673
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object fpnlMainBar: TFlowPanel
    Left = 0
    Top = 0
    Width = 673
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 3
    Padding.Top = 3
    Padding.Right = 3
    Padding.Bottom = 3
    TabOrder = 0
    object edtInput: TEdit
      Left = 3
      Top = 3
      Width = 243
      Height = 23
      ImeMode = imAlpha
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      TextHint = #35831#36755#20837#25628#32034#39033
    end
    object btnExeQuery: TButton
      Left = 246
      Top = 3
      Width = 66
      Height = 25
      Caption = #25628#32034
      TabOrder = 1
    end
    object btnClear: TButton
      Left = 312
      Top = 3
      Width = 75
      Height = 25
      Caption = #28165#29702
      TabOrder = 2
    end
  end
  object lsvMainListShow: TListView
    Left = 0
    Top = 33
    Width = 673
    Height = 439
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = #26174#31034#21517
      end
      item
        AutoSize = True
        Caption = #21457#24067#32773
      end
      item
        AutoSize = True
        Caption = #36719#20214#29256#26412
      end
      item
        AutoSize = True
        Caption = #23433#35013#26102#38388
      end
      item
        AutoSize = True
        Caption = #21368#36733#23383#31526#20018
      end
      item
        AutoSize = True
        Caption = #27880#20876#34920#36335#24452
      end>
    FlatScrollBars = True
    StyleName = 'Windows'
    RowSelect = True
    SortType = stText
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = lsvMainListShowDblClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 472
    Width = 673
    Height = 19
    Panels = <>
  end
end
