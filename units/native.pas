unit native;

{$mode ObjFPC}{$H+}

interface

const
  STATUS_SUCCESS                = NTSTATUS($00000000); // Operation completed successfully.
  STATUS_PENDING                = NTSTATUS($00000103); // The request is pending and hasn't been completed yet.
  STATUS_NO_MORE_FILES          = NTSTATUS($80000006); // No more files are available to process.
  STATUS_NO_MORE_ENTRIES        = NTSTATUS($8000001A); // No more entries are available to process.
  STATUS_INVALID_HANDLE         = NTSTATUS($C0000008); // The handle is invalid or no longer active.
  STATUS_INVALID_PARAMETER      = NTSTATUS($C000000D); // An invalid parameter was passed to the function.
  STATUS_OBJECT_TYPE_MISMATCH   = NTSTATUS($C0000024); // The object type is not what was expected
  STATUS_OBJECT_NAME_COLLISION  = NTSTATUS($C0000035); // An object name collision occurred
  STATUS_INVALID_DEVICE_REQUEST = NTSTATUS($C0000010); // The request sent to the device is invalid or unsupported
  STATUS_IO_DEVICE_ERROR        = NTSTATUS($C0000185); // A problem occurred with the I/O device
  STATUS_INSUFFICIENT_RESOURCES = NTSTATUS($C000009A); // Insufficient resources to process the request
  STATUS_NO_MEMORY              = NTSTATUS($C0000017); // The system cannot allocate memory to complete the request
  STATUS_NOT_SUPPORTED          = NTSTATUS($C00000BB); // The function or operation is not supported by the device or driver
  STATUS_ACCESS_DENIED          = NTSTATUS($C0000022); // Access to the requested resource was denied
  STATUS_OBJECT_NAME_NOT_FOUND  = NTSTATUS($C0000034); // The specified object name was not found
  STATUS_BUFFER_TOO_SMALL       = NTSTATUS($C0000023); // The provided buffer is too small to hold the data

// https://learn.microsoft.com/en-us/windows-hardware/drivers/debuggercmds/-irp
// Major function codes for IRP (I/O Request Packet)
const
  IRP_MJ_CREATE                   = $00; // Create a file or device
  IRP_MJ_CREATE_NAMED_PIPE        = $01; // Create a named pipe
  IRP_MJ_CLOSE                    = $02; // Close a handle to a file or device
  IRP_MJ_READ                     = $03; // Read data from a file or device
  IRP_MJ_WRITE                    = $04; // Write data to a file or device
  IRP_MJ_QUERY_INFORMATION        = $05; // Query information about a file
  IRP_MJ_SET_INFORMATION          = $06; // Set information about a file
  IRP_MJ_QUERY_EA                 = $07; // Query extended attributes of a file
  IRP_MJ_SET_EA                   = $08; // Set extended attributes of a file
  IRP_MJ_FLUSH_BUFFERS            = $09; // Flush buffers to the underlying hardware
  IRP_MJ_QUERY_VOLUME_INFORMATION = $0A; // Query volume information
  IRP_MJ_SET_VOLUME_INFORMATION   = $0B; // Set volume information
  IRP_MJ_DIRECTORY_CONTROL        = $0C; // Perform directory operations (e.g., listing files)
  IRP_MJ_FILE_SYSTEM_CONTROL      = $0D; // Perform file system control operations
  IRP_MJ_DEVICE_CONTROL           = $0E; // Perform device-specific control operations
  IRP_MJ_INTERNAL_DEVICE_CONTROL  = $0F; // Perform internal device-specific operations
  IRP_MJ_SHUTDOWN                 = $10; // Shut down the system or device
  IRP_MJ_LOCK_CONTROL             = $11; // Perform file or volume lock operations
  IRP_MJ_CLEANUP                  = $12; // Clean up after file or device handle closure
  IRP_MJ_CREATE_MAILSLOT          = $13; // Create a mailslot
  IRP_MJ_QUERY_SECURITY           = $14; // Query security information of a file or device
  IRP_MJ_SET_SECURITY             = $15; // Set security information of a file or device
  IRP_MJ_POWER                    = $16; // Manage power state transitions
  IRP_MJ_SYSTEM_CONTROL           = $17; // Handle system control requests (e.g., WMI queries)
  IRP_MJ_DEVICE_CHANGE            = $18; // Notify device changes (e.g., hot-plug events)
  IRP_MJ_QUERY_QUOTA              = $19; // Query disk quota information
  IRP_MJ_SET_QUOTA                = $1A; // Set disk quota information
  IRP_MJ_PNP                      = $1B; // Handle Plug and Play requests
  IRP_MJ_PNP_POWER                = IRP_MJ_PNP; // Obsolete: Alias for IRP_MJ_PNP
  IRP_MJ_MAXIMUM_FUNCTION         = $1B; // Maximum defined IRP major function code

