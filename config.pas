unit config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Spin, StdCtrls, IniFiles;

type

  { TfrConfig }

  TfrConfig = class(TForm)
    btActualiza: TButton;
    btCancela: TButton;
    cbConPeso: TCheckBox;
    cbBlink: TCheckBox;
    cbPendiente: TCheckBox;
    cbHerramientas: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    seTiempo: TSpinEdit;
    seTimAma: TSpinEdit;
    seTimTra: TSpinEdit;
    seTimBlink: TSpinEdit;
    procedure btActualizaClick(Sender: TObject);
    procedure btCancelaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { private declarations }
    INI: TIniFile;
    procedure LeerPropiedades;
    procedure GrabarPropiedades;
  public
    { public declarations }
    function GetI(AVar:string):integer;
    function GetB(AVar:string):boolean;
  end;

var
  frConfig: TfrConfig;

implementation

{$R *.lfm}
{ TfrConfig }
function TfrConfig.GetI(AVar:string):integer;
begin
  case AVAR of
    'Tiempo_Total': Result:= INI.ReadInteger('TIEMPOS',AVar,180);
    'Tiempo_Amarillo': Result:= INI.ReadInteger('TIEMPOS',AVar,33);
    'Factor_Traduccion' : Result:= INI.ReadInteger('TIEMPOS',AVar,2);
    'Tiempo_Blink' : Result:= INI.ReadInteger('TIEMPOS',AVar,5);
  end;
end;
function TfrConfig.GetB(Avar:string):boolean;
begin
  case Avar of
    'Con Peso': result := INI.ReadBool('GENERAL',AVar, TRUE);
    'Pendiente': result :=  INI.ReadBool('GENERAL',AVar, TRUE);
    'Acceso Herramientas': result := INI.ReadBool('GENERAL',AVar, FALSE);
    'Habilita Blink': result := INI.ReadBool('GENERAL',AVar, FALSE);
  end;
end;

procedure TfrConfig.LeerPropiedades;
begin
  seTiempo.Value:=INI.ReadInteger('TIEMPOS','Tiempo_Total',180);
  seTimAma.Value:=INI.ReadInteger('TIEMPOS','Tiempo_Amarillo',33);
  seTimTra.Value:=INI.ReadInteger('TIEMPOS','Factor_Traduccion',2);
  seTimBlink.Value :=INI.ReadInteger('TIEMPOS','Tiempo_Blink',5);
  cbConPeso.Checked:=INI.ReadBool('GENERAL','Con Peso', TRUE);
  cbPendiente.Checked:=INI.ReadBool('GENERAL','Pendiente', TRUE);
  cbHerramientas.Checked:=INI.ReadBool('GENERAL','Acceso Herramientas', FALSE);
  cbBlink.Checked:=INI.ReadBool('GENERAL','Habilita Blink', FALSE);
end;
procedure TfrConfig.GrabarPropiedades;
begin
  INI.WriteInteger('TIEMPOS','Tiempo_Total',seTiempo.Value);
  INI.WriteInteger('TIEMPOS','Tiempo_Amarillo',seTimAma.Value);
  INI.WriteInteger('TIEMPOS','Factor_Traduccion',seTimTra.Value);
  INI.WriteInteger('TIEMPOS','Tiempo_Blink',seTimBlink.Value);
  INI.WriteBool('GENERAL','Con Peso', cbConPeso.Checked);
  INI.WriteBool('GENERAL','Pendiente', cbPendiente.Checked);
  INI.WriteBool('GENERAL','Acceso Herramientas', cbHerramientas.Checked);
  INI.WriteBool('GENERAL','Habilita Blink', cbBlink.Checked);
end;

procedure TfrConfig.FormCreate(Sender: TObject);
begin
  INI := TIniFile.Create('NextQueue.cfg');
end;

procedure TfrConfig.FormActivate(Sender: TObject);
begin
  LeerPropiedades;
end;

procedure TfrConfig.btActualizaClick(Sender: TObject);
begin
  GrabarPropiedades;
  Close;
end;

procedure TfrConfig.btCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TfrConfig.FormDestroy(Sender: TObject);
begin
  INI.Free;
end;

end.

