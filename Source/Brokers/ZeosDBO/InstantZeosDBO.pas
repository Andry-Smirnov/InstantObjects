(*
 *   InstantObjects
 *   Zeos Database Objects Support
 *)

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is: InstantObjects ZeosDBO Support
 *
 * The Initial Developer of the Original Code is: Joao Morais
 *
 * Portions created by the Initial Developer are Copyright (C) 2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * Enrique Esquivel
 *
 * ***** END LICENSE BLOCK ***** *)

unit InstantZeosDBO;

{$IFDEF LINUX}
{$I '../../InstantDefines.inc'}
{$ELSE}
{$I '..\..\InstantDefines.inc'}
{$ENDIF}

// Supported databases

{$DEFINE SYBASE_SUPPORT}
{$DEFINE MSSQL_SUPPORT}
{$DEFINE IBFB_SUPPORT}
{$DEFINE ORACLE_SUPPORT}
{$DEFINE PGSQL_SUPPORT}
{$DEFINE MYSQL_SUPPORT}
{$DEFINE SQLITE_SUPPORT}

interface

uses
  Classes, Db, InstantPersistence, InstantCommand, ZConnection;

type
  TInstantZeosDBOConnectionDef = class(TInstantRelationalConnectionDef)
  private
    FDatabase: string;
    FHostName: string;
    FLoginPrompt: Boolean;
    FPassword: string;
    FPort: Integer;
    FProperties: string;
    FProtocol: string;
    FUseDelimitedIdents: Boolean;
    FUserName: string;
  protected
    procedure InitConnector(Connector: TInstantConnector); override;
  public
    function Edit: Boolean; override;
    class function ConnectionTypeName: string; override;
    class function ConnectorClass: TInstantConnectorClass; override;
  published
    property Database: string read FDatabase write FDatabase;
    property HostName: string read FHostName write FHostName;
    property LoginPrompt: Boolean read FLoginPrompt write FLoginPrompt;
    property Password: string read FPassword write FPassword;
    property Port: Integer read FPort write FPort;
    property Properties: string read FProperties write FProperties;
    property Protocol: string read FProtocol write FProtocol;
    property UseDelimitedIdents: Boolean read FUseDelimitedIdents write FUseDelimitedIdents;
    property UserName: string read FUserName write FUserName;
  end;

  TInstantZeosDBOConnector = class(TInstantRelationalConnector)
  private
    FConnection: TZConnection;
    FLoginPrompt: Boolean;
    FOnLogin: TLoginEvent;
    FUseDelimitedIdents: Boolean;
    procedure DoAfterConnectionChange;
    procedure DoBeforeConnectionChange;
    procedure SetConnection(Value: TZConnection);
    procedure SetLoginPrompt(const Value: Boolean);
    procedure SetUseDelimitedIdents(const Value: Boolean);
  protected
    procedure AfterConnectionChange; virtual;
    procedure BeforeConnectionChange; virtual;
    procedure AssignLoginOptions; virtual;
    procedure CheckConnection;
    function CreateBroker: TInstantBroker; override;
    function GetConnected: Boolean; override;
    procedure InternalBuildDatabase(Scheme: TInstantScheme); override;
    procedure InternalCommitTransaction; override;
    procedure InternalConnect; override;
    procedure InternalDisconnect; override;
    procedure InternalRollbackTransaction; override;
    procedure InternalStartTransaction; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function ParamByName(const AName: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    class function ConnectionDefClass: TInstantConnectionDefClass; override;
    function HasConnection: Boolean;
  published
    property Connection: TZConnection read FConnection write SetConnection;
    property LoginPrompt: Boolean read FLoginPrompt write SetLoginPrompt default False;
    property OnLogin: TLoginEvent read FOnLogin write FOnLogin;
    property UseDelimitedIdents: Boolean read FUseDelimitedIdents write SetUseDelimitedIdents default False;
  end;

  TInstantZeosDBOBroker = class(TInstantSQLBroker)
  private
    function GetConnector: TInstantZeosDBOConnector;
  protected
    procedure AssignDataSetParams(DataSet: TDataSet; AParams: TParams); override;
    procedure AssignParam(SourceParam, TargetParam: TParam); virtual;
    function CreateResolver(Map: TInstantAttributeMap): TInstantSQLResolver; override;
    function GetDatabaseName: string; override;
    function GetSQLDelimiters: string; override;
    function GetSQLQuote: Char; override;
    function InternalCreateQuery: TInstantQuery; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; virtual; abstract;
    function SupportsQuotedIdents: Boolean; virtual; abstract;
    function UseBooleanFields: Boolean; virtual; abstract;
  public
    function CreateDataSet(const AStatement: string; AParams: TParams = nil): TDataSet; override;
    function CreateDBBuildCommand(
      const CommandType: TInstantDBBuildCommandType): TInstantDBBuildCommand; override;
    function DataTypeToColumnType(DataType: TInstantDataType; Size: Integer): string; override;
    function Execute(const AStatement: string; AParams: TParams = nil): Integer; override;
    property Connector: TInstantZeosDBOConnector read GetConnector;
  end;

  TInstantZeosDBOResolver = class(TInstantSQLResolver)
  // Read an integer field and convert it to boolean expression
  protected
    function ReadBooleanField(DataSet: TDataSet; const FieldName: string): Boolean; override;
  end;

  TInstantZeosDBOTranslator = class(TInstantRelationalTranslator)
  // Translate boolean expressions to '0' or '1'
  protected
    function TranslateConstant(Constant: TInstantIQLConstant; Writer: TInstantIQLWriter): Boolean; override;
  end;

  TInstantZeosDBOQuery = class(TInstantSQLQuery)
  protected
    class function TranslatorClass: TInstantRelationalTranslatorClass; override;
  end;

  { Sybase broker }

  {$IFDEF SYBASE_SUPPORT}
  TInstantZeosDBOSybaseBroker = class(TInstantZeosDBOBroker)
  protected
    function GetDBMSName: string; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function SupportsQuotedIdents: Boolean; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { MS SQL Server broker }

  {$IFDEF MSSQL_SUPPORT}
  TInstantZeosDBOMSSQLBroker = class(TInstantZeosDBOBroker)
  protected
    function CreateCatalog(const AScheme: TInstantScheme): TInstantCatalog; override;
    function GetDBMSName: string; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function SupportsQuotedIdents: Boolean; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { Interbase and Firebird brokers }

  {$IFDEF IBFB_SUPPORT}
  TInstantZeosDBOIbFbBroker = class(TInstantZeosDBOBroker)
  protected
    function CreateCatalog(const AScheme: TInstantScheme): TInstantCatalog; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function SupportsQuotedIdents: Boolean; override;
    function UseBooleanFields: Boolean; override;
  end;

  TInstantZeosDBOInterbaseBroker = class(TInstantZeosDBOIbFbBroker)
  protected
    function GetDBMSName: string; override;
  end;

  TInstantZeosDBOFirebirdBroker = class(TInstantZeosDBOIbFbBroker)
  protected
    function GetDBMSName: string; override;
  end;
  {$ENDIF}

  { Oracle broker }

  {$IFDEF ORACLE_SUPPORT}
  TInstantZeosDBOOracleBroker = class(TInstantZeosDBOBroker)
  protected
    function GetDBMSName: string; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function SupportsQuotedIdents: Boolean; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { PostgreSQL broker }

  {$IFDEF PGSQL_SUPPORT}
  TInstantZeosDBOPgSQLBroker = class(TInstantZeosDBOBroker)
  protected
    function GetDBMSName: string; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function SupportsQuotedIdents: Boolean; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { MySQL broker }

  {$IFDEF MYSQL_SUPPORT}
  TInstantZeosDBOMySQLBroker = class(TInstantZeosDBOBroker)
  protected
    function GetDBMSName: string; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function SupportsQuotedIdents: Boolean; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  { SQLite broker }

  {$IFDEF SQLITE_SUPPORT}
  TInstantZeosDBOSQLiteBroker = class(TInstantZeosDBOBroker)
  protected
    function GetDBMSName: string; override;
    function InternalDataTypeToColumnType(DataType: TInstantDataType): string; override;
    function SupportsQuotedIdents: Boolean; override;
    function UseBooleanFields: Boolean; override;
  end;
  {$ENDIF}

  procedure AssignZeosDBOProtocols(Strings: TStrings);

implementation

uses
  SysUtils,
  {$IFDEF D7+}Types,{$ENDIF}
  Controls,
  InstantConsts,
  InstantClasses,
  InstantDBBuild,
  {$IFDEF IBFB_SUPPORT}InstantIbFbCatalog,{$ENDIF}
  {$IFDEF MSSQL_SUPPORT}InstantMSSQLCatalog,{$ENDIF}
  InstantZeosDBOConnectionDefEdit,
  InstantUtils,
  ZClasses,
  ZCompatibility,
  ZDbcIntfs,
  ZDataset;

{ Global routines }

procedure AssignZeosDBOProtocols(Strings: TStrings);
var
  i, j: Integer;
  Drivers: IZCollection;
  Protocols: TStringDynArray;
begin
  Strings.Clear;
  Drivers := DriverManager.GetDrivers;
  Protocols := nil;
  for i := 0 to Pred(Drivers.Count) do
  begin
    Protocols := (Drivers[i] as IZDriver).GetSupportedProtocols;
    for j := Low(Protocols) to High(Protocols) do
      Strings.Add(Protocols[j]);
  end;
end;

{ TInstantZeosDBOConnectionDef }

class function TInstantZeosDBOConnectionDef.ConnectionTypeName: string;
begin
  Result := 'ZeosDBO';
end;

class function TInstantZeosDBOConnectionDef.ConnectorClass: TInstantConnectorClass;
begin
  Result := TInstantZeosDBOConnector;
end;

function TInstantZeosDBOConnectionDef.Edit: Boolean;
begin
  with TInstantZeosDBOConnectionDefEditForm.Create(nil) do
  try
    LoadData(Self);
    Result := ShowModal = mrOk;
    if Result then
      SaveData(Self);
  finally
    Free;
  end;
end;

procedure TInstantZeosDBOConnectionDef.InitConnector(Connector: TInstantConnector);
var
  Connection: TZConnection;
begin
  inherited;
  Connection := TZConnection.Create(Connector);
  try
    (Connector as TInstantZeosDBOConnector).Connection := Connection;
    (Connector as TInstantZeosDBOConnector).LoginPrompt := LoginPrompt;
    (Connector as TInstantZeosDBOConnector).UseDelimitedIdents := UseDelimitedIdents;
    Connection.AutoCommit := False;
    Connection.Database := Database;
    Connection.HostName := HostName;
    Connection.Port := Port;
    Connection.Properties.Text := Properties;
    Connection.Protocol := Protocol;
    Connection.TransactIsolationLevel := tiReadCommitted;
    Connection.User := UserName;
    Connection.Password := Password;
  except
    Connection.Free;
    raise;
  end;
end;

{ TInstantZeosDBOConnector }

procedure TInstantZeosDBOConnector.AfterConnectionChange;
begin
  { TODO : Is it a good idea changes connection properties after assignment? }
  if HasConnection then
  begin
    FConnection.Connected := False;
    // We need to turn Auto Commit off and set ReadCommitted
    // Transaction Isolation Level
    FConnection.AutoCommit := False;
    FConnection.TransactIsolationLevel := tiReadCommitted;
  end;
end;

procedure TInstantZeosDBOConnector.AssignLoginOptions;
begin
  if HasConnection then
  begin
    Connection.LoginPrompt := FLoginPrompt;
    if Assigned(FOnLogin) and not Assigned(Connection.OnLogin) then
      Connection.OnLogin := FOnLogin;
  end;
end;

procedure TInstantZeosDBOConnector.BeforeConnectionChange;
begin
end;

procedure TInstantZeosDBOConnector.CheckConnection;
begin
  if not HasConnection then
    raise EInstantError.Create(SUnassignedConnection);
end;

class function TInstantZeosDBOConnector.ConnectionDefClass: TInstantConnectionDefClass;
begin
  Result := TInstantZeosDBOConnectionDef;
end;

constructor TInstantZeosDBOConnector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLoginPrompt := False;
  FUseDelimitedIdents := False;
end;

function TInstantZeosDBOConnector.CreateBroker: TInstantBroker;
begin
  CheckConnection;
  Result := nil;

  {$IFDEF SYBASE_SUPPORT}
  if SameText(Connection.Protocol, 'sybase') then
    Result := TInstantZeosDBOSybaseBroker.Create(Self);
  {$ENDIF}

  {$IFDEF MSSQL_SUPPORT}
  if SameText(Connection.Protocol, 'mssql') then
    Result := TInstantZeosDBOMSSQLBroker.Create(Self);
  {$ENDIF}

  {$IFDEF IBFB_SUPPORT}
  if SameText(Connection.Protocol, 'interbase-5') or
   SameText(Connection.Protocol, 'interbase-6') then
    Result := TInstantZeosDBOInterbaseBroker.Create(Self);

  if SameText(Connection.Protocol, 'firebird-1.0') or
   SameText(Connection.Protocol, 'firebird-1.5') then
    Result := TInstantZeosDBOFirebirdBroker.Create(Self);
  {$ENDIF}

  {$IFDEF ORACLE_SUPPORT}
  if SameText(Connection.Protocol, 'oracle') or
   SameText(Connection.Protocol, 'oracle-9i') then
    Result := TInstantZeosDBOOracleBroker.Create(Self);
  {$ENDIF}

  {$IFDEF PGSQL_SUPPORT}
  if SameText(Connection.Protocol, 'postgresql') or
   SameText(Connection.Protocol, 'postgresql-6.5') or
   SameText(Connection.Protocol, 'postgresql-7.2') or
   SameText(Connection.Protocol, 'postgresql-7.3') or
   SameText(Connection.Protocol, 'postgresql-7.4') then
    Result := TInstantZeosDBOPgSQLBroker.Create(Self);
  {$ENDIF}

  {$IFDEF MYSQL_SUPPORT}
  if SameText(Connection.Protocol, 'mysql') or
   SameText(Connection.Protocol, 'mysql-3.20') or
   SameText(Connection.Protocol, 'mysql-3.23') or
   SameText(Connection.Protocol, 'mysql-4.0') or
   SameText(Connection.Protocol, 'mysql-4.1') then
    Result := TInstantZeosDBOMySQLBroker.Create(Self);
  {$ENDIF}

  {$IFDEF SQLITE_SUPPORT}
  if SameText(Connection.Protocol, 'sqlite') or
   SameText(Connection.Protocol, 'sqlite-2.8') then
    Result := TInstantZeosDBOSQLiteBroker.Create(Self);
  {$ENDIF}

  if Result = nil then
    raise EInstantError.CreateFmt('ZeosDBO protocol "%s" not supported',
     [Connection.Protocol]);
end;

procedure TInstantZeosDBOConnector.DoAfterConnectionChange;
begin
  if HasConnection then
    FConnection.FreeNotification(Self);
  AfterConnectionChange;
end;

procedure TInstantZeosDBOConnector.DoBeforeConnectionChange;
begin
  try
    BeforeConnectionChange;
  finally
    if HasConnection then
      FConnection.RemoveFreeNotification(Self);
  end;
end;

function TInstantZeosDBOConnector.GetConnected: Boolean;
begin
  if HasConnection then
    Result := Connection.Connected
  else
    Result := inherited GetConnected;
end;

function TInstantZeosDBOConnector.HasConnection: Boolean;
begin
  Result := Assigned(FConnection);
end;

procedure TInstantZeosDBOConnector.InternalBuildDatabase(Scheme: TInstantScheme);
begin
  try
    inherited;
    CommitTransaction;
  except
    RollbackTransaction;
    raise;
  end;
end;

procedure TInstantZeosDBOConnector.InternalCommitTransaction;
begin
  if HasConnection and not Connection.AutoCommit then
    Connection.Commit;
end;

procedure TInstantZeosDBOConnector.InternalConnect;
begin
  CheckConnection;
  AssignLoginOptions;
  Connection.Connect;
end;

procedure TInstantZeosDBOConnector.InternalDisconnect;
begin
  if HasConnection then
    Connection.Disconnect;
end;

procedure TInstantZeosDBOConnector.InternalRollbackTransaction;
begin
  if HasConnection and not Connection.AutoCommit then
    Connection.Rollback;
end;

procedure TInstantZeosDBOConnector.InternalStartTransaction;
begin
  // ZeosDBO starts new transaction when necessary
end;

procedure TInstantZeosDBOConnector.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FConnection) and (Operation = opRemove) then
  begin
    Disconnect;
    FConnection := nil;
  end;