const
  IO_NO_INCREMENT        = 0;    // Indicates that no increment should occur in the I/O count
  IO_INCREMENT           = 1;    // Indicates that the I/O count should be incremented
  IO_COMPLETE_REQUEST    = 2;    // Indicates that the request is complete
  IO_ASYNC_OPERATION     = $00000001; // Marks an asynchronous operation
  IO_SYNC_OPERATION      = $00000002; // Marks a synchronous operation
  IO_IGNORE_EA           = $00000004; // Ignore Extended Attributes during I/O
  IO_DISABLE_CACHE       = $00000008; // Disables caching for the operation
  IO_FORCE_ACCESS_CHECK  = $00000010; // Forces an access check
  IO_DELAY_OPERATION     = $00000020; // Delays the I/O operation
  IO_DO_NOT_LOG          = $00000040; // Do not log the I/O request

const
  // Common device types
  FILE_DEVICE_DISK           = $00000007; // Disk device
  FILE_DEVICE_KEYBOARD       = $0000000B; // Keyboard device
  FILE_DEVICE_MOUSE          = $0000000F; // Mouse device
  FILE_DEVICE_PRINTER        = $00000018; // Printer device
  FILE_DEVICE_NETWORK        = $00000012; // Network device
  FILE_DEVICE_UNKNOWN        = $00000022; // Device type for an unspecified or unknown device

  // Access flags
  FILE_ANY_ACCESS            = 0;         // No specific access required
  FILE_READ_ACCESS           = $0001;     // Read access
  FILE_WRITE_ACCESS          = $0002;     // Write access

  // IOCTL method definitions
  METHOD_BUFFERED            = 0; // Buffered I/O
  METHOD_IN_DIRECT           = 1; // Direct I/O for input
  METHOD_OUT_DIRECT          = 2; // Direct I/O for output
  METHOD_NEITHER             = 3; // Neither buffered nor direct I/O

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
    MajorFunction: array[0..26] of Pointer; // func
  end;
  DRIVER_OBJECT = _DRIVER_OBJECT;
  PDRIVER_OBJECT = ^_DRIVER_OBJECT;

  _LIST_ENTRY = packed record
    Flink: ^LIST_ENTRY;
    Blink: ^LIST_ENTRY;
  end;
  LIST_ENTRY = _LIST_ENTRY;
  PLIST_ENTRY = ^_LIST_ENTRY;

  _IO_STATUS_BLOCK = packed record
    union: packed record
    case byte of
      0: (Status: Long);
      1: (Pointer: Pointer);
    end;
    Information: PtrUInt;
  end;
  IO_STATUS_BLOCK = _IO_STATUS_BLOCK;
  PIO_STATUS_BLOCK = ^_IO_STATUS_BLOCK;

  _IRP = packed record
    union: packed record
    case byte of
      0: (
        Typ: Int16;
        Size: UInt16;
      );
      1: (_padding: Pointer);
    end;
    MdlAddress: Pointer; // PMDL
    Flags: ULONG;
    {$ifdef CPU64}
    _padding2: dword;
    {$endif}
    AssociatedIrp: packed record
    case byte of
      0: (MasterIrp: ^_IRP;);
      1: (IrpCount: LONG;);
      2: (SystemBuffer: PByte;);
    end;
    ThreadListEntry: _LIST_ENTRY;
    IoStatus: _IO_STATUS_BLOCK;
    // @@todo add more
  end;
  IRP = _IRP;
  PIRP = ^_IRP;

  _DEVICE_OBJECT = packed record
    // @@todo
  end;
  DEVICE_OBJECT = _DEVICE_OBJECT;
  PDEVICE_OBJECT = ^_DEVICE_OBJECT;

  _IO_STACK_LOCATION = packed record
    u: packed record
    case byte of
      0: (
        MajorFunction: Byte;
        MinorFunction: Byte;
        Flags: Byte;
        Control: Byte;
      );
      1: (
        _padding: Pointer;
      );
    end;
    Parameters: packed record
    case byte of
      0: (DeviceIoControl: packed record
        OutputBufferLength: PtrUInt;
        InputBufferLength: PtrUInt;
        IoControlCode: PtrUInt;
        Type3InputBuffer: Pointer;
      end;);
      //1: ();
    end;
  end;
  IO_STACK_LOCATION = _IO_STACK_LOCATION;
  PIO_STACK_LOCATION = ^_IO_STACK_LOCATION;

