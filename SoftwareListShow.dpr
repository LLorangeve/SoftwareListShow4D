program SoftwareListShow;

uses
  Vcl.Forms,
  UnitForm.Main in 'UnitForm.Main.pas' {MainForm},
  UnitFrom.Dialog.RegKeyInfos in 'UnitFrom.Dialog.RegKeyInfos.pas' {dlgRegKeyInfos};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
