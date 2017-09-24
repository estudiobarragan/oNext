unit Estadistica;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, ComCtrls, Grids, IniPropStorage, StdCtrls, ExtCtrls,NextQueue, TACustomSeries;

type

  { TfrEstadistica }

  TfrEstadistica = class(TForm)
    cGraf1: TChart;
    Chart1: TChart;
    Chart2: TChart;
    sBarras: TBarSeries;
    sBarras2: TBarSeries;
    sConstante: TConstantLine;
    sPie: TPieSeries;
    ImageList1: TImageList;
    ipsFormStorage: TIniPropStorage;
    pcStat: TPageControl;
    rb1: TRadioButton;
    rb2: TRadioButton;
    rb3: TRadioButton;
    rgUnidades: TRadioGroup;
    StatusBar1: TStatusBar;
    sgDatos: TStringGrid;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    tsGraf3: TTabSheet;
    tsGraf2: TTabSheet;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    tsDatos: TTabSheet;
    tsGraf1: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rb1Change(Sender: TObject);
    procedure sgDatosPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);

    procedure ToolButton1Click(Sender: TObject);
    procedure CargaONext(AoNext: TQueue);
    procedure CargaGrilla;
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
  private
    { private declarations }
    oNext: TQueue;
    nFac: Integer;
    procedure DibujaTortaLenguaje;
    procedure DibujaTiempoPromedio;
    procedure DibujaTiempoTotal;
  public
    { public declarations }
  end;

var
  frEstadistica: TfrEstadistica;

implementation

{$R *.lfm}

{ TfrEstadistica }
procedure TfrEstadistica.CargaGrilla;
var
  i,j:Integer;
begin
  oNext.CargaMatrizEstad;
  for i:=0 to length(oNext.xEstad)-1 do
    for j:=0 to length(oNext.xEstad[i])-1 do
      case i of
        0: sgDatos.Cells[j+1,i+1]:= IntToStr(Round(oNext.xEstad[i][j]/1));
      else
        case nFac of
        1: sgDatos.Cells[j+1,i+1]:= IntToStr(Round(oNext.xEstad[i][j]/nFac))+'"';
        60: sgDatos.Cells[j+1,i+1]:= IntToStr(Round(oNext.xEstad[i][j]/nFac))+'''';
        else
          sgDatos.Cells[j+1,i+1]:= IntToStr(Round(oNext.xEstad[i][j]/nFac))+'h';
        end;
      end;
end;

procedure TfrEstadistica.ToolButton3Click(Sender: TObject);
begin
  pcStat.ActivePage:=tsDatos;
end;

procedure TfrEstadistica.ToolButton5Click(Sender: TObject);
begin
  DibujaTortaLenguaje;
end;

procedure TfrEstadistica.ToolButton7Click(Sender: TObject);
begin
  DibujaTiempoPromedio;
end;

procedure TfrEstadistica.ToolButton9Click(Sender: TObject);
begin
  DibujaTiempoTotal;
end;

procedure TfrEstadistica.DibujaTortaLenguaje;
var
  i:integer;
begin
  pcStat.ActivePage:=tsGraf1;
  tsGraf1.Visible:=false;
  sPie.Clear;
  for i:=1 to sgDatos.ColCount-2 do
    begin
    sPie.Add(StrToInt(sgDatos.Cells[i,1]),sgDatos.Cells[i,0],clBlue);
    end;
  tsGraf1.Visible:=true;
end;

procedure TfrEstadistica.DibujaTiempoPromedio;
var
  i:integer;
begin
  pcStat.ActivePage:=tsGraf2;
  tsGraf2.Visible:=false;
  sBarras.Clear;
  for i:=1 to sgDatos.ColCount-2 do
    begin
    sBarras.Add(Round(oNext.xEstad[1][i-1]/nFac),sgDatos.Cells[i,0],clRed);
    end;
  sConstante.Position:=Round(oNext.xEstad[1][sgDatos.ColCount-2]/nFac);

  if nFac=1 then
    Chart1.Foot.Text.Text :='Tiempo promedio en Segundos'
  else
    begin
    if nFac=60 then
      Chart1.Foot.Text.Text:='Tiempo promedio en Minutos'
    else
      Chart1.Foot.Text.Text:='Tiempo promedio en Horas'
    end;
  tsGraf2.Visible:=true;
end;

procedure TfrEstadistica.DibujaTiempoTotal;
var
  i:integer;
begin
  pcStat.ActivePage:=tsGraf3;
  tsGraf3.Visible:=false;
  sBarras2.Clear;
  for i:=1 to sgDatos.ColCount-2 do
    begin
    sBarras2.Add(Round(oNext.xEstad[2][i-1]/nFac),sgDatos.Cells[i,0],clRed);
    end;

  if nFac=1 then
    Chart2.Foot.Text.Text :='Tiempo Total en Segundos'
  else
    begin
    if nFac=60 then
      Chart2.Foot.Text.Text:='Tiempo Total en Minutos'
    else
      Chart2.Foot.Text.Text:='Tiempo Total en Horas'
    end;
  tsGraf3.Visible:=true;

end;

procedure TfrEstadistica.CargaONext(AoNext:TQueue);
begin
  oNext:= AoNext;
end;

procedure TfrEstadistica.FormActivate(Sender: TObject);
begin
  nFac := rgUnidades.Tag;
  if nFac=1 then
    rb1.Checked:=true
  else
    if nFac=60 then
      rb2.Checked:=true
    else
      rb3.Checked:=true;
  pcStat.ActivePage:=tsDatos;
  CargaGrilla;
end;

procedure TfrEstadistica.FormCreate(Sender: TObject);
begin
  ipsFormStorage.Restore;
end;

procedure TfrEstadistica.rb1Change(Sender: TObject);
begin
  nFac := TRadioButton(Sender).Tag;
  rgUnidades.Tag:= nFac;
  CargaGrilla;
end;



procedure TfrEstadistica.sgDatosPrepareCanvas(sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
var
  MyTextStyle: TTextStyle;
begin
  if aCol>=1 then
  begin
    MyTextStyle := sgDatos.Canvas.TextStyle;
    MyTextStyle.Alignment := taCenter;
    sgDatos.Canvas.TextStyle := MyTextStyle;
  end;
end;




procedure TfrEstadistica.ToolButton1Click(Sender: TObject);
begin
  ipsFormStorage.Save;
  Close;
end;


end.

