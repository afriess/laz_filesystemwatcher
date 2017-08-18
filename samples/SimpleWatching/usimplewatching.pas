unit uSimpleWatching;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, SHChangeNotify;

type

  { TFormSimpleWatching }

  TFormSimpleWatching = class(TForm)
    BuClear: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    SHChangeNotify1: TSHChangeNotify;
    procedure BuClearClick(Sender: TObject);
    procedure SHChangeNotify1Create(Sender: TObject; Flags: cardinal;
      Path1: string);
    procedure SHChangeNotify1Delete(Sender: TObject; Flags: cardinal;
      Path1: string);
    procedure SHChangeNotify1MkDir(Sender: TObject; Flags: cardinal;
      Path1: string);
    procedure SHChangeNotify1RenameItem(Sender: TObject; Flags: cardinal;
      Path1, Path2: string);
    procedure SHChangeNotify1RmDir(Sender: TObject; Flags: cardinal;
      Path1: string);
  private

  public

  end;

var
  FormSimpleWatching: TFormSimpleWatching;

implementation

{$R *.lfm}

{ TFormSimpleWatching }

procedure TFormSimpleWatching.SHChangeNotify1Create(Sender: TObject;
  Flags: cardinal; Path1: string);
begin
  Memo1.lines.add('Item created: ' + Path1);
end;

procedure TFormSimpleWatching.BuClearClick(Sender: TObject);
begin
  SHChangeNotify1.Stop;
  Memo1.Clear;
  SHChangeNotify1.Execute;
end;

procedure TFormSimpleWatching.SHChangeNotify1Delete(Sender: TObject;
  Flags: cardinal; Path1: string);
begin
  Memo1.lines.add('Item deleted: ' + Path1);
end;

procedure TFormSimpleWatching.SHChangeNotify1MkDir(Sender: TObject;
  Flags: cardinal; Path1: string);
begin
  Memo1.lines.add('Folder created: ' + Path1);
end;

procedure TFormSimpleWatching.SHChangeNotify1RenameItem(Sender: TObject;
  Flags: cardinal; Path1, Path2: string);
begin
  Memo1.lines.add('Item renamed from ' + Path1);
  Memo1.lines.add('to ' + Path2);
end;

procedure TFormSimpleWatching.SHChangeNotify1RmDir(Sender: TObject;
  Flags: cardinal; Path1: string);
begin
  Memo1.lines.add('Directory removed: ' + Path1);
end;

end.

