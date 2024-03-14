unit UnitForm.Main;

interface

uses
  System.Generics.Collections,
  System.RegularExpressions,
  System.Win.Registry, Winapi.Windows,
  Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  UnitFrom.Dialog.RegKeyInfos;

type
  TMainForm = class(TForm)
    fpnlMainBar: TFlowPanel;
    lsvMainListShow: TListView;
    edtInput: TEdit;
    btnExeQuery: TButton;
    btnClear: TButton;
    StatusBar1: TStatusBar;
    chkWinSysSw: TCheckBox;
    CheckBox2: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure lsvMainListShowDblClick(Sender: TObject);
    procedure lsvMainListShowColumnClick(Sender: TObject; Column: TListColumn);
    procedure lsvMainListShowCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

var
  SortedColumn: Integer = 0;
  UseDescending: Boolean = false;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
  input, output: string;
  RegKeyNames: TStringList;
  keyname, ragpath: string;
  keyrootI: HKEY;
  rgxMatchInstallDate: TRegEx;
  regkeyFInstallDate: string;
  regkeyFDisplayName: string;

begin
  ragpath := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';

  rgxMatchInstallDate := TRegEx.Create('((?:19|20)\d{2})(\d{2})(\d{2})');

  RegKeyNames := TStringList.Create;
  for keyrootI in [HKEY_LOCAL_MACHINE, HKEY_CLASSES_ROOT] do
    with TRegistry.Create do
      try
        Access := KEY_READ;
        RootKey := keyrootI;
        OpenKeyReadOnly(ragpath);

        GetKeyNames(RegKeyNames);
        for keyname in RegKeyNames do
        begin
          CloseKey;

          if not OpenKeyReadOnly(ragpath + '\' + keyname) then
            continue;

          if ValueExists('DisplayName') then
          begin
            regkeyFDisplayName := ReadString('DisplayName');

            if chkWinSysSw.Checked then
              if regkeyFDisplayName.StartsWith('vs_') then
                continue;

            if regkeyFDisplayName.Trim = string.Empty then
              continue;

            with lsvMainListShow.Items.Add do
            begin
              { 显示名 } Caption := regkeyFDisplayName;
              { 发布者 } SubItems.Add(ReadString('Publisher'));
              { 软件版本 } SubItems.Add(ReadString('DisplayVersion'));
              { 安装时间 } regkeyFInstallDate := ReadString('InstallDate').Trim;
              with rgxMatchInstallDate.Match(regkeyFInstallDate) do
                if Success then
                  SubItems.Add(Format('%s年%s月%s日', [
                    { 年 } Groups[1].Value,
                    { 月 } Groups[2].Value,
                    { 日 } Groups[3].Value]))
                else
                  SubItems.Add(regkeyFInstallDate);

              { 卸载字符串 } SubItems.Add(ReadString('UninstallString'));
              { 注册表路径 } SubItems.Add(ragpath + '\' + keyname);
            end;
          end;

        end;

      finally
        CloseKey;
        Free;
      end;

  // InputBox('标题', '提示信息', '默认值');
  // ShowMessage(output);
end;

procedure TMainForm.lsvMainListShowColumnClick(Sender: TObject;
  Column: TListColumn);
begin

  SortedColumn := Column.Index;

  (Sender as TListView).CustomSort(nil, SortedColumn);

  UseDescending := not UseDescending;

end;

procedure TMainForm.lsvMainListShowCompare(Sender: TObject;
  Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin

  if SortedColumn = 0 then
    Compare := AnsiCompareText(Item1.Caption, Item2.Caption)
  else if SortedColumn <> 0 then
    Compare := AnsiCompareText(Item1.SubItems[SortedColumn - 1],
      Item2.SubItems[SortedColumn - 1]);

  if UseDescending then
    Compare := -Compare;

end;

procedure TMainForm.lsvMainListShowDblClick(Sender: TObject);
var
  showonlist: TList<string>;
  i: string;
begin
  with (Sender as TListView) do
  begin
    // ShowMessage(Selected.Caption);
    // dlgRegKeyInfos.ShowModal;
    showonlist := TList<string>.Create;
    showonlist.Add(Selected.Caption);
    for i in (Sender as TListView).Selected.SubItems do
      showonlist.Add(i);

    with TdlgRegKeyInfos.Create(MainForm, ['显示名', '发布者', '软件版本', '安装时间',
      '卸载字符串', '注册表路径'], showonlist) do
      try
        ShowModal
      finally
        Free
      end;
  end;
end;

end.
