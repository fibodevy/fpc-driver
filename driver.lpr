library driver;

uses native, api;

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
  DbgPrint('[fpcd] CreateApiDevice');

  RtlInitUnicodeString(@devname, API_DEVICE_NAME);
  result := IoCreateDevice(DriverObject, 0, @devname, FILE_DEVICE_UNKNOWN, 0, false, devobj);
  DbgPrint('[fpcd] IoCreateDevice result = %p', result);
  if not NT_SUCCESS(result) then begin
    DbgPrint('[fpcd] CreateApiDevice: IoCreateDevice failed');
    exit;
  end;

  RtlInitUnicodeString(@linkname, API_LINK_NAME);
  result := IoCreateSymbolicLink(@linkname, @devname);
  DbgPrint('[fpcd] IoCreateSymbolicLink result = %p', result);
  if not NT_SUCCESS(result) then begin
    DbgPrint('[fpcd] CreateApiDevice: IoCreateSymbolicLink failed');
    IoDeleteDevice(devobj);
    exit;
  end;

  DbgPrint('[fpcd] CreateApiDevice: device created');
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

function OnDeviceControl(DeviceObject: PDEVICE_OBJECT; Irp: PIRP): LONG; stdcall;
var
  sl: PIO_STACK_LOCATION;
  bufin, bufout: pbyte;
  bufinlen, bufoutlen: dword;
  i: integer;
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

  result := STATUS_INVALID_PARAMETER;

  for i := 0 to high(IOCTL_CALLBACKS) do
    if IOCTL_CALLBACKS[i].IOCTL = sl^.Parameters.DeviceIoControl.IoControlCode then begin
      DbgPrint('[fpcf] found callback');
      result := IOCTL_CALLBACKS[i].Cb(Irp, bufin, bufinlen, bufout, bufoutlen);
      break;
    end;

  result := IrpDispatchDone(Irp, result);
end;

procedure DestroyApiDevice({%H-}DriverObject: PDRIVER_OBJECT);
var
  linkname: UNICODE_STRING;
begin
  DbgPrint('[fpcd] DestroyApiDevice');
  if ApiDevice = nil then begin
    DbgPrint('[fpcd] DestroyApiDevice: ApiDevice is nil');
    exit;
  end;
  RtlInitUnicodeString(@linkname, API_LINK_NAME);
  IoDeleteSymbolicLink(@linkname);
  IoDeleteDevice(ApiDevice);
  ApiDevice := nil;
end;

procedure DriverUnload(DriverObject: PDRIVER_OBJECT); stdcall;
begin
  DbgPrint('[fpcd] DriverUnload');
  DestroyApiDevice(DriverObject);
end;

function {%H-}DriverEntry(DriverObject: PDRIVER_OBJECT; RegistryPath: PUNICODE_STRING): LongInt; stdcall; public name 'DriverEntry';
var
  i: integer;
begin
  DbgPrint('[fpcd] FPC version = %s | target = %s | build time = %s', {$I %FPCVERSION%}, {$I %FPCTARGET%}, {$I %DATE%}+' '+{$I %TIME%});

  for i := 0 to high(DriverObject^.MajorFunction) do
    DriverObject^.MajorFunction[i] := @OnOther;

  DriverObject^.MajorFunction[IRP_MJ_CREATE] := @OnDevCreate;
  DriverObject^.MajorFunction[IRP_MJ_CLOSE] := @OnDevClose;
  DriverObject^.MajorFunction[IRP_MJ_DEVICE_CONTROL] := @OnDeviceControl;

  DriverObject^.DriverUnload := @DriverUnload;

  result := CreateApiDevice(DriverObject);

  DbgPrint('[fpcd] End of DriverEntry | result = %p', result);
end;

end.

