unit api;

{$mode ObjFPC}{$H+}

interface

uses native;

function IOCTL_CALLBACK_ADD(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var bufoutlen: DWORD): NTSTATUS;
function IOCTL_CALLBACK_REBOOT(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var bufoutlen: DWORD): NTSTATUS;

type
  TIOCTL_CALLBACK = record
    IOCTL: DWord;
    Cb: function(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var butouflen: DWORD): NTSTATUS;
  end;

const
  IOCTL_CALLBACKS: array[0..1] of TIOCTL_CALLBACK = (
    // add
    (ioctl: (FILE_DEVICE_UNKNOWN shl 16) or (FILE_ANY_ACCESS shl 14) or (1000 shl 2) or METHOD_BUFFERED; cb: @IOCTL_CALLBACK_ADD),
    // reboot
    (ioctl: (FILE_DEVICE_UNKNOWN shl 16) or (FILE_ANY_ACCESS shl 14) or (1001 shl 2) or METHOD_BUFFERED; cb: @IOCTL_CALLBACK_REBOOT)
  );

implementation

function IOCTL_CALLBACK_ADD(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var bufoutlen: DWORD): NTSTATUS;
begin
  // @@todo: should check if bufin/out belongs to the process?
  if (bufin = nil) or (bufinlen <> 8) or (bufout = nil) or (bufoutlen <> 4) then begin
    DbgPrint('[fpcd] IOCTL_PING invalid buffer');
    exit(STATUS_INVALID_PARAMETER);
  end;

  DbgPrint('[fpcd] IOCTL_PING a = %d | b = %d | UserBuffer = %p', pdword(bufin)^, pdword(bufin+4)^, bufout);
  pdword(bufout)^ := pdword(bufin)^+pdword(bufin+4)^;

  result := STATUS_SUCCESS;
end;

function IOCTL_CALLBACK_REBOOT(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var bufoutlen: DWORD): NTSTATUS;
begin
  result := NtShutdownSystem(ShutdownReboot);
  DbgPrint('[fpcd] IRQL         = %d', KeGetCurrentIrql); // level 0 here
  DbgPrint('[fpcd] IOCTL_REBOOT = %p', result);

  if not NT_SUCCESS(result) then begin
    // still here?                      
    DbgPrint('[fpcd] still here... calling HalReturnToFirmware');
    //HalReturnToFirmware(HalRestartRoutine); // this one does shutdown
    //HalReturnToFirmware(HalRebootRoutine); // this one does nothing
    HalReturnToFirmware(HalMaximumRoutine); // freeze and eventually reboot
  end;

  result := STATUS_SUCCESS;
end;

end.

