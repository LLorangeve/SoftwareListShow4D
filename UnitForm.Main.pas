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
    btnExportCSV: TButton;
    dlgSaveExport: TSaveDialog;
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
    procedure btnExportCSVClick(Sender: TObject);
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
  SortColumn: Integer = -1;
  RegKVPairs: TList<TregPair>;
  RegKVPairsWhereShow: TList<TregPair>;

  { procedrue and function private on implementation }

function TestWinSysSw(x: TregPair): boolean;
begin
  if x['DisplayName'].StartsWith('vs_') //
    or x['DisplayName'].StartsWith('icecap_') //
    or x['DisplayName'].StartsWith('vcpp_') then
    Result := false
  else
    Result := true;
end;

function StdCSVFormat(aCSVItem: string): string;
begin
  Result := aCSVItem;

  if Pos('"', aCSVItem) > 0 then
    Result := Format('"%s"', [aCSVItem.Replace('"', '""')])
  else if Pos(',', aCSVItem) > 0 then
    Result := Format('"%s"', [aCSVItem]);
end;

procedure WriteCSVFile(FileName: string; aEncoding: TEncoding);
var
  fs: TFileStream;
  keyrec: TregPair;
  slbuf: TStringList;
  i: Integer;
begin

  slbuf := TStringList.Create;
  slbuf.Add(Format('%s,%s,%s,%s,%s', ['显示名', '发布者', '软件版本', '安装时间', '卸载字符串',
    '注册表路径']));

  for keyrec in RegKVPairs do
  begin
    slbuf.Add(Format('%s,%s,%s,%s,%s', [
      { } StdCSVFormat(keyrec['DisplayName']),
      { } StdCSVFormat(keyrec['Publisher']),
      { } StdCSVFormat(keyrec['DisplayVersion']),
      { } StdCSVFormat(keyrec['InstallDate']),
      { } StdCSVFormat(keyrec['UninstallString']),
      { } StdCSVFormat(keyrec['RegistryPath'])]));
  end;

  fs := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
  try
    slbuf.SaveToStream(fs, aEncoding);
  finally
    fs.Free;
  end;

  if FileExists(FileName) then
    ShowMessage('已保存')
  else
    ShowMessage('保存未成功，请重试');
end;

procedure GetUninstallRegistrys(out RegKVPairs: TList<TregPair>);
var

  RegKeyNames: TStringList;
  keyname, ragpath: string;
  keyrootI: HKEY;
  rgxMatchInstallDate: TRegEx;
  regkeyFInstallDate: string;
  regkeyFDisplayName: string;

  regKVPair: TDictionary<string, string>;
  ragpaths: array of string;
  regacc: HKEY;

begin
  ragpath := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';

  rgxMatchInstallDate := TRegEx.Create('((?:19|20)\d{2})(\d{2})(\d{2})');

  RegKeyNames := TStringList.Create;
  RegKVPairs := TList<TregPair>.Create;

  for keyrootI in [HKEY_LOCAL_MACHINE, HKEY_CURRENT_USER] do
    for regacc in [
    { 32位注册表 } KEY_READ or KEY_WOW64_32KEY or KEY_QUERY_VALUE,
    { 64位注册表 } KEY_READ or KEY_WOW64_64KEY or KEY_QUERY_VALUE] do
      with TRegistry.Create do
        try
          Access := regacc;
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
                { 显示名 } Add('DisplayName', ReadString('DisplayName'));
                { 发布者 } Add('Publisher', ReadString('Publisher'));
                { 软件版本 } Add('DisplayVersion', ReadString('DisplayVersion'));
                { 安装时间 } regkeyFInstallDate := ReadString('InstallDate').Trim;
                with rgxMatchInstallDate.Match(regkeyFInstallDate) do
                  if Success then
                    Add('InstallDate', Format('%s年%s月%s日', [
                      { 年 } Groups[1].Value,
                      { 月 } Groups[2].Value,
                      { 日 } Groups[3].Value]))
                  else
                    Add('InstallDate', regkeyFInstallDate);
                { 卸载字符串 } Add('UninstallString', ReadString('UninstallString'));
                { 注册表路径 }
                case keyrootI of
                  HKEY_CURRENT_USER:
                    Add('RegistryPath', Format('HKCU\%s\%s',
                      [ragpath, keyname]));
                  HKEY_LOCAL_MACHINE:
                    Add('RegistryPath', Format('HKLM\%s\%s',
                      [ragpath, keyname]));
                end;

              end;
              RegKVPairs.Add(regKVPair);
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
      newRegList.Add(regpair);
  end;
end;

procedure RefreshListViewShoW(aListView: TListView;
  RegKVPairs: TList<TregPair>);
var
  kvpair: TregPair;
  i: Integer;
begin
  UseDescending := false;
  aListView.Items.BeginUpdate;
  aListView.Clear;

  for kvpair in RegKVPairs do
    with aListView.Items.Add do
    begin
      Caption := kvpair['DisplayName'];
      SubItems.Add(kvpair['Publisher']);
      SubItems.Add(kvpair['DisplayVersion']);
      SubItems.Add(kvpair['InstallDate']);
      SubItems.Add(kvpair['UninstallString']);
      SubItems.Add(kvpair['RegistryPath']);
    end;

  aListView.Items.EndUpdate;
end;

procedure TMainForm.chkWinSysSwClick(Sender: TObject);
var
  oldRegKVPairs: TList<TregPair>;
  newRegKVPairs: TList<TregPair>;