end;

function TInstantZeosDBOConnector.ParamByName(const AName: string): string;
begin
  { TODO : Check }
  Result := Connection.Properties.Values[AName];
end;

procedure TInstantZeosDBOConnector.SetConnection(Value: TZConnection);
begin
  if Value <> FConnection then
  begin
    Disconnect;
    DoBeforeConnectionChange;
    FConnection := Value;
    DoAfterConnectionChange;
  end;
end;

procedure TInstantZeosDBOConnector.SetLoginPrompt(const Value: Boolean);
begin
  FLoginPrompt := Value;
end;

procedure TInstantZeosDBOConnector.SetUseDelimitedIdents(const Value: Boolean);
begin
  FUseDelimitedIdents := Value;
end;

{ TInstantZeosDBOBroker }

procedure TInstantZeosDBOBroker.AssignDataSetParams(DataSet: TDataSet; AParams: TParams);
var
  i: Integer;
  TargetParams : TParams;
  SourceParam, TargetParam: TParam;
begin
  //don't call inherited
  TargetParams := (DataSet as TZReadOnlyQuery).Params;
  for i := 0 to Pred(AParams.Count) do
  begin
    SourceParam := AParams[i];
    TargetParam := TargetParams.FindParam(SourceParam.Name);
    if Assigned(TargetParam) then
      AssignParam(SourceParam, TargetParam);
  end;
