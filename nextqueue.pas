unit NextQueue;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,math;
type
  {TQFile}
  TQFile = record
    Id: word;
    DHc: TDateTime;
    DHi: TDateTime;
    DHf: TDateTime;
    Nombre: string[100];
    Idioma: byte; //0:nada 1:SPA 2:BR 3:ENG 4:OTR
    Peso: byte;
    Pesos2:byte;
    Next: word;
    Fin: Boolean;
  end;

type
  { TQueue }
  TQueue = class
    private
      fTQF: file of TQFile;
      lPermitePte: Boolean;
      lSinPeso:Boolean;
      xP: array [1 .. 2] of array[0 .. 99] of word;
      xLang: array[0..4] of string;
    public
      xEstad: array[0..3] of array [0..4] of integer;
      constructor Create;
      destructor Destroy; override;
      function PermitePendiente(Permite:Boolean = true):Boolean;
      function PermiteSinPeso(APermite:Boolean = false):Boolean;
      function Put(AValue: string; ALen:byte): Integer; // Grava el anotado
      function ReAparece(AValue: String):Integer; // no anotado 255 vuelve a aparecer
      function ReadAll(var ResultList: TStringList):Boolean; // Vuelve todo
      function Pesar(ANom:String; APos:Integer):Integer; // Pesaje
      function ReConfig:Boolean;
      function ReIndex:Boolean;
      function ReadAllOrder(var ResultList: TStringList):Boolean; // Vuelve todo Ordenado
      function ReadNP(var ANext, AProx:string; var ALen1,ALen2:byte):Integer;
      function GetFirst(AReg:Integer;ATIni,ATFin: TDateTime):Boolean;
      function ContarPte: Integer; //Cuenta pendientes
      function BackupDatos:Boolean;
      function QuitFlag:Boolean;
      function LenguajesActivos(var ALen:Array of String):Boolean;
      function Siguiente(AReg:Integer; var ALen:byte):string;
      procedure Exponiendo(AReg:Integer);
      procedure VaciarDatos;
      procedure CargaMatrizEstad;
  end;


implementation
{ TQueue }
procedure TQueue.CargaMatrizEstad;
var
  i,j:integer;
  Reg: TQFile;
  tP: Integer =999999;
  tF: Integer =0;
begin

  for i:=0 to Length(xEstad)-1 do
    for j:=0 to Length(xEstad[i])-1 do
      xEstad[i][j]:=0;
  Reset(fTQF);

  while not Eof(fTQF) do
    begin
    Read(fTQF, Reg);
    if Reg.Fin then
      begin
      case reg.Idioma of
        1..3: begin
              inc(xEstad[0][reg.Idioma-1]);
              xEstad[2][reg.Idioma-1]:= xEstad[2][reg.Idioma-1]+ Round(frac(Reg.DHf-Reg.DHi)*24*60*60);
              end;
      else
        begin
        inc(xEstad[0][3]);
        xEstad[2][reg.Idioma-1]:= xEstad[2][reg.Idioma-1]+ Round(frac(Reg.DHf-Reg.DHi)*24*60*60);
        end;
      end;
      tP:= Min(tP, Round(frac(Reg.DHc)*24*60*60));
      tF:= Max(tF, Round(frac(Reg.DHf)*24*60*60));
      inc(xEstad[0][4]);
      xEstad[2][4]:=xEstad[2][4]+Round(frac(Reg.DHf-Reg.DHi)*24*60*60);
      end;

    end;
    for j:=0 to Length(xEstad[0])-1 do
      begin
      if xEstad[0][j]=0 then
        xEstad[1][j]:=0
      else
        xEstad[1][j]:=Round(xEstad[2][j]/xEstad[0][j]);
      end;
    // Tiempo Total de uso
    xEstad[3][4]:= tF-tP;
    for j:=0 to Length(xEstad[0])-2 do
      begin
      xEstad[3][j]:=xEstad[3][4]-xEstad[2][j];
      end;
    xEstad[3][4]:=xEstad[3][4]-xEstad[2][4];

