unit UnitForm.Main;

interface

uses
  system.Generics.Collections,
  system.RegularExpressions,
  system.Win.Registry, Winapi.Windows,
  Winapi.Messages, system.SysUtils,
  system.Variants, system.Classes,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  UnitFrom.Dialog.RegKeyInfos;

type
  TMainForm = class(TForm)
    lsvMainListShow: TListView;
    stuMainBar: TStatusBar;
    pnlMainBar: TPanel;
    btnExeQuery: TButton;
    btnClear: TButton;
    chkWinSysSw: TCheckBox;
    edtInput: TEdit;
    chkRegHKCU: TCheckBox;
    chkRegHKLM: TCheckBox;
    procedure lsvMainListShowDblClick(Sender: TObject);
    procedure lsvMainListShowColumnClick(Sender: TObject; Column: TListColumn);
    procedure lsvMainListShowCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure FormCreate(Sender: TObject);
    procedure chkWinSysSwClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure chkHKCU_HKLM_Click(Sender: TObject);
    procedure btnExeQueryClick(Sender: TObject);
    procedure edtInputKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

type
  TregPair = TDictionary<string, string>;

var
  UseDescending: boolean = false;
  RegKVPairs: TList<TregPair>;

  { procedrue and function private on implementation }

procedure GetUninstallRegistrys(out RegKVPairs: TList<TregPair>);
var

  RegKeyNames: TStringList;
  keyname, ragpath: string;
  keyrootI: HKEY;
  rgxMatchInstallDate: TRegEx;
  regkeyFInstallDate: string;
  regkeyFDisplayName: string;

  regKVPair: TDictionary<string, string>;

begin
  ragpath := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';

  rgxMatchInstallDate := TRegEx.Create('((?:19|20)\d{2})(\d{2})(\d{2})');

  RegKeyNames := TStringList.Create;
  RegKVPairs := TList<TregPair>.Create;

  for keyrootI in [HKEY_LOCAL_MACHINE, HKEY_CURRENT_USER] do
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

            if regkeyFDisplayName.Trim = string.Empty then
              continue;

            regKVPair := TDictionary<string, string>.Create;
            with regKVPair do
            begin

              { 显示名 } add('DisplayName', ReadString('DisplayName'));
              { 发布者 } add('Publisher', ReadString('Publisher'));
              { 软件版本 } add('DisplayVersion', ReadString('DisplayVersion'));
              { 安装时间 } regkeyFInstallDate := ReadString('InstallDate').Trim;
              with rgxMatchInstallDate.Match(regkeyFInstallDate) do
                if Success then
                  add('InstallDate', Format('%s年%s月%s日', [
                    { 年 } Groups[1].Value,
                    { 月 } Groups[2].Value,
                    { 日 } Groups[3].Value]))
                else
                  add('InstallDate', regkeyFInstallDate);
              { 卸载字符串 } add('UninstallString', ReadString('UninstallString'));
              { 注册表路径 }
              case keyrootI of
                HKEY_CURRENT_USER:
                  add('RegistryPath', Format('HKCU\%s\%s', [ragpath, keyname]));
                HKEY_LOCAL_MACHINE:
                  add('RegistryPath', Format('HKLM\%s\%s', [ragpath, keyname]));
              end;

            end;
            RegKVPairs.add(regKVPair);
          end;

        end;

      finally
        CloseKey;
        Free;
      end;
end;

procedure FilterUninstallRegistrys(oldRegList: TList<TregPair>;
  out newRegList: TList<TregPair>; aRegFilter: TPredicate<TregPair>);
var
  regpair: TregPair;
begin
  newRegList := TList<TregPair>.Create;
  for regpair in oldRegList do
  begin
    if aRegFilter(regpair) then
      newRegList.add(regpair);
  end;
end;

procedure RefreshListViewShoW(aListView: TListView;
  RegKVPairs: TList<TregPair>);
var
  kvpair: TregPair;
  i: Integer;
begin

  aListView.Items.BeginUpdate;
  aListView.Clear;

  for kvpair in RegKVPairs do
    with aListView.Items.add do
    begin
      Caption := kvpair['DisplayName'];
      SubItems.add(kvpair['Publisher']);
      SubItems.add(kvpair['DisplayVersion']);
      SubItems.add(kvpair['InstallDate']);
      SubItems.add(kvpair['UninstallString']);
      SubItems.add(kvpair['RegistryPath']);
    end;

  aListView.Items.EndUpdate;
