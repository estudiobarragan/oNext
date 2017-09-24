unit SegundoForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,  LResources;

type
  {TMiLabel}
  TMILabel = Class(TLabel)
    private
    FOnChange: TNotifyEvent;
    function GetCaption: string;
    procedure SetCaption(const Value: string);
  published
    { Published declarations }
    property Caption: string read GetCaption write SetCaption;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  { TfrProyec }
  TfrProyec = class(TForm)
    laTiempo: TMiLabel;
    laMensaje:TMiLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    laPte: TLabel;
    lbActual: TLabel;
    lbLenA: TLabel;
    lbLenP: TLabel;
    lbSiguiente: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    spA: TShape;
    spR: TShape;
    spV: TShape;
    Timer1: TTimer;
    tiBlink: TTimer;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tiBlinkTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Arranca;
    procedure Pausa;
    procedure Stop;
    procedure Reinicio;
    procedure CargaTiempoMax(AMaxT:Integer; ABotton: TObject);
    Procedure Mensaje(AMsg: String; Ablink:Boolean; ATime:Integer);
  private
    { private declarations }
    obtPadre: TCheckBox;
    nBlink:Integer;
    lBlink:Boolean;

  public
    { public declarations }
    MaxT:integer;
    nTime:integer;
    lStop:Boolean;
    nFracAmarillo: integer;
  end;

var
  frProyec: TfrProyec;

implementation

{$R *.lfm}
{ TSampleLabel }
function TMILabel.GetCaption: string;
begin
  result := inherited Caption;
end;
procedure TMILabel.SetCaption(const Value: string);
var
  Str : string;
begin
  Str := inherited Caption;
  if Value <> Str then begin
    inherited Caption := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
    end;

end;
{ TfrProyec }
procedure TfrProyec.Mensaje(AMsg: String;Ablink:Boolean;ATime:Integer);
Begin
  laMensaje.Visible:=false;
  laMensaje.Caption:=AMsg;
  lBlink:=Ablink;
  nBlink:=ATime*2;
  tiBlink.Enabled:=true;
  laMensaje.Visible:=true;
end;

procedure TfrProyec.tiBlinkTimer(Sender: TObject);
begin
  if lBlink then
    laMensaje.Visible:=not laMensaje.Visible;
  dec(nBlink);
  if nBlink=0 then
    begin
    laMensaje.Visible:=false;
    laMensaje.Caption:='';
    tiBlink.Enabled:=false;
    end;
end;
procedure TfrProyec.Reinicio;
begin
  Timer1.Enabled:= false;
  nTime:= MaxT;
  spR.Visible:=False;
  spA.Visible:=False;
  spV.Visible:=true;
  Arranca;
end;

procedure TfrProyec.CargaTiempoMax(AMaxT:Integer ; ABotton:TObject);
begin
  obtPadre := TCheckBox(ABotton);
  MaxT := AMaxT;
  nTime:= AMaxT;
  spR.Visible:=False;

  laTiempo.Visible:=False;
  laTiempo.Caption:='¡Atención!';
  laTiempo.Font.Color:=clblack;
  laTiempo.Visible:=True;
end;

procedure TfrProyec.Arranca;
begin
  spV.Visible:=true;
  lStop:=False;
  Timer1.Enabled:= True;
end;
procedure TfrProyec.Pausa;
begin
  Timer1.Enabled:= Not Timer1.Enabled;
end;
procedure TfrProyec.Stop;
begin
  lSTop := True;
end;

procedure TfrProyec.Timer1Timer(Sender: TObject);
begin
  if lStop then
    nTime :=0;
  laTiempo.Caption := Format('%d',[nTime]);
  Dec(nTime);
  if nTime/MaxT <nFracAmarillo/100 then
    begin
    spA.Visible:=True;
    spV.Visible:=False;
    end;
  if (nTime < 0) then
    begin
    Timer1.Enabled := False;
    laTiempo.font.Color:=clyellow;
    laTiempo.Caption := 'Gracias';
    spR.Visible:=true;
    spA.Visible:=False;
    obtPadre.Checked:= false;
    end;
end;

procedure TfrProyec.FormCreate(Sender: TObject);
begin
  lbSiguiente.Caption:='';
  lbActual.Caption:='';
  lbLenA.Caption:='';
  lbLenP.Caption:='';

  {laTiempo inicializacion}
  laTiempo := TMiLabel.Create(nil);
  laTiempo.Parent:= Panel4;
  laTiempo.top:=370;
  laTiempo.Left:=371;
  laTiempo.Height := 78;
  laTiempo.Width := 359;
  laTiempo.Caption := '¡Atención!';
  laTiempo.Visible:=false;
  laTiempo.Alignment:=taCenter;
  laTiempo.AutoSize:=false;
  laTiempo.AnchorSideLeft.Control := Panel4;
  laTiempo.AnchorSideLeft.Side := asrCenter;
  laTiempo.AnchorSideTop.Control := Panel4;
  laTiempo.AnchorSideTop.Side := asrCenter;
  laTiempo.Font.Height := -64;
  laTiempo.Font.Name := 'Century Gothic';
  laTiempo.Font.Pitch := fpVariable;
  laTiempo.Font.Quality := fqDraft;
  laTiempo.ParentColor := False;
  laTiempo.ParentFont := False;

  {laMensaje inicializacion}
  laMensaje := TMiLabel.Create(nil);
  laMensaje.Parent:= Panel3;
  laMensaje.top:=67;
  laMensaje.Left:=1;
  laMensaje.Height := 44;
  laMensaje.Width := 1101;
  laMensaje.Align := alBottom;
  laMensaje.Caption := 'Expositor' ;
  laMensaje.Visible:=false;
  laMensaje.Alignment:=taCenter;
  laMensaje.AutoSize:=true;
  laMensaje.Font.Color:= clRed;
  laMensaje.Font.Height := -37;
  laMensaje.Font.Name := 'Century Gothic';
  laMensaje.Font.Pitch := fpVariable;
  laMensaje.Font.Quality := fqDraft;
  laMensaje.ParentColor := False;
  laMensaje.ParentFont := False;
end;


procedure TfrProyec.FormActivate(Sender: TObject);
begin
  laTiempo.Visible:= false;
  laPte.Caption:='';
  Timer1.Enabled:=false;
  nTime:=MaxT;
  lStop:=False;
end;


end.

