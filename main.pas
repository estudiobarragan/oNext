unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, Menus, NextQueue, config, segundoform,Estadistica;

type

  { TfrAdmin }

  TfrAdmin = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    btAdd: TButton;
    btAviso: TButton;
    btStart: TButton;
    btStop: TButton;
    btReinicio: TButton;
    btExp: TButton;
    btMensaje: TButton;
    cbEstado: TCheckBox;
    cbMensaje: TComboBox;
    edMensaje: TEdit;
    edName: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    laMsg: TLabel;
    laExpSig: TLabel;
    laExpAct: TLabel;
    laTiempo: TLabel;
    laPte: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbProximo: TLabel;
    mConfig: TMenuItem;
    miEstadistica: TMenuItem;
    mhWhiteFlag: TMenuItem;
    mhVaciar: TMenuItem;
    mhBackup: TMenuItem;
    mMenu: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    mH: TMenuItem;
    mEnd: TMenuItem;
    mhReConfig: TMenuItem;
    mhOriginal: TMenuItem;
    mhOrdenada: TMenuItem;
    MenuItem6: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    rb3: TRadioButton;
    rb0: TRadioButton;
    rb1: TRadioButton;
    rb2: TRadioButton;
    rgIdioma: TRadioGroup;
    sbAddMsg: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    tbPausa: TToggleBox;
    procedure btAddClick(Sender: TObject);
    procedure btMensajeClick(Sender: TObject);
    procedure btMensajeKeyPress(Sender: TObject; var Key: char);
    procedure btMostrarClick(Sender: TObject);
    procedure btReinicioClick(Sender: TObject);
    procedure btAvisoClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btExpClick(Sender: TObject);
    procedure cbEstadoChange(Sender: TObject);
    procedure cbMensajeChange(Sender: TObject);
    procedure edMensajeClick(Sender: TObject);
    procedure edMensajeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edMensajeKeyPress(Sender: TObject; var Key: char);
    procedure edNameKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mConfigClick(Sender: TObject);
    procedure mEndClick(Sender: TObject);
    procedure miEstadisticaClick(Sender: TObject);
    procedure mhBackupClick(Sender: TObject);
    procedure mhReConfigClick(Sender: TObject);
    procedure mhOriginalClick(Sender: TObject);
    procedure mhOrdenadaClick(Sender: TObject);
    procedure mhVaciarClick(Sender: TObject);
    procedure mhWhiteFlagClick(Sender: TObject);
    procedure rb0Click(Sender: TObject);
    procedure sbAddMsgClick(Sender: TObject);
    procedure tbPausaChange(Sender: TObject);
    procedure TerminaReloj;
  private
    { private declarations }
    oF2: TfrProyec;      // Formulario a proyectar
    oFConf: TfrConfig;   // Formulario edicion parametros
    oFEstad: TfrEstadistica; // Formulario estadistico
    nTimeIni,nTimeFin:TDateTime;
    nNroReg:Integer;
    lNeedTra:Boolean;
    xL:Array [0..10] of String; // Lenguajes habilitados
    procedure laTiempoOnChanged(Sender:TObject);
    procedure laMensajeOnChanged(Sender:TObject);
  public
    { public declarations }
    oNext: TQueue;       // Objeto Cola
  end;

var
  frAdmin: TfrAdmin;

implementation

{$R *.lfm}

{ TfrAdmin }

procedure TfrAdmin.btAddClick(Sender: TObject);
var
  nI:integer;
  nLen:byte=0;
begin
  if (edName.Text>'') then
    begin
    nI:= rgIdioma.Tag;
    oNext.Put(uppercase(edName.Text), nI);

    mhOriginal.Click;
    mhOrdenada.Click;
    oF2.laPte.Caption:= IntToStr(oNext.ContarPte);
    laPte.Caption:=IntToStr(oNext.ContarPte);

    oF2.lbSiguiente.Caption:= oNext.Siguiente(nNroReg, nLen);
    laExpSig.Caption:=oNext.Siguiente(nNroReg, nLen)+' - '+xL[nLen];
    oF2.lbLenP.Caption:=xL[nLen];

    oF2.lbLenP.Caption:= xL[nLen];

    if  cbEstado.Checked then
      if oNext.ContarPte>0 then
        btAviso.enabled:= true;
    end;
  edName.Text:='';
  edName.SetFocus;
  rb0.Checked:= true;
  rgIdioma.Tag:=1;
end;

procedure TfrAdmin.btMensajeClick(Sender: TObject);
begin
  oF2.Mensaje(edMensaje.Text,oFConf.GetB('Habilita Blink'),
              oFConf.GetI('Tiempo_Blink'));
  laMsg.Caption:=edMensaje.Text;
end;

procedure TfrAdmin.btMensajeKeyPress(Sender: TObject; var Key: char);
begin
  if key=chr(13) then
    self.Click;
