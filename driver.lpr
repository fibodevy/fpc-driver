library driver;

uses native;

var
  API_DEVICE_NAME: PWideChar = '\Device\fpcd';
  API_LINK_NAME: PWideChar = '\DosDevices\fpcd';
  ApiDevice: PDEVICE_OBJECT = nil;

function IrpDispatchDone(Irp: PIRP; status: NTSTATUS; info: NativeUInt = 0): NTSTATUS;
begin
  Irp^.IoStatus.union.Status := status;
  Irp^.IoStatus.Information := info;
  IoCompleteRequest(Irp, IO_NO_INCREMENT);
  result := status;
end;

function OnOther(DeviceObject: PDEVICE_OBJECT; Irp: PIRP): LONG; stdcall;
begin
  DbgPrint('[fpcd] OnOther');
  result := IrpDispatchDone(irp, STATUS_INVALID_DEVICE_REQUEST);
end;

function CreateApiDevice(DriverObject: PDRIVER_OBJECT): NTSTATUS;
var
  devname, linkname: UNICODE_STRING;
  devobj: PDEVICE_OBJECT;
begin
  DbgPrint('[fpcd] CreateApiDevice'+CRLF);

  RtlInitUnicodeString(@devname, API_DEVICE_NAME);
  result := IoCreateDevice(DriverObject, 0, @devname, FILE_DEVICE_UNKNOWN, 0, false, devobj);
  DbgPrint('[fpcd] IoCreateDevice result = %p'+CRLF, result);
  if not NT_SUCCESS(result) then begin
    DbgPrint('[fpcd] CreateApiDevice: IoCreateDevice failed'+CRLF);
    exit;
  end;

  RtlInitUnicodeString(@linkname, API_LINK_NAME);
  result := IoCreateSymbolicLink(@linkname, @devname);
  DbgPrint('[fpcd] IoCreateSymbolicLink result = %p'+CRLF, result);
  if not NT_SUCCESS(result) then begin
    DbgPrint('[fpcd] CreateApiDevice: IoCreateSymbolicLink failed'+CRLF);
    IoDeleteDevice(devobj);
    exit;
  end;

  DbgPrint('[fpcd] CreateApiDevice: device created'+CRLF);
  ApiDevice := devobj;
  result := STATUS_SUCCESS;
end;

function OnDevCreate(DeviceObject: PDEVICE_OBJECT; Irp: PIRP): LONG; stdcall;
begin
  DbgPrint('[fpcd] OnDevCreate');
  result := IrpDispatchDone(Irp, STATUS_SUCCESS);
end;

function OnDevClose(DeviceObject: PDEVICE_OBJECT; Irp: PIRP): LONG; stdcall;
begin
  DbgPrint('[fpcd] OnDevClose');
  result := IrpDispatchDone(Irp, STATUS_SUCCESS);
end;

function CTL_CODE(DeviceType, FunctionCode, Method, Access: DWORD): DWORD; inline;
begin
  result := (DeviceType shl 16) or (Access shl 14) or (FunctionCode shl 2) or Method;
end;

function IOCTL_PING: DWORD;
begin
  result := CTL_CODE(FILE_DEVICE_UNKNOWN, 555, METHOD_BUFFERED, FILE_ANY_ACCESS);
end;

function OnDeviceControl(DeviceObject: PDEVICE_OBJECT; Irp: PIRP): LONG; stdcall;
var
  sl: PIO_STACK_LOCATION;
  bufin, bufout: pbyte;
  bufinlen, bufoutlen, icc: dword;
