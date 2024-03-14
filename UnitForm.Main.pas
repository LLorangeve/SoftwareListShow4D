unit UnitForm.Main;

interface

uses
  System.Generics.Collections,
  System.RegularExpressions,
  System.Win.Registry, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants,
  System.Classes, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
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
    procedure FormCreate(Sender: TObject);
    procedure lsvMainListShowDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

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
            with lsvMainListShow.Items.Add do
            begin
              regkeyFDisplayName := ReadString('DisplayName');
              if regkeyFDisplayName.Trim = string.Empty then
                continue;
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

      finally
        CloseKey;
        Free;
      end;

  // InputBox('标题', '提示信息', '默认值');
  // ShowMessage(output);
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