begin
  if Trim(edtInput.Text).IsEmpty then
    oldRegKVPairs := RegKVPairs
  else
    FilterUninstallRegistrys(RegKVPairs, oldRegKVPairs,
      function(x: TregPair): boolean
      begin
        if x['DisplayName'].ToLower.Contains(LowerCase(edtInput.Text).Trim) then
          Result := true
        else
          Result := false
      end);

  with Sender as TCheckBox do
    if Checked then
    begin
      FilterUninstallRegistrys(oldRegKVPairs, newRegKVPairs, TestWinSysSw);
      RegKVPairsWhereShow := newRegKVPairs;
    end
    else
    begin
      newRegKVPairs := oldRegKVPairs;
      RegKVPairsWhereShow := RegKVPairs;
    end;

  if SortColumn <> -1 then
    lsvMainListShow.CustomSort(nil, SortColumn);

  if Assigned(newRegKVPairs) then
    RefreshListViewShoW(lsvMainListShow, newRegKVPairs);

  stuMainBar.SimpleText := Format('Total: %d', [lsvMainListShow.Items.Count]);
end;

procedure TMainForm.chkHKCU_HKLM_Click(Sender: TObject);
var
  oldRegKVPairs: TList<TregPair>;
  newRegKVPairs: TList<TregPair>;
begin
  newRegKVPairs := nil;
  if Trim(edtInput.Text).IsEmpty then
    oldRegKVPairs := RegKVPairs
  else
    FilterUninstallRegistrys(RegKVPairs, oldRegKVPairs,
      function(x: TregPair): boolean
      begin
        if x['DisplayName'].ToLower.Contains(LowerCase(edtInput.Text).Trim) then
          Result := true
        else
          Result := false
      end);

  if not chkRegHKCU.Checked and chkRegHKLM.Checked then
  begin
    FilterUninstallRegistrys(oldRegKVPairs, newRegKVPairs,
      function(x: TregPair): boolean
      begin
        if x['RegistryPath'].StartsWith('HKCU') then
          Result := false
        else
          Result := true;
      end);
    RegKVPairsWhereShow := newRegKVPairs;
  end
  else if chkRegHKCU.Checked and not chkRegHKLM.Checked then
  begin
    FilterUninstallRegistrys(oldRegKVPairs, newRegKVPairs,
      function(x: TregPair): boolean
      begin
        if x['RegistryPath'].StartsWith('HKLM') then
          Result := false
        else
          Result := true;
      end);
    RegKVPairsWhereShow := newRegKVPairs;
  end
  else if chkRegHKCU.Checked and chkRegHKLM.Checked then
  begin
    newRegKVPairs := oldRegKVPairs;
    RegKVPairsWhereShow := RegKVPairs;
  end
  else
    lsvMainListShow.Clear;

  if SortColumn <> -1 then
    lsvMainListShow.CustomSort(nil, SortColumn);

  if Assigned(newRegKVPairs) then
    RefreshListViewShoW(lsvMainListShow, newRegKVPairs);

  stuMainBar.SimpleText := Format('Total: %d', [lsvMainListShow.Items.Count]);
end;

procedure TMainForm.btnExeQueryClick(Sender: TObject);
var
  newRegKVPairs: TList<TregPair>;
begin
  if string(edtInput.Text).Trim.IsEmpty then
  begin
    RefreshListViewShoW(lsvMainListShow, RegKVPairsWhereShow);
    stuMainBar.SimpleText := Format('Total: %d', [lsvMainListShow.Items.Count]);
    exit;
  end;

  FilterUninstallRegistrys(RegKVPairsWhereShow, newRegKVPairs,
    function(x: TregPair): boolean
    begin
      if x['DisplayName'].ToLower.Contains(LowerCase(edtInput.Text).Trim) then
        Result := true
      else
        Result := false;
    end);

  if SortColumn <> -1 then
    lsvMainListShow.CustomSort(nil, SortColumn);

  RefreshListViewShoW(lsvMainListShow, newRegKVPairs);
  stuMainBar.SimpleText := Format('Total: %d', [lsvMainListShow.Items.Count]);
end;

procedure TMainForm.btnExportCSVClick(Sender: TObject);
begin
  if dlgSaveExport.Execute then

    case dlgSaveExport.FilterIndex of
      1:
        WriteCSVFile(dlgSaveExport.FileName, TEncoding.GetEncoding('GBK'));
      2:
        WriteCSVFile(dlgSaveExport.FileName, TEncoding.GetEncoding('UTF8'));
    end;
end;

procedure TMainForm.btnClearClick(Sender: TObject);
begin
  edtInput.Clear;
  RefreshListViewShoW(lsvMainListShow, RegKVPairsWhereShow);
  stuMainBar.SimpleText := Format('Total: %d', [RegKVPairsWhereShow.Count]);
end;

procedure TMainForm.edtInputKeyPress(Sender: TObject; var Key: Char);
begin

  case Key of
    chr(VK_RETURN):
      btnExeQueryClick(Sender);
  end;
end;

procedure TMainForm.lsvMainListShowColumnClick(Sender: TObject;
Column: TListColumn);
begin

  (Sender as TListView).CustomSort(nil, Column.Index);

  SortColumn := Column.Index;
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
    showonlist.Add(Selected.Caption);

    for i in (Sender as TListView).Selected.SubItems do
      showonlist.Add(i);

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

procedure TMainForm.FormCreate(Sender: TObject);
var
  newRegKVPairs: TList<TregPair>;
begin
  GetUninstallRegistrys(RegKVPairs);
  FilterUninstallRegistrys(RegKVPairs, newRegKVPairs, TestWinSysSw);
  RegKVPairsWhereShow := newRegKVPairs;
  RefreshListViewShoW(lsvMainListShow, RegKVPairsWhereShow);
  stuMainBar.SimpleText := Format('Total: %d', [lsvMainListShow.Items.Count]);
end;

end.
