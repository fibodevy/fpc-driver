unit system;

{$mode ObjFPC}{$H+}

interface

const
  CP_ACP     = 0;     // default to ANSI code page
  CP_OEMCP   = 1;     // default to OEM (console) code page
  CP_UTF16   = 1200;  // utf-16
  CP_UTF16BE = 1201;  // unicodeFFFE
  CP_UTF7    = 65000; // utf-7
  CP_UTF8    = 65001; // utf-8
  CP_ASCII   = 20127; // us-ascii
  CP_NONE    = $FFFF; // rawbytestring encoding

type
  {$if not declared(Char)}
  Char = AnsiChar;
  {$endif}
  {$if not declared(AnsiChar)}
  AnsiChar = Char;
  {$endif}
  PChar          = ^AnsiChar;
  PAnsiChar      = ^AnsiChar;
  PAnsiString    = ^AnsiString;
  PWideChar      = ^WideChar;
  PShortString   = ^ShortString;
  RawByteString  = type AnsiString(CP_NONE);
  PRawByteString = ^RawByteString;
  UTF8Char       = AnsiChar;
  PUTF8Char      = ^UTF8Char;
  UTF8String     = type AnsiString(CP_UTF8);
  PUTF8String    = ^UTF8String;
  UnicodeChar    = WideChar;
  PUnicodeChar   = ^UnicodeChar;
  PUnicodeString = ^UnicodeString;

  Cardinal    = 0..$FFFFFFFF;
  HRESULT     = type LongInt;
  Int16       = Smallint;
  UInt16      = Word;
  Integer     = LongInt;
  Long        = LongInt;
  ULONG       = LongWord;
  DWord       = LongWord;
  Int         = Integer;
  Int32       = Integer;
  UInt        = DWord;
  UInt32      = DWord;
  UInt64      = QWord;
  {$ifdef CPU64}
  NativeInt   = Int64;
  NativeUInt  = QWord;
  {$else}
  NativeInt   = Integer;
  NativeUInt  = DWord;
  {$endif}
  PtrInt      = NativeInt;
  PtrUInt     = NativeUInt;
  SizeInt     = PtrInt;
  SizeUInt    = PtrUInt;

  HANDLE      = NativeUInt;
  HWND        = HANDLE;
  THandle     = NativeUInt;
  SIZE_T      = NativeUInt;
  ULONG_PTR   = NativeUInt;
  ValSInt     = NativeInt;
  PVOID       = Pointer;
  LPVOID      = Pointer;
  LPDWORD     = ^DWord;
  BOOL        = Boolean;
  NTSTATUS    = Long;

  PSmallInt   = ^Smallint;
  PShortInt   = ^Shortint;
  PInteger    = ^Integer;
  PByte       = ^Byte;
  PWord       = ^word;
  PDWord      = ^DWord;
  PLongWord   = ^LongWord;
  PLongint    = ^Longint;
  PCardinal   = ^Cardinal;
  PQWord      = ^QWord;
  PInt64      = ^Int64;
  PUInt64     = ^UInt64;
  PPtrInt     = ^PtrInt;
  PPtrUInt    = ^PtrUInt;
  PSizeInt    = ^SizeInt;
  PSizeUInt   = ^SizeUInt;
  PSingle     = ^Single;
  PDouble     = ^Double;
  PExtended   = ^Extended;
  PBoolean    = ^Boolean;
  PBoolean16  = ^Boolean16;
  PBoolean32  = ^Boolean32;
  PBoolean64  = ^Boolean64;
  PByteBool   = ^ByteBool;
  PWordBool   = ^WordBool;
  PLongBool   = ^LongBool;
  PQWordBool  = ^QWordBool;
  PNativeInt  = ^NativeInt;
  PNativeUInt = ^NativeUint;
  PInt8       = PShortInt;
  PInt16      = PSmallint;
  PInt32      = PLongint;
  PIntPtr     = PPtrInt;
  PUInt8      = PByte;
  PUInt16     = PWord;
  PUInt32     = PDWord;
  PUIntPtr	  = PPtrUInt;
  PCurrency   = ^Currency;
  PVariant    = ^Variant;

  TDateTime   = type Double;
  TDate       = type Double;
  TTime       = type Double;
  TProcedure  = procedure;
  PText       = ^Text;
  CodePointer = Pointer;
  TFileTextRecChar = UnicodeChar;
  PFileTextRecChar = ^TFileTextRecChar;

  TTypeKind = (tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkSet,
  tkMethod, tkSString, tkLString, tkAString, tkWString, tkVariant, tkArray,
  tkRecord, tkInterface, tkClass, tkObject, tkWChar, tkBool, tkInt64, tkQWord,
  tkDynArray, tkInterfaceRaw, tkProcVar, tkUString, tkUChar, tkHelper, tkFile,
  tkClassRef, tkPointer);

  pjmp_buf = ^jmp_buf;
  {$ifdef CPU64}
  jmp_buf = packed record
    rbx, rbp, r12, r13, r14, r15, rsp, rip: qword;
    rsi, rdi: qword;
    xmm6, xmm7, xmm8, xmm9, xmm10, xmm11, xmm12, xmm13, xmm14, xmm15: record m1, m2: qword; end;
    mxcsr: longword;
    fpucw: word;
    padding: word;
  end;
  {$else}
  jmp_buf = packed record
    ebx, esi, edi: LongInt;
    bp, sp, pc: Pointer;
    {$ifdef FPC_USE_WIN32_SEH}
    exhead: Pointer;
    {$endif FPC_USE_WIN32_SEH}
  end;
  {$endif}

  PExceptAddr = ^TExceptAddr;
  TExceptAddr = record
    buf: pjmp_buf;
    next: PExceptAddr;
    frametype: LongInt;
  end;

  PGUID = ^TGuid;
  TGUID = packed record
    case Byte of
    1: (
      Data1: LongWord;
      Data2: Word;
      Data3: Word;
      Data4: array[0..7] of Byte;
    );
    2: (
      D1: LongWord;
      D2: Word;
      D3: Word;
      D4: array[0..7] of Byte;
    );
    3: (
      { uuid fields according to RFC4122 }
      time_low: LongWord; // The low field of the timestamp
      time_mid: Word; // The middle field of the timestamp
      time_hi_and_version: Word; // The high field of the timestamp multiplexed with the version number
      clock_seq_hi_and_reserved: Byte; // The high field of the clock sequence multiplexed with the variant
      clock_seq_low: Byte; // The low field of the clock sequence
      node: array[0..5] of Byte; // The spatially unique node identifier
    );
  end;

