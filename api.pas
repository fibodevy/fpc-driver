unit api;

{$mode ObjFPC}{$H+}

interface

uses native;

function IOCTL_ADD_CALLBACK(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var bufoutlen: DWORD): NTSTATUS; 
function IOCTL_REBOOT_CALLBACK(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var bufoutlen: DWORD): NTSTATUS;

implementation

function IOCTL_ADD_CALLBACK(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var bufoutlen: DWORD): NTSTATUS;
begin
  // @@todo: should check if bufin/out belongs to the process?
  if (bufin = nil) or (bufinlen <> 8) or (bufout = nil) or (bufoutlen <> 4) then begin
    DbgPrint('[fpcd] IOCTL_PING invalid buffer');
    exit(STATUS_INVALID_PARAMETER);
  end;

  DbgPrint('[fpcd] IOCTL_PING a = %d | b = %d | UserBuffer = %p', pdword(bufin)^, pdword(bufin+4)^, bufout);
  pdword(bufout)^ := pdword(bufin)^+pdword(bufin+4)^;

  // weird, it copies this amount of bytes from input to output?
  // lets just return .Information = 0 for now
  result := STATUS_SUCCESS;
end;

function IOCTL_REBOOT_CALLBACK(var Irp: PIRP; var bufin: PByte; var bufinlen: DWORD; var bufout: PByte; var bufoutlen: DWORD): NTSTATUS;
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

