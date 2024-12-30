library driver;

uses native;

procedure DriverUnload(DriverObject: PDRIVER_OBJECT); stdcall;
begin
  DbgPrint('[fpcd] DriverUnload'+LineEnding);
end;

function DriverEntry(DriverObject: PDRIVER_OBJECT; RegistryPath: PUNICODE_STRING): LongInt; stdcall; public name 'DriverEntry';
begin
  DbgPrint(LineEnding);
  DbgPrint('[fpcd] Hello World! Windows Kernel Mode Driver in FPC'+LineEnding);
  DbgPrint('[fpcd] Build time  = '+{$I %DATE%}+' '+{$I %TIME%}+LineEnding);
  DbgPrint('[fpcd] FPC version = '+{$I %FPCVERSION%}+LineEnding);
  DbgPrint('[fpcd] FPC target  = '+{$I %FPCTARGET%}+LineEnding);
  DbgPrint(LineEnding);

  DriverObject^.DriverUnload := @DriverUnload;

  DbgPrint('[fpcd] End of DriverEntry'+LineEnding);
  DbgPrint(LineEnding);

  result := STATUS_SUCCESS;
end;

end.