end;

procedure TInstantZeosDBOBroker.AssignParam(SourceParam, TargetParam: TParam);
begin
  case SourceParam.DataType of
    ftBoolean:
      if UseBooleanFields then
        TargetParam.Assign(SourceParam)
      else
        TargetParam.AsInteger := Integer(SourceParam.AsBoolean);
    (*
    ftDateTime:
    begin
      TargetParam.DataType := ftTimeStamp;
      TargetParam.Value := SourceParam.AsDateTime;
    end;
    ftCurrency:
    begin
      TargetParam.DataType := ftBCD;
      TargetParam.Value := SourceParam.AsCurrency;
    end;
    *)
    else
      TargetParam.Assign(SourceParam);
  end;
end;

function TInstantZeosDBOBroker.CreateDataSet(const AStatement: string;
  AParams: TParams): TDataSet;
var
  Query: TZReadOnlyQuery;
begin
  Query := TZReadOnlyQuery.Create(nil);
  Query.Connection := Connector.Connection;
  Query.SQL.Text := AStatement;
  if Assigned(AParams) then
    AssignDatasetParams(Query, AParams);
  Result := Query;
end;

function TInstantZeosDBOBroker.CreateDBBuildCommand(
  const CommandType: TInstantDBBuildCommandType): TInstantDBBuildCommand;
