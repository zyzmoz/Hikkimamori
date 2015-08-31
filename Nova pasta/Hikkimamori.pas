unit Hikkimamori;

interface

uses
  SysUtils, Classes;

type
  THPrint = class(TComponent)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Hikkimamori', [THPrint]);
end;

end.
