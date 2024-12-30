unit native;

interface

const
  STATUS_SUCCESS               = NTSTATUS($00000000);
  STATUS_PENDING               = NTSTATUS($00000103);
  STATUS_NO_MORE_FILES         = NTSTATUS($80000006);
  STATUS_NO_MORE_ENTRIES       = NTSTATUS($8000001A);
  STATUS_INVALID_HANDLE        = NTSTATUS($C0000008);
  STATUS_INVALID_PARAMETER     = NTSTATUS($C000000D);
  STATUS_OBJECT_TYPE_MISMATCH  = NTSTATUS($C0000024);
  STATUS_OBJECT_NAME_COLLISION = NTSTATUS($C0000035);

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

function NT_SUCCESS(status: NTSTATUS): Boolean; inline;
function NT_INFORMATION(status: NTSTATUS): Boolean; inline;
function NT_WARNING(status: NTSTATUS): Boolean; inline;
function NT_ERROR(status: NTSTATUS): Boolean; inline;

implementation

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