begin
  if CommandType = ctAddTable then
    Result := TInstantDBBuildAddTableSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctDropTable then
    Result := TInstantDBBuildDropTableSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctAddField then
    Result := TInstantDBBuildAddFieldSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctAlterField then
    Result := TInstantDBBuildAlterFieldSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctDropField then
    Result := TInstantDBBuildDropFieldSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctAddIndex then
    Result := TInstantDBBuildAddIndexSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctAlterIndex then
    Result := TInstantDBBuildAlterIndexSQLCommand.Create(CommandType, Connector)
  else if CommandType = ctDropIndex then
    Result := TInstantDBBuildDropIndexSQLCommand.Create(CommandType, Connector)
  else
    Result := inherited CreateDBBuildCommand(CommandType);
end;

function TInstantZeosDBOBroker.CreateResolver(
  Map: TInstantAttributeMap): TInstantSQLResolver;
begin
  if UseBooleanFields then
    Result := TInstantSQLResolver.Create(Self, Map)
  else
    Result := TInstantZeosDBOResolver.Create(Self, Map);
end;

function TInstantZeosDBOBroker.DataTypeToColumnType(DataType: TInstantDataType;
  Size: Integer): string;
begin
  Result := InternalDataTypeToColumnType(DataType);
  if (DataType = dtString) and (Size > 0) then
    Result := Result + InstantEmbrace(IntToStr(Size), '()');