end;

procedure TMainForm.btnExeQueryClick(Sender: TObject);
var
  newRegKVPairs: TList<TregPair>;
begin
  if string(edtInput.Text).Trim.IsEmpty then
  begin
    RefreshListViewShoW(lsvMainListShow, RegKVPairs);
    exit;
  end;

  FilterUninstallRegistrys(RegKVPairs, newRegKVPairs,
    function(x: TregPair): boolean
    begin
      if LowerCase(x['DisplayName']).Contains(LowerCase(edtInput.Text).Trim)
      then
        Result := true
      else
        Result := false;
    end);
  RefreshListViewShoW(lsvMainListShow, newRegKVPairs)
end;

procedure TMainForm.btnClearClick(Sender: TObject);
begin
  edtInput.Clear;
  RefreshListViewShoW(lsvMainListShow, RegKVPairs);
end;

procedure TMainForm.chkWinSysSwClick(Sender: TObject);
var
  newRegKVPairs: TList<TregPair>;
begin
  with Sender as TCheckBox do
    if Checked then
    begin
      FilterUninstallRegistrys(RegKVPairs, newRegKVPairs,
        function(x: TregPair): boolean
        begin
          if x['DisplayName'].StartsWith('vs_') //
            or x['DisplayName'].StartsWith('icecap_') //
            or x['DisplayName'].StartsWith('vcpp_') then
            Result := false
          else
            Result := true;
        end);
      RefreshListViewShoW(lsvMainListShow, newRegKVPairs);
    end
    else
      RefreshListViewShoW(lsvMainListShow, RegKVPairs);
end;

procedure TMainForm.edtInputKeyPress(Sender: TObject; var Key: Char);
begin

  case Key of
    chr(VK_RETURN):
      btnExeQueryClick(Sender);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  GetUninstallRegistrys(RegKVPairs);
  RefreshListViewShoW(lsvMainListShow, RegKVPairs)
end;

procedure TMainForm.lsvMainListShowColumnClick(Sender: TObject;
Column: TListColumn);
begin

  (Sender as TListView).CustomSort(nil, Column.Index);

  UseDescending := not UseDescending;

end;

procedure TMainForm.lsvMainListShowDblClick(Sender: TObject);
var
  showonlist: TList<string>;
  i: string;
begin
  with (Sender as TListView) do
  begin

    showonlist := TList<string>.Create;
    showonlist.add(Selected.Caption);

    for i in (Sender as TListView).Selected.SubItems do
      showonlist.add(i);

    with TdlgRegKeyInfos.Create(MainForm, //
      ['显示名', '发布者', '软件版本', '安装时间', '卸载字符串', '注册表路径'], //
      showonlist) do
      try
        ShowModal
      finally
        Free
      end;
  end;
end;

procedure TMainForm.chkHKCU_HKLM_Click(Sender: TObject);
var
  newRegKVPairs: TList<TregPair>;
begin

  if not chkRegHKCU.Checked and chkRegHKLM.Checked then
  begin
    FilterUninstallRegistrys(RegKVPairs, newRegKVPairs,
      function(x: TregPair): boolean
      begin
        if x['RegistryPath'].StartsWith('HKCU') then
          Result := false
        else
          Result := true;
      end);
    RefreshListViewShoW(lsvMainListShow, newRegKVPairs);
  end
  else if chkRegHKCU.Checked and not chkRegHKLM.Checked then
  begin
    FilterUninstallRegistrys(RegKVPairs, newRegKVPairs,
      function(x: TregPair): boolean
      begin
        if x['RegistryPath'].StartsWith('HKLM') then
          Result := false
        else
          Result := true;
      end);
    RefreshListViewShoW(lsvMainListShow, newRegKVPairs);
  end
  else if chkRegHKCU.Checked and chkRegHKLM.Checked then
    RefreshListViewShoW(lsvMainListShow, RegKVPairs)
  else
    lsvMainListShow.Clear;
end;

procedure TMainForm.lsvMainListShowCompare(Sender: TObject;
Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if Data = 0 then
    Compare := AnsiCompareText(Item1.Caption, Item2.Caption)
  else if Data <> 0 then
    Compare := AnsiCompareText(Item1.SubItems[Data - 1],
      Item2.SubItems[Data - 1]);

  if UseDescending then
    Compare := -Compare;
end;

end.
