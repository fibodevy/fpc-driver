program ioctl;

uses SysUtils, Windows;

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

function CTL_CODE(DeviceType, FunctionCode, Method, Access: DWORD): DWORD; inline;
begin
  result := (DeviceType shl 16) or (Access shl 14) or (FunctionCode shl 2) or Method;
end;

function IOCTL_PING: DWORD;
begin
  result := CTL_CODE(FILE_DEVICE_UNKNOWN, 555, METHOD_BUFFERED, FILE_ANY_ACCESS);
end;

var
  dev: HANDLE;
  a, b, d, ret: dword;
  q: qword;

begin
  try
    dev := CreateFile('\\.\fpcd', GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
    if dev = INVALID_HANDLE_VALUE then begin
      writeln('Failed opening device with error ', GetLastError);
      exit;
    end;

    try
      // send random numbers
      Randomize;
      a := Random(10);
      b := Random(10);
      writeln('Sending ', a, ' and ', b);
      writeln('IOCTL_PING = ', IOCTL_PING, ' / hex = ', IntToHex(IOCTL_PING, 8));

      pdword(@q)^ := a;
      pdword(@q+4)^ := b;
      writeln('@ret = ', IntToHex(PtrUInt(@ret), 16));
      if not DeviceIoControl(dev, IOCTL_PING, @q, 8, @ret, 4, @d, nil) then begin
        writeln('IOCTL failed with error ', GetLastError);
        exit;
      end;

      writeln('Bytes returned = ', d);
      Writeln('Reply = ', ret);
      writeln('Which is... ', specialize IfThen<String>(a+b = ret, 'Correct!', 'Incorrect!'));
    finally
      CloseHandle(dev);
    end;
  finally
    writeln('Done');
    readln;
  end;
end.

