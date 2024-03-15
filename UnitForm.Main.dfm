object MainForm: TMainForm
  Left = 0
  Top = 0
  ActiveControl = lsvMainListShow
  AlphaBlendValue = 100
  Caption = 'MainForm'
  ClientHeight = 504
  ClientWidth = 661
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object lsvMainListShow: TListView
    Left = 0
    Top = 25
    Width = 661
    Height = 460
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
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnColumnClick = lsvMainListShowColumnClick
    OnCompare = lsvMainListShowCompare
    OnDblClick = lsvMainListShowDblClick
    ExplicitLeft = 216
    ExplicitTop = 207
    ExplicitWidth = 673
    ExplicitHeight = 408
  end
  object stuMainBar: TStatusBar
    Left = 0
    Top = 485
    Width = 661
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 472
    ExplicitWidth = 673
  end
  object pnlMainBar: TPanel
    Left = 0
    Top = 0
    Width = 661
    Height = 25
    Align = alTop
    TabOrder = 2
    ExplicitLeft = -40
    ExplicitTop = -6
    ExplicitWidth = 689
    object btnExeQuery: TButton
      Left = 244
      Top = 1
      Width = 66
      Height = 23
      Align = alLeft
      Caption = #25628#32034
      TabOrder = 0
      OnClick = btnExeQueryClick
      ExplicitLeft = 297
      ExplicitHeight = 39
    end
    object btnClear: TButton
      Left = 310
      Top = 1
      Width = 75
      Height = 23
      Align = alLeft
      Caption = #28165#29702
      TabOrder = 1
      OnClick = btnClearClick
      ExplicitLeft = 259
      ExplicitTop = 2
      ExplicitHeight = 25
    end
    object chkWinSysSw: TCheckBox
      Left = 385
      Top = 1
      Width = 118
      Height = 23
      Align = alLeft
      Caption = #19981#26174#31034#31995#32479#32452#20214
      TabOrder = 2
      OnClick = chkWinSysSwClick
      ExplicitLeft = 380
      ExplicitTop = 0
      ExplicitHeight = 17
    end
    object edtInput: TEdit
      Left = 1
      Top = 1
      Width = 243
      Height = 23
      Align = alLeft
      ImeMode = imAlpha
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      TextHint = #35831#36755#20837#25628#32034#39033
      OnKeyPress = edtInputKeyPress
      ExplicitLeft = -5
      ExplicitTop = -3
      ExplicitHeight = 39
    end
    object chkRegHKCU: TCheckBox
      Left = 561
      Top = 1
      Width = 58
      Height = 23
      Align = alLeft
      Caption = 'HKCU'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = chkHKCU_HKLM_Click
      ExplicitLeft = 625
      ExplicitTop = -4
    end
    object chkRegHKLM: TCheckBox
      Left = 503
      Top = 1
      Width = 58
      Height = 23
      Align = alLeft
      Caption = 'HKLM'
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = chkHKCU_HKLM_Click
      ExplicitLeft = 649
      ExplicitTop = -4
    end
  end
end