function NT_SUCCESS(status: NTSTATUS): Boolean; inline;
function NT_INFORMATION(status: NTSTATUS): Boolean; inline;
function NT_WARNING(status: NTSTATUS): Boolean; inline;
function NT_ERROR(status: NTSTATUS): Boolean; inline;

// get Irp.Tail.Overlay.CurrentStackLocation
function IoGetCurrentIrpStackLocation(Irp: PIRP): PIO_STACK_LOCATION; inline;
// get Irp.UserBuffer; temp function until the struct is complete
function IrpUserBuffer(Irp: PIRP): Pointer; inline;

procedure RtlInitUnicodeString(DestinationString: PUNICODE_STRING; SourceString: PWideChar); stdcall; external ntoskrnl;
procedure RtlMoveMemory(Destination: Pointer; Source: Pointer; Length: SIZE_T); stdcall; external ntoskrnl;
procedure RtlCopyMemory(Destination: Pointer; Source: Pointer; Length: SIZE_T); stdcall; external ntoskrnl;
procedure RtlZeroMemory(Destination: Pointer; Length: SIZE_T); stdcall; external ntoskrnl;

function IoDetachDevice(TargetDevice: PDEVICE_OBJECT): Boolean; stdcall; external ntoskrnl;
function IoDeleteDevice(DeviceObject: PDEVICE_OBJECT): Boolean; stdcall; external ntoskrnl;
procedure IoSkipCurrentIrpStackLocation(Irp: PIRP); stdcall; external ntoskrnl;
function IoCallDriver(DeviceObject: PDEVICE_OBJECT; Irp: PIRP): LongInt; stdcall; external ntoskrnl;
function IoCreateDevice(DriverObject: PDRIVER_OBJECT; DeviceExtensionSize: Cardinal; DeviceName: PUNICODE_STRING;
  DeviceType: Cardinal; DeviceCharacteristics: Cardinal; Exclusive: Boolean; out DeviceObject: PDEVICE_OBJECT): LongInt; stdcall; external ntoskrnl;
function IoAttachDeviceToDeviceStack(SourceDevice: PDEVICE_OBJECT; TargetDevice: PDEVICE_OBJECT): PDEVICE_OBJECT; stdcall; external ntoskrnl;
procedure IoCompleteRequest(Irp: Pointer; PriorityBoost: Byte); stdcall; external ntoskrnl;
function IoCreateSymbolicLink(SymbolicLinkName: PUNICODE_STRING; DeviceName: PUNICODE_STRING): NTSTATUS; stdcall; external ntoskrnl;
function IoDeleteSymbolicLink(SymbolicLinkName: PUNICODE_STRING): NTSTATUS; stdcall; external ntoskrnl;

// https://ntdoc.m417z.com/ntshutdownsystem
type
  _SHUTDOWN_ACTION = (
    ShutdownNoReboot,
    ShutdownReboot,
    ShutdownPowerOff,
    ShutdownRebootForRecovery // since WIN11
  );
  SHUTDOWN_ACTION = _SHUTDOWN_ACTION;

procedure NtShutdownSystem(ShutdownAction: SHUTDOWN_ACTION); stdcall; external ntoskrnl;

implementation

function IoGetCurrentIrpStackLocation(Irp: PIRP): PIO_STACK_LOCATION;
begin
  {$ifdef CPU64}
  result := PIO_STACK_LOCATION(PPtrUInt(PtrUInt(Irp)+$b8)^);
  {$else}
  result := PIO_STACK_LOCATION(PPtrUInt(PtrUInt(Irp)+$60)^);
  {$endif}
end;

function IrpUserBuffer(Irp: PIRP): Pointer;
begin
  {$ifdef CPU64}
  result := pointer(PPtrUInt(PtrUInt(Irp)+$70)^);
  {$else}
  result := pointer(PPtrUInt(PtrUInt(Irp)+$3c)^);
  {$endif}
end;

function NT_SUCCESS(status: NTSTATUS): Boolean;
begin
  result := status >= 0;
end;

function NT_INFORMATION(status: NTSTATUS): Boolean;
begin
  result := ULONG(status) shr 30 = 1;
end;

function NT_WARNING(status: NTSTATUS): Boolean;
begin
  result := ULONG(status) shr 30 = 2;
end;

function NT_ERROR(status: NTSTATUS): Boolean;
begin
  result := ULONG(status) shr 30 = 3;
end;

end.

