object MainForm: TMainForm
  Left = 0
  Top = 0
  ActiveControl = lsvMainListShow
  AlphaBlendValue = 100
  Caption = 'MainForm'
  ClientHeight = 531
  ClientWidth = 692
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
    Width = 692
    Height = 487
    Align = alClient
    Columns = <
      item
        Caption = #26174#31034#21517
        Width = 100
      end
      item
        Caption = #21457#24067#32773
        Width = 100
      end
      item
        Caption = #36719#20214#29256#26412
        Width = 100
      end
      item
        Caption = #23433#35013#26102#38388
        Width = 100
      end
      item
        Caption = #21368#36733#23383#31526#20018
        Width = 200
      end
      item
        Caption = #27880#20876#34920#36335#24452
        Width = 200
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
  end
  object stuMainBar: TStatusBar
    Left = 0
    Top = 512
    Width = 692
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 518
  end
  object pnlMainBar: TPanel
    Left = 0
    Top = 0
    Width = 692
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object btnExeQuery: TButton
      Left = 243
      Top = 0
      Width = 66
      Height = 25
      Align = alLeft
      Caption = #25628#32034
      TabOrder = 0
      OnClick = btnExeQueryClick
    end
    object btnClear: TButton
      Left = 309
      Top = 0
      Width = 75
      Height = 25
      Align = alLeft
      Caption = #28165#29702
      TabOrder = 1
      OnClick = btnClearClick
    end
    object chkWinSysSw: TCheckBox
      Left = 384
      Top = 0
      Width = 118
      Height = 25
      Align = alLeft
      Caption = #19981#26174#31034#31995#32479#32452#20214
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = chkWinSysSwClick
    end
    object edtInput: TEdit
      Left = 0
      Top = 0
      Width = 243
      Height = 25
      Align = alLeft
      ImeMode = imAlpha
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      TextHint = #35831#36755#20837#25628#32034#39033
      OnKeyPress = edtInputKeyPress
      ExplicitHeight = 23
    end
    object chkRegHKCU: TCheckBox
      Left = 560
      Top = 0
      Width = 58
      Height = 25
      Align = alLeft
      Caption = 'HKCU'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = chkHKCU_HKLM_Click
    end
    object chkRegHKLM: TCheckBox
      Left = 502
      Top = 0
      Width = 58
      Height = 25
      Align = alLeft
      Caption = 'HKLM'
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = chkHKCU_HKLM_Click
    end
    object btnExportCSV: TButton
      Left = 617
      Top = 0
      Width = 75
      Height = 25
      Align = alRight
      Caption = #23548#20986
      TabOrder = 6
      OnClick = btnExportCSVClick
    end
  end
  object dlgSaveExport: TSaveDialog
    FileName = 'SoftwareUninstallListOnRegistry.csv'
    Filter = 'CSV(GBK)|*.csv|CSV(UTF-8)|*.csv'
    Left = 648
    Top = 48
  end
end
