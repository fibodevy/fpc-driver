unit fpintres;

{$mode ObjFPC}{$H+}
 
interface

type
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
    {$ifdef CPU16}
    frametype: SmallInt;
    {$else CPU16}
    frametype: LongInt;
    {$endif CPU16}
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
 
implementation
 
end.
