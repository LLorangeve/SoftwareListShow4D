unit UnitFrom.Dialog.RegKeyInfos;

interface

uses
  System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TdlgRegKeyInfos = class(TForm)
    ListView1: TListView;
    constructor Create(AOwner: TComponent; FieldNames: array of string;
      params: TList<string>);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgRegKeyInfos: TdlgRegKeyInfos;

implementation

{$R *.dfm}
{ TPos }
{ TdlgRegKeyInfos }

constructor TdlgRegKeyInfos.Create(AOwner: TComponent;
  FieldNames: array of string; params: TList<string>);
var
  i: integer;
begin
  inherited Create(AOwner);

  with AOwner as TForm do
  begin
    Self.Top := Top + (Height - Self.Height) div 2;
    Self.Left := Left + (Width - Self.Width) div 2;
  end;

  for i := Low(FieldNames) to High(FieldNames) do
    with ListView1.Items.Add do
    begin
      Caption := FieldNames[i];
      SubItems.Add(params[i]);
    end;

end;

end.