end;



function TQueue.LenguajesActivos(var ALen:Array of String):Boolean;
var
  i:byte;
begin
  // SetLength(ALen,3);
  for i:=0 to length(xLang)-1 do
    Alen[i] :=xLang[i];
  Result:=true;
end;

function TQueue.QuitFlag:Boolean;
var
  Reg: TQFile;
begin
  Result:= False;
  Reset(fTQF);
  while not Eof(fTQF) do
    begin
    Read(fTQF, Reg);
    Reg.Fin:=false;
    Reg.DHc:=0;
    Reg.DHf:=0;
    Reg.DHi:=0;
    Seek(fTQF,Reg.Id-1);
    Write(fTQF,Reg);
    end;
  Result:=true;
end;
procedure TQueue.exponiendo(AReg:Integer);
var
  Reg: TQFile;
begin
  Reset(fTQF);
  Seek(fTQF, AReg);
  Read(fTQF, Reg);
  Reg.Pesos2:=Reg.Peso;
  Reg.Peso :=0;
  Seek(fTQF, AReg);
  write(fTQF,Reg);
end;
function TQueue.Siguiente(AReg:Integer; var ALen:byte):string;
var
  Reg: TQFile;
begin
  Result:= '';
  Reset(fTQF);
  if FileSize(fTQF)>1 then
    begin
    Seek(fTQF, AReg);
    Read(fTQF, Reg);
    if Reg.Next>0 then
      begin
      Seek(fTQF,Reg.Next-1);
      Read(fTQF, Reg);
      Result:= Reg.Nombre;
      ALen := Reg.Idioma;
      end
    else
      begin
      Result :=' ANOTARSE EN LA LISTA ';
      ALen:=0;
      end
    end
  else
    begin
      Result :=' ANOTARSE EN LA LISTA '
    end;
end;

function TQueue.GetFirst(AReg:Integer;ATIni,ATFin: TDateTime):Boolean;
var
  Reg: TQFile;
begin
  Result:= False;
  Reset(fTQF);
  Seek(fTQF, AReg);
  Read(fTQF, Reg);

  Reg.Fin := True;
  Reg.DHi:=ATIni;
  Reg.DHf:=ATFin;
  Reg.Peso:=Reg.Pesos2;
  Reg.Pesos2:=0;
  Seek(fTQF,AReg);
  Write(fTQF,Reg);
  if not lPermitePte then
    ReAparece(Reg.Nombre);
end;

function TQueue.ReadNP(var ANext, AProx:string; var ALen1,ALen2:byte):Integer;
var
  Reg: TQFile;
  lFin: Boolean;
begin
  ANext := '';
  aProx:= '';
  lFin := False;
  Result:= 0;
  if FileSize(fTQF)>0 then
    begin
    Reset(fTQF);
    while (not lFin) do    //
      begin
      Read(fTQF, Reg);

      if not Reg.Fin then
        begin
        ANext:=Reg.Nombre;
        ALen1 :=Reg.Idioma;
        Result:=Reg.Id-1;
        while (not lFin) do
          begin
          if Reg.Next =0 then
            lFin:=True
          else
            begin
            Seek(fTQF,Reg.Next-1);
            Read(fTQF,Reg);
            if not Reg.Fin then
              begin
              AProx:=Reg.Nombre;
              ALen2 :=Reg.Idioma;
              lFin:=True;
              end;
            end;
          end;
        end
      else
        if Reg.Next =0 then
          lFin:=True
        else
          Seek(fTQF,Reg.Next-1);

      end;
    end;

  if ANext='' then ANext := ' ANOTARSE EN LA LISTA ';
  if AProx='' then AProx := ' ANOTARSE EN LA LISTA ';
end;
function TQueue.ContarPte:Integer;
var
  Reg: TQFile;
  lFin: Boolean;
