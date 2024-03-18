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
    for regacc in [KEY_ALL_ACCESS or KEY_WOW64_32KEY, KEY_ALL_ACCESS or
      KEY_WOW64_64KEY] do
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
                // Assert(not ReadString('DisplayName').Contains('����'));
                { ��ʾ�� } add('DisplayName', ReadString('DisplayName'));
                { ������ } add('Publisher', ReadString('Publisher'));
                { ����汾 } add('DisplayVersion', ReadString('DisplayVersion'));
                { ��װʱ�� } regkeyFInstallDate := ReadString('InstallDate').Trim;
                with rgxMatchInstallDate.Match(regkeyFInstallDate) do
                  if Success then
                    add('InstallDate', Format('%s��%s��%s��', [
                      { �� } Groups[1].Value,
                      { �� } Groups[2].Value,
                      { �� } Groups[3].Value]))
                  else
                    add('InstallDate', regkeyFInstallDate);
                { ж���ַ��� } add('UninstallString', ReadString('UninstallString'));
                { ע���·�� }
                case keyrootI of
                  HKEY_CURRENT_USER:
                    add('RegistryPath', Format('HKCU\%s\%s',
                      [ragpath, keyname]));
                  HKEY_LOCAL_MACHINE:
                    add('RegistryPath', Format('HKLM\%s\%s',
                      [ragpath, keyname]));
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
  UseDescending := false;
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

  RefreshListViewShoW(lsvMainListShow, newRegKVPairs);
  if SortColumn <> -1 then
    lsvMainListShow.CustomSort(nil, SortColumn);
end;

procedure TMainForm.btnClearClick(Sender: TObject);
begin
  edtInput.Clear;
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
var
  newRegKVPairs: TList<TregPair>;
begin
  GetUninstallRegistrys(RegKVPairs);
  FilterUninstallRegistrys(RegKVPairs, newRegKVPairs, TestWinSysSw);
  RegKVPairsWhereShow := newRegKVPairs;
  RefreshListViewShoW(lsvMainListShow, RegKVPairsWhereShow);
  stuMainBar.SimpleText := Format('Total: %d', [lsvMainListShow.Items.Count]);
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
    showonlist.add(Selected.Caption);

    for i in (Sender as TListView).Selected.SubItems do
      showonlist.add(i);

    with TdlgRegKeyInfos.Create(MainForm, //
      ['��ʾ��', '������', '����汾', '��װʱ��', 'ж���ַ���', 'ע���·��'], //
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

end.