end;

function TInstantZeosDBOBroker.Execute(const AStatement: string;
  AParams: TParams): Integer;
var
  DataSet: TZReadOnlyQuery;
begin
  DataSet := AcquireDataSet(AStatement, AParams) as TZReadOnlyQuery;
  try
    DataSet.ExecSQL;
    Result := DataSet.RowsAffected;
  finally
    ReleaseDataSet(DataSet);
  end;
end;

function TInstantZeosDBOBroker.GetConnector: TInstantZeosDBOConnector;
begin
  Result := inherited Connector as TInstantZeosDBOConnector;
end;

function TInstantZeosDBOBroker.GetDatabaseName: string;
begin
  Result := Connector.Connection.Database;
end;

function TInstantZeosDBOBroker.GetSQLDelimiters: string;
begin
  // This method returns the delimiter that *will be* used and we are
  // changing its behavior (choosing if will be used or not), thus,
  // it'll only supports double quote for the time being
  { TODO : TInstantSQLBroker needs to know if I want to use Delimiters or not }
  if Connector.UseDelimitedIdents and SupportsQuotedIdents then
    Result := '""'
  else
    Result := ''; //inherited GetSQLDelimiters;
end;

function TInstantZeosDBOBroker.GetSQLQuote: Char;
begin
  { TODO : Check Oracle and SQLite compatibility. }
  Result := '''';
end;

function TInstantZeosDBOBroker.InternalCreateQuery: TInstantQuery;
begin
  if UseBooleanFields then
    Result := TInstantSQLQuery.Create(Connector)
  else
    Result := TInstantZeosDBOQuery.Create(Connector);
end;

{ TInstantZeosDBOResolver }

function TInstantZeosDBOResolver.ReadBooleanField(DataSet: TDataSet;
  const FieldName: string): Boolean;
begin
  Result := Boolean(DataSet.FieldByName(FieldName).AsInteger);
end;

{ TInstantZeosDBOTranslator }

function TInstantZeosDBOTranslator.TranslateConstant(
  Constant: TInstantIQLConstant; Writer: TInstantIQLWriter): Boolean;
begin
  if SameText(Constant.Value, InstantTrueString) then
  begin
    Writer.WriteChar('1');
    Result := True;
  end else if SameText(Constant.Value, InstantFalseString) then
  begin
    Writer.WriteChar('0');
    Result := True;
  end else
    Result := inherited TranslateConstant(Constant, Writer);
end;

{ TInstantZeosDBOQuery }

class function TInstantZeosDBOQuery.TranslatorClass: TInstantRelationalTranslatorClass;
begin
  Result := TInstantZeosDBOTranslator;
end;

{ TInstantZeosDBOSybaseBroker }

{$IFDEF SYBASE_SUPPORT}
function TInstantZeosDBOSybaseBroker.GetDBMSName: string;
begin
  Result := 'Sybase';
end;

function TInstantZeosDBOSybaseBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'DOUBLE PRECISION',
    'MONEY',
    'TINYINT',
    'VARCHAR',
    'TEXT',
    'DATETIME',
    'IMAGE');
begin
  Result := Types[DataType];
end;

function TInstantZeosDBOSybaseBroker.SupportsQuotedIdents: Boolean;
begin
  // Sybase needs a "SET quoted_identifier ON" before first statement using
  // Quoted Identifier
  Result := False;
end;

function TInstantZeosDBOSybaseBroker.UseBooleanFields: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TInstantZeosDBOMSSQLBroker }

{$IFDEF MSSQL_SUPPORT}
function TInstantZeosDBOMSSQLBroker.CreateCatalog(
  const AScheme: TInstantScheme): TInstantCatalog;
begin
  Result := TInstantMSSQLCatalog.Create(AScheme, Self);
end;

function TInstantZeosDBOMSSQLBroker.GetDBMSName: string;
begin
  Result := 'MS SQL Server';
end;

function TInstantZeosDBOMSSQLBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT',
    'MONEY',
    'BIT',
    'VARCHAR',
    'TEXT',
    'DATETIME',
    'IMAGE');
begin
  Result := Types[DataType];
end;

function TInstantZeosDBOMSSQLBroker.SupportsQuotedIdents: Boolean;
begin
  { TODO : Check }
  Result := False;
end;

function TInstantZeosDBOMSSQLBroker.UseBooleanFields: Boolean;
begin
  Result := True;
end;
{$ENDIF}

{ TInstantZeosDBOIbFbBroker }

{$IFDEF IBFB_SUPPORT}
function TInstantZeosDBOIbFbBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'DOUBLE PRECISION',
    'DECIMAL(14,4)',
    'SMALLINT',
    'VARCHAR',
    'BLOB SUB_TYPE 1',
    'TIMESTAMP',
    'BLOB');
begin
  Result := Types[DataType];
end;

function TInstantZeosDBOIbFbBroker.CreateCatalog(
  const AScheme: TInstantScheme): TInstantCatalog;
begin
  Result := TInstantIbFbCatalog.Create(AScheme, Self);
end;

function TInstantZeosDBOIbFbBroker.SupportsQuotedIdents: Boolean;
begin
  Result := True;
end;

function TInstantZeosDBOIbFbBroker.UseBooleanFields: Boolean;
begin
  Result := False;
end;

{ TInstantZeosDBOInterbaseBroker }

function TInstantZeosDBOInterbaseBroker.GetDBMSName: string;
begin
  Result := 'Interbase';
end;

{ TInstantZeosDBOFirebirdBroker }

function TInstantZeosDBOFirebirdBroker.GetDBMSName: string;
begin
  Result := 'Firebird';
end;
{$ENDIF}

{ TInstantZeosDBOOracleBroker }

{$IFDEF ORACLE_SUPPORT}
function TInstantZeosDBOOracleBroker.GetDBMSName: string;
begin
  Result := 'Oracle';
end;

function TInstantZeosDBOOracleBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
(*
const
  //dtInteger, dtFloat, dtCurrency, dtBoolean, dtString, dtMemo, dtDateTime, dtBlob
  Types: array[TInstantDataType] of string = (
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');
*)
begin
  //Result := Types[DataType];
  { TODO : Implement }
  raise EInstantError.Create('Oracle protocol not implemented yet');
end;

function TInstantZeosDBOOracleBroker.SupportsQuotedIdents: Boolean;
begin
  { TODO : Chech }
  Result := False;
end;

function TInstantZeosDBOOracleBroker.UseBooleanFields: Boolean;
begin
  { TODO : Check }
  Result := False;
end;
{$ENDIF}

{ TInstantZeosDBOPgSQLBroker }

{$IFDEF PGSQL_SUPPORT}
function TInstantZeosDBOPgSQLBroker.GetDBMSName: string;
begin
  Result := 'PostgreSQL';
end;

function TInstantZeosDBOPgSQLBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT8',
    'DECIMAL(14,4)',
    'BOOLEAN',
    'VARCHAR',
    'TEXT',
    'TIMESTAMP',
    'BYTEA');
begin
  Result := Types[DataType];
end;

function TInstantZeosDBOPgSQLBroker.SupportsQuotedIdents: Boolean;
begin
  Result := True;
end;

function TInstantZeosDBOPgSQLBroker.UseBooleanFields: Boolean;
begin
  Result := True;
end;
{$ENDIF}

{ TInstantZeosDBOMySQLBroker }

{$IFDEF MYSQL_SUPPORT}
function TInstantZeosDBOMySQLBroker.GetDBMSName: string;
begin
  Result := 'MySQL';
end;

function TInstantZeosDBOMySQLBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT',
    'DECIMAL(14,4)',
    'TINYINT(1)',
    'VARCHAR',
    'TEXT',
    'DATETIME',
    'BLOB');
begin
  Result := Types[DataType];
end;

function TInstantZeosDBOMySQLBroker.SupportsQuotedIdents: Boolean;
begin
  { TODO : Check }
  Result := False;
end;

function TInstantZeosDBOMySQLBroker.UseBooleanFields: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TInstantZeosDBOSQLiteBroker }

{$IFDEF SQLITE_SUPPORT}
function TInstantZeosDBOSQLiteBroker.GetDBMSName: string;
begin
  Result := 'SQLite';
end;

function TInstantZeosDBOSQLiteBroker.InternalDataTypeToColumnType(
  DataType: TInstantDataType): string;
const
  Types: array[TInstantDataType] of string = (
    'INTEGER',
    'FLOAT',
    'NUMERIC(14,4)',
    'BOOLEAN',
    'VARCHAR',
    'TEXT',
    'TIMESTAMP',
    'BLOB');
begin
  Result := Types[DataType];
end;

function TInstantZeosDBOSQLiteBroker.SupportsQuotedIdents: Boolean;
begin
  { TODO : Check }
  Result := False;
end;

function TInstantZeosDBOSQLiteBroker.UseBooleanFields: Boolean;
begin
  Result := True;
end;
{$ENDIF}

initialization
  RegisterClass(TInstantZeosDBOConnectionDef);
  TInstantZeosDBOConnector.RegisterClass;

finalization
  TInstantZeosDBOConnector.UnregisterClass;

end.
