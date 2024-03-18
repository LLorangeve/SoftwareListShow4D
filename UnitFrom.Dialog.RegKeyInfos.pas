unit UnitFrom.Dialog.RegKeyInfos;

interface

uses
  System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, Vcl.Clipbrd,
  System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus;

type
  TdlgRegKeyInfos = class(TForm)
    lsvMainKVShow: TListView;
    pupCopy: TPopupMenu;
    pupItemCopy: TMenuItem;
    constructor Create(AOwner: TComponent; FieldNames: array of string;
      params: TList<string>);
    procedure pupItemCopyClick(Sender: TObject);
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
    with lsvMainKVShow.Items.Add do
    begin
      Caption := FieldNames[i];
      SubItems.Add(params[i]);
    end;

end;

procedure TdlgRegKeyInfos.pupItemCopyClick(Sender: TObject);
begin

  with TClipboard.Create, Sender as TMenuItem do
    AsText := ((GetParentMenu as TPopupMenu).PopupComponent as TListView)
      .Selected.SubItems[0];

end;

end.