begin
  DbgPrint('[fpcd] OnDeviceControl');
  DbgPrint('[fpcd] OnDeviceControl Irp = %p | Type = %d | Size = %d', Irp, Irp^.union.Typ, Irp^.union.Size);

  sl := IoGetCurrentIrpStackLocation(Irp);
  DbgPrint('[fpcd] OnDeviceControl stack = %p', sl);
  DbgPrint('[fpcd] OnDeviceControl stack Major = %d | Minor = %d | Flags = %d | Control = %d', sl^.u.MajorFunction, sl^.u.MinorFunction, sl^.u.Flags, sl^.u.Control);
  DbgPrint('[fpcd] OnDeviceControl stack IoControlCode    = %d', sl^.Parameters.DeviceIoControl.IoControlCode);
  DbgPrint('[fpcd] OnDeviceControl stack Type3InputBuffer = %d', sl^.Parameters.DeviceIoControl.Type3InputBuffer);

  bufin := Irp^.AssociatedIrp.SystemBuffer;
  bufinlen := sl^.Parameters.DeviceIoControl.InputBufferLength;
  DbgPrint('[fpcd] OnDeviceControl bufin  = %p | len = %d', bufin, bufinlen);
  bufout := IrpUserBuffer(Irp);
  bufoutlen := sl^.Parameters.DeviceIoControl.OutputBufferLength;
  DbgPrint('[fpcd] OnDeviceControl bufout = %p | len = %d', bufout, bufoutlen);

  icc := sl^.Parameters.DeviceIoControl.IoControlCode;
  if icc = IOCTL_PING then begin
    // @@todo: should check if bufin/out belongs to the process?
    if (bufin = nil) or (bufinlen <> 8) or (bufout = nil) or (bufoutlen <> 4) then begin
      DbgPrint('[fpcd] IOCTL_PING invalid buffer');
      // @@todo: cant use try-finally yet (Error: Unknown compilerproc "_fpc_local_unwind")
      exit(IrpDispatchDone(Irp, STATUS_INVALID_PARAMETER));
    end;
    DbgPrint('[fpcd] IOCTL_PING a = %d | b = %d | UserBuffer = %p', pdword(bufin)^, pdword(bufin+4)^, bufout);
    pdword(bufout)^ := pdword(bufin)^+pdword(bufin+4)^;
    // weird, it copies this amount of bytes from input to output?
    // lets just return .Information = 0 for now
    //exit(IrpDispatchDone(Irp, STATUS_SUCCESS, 4));
    result := STATUS_SUCCESS;
  end else
    result := STATUS_INVALID_PARAMETER;

  result := IrpDispatchDone(Irp, result);
end;

procedure DestroyApiDevice({%H-}DriverObject: PDRIVER_OBJECT);
var
  linkname: UNICODE_STRING;
begin
  DbgPrint('[fpcd] DestroyApiDevice'+CRLF);
  if ApiDevice = nil then begin
    DbgPrint('[fpcd] DestroyApiDevice: ApiDevice is nil'+CRLF);
    exit;
  end;
  RtlInitUnicodeString(@linkname, API_LINK_NAME);
  IoDeleteSymbolicLink(@linkname);
  IoDeleteDevice(ApiDevice);
  ApiDevice := nil;
end;

procedure DriverUnload(DriverObject: PDRIVER_OBJECT); stdcall;
begin
  DbgPrint('[fpcd] DriverUnload'+CRLF);
  DestroyApiDevice(DriverObject);
end;

function {%H-}DriverEntry(DriverObject: PDRIVER_OBJECT; RegistryPath: PUNICODE_STRING): LongInt; stdcall; public name 'DriverEntry';
var
  i: integer;
begin
  DbgPrint(CRLF);
  DbgPrint('[fpcd] Hello World! Windows Kernel Mode Driver in FPC'+CRLF);
  DbgPrint('[fpcd] Build time  = '+{$I %DATE%}+' '+{$I %TIME%}+CRLF);
  DbgPrint('[fpcd] FPC version = '+{$I %FPCVERSION%}+CRLF);
  DbgPrint('[fpcd] FPC target  = '+{$I %FPCTARGET%}+CRLF);
  DbgPrint(CRLF);

  for i := 0 to high(DriverObject^.MajorFunction) do
    DriverObject^.MajorFunction[i] := @OnOther;

  DriverObject^.MajorFunction[IRP_MJ_CREATE] := @OnDevCreate;
  DriverObject^.MajorFunction[IRP_MJ_CLOSE] := @OnDevClose;
  DriverObject^.MajorFunction[IRP_MJ_DEVICE_CONTROL] := @OnDeviceControl;

  DriverObject^.DriverUnload := @DriverUnload;

  result := CreateApiDevice(DriverObject);

  DbgPrint('[fpcd] End of DriverEntry'+CRLF);
  DbgPrint(CRLF);
end;

end.

