unit oConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles;
type
  { TConfig }
  TConfig = class
    private
      INI: TIniFile;

      {variables privadas}
    public
      constructor Create(cFileName:string);
      destructor Destroy; override;
      function Get(ASeccion,AKey:String; var AValue: String):String;
      // function Get(ASeccion,AKey:String; var AValue: String):Integer; override;
      // function Get(ASeccion,AKey:String; var AValue: String):Boolean; override;
  end;
implementation
{TConfig}
function TConfig.Get(ASeccion,AKey:String; var AValue: String):String;
begin
  result := INI.ReadString(ASeccion,AKey,AValue);
end;

constructor TConfig.Create(cFileName:string);
begin
  INI := TIniFile.Create(cFileName);
end;
destructor TConfig.Destroy;
begin
  INI.Free;
end;
end.