begin
  Result:=0;
  lFin := False;
  Reset(fTQF);
  while not Eof(fTQF) and (not lFin) do
    begin
    Read(fTQF, Reg);
    if not Reg.Fin then
      Inc(Result);
    if Reg.Next=0 then
      lFin:=true
    else
      Seek(fTQF,Reg.Next-1);
    end;
end;

function TQueue.ReadAllOrder(var ResultList: TStringList):Boolean;
var
  Reg: TQFile;
  lFin: Boolean;
begin
  lFin := False;
  ResultList.Clear;
  Result:= False;
  Reset(fTQF);
  while not Eof(fTQF) and (not lFin) do
    begin
    Read(fTQF, Reg);
    if not Reg.Fin then
      ResultList.Add(IntToStr(Reg.Id) + ' : ' + Reg.Nombre + ' : ' +
             IntToStr(Reg.Peso) + ' : ' + xLang[Reg.Idioma]+ ' : ' +
             IntToStr(Reg.Next));
    if Reg.Next = 0 then
      lFin := true
    else
      Seek(fTQF,Reg.Next-1);

    end;
  Result:= True;
end;

function TQueue.Reindex:Boolean;
var
  i:Integer;
  nId: word;
  nPeso:byte;
  Reg,RegP: TQFile;
begin
  for i:=0 to 99 do begin
    xP[1][i]:= 0;
    xP[2][i]:= 0;
  end;
  Result:= false;
  Reset(fTQF);
  for i:=0 to  FileSize(fTQF)-1 do
    begin
      Seek(fTQF,i);
      Read(fTQF,Reg);
      nId := Reg.Id;
      nPeso := Reg.Peso;
      if Reg.Peso<255 then
        begin;
        Reg.Next := xP[1][nPeso+1];
        {if xP[nPeso]=word(0) and nPeso=0 then  No hacer nada;}

        if (xP[2][nPeso]>0) or (nPeso>0) then
          if xP[2][nPeso]>0 then
            begin
            Seek(fTQF,xP[2][nPeso]-1);
            Read(fTQF,RegP);
            RegP.Next:=nId;
            Seek(fTQF,xP[2][nPeso]-1);
            Write(fTQF,RegP);
            end
          else
            begin
            Seek(fTQF,xP[2][nPeso-1]-1);
            Read(fTQF,RegP);
            RegP.Next:=nId;
            Seek(fTQF,xP[2][nPeso-1]-1);
            Write(fTQF,RegP);
            end;

        if xP[2][nPeso]=0 then
          xP[1][nPeso]:=nId;

        xP[2][nPeso]:=nId;
        end
      else
        Reg.Next:=0;

      Seek(fTQF,i);
      Write(fTQF,Reg);
    end;

end;
function TQueue.ReConfig:Boolean;
var
  i:Integer;
  Reg: TQFile;
begin
  Result:= false;
  Reset(fTQF);
  for i:=0 to  FileSize(fTQF)-1 do
    begin
    Seek(fTQF,i);
    Read(fTQF,Reg);
    Reg.Peso:= Pesar(Reg.Nombre,i);
    Seek(fTQF,i);
    write(fTQF,Reg);
    end;
  Result:=true;
  self.ReIndex;
end;

function TQueue.Pesar(ANom:String; APos:Integer):Integer;
var
  j:integer;
  Reg: TQFile;
begin

  Result:= 0;
  if lSinPeso then
    begin
    Reset(fTQF);
    for j:=0 to APos-1 do
      begin
      Seek(fTQF,j);
      Read(fTQF, Reg);
      if ANom=Reg.Nombre then
        if (not lPermitePte) and (not Reg.Fin) then
          begin
          Result:=255;
          break;
          end
        else
          inc(Result);

      end;
    end;
end;

function TQueue.PermitePendiente(Permite:Boolean = true):Boolean;
begin
  lPermitePte :=Permite;
  Result := lPermitePte;
end;
function TQueue.PermiteSinPeso(APermite:Boolean = false):Boolean;
begin
  lSinPeso:=APermite;
  Result := lSinPeso;
end;

