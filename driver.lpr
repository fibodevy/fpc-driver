library driver;

uses native;

type
  _UNICODE_STRING = packed record
    Length, MaximumLength: word;
    {$ifdef CPU64}
    _paddding: dword;
    {$endif}
    Buffer: PWideChar;
  end;
  UNICODE_STRING = _UNICODE_STRING;
  PUNICODE_STRING = ^_UNICODE_STRING;

  _DRIVER_OBJECT = packed record
    Typ: SmallInt;
    Size: SmallInt;
    {$ifdef CPU64}
    _padding: DWord;
    {$endif}
    DeviceObject: Pointer; // _DEVICE_OBJECT*
    Flags: DWord;
    {$ifdef CPU64}
    _padding2: DWord;
    {$endif}
    DriverStart: Pointer;
    DriverSize: DWord;
    {$ifdef CPU64}
    _padding3: DWord;
    {$endif}
    DriverSection: Pointer;
    DriverExtension: Pointer; // _DRIVER_EXTENSION*
    DriverName: _UNICODE_STRING;
    HardwareDatabase: PUNICODE_STRING;
    FastIoDispatch: Pointer; // _FAST_IO_DISPATCH*
    DriverInit: Pointer; // func
    DriverStartIo: Pointer; //func
    DriverUnload: Pointer; //func
    MajorFunction: array[0..27-1] of Pointer; // func
  end;
  DRIVER_OBJECT = _DRIVER_OBJECT;
  PDRIVER_OBJECT = ^_DRIVER_OBJECT;

const
  ntoskrnl = 'ntoskrnl.exe';

function DbgPrint(aFormat: PAnsiChar): Integer; cdecl; varargs; external ntoskrnl;
function DbgPrintEx(ComponentId: Integer; Level: Integer; Format: PAnsiChar): Integer; cdecl; external ntoskrnl;

procedure DriverUnload(DriverObject: PDRIVER_OBJECT); stdcall;
begin
  DbgPrint('[fpcd] DriverUnload'+LineEnding);
end;

begin
  DbgPrint(LineEnding);
  DbgPrint('[fpcd] Hello World! Windows Kernel Mode Driver in FPC'+LineEnding);
  DbgPrint('[fpcd] Build time  = '+{$I %DATE%}+' '+{$I %TIME%}+LineEnding);
  DbgPrint('[fpcd] FPC version = '+{$I %FPCVERSION%}+LineEnding);
  DbgPrint('[fpcd] FPC target  = '+{$I %FPCTARGET%}+LineEnding);
  DbgPrint(LineEnding);

  PDRIVER_OBJECT(SysDriverObject)^.DriverUnload := @DriverUnload;

  DbgPrint('[fpcd] End of DriverEntry'+LineEnding);
  DbgPrint(LineEnding);

  ExitCode := STATUS_SUCCESS;
end.