end;

procedure TfrAdmin.btMostrarClick(Sender: TObject);
var
  ResultList: TStringList;
begin
  ResultList:= TStringList.Create;
  oNext.ReadAll(ResultList);
  self.Memo1.Clear;
  self.Memo1.Lines.Add(ResultList.Text);
end;

procedure TfrAdmin.btReinicioClick(Sender: TObject);
begin
  if InputBox('Confirme Rinicio','Seguro que quiere reinicia?','SI')='SI' then
    begin
    tbPausa.Checked:=false;
    oF2.Reinicio;
    end;
end;

procedure TfrAdmin.btAvisoClick(Sender: TObject);
begin
  btExp.OnClick(sender);
  if oNext.ContarPte>0 then
    begin
    if lNeedTra then
      oF2.CargaTiempoMax(oFConf.GetI('Tiempo_Total')*oFConf.GetI('Factor_Traduccion'), cbEstado)
    else
      oF2.CargaTiempoMax(oFConf.GetI('Tiempo_Total'), cbEstado);

    btAviso.Enabled:=false;
    btStart.Enabled:=True;
    end
  else
    btAviso.Enabled:=false;
end;

procedure TfrAdmin.btStartClick(Sender: TObject);
begin
  nTimeIni:=now();
  oNext.exponiendo(nNroReg);
  cbEstado.Checked:=true;
  btStart.Enabled:=false;
  tbPausa.Enabled:=true;
  btStop.Enabled:=true;
  btReinicio.Enabled:=true;
  btAviso.Enabled:=false;
  oF2.Arranca;
end;



procedure TfrAdmin.btStopClick(Sender: TObject);
begin
  tbPausa.Checked:=false;
  oF2.Stop;
  cbEstado.Checked:=false;
end;

procedure TfrAdmin.btExpClick(Sender: TObject);
var
  cA,cP:string;
  nLen1:byte = 0;
  nLen2:byte = 0;
begin
  nNroReg:= oNext.ReadNP(cA,cP,nLen1, nLen2);
  oF2.laPte.Caption:=IntToStr(oNext.ContarPte);
  laPte.Caption:=IntToStr(oNext.ContarPte);
  oF2.lbActual.Caption:=uppercase(cA);
  laExpAct.Caption:=uppercase(cA)+' - '+xL[nLen1];
  oF2.lbLenA.Caption:= xL[nLen1];
  oF2.lbLenP.Caption:= xL[nLen2];
  oF2.nFracAmarillo:= oFConf.GetI('Tiempo_Amarillo');
  lbProximo.Caption:=cA;
  oF2.lbLenA.Caption:=xL[nLen1];
  oF2.lbLenP.Caption:=xL[nLen2];
  oF2.lbSiguiente.Caption:=uppercase(cP);
  laExpSig.Caption:=uppercase(cP)+' - '+xL[nLen2];
  {o: No definid 1: Español ambos sin traduccion}
  if (nLen1 = 0) or (nLen1=1) then
    lNeedTra:=False
  else
    lNeedTra:=True;

  if oNext.ContarPte>0 then
    btAviso.Enabled:=true;
end;

procedure TfrAdmin.cbEstadoChange(Sender: TObject);
begin
  if not cbEstado.Checked then
    TerminaReloj;
end;

procedure TfrAdmin.cbMensajeChange(Sender: TObject);
begin
  edMensaje.Text:= cbMensaje.Items[cbMensaje.ItemIndex];
  edMensaje.SetFocus;
end;

procedure TfrAdmin.TerminaReloj;
begin
  nTimeFin:=now();
  btStart.Enabled:=false;
  btStop.Enabled:=false;
  tbPausa.Enabled:=false;
  btReinicio.Enabled:=false;

  // Mancar get - Marca expositor y sigue
  oNext.GetFirst(nNroReg,nTimeIni,nTimeFin);
  mhOriginal.Click;
  mhOrdenada.Click;
  if oNext.ContarPte>0 then
    btAviso.Enabled:=true
  else
    btAviso.Enabled:=false;

end;

procedure TfrAdmin.edMensajeClick(Sender: TObject);
begin
  edMensaje.SelectAll;
end;

procedure TfrAdmin.edMensajeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key >=112) and (Key<= 119) then
    begin
    edMensaje.Text:=self.cbMensaje.Items[Key-112];
    btMensaje.SetFocus;
    end;
end;

procedure TfrAdmin.edMensajeKeyPress(Sender: TObject; var Key: char);
begin
  if Key=Char(13) then
    btMensaje.SetFocus;
end;

procedure TfrAdmin.edNameKeyPress(Sender: TObject; var Key: char);
begin
  if Key = Char(13) then
    btAdd.SetFocus;
end;