{$I types.inc}

var
  FPC_EMPTYCHAR: AnsiChar; public name 'FPC_EMPTYCHAR';
  ExitCode: HRESULT = 0; export name 'operatingsystem_result';

const
  LineEnding = #13#10;

procedure fpc_initializeunits; compilerproc;
procedure fpc_libinitializeunits; compilerproc;
procedure fpc_do_exit; compilerproc;
procedure fpc_lib_exit; compilerproc;

function DriverEntry(DriverObject: Pointer; RegistryPath: Pointer): LongInt; stdcall; external name 'DriverEntry';

const
  ntoskrnl = 'ntoskrnl.exe';

function DbgPrint(aFormat: PAnsiChar): Integer; cdecl; varargs; external ntoskrnl;
function DbgPrintEx(ComponentId: Integer; Level: Integer; Format: PAnsiChar): Integer; cdecl; external ntoskrnl;

implementation

function _FPC_DLLMainCRTStartup(DriverObject: Pointer; RegistryPath: Pointer): LongInt; stdcall; public name '_DLLMainCRTStartup';
begin
  result := DriverEntry(DriverObject, RegistryPath);
end;

procedure fpc_initializeunits; [public, alias: 'FPC_INITIALIZEUNITS'];
begin
end;

procedure fpc_libinitializeunits; compilerproc; [public, alias: 'FPC_LIBINITIALIZEUNITS'];
begin
end;

procedure fpc_do_exit; [public, alias: 'FPC_DO_EXIT'];
begin
end;

procedure fpc_lib_exit; [public, alias: 'FPC_LIB_EXIT'];
begin
end;

end.