function TQueue.ReadAll(var ResultList: TStringList):Boolean;
var
  i:Integer;
  sFin:string;
  Reg: TQFile;
begin
  ResultList.Clear;
  Result:= False;
  Reset(fTQF);
  for i:=0 to fileSize(fTQF)-1 do
    begin
    Read(fTQF, Reg);
    sFin:='OPEN';
    if Reg.Fin then
      sFin :='FIN';
    ResultList.Add(IntToStr(Reg.Id) + ' : ' + Reg.Nombre + ' : ' +
             IntToStr(Reg.Peso) + ' : ' + xLang[Reg.Idioma]+ ' : ' +
             IntToStr(Reg.Next)+ ' : ' +sFin);
    Result:= True;
    end;
end;
function TQueue.ReAparece(AValue: String):Integer;
var
  nPeso:Integer;
  nId:word;
  Reg: TQFile;
begin
  Result:=0;
  nID:=0;
  Reset(fTQF);
  while not eof(fTQF) do
    begin
    read(fTQF,Reg);
    if (Reg.Nombre=AValue) and (not Reg.Fin) and (Reg.Peso=255) then
      begin
        Reg.Peso:=0;
        Seek(fTQF,Reg.Id-1);
        write(fTQF,Reg);
        nId:=Reg.Id;
        Result:=nId;
        nPeso:= Pesar(Avalue,nId-1);
        Seek(fTQF,nId-1);
        Reg.Peso:= nPeso;
        Seek(fTQF,Reg.Id-1);
        write(fTQF,Reg);
        Reindex;
        break;
      end;
    end;
end;

function TQueue.Put(AValue: string; ALen:byte):Integer;
var
  nPeso:Integer;
  Reg: TQFile;
begin
  nPeso:= Pesar(Avalue,FileSize(fTQF));

  Seek(fTQF, FileSize(fTQF)); // Ir hasta el último registro
  Reg.Id:=FileSize(fTQF)+1; // Colocar el ultimo mas 1
  Reg.DHc:=Now; // Hora y Fecha de carga
  Reg.Next:= 0; // proximo, buscar en indice
  Reg.Nombre:= Avalue; // Nombre
  Reg.Idioma:=ALen; // Lengua (0:SPA 1:BR 2:ENG
  Reg.Peso:= nPeso; // Buscar peso
  Reg.Pesos2:=0;
  Reg.Fin:=false; // Pasa a True cuando habla.
  write(fTQF, Reg);

  Result := Reg.Id;
  if Reg.Peso <> 255 then
    ReIndex;
end;
function TQueue.BackupDatos:Boolean;
var
  Reg: TQFile;
  fRB: file of TQFile;
begin
  Result := False;
  AssignFile(fRB, 'NextQueue.bak');
  Rewrite(fRB);
  Seek(fTQF,0);
  while not Eof(fTQF) do
    begin
      Read(fTQF,Reg);
      Write(fRB,Reg);
    end;
  Closefile(fRB);
  Result:=True;
end;

procedure TQueue.VaciarDatos;
begin
  Closefile(fTQF);
  AssignFile(fTQF, 'NextQueue.dat');
  // Archivo no encontrado, crearlo
  Rewrite(fTQF);
end;

constructor TQueue.Create;
begin
  lPermitePte:= true;
  lSinPeso:=false;
  xLang[0]:='';
  xLang[1]:='SPA';
  xLang[2]:='BR';
  xLang[3]:='ENG';
  xLang[4]:='OTR';
  AssignFile(fTQF, 'NextQueue.dat');
  if FileExists('NextQueue.dat') then
    begin
    FileMode:= 2; // Poner en modo lectura/escritura
    Reset(fTQF); // Abrir archivo
    Seek(fTQF, FileSize(fTQF)); // Ir hasta el último registro
    end
  else // Archivo no encontrado, crearlo
    Rewrite(fTQF);

end;

destructor TQueue.Destroy;
begin
  CloseFile(fTQF); // Cierra el archivo
  inherited Destroy;
end;



end.