procedure TfrAdmin.FormActivate(Sender: TObject);
begin
 mhOriginal.Click;
 mhOrdenada.Click;
 if oNext.ContarPte>0 then
   btAviso.Enabled:=true;
 edName.Text:='';
 edName.SetFocus;
end;

procedure TfrAdmin.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=False;
  if InputBox('Confirme Reinicio','Seguro que quiere Terminar?','SI')='SI' then
    begin
    CanClose:=True;
    oNext.Destroy;
    end;
end;

procedure TfrAdmin.laTiempoOnChanged(Sender:TObject);
begin
  laTiempo.Caption:=oF2.laTiempo.Caption;
end;
procedure TfrAdmin.laMensajeOnChanged(Sender:TObject);
begin
  laMsg.Caption:=oF2.laMensaje.Caption;
end;
procedure TfrAdmin.FormCreate(Sender: TObject);
begin
  oNext := TQueue.Create;

  oF2 := TfrProyec.Create(self);
  oF2.ShowOnTop;
  oF2.laTiempo.OnChange:= @laTiempoOnChanged;
  oF2.laMensaje.OnChange:= @laMensajeOnChanged;

  oFEstad := TfrEstadistica.Create(self);
  oFEstad.CargaONext(oNext);

  oFConf := TfrConfig.Create(self);
  lbProximo.Caption:='';

  cbMensaje.Items.add('Hable mas Alto, por favor');
  cbMensaje.Items.add('Hable mas pausado, por favor');
  cbMensaje.Items.add('Su tiempo ha finalizado, gracias');
  cbMensaje.Items.add('Focalice en el tema definido, gracias');
  cbMensaje.Items.add('Acerque su boca al micrófono, gracias');
  cbMensaje.Items.add('Aleje su boca del micrófono, gracias');
  cbMensaje.Items.add('Muchas gracias');
  cbMensaje.Items.add('Puede comenzar, gracias');

  oNext.LenguajesActivos(xL);

  mH.Visible:= oFConf.GetB('Acceso Herramientas');
  oNext.PermitePendiente(oFConf.GetB('Pendiente'));
  oNext.PermiteSinPeso(oFConf.GetB('Con Peso'));

  rgIdioma.Tag:=1;

end;

procedure TfrAdmin.FormDestroy(Sender: TObject);
begin
  oF2.Free;
  oFConf.Destroy;
end;

procedure TfrAdmin.mConfigClick(Sender: TObject);
begin
  oFConf.ShowModal;
  mH.Visible:= oFConf.GetB('Acceso Herramientas');
  oNext.PermitePendiente(oFConf.GetB('Pendiente'));
  oNext.PermiteSinPeso(oFConf.GetB('Con Peso'));

end;

procedure TfrAdmin.mEndClick(Sender: TObject);
begin
  Close;
end;

procedure TfrAdmin.miEstadisticaClick(Sender: TObject);
begin
  oFEstad.ShowModal;
end;

procedure TfrAdmin.mhBackupClick(Sender: TObject);
begin
  oNext.BackupDatos;
end;

procedure TfrAdmin.mhReConfigClick(Sender: TObject);
begin
  oNext.ReConfig;
  mhOriginal.Click;
  mhOrdenada.Click;
end;

procedure TfrAdmin.mhOriginalClick(Sender: TObject);
var
  ResultList: TStringList;
begin
  ResultList:= TStringList.Create;
  oNext.ReadAll(ResultList);
  self.Memo1.Clear;
  self.Memo1.Lines.Add(ResultList.Text);

end;

procedure TfrAdmin.mhOrdenadaClick(Sender: TObject);
var
  ResultList: TStringList;
begin
  ResultList:= TStringList.Create;
  oNext.ReadAllOrder(ResultList);
  self.Memo2.Clear;
  self.Memo2.Lines.Add(ResultList.Text);
end;

procedure TfrAdmin.mhVaciarClick(Sender: TObject);
begin
  oNext.VaciarDatos;
  mhOriginal.Click;
  mhOrdenada.Click;
end;

procedure TfrAdmin.mhWhiteFlagClick(Sender: TObject);
begin
  oNext.QuitFlag;
  oNext.ReConfig;
  mhOriginal.Click;
  mhOrdenada.Click;
end;


procedure TfrAdmin.rb0Click(Sender: TObject);
begin
  rgIdioma.Tag := TRadioButton(Sender).Tag;
end;

procedure TfrAdmin.sbAddMsgClick(Sender: TObject);
var
  i:integer;
  lFound:Boolean;
begin
  i:=0;
  lfound :=false;
  while not lFound and (i<cbMensaje.Items.Count) do
    begin
    if edmensaje.Text=cbMensaje.Items[i] then
      lFound:=true;
    inc(i);
    end;
  if not lFound then
    cbMensaje.Items.Add(edmensaje.Text);
end;

procedure TfrAdmin.tbPausaChange(Sender: TObject);
begin
  oF2.Pausa;
end;

end.

