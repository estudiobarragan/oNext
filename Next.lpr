program Next;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, main, SegundoForm, config, Estadistica;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrAdmin, frAdmin);
  Application.CreateForm(TfrProyec, frProyec);
  Application.CreateForm(TfrConfig, frConfig);
  Application.CreateForm(TfrEstadistica, frEstadistica);
  Application.Run;
end.

