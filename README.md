> [!WARNING]  
> Heavy work on the readme!

# fpc-driver

## Compiler
First, get the compiler. You can try your current binaries, you can get it with fpcupdeluxe, or you can download the binaries I built.

## FPC trunk/main
FPC 3.3.1 changes every day, introducing new bugs and fixes for them. I spent some time looking for what is "missing" in my RTL. If I got rid of Internal Error 2006012304, I got internal exceptions. There were syntax errors in some commits, missing semicolons. 3.3.1 is not ready, so we have to choose a commit where it works and build the compiler.

Here are 2 commits from the same day:

- `97f159e4b2c861df559966142a50682130e8a1f2` - with this commit RTL compiles fine
- `1351746a46807cecd8064e873c41c615f9af6ec9` - this one gives an internal exception

Few days later, at this commit:
- `1e3865a187d8ef54d877185da306713640f935a1` - Internal Error 2006012304

So it stops now. The commit of the trunk compiler used in this project is `b61a0fab97a47f5281778c6a8322f0eeb2747418`. Both x86 and x64 compilers compile well and work.

To facilitate this, I have created a repository that will hold the FPC sources used in this project. Also binaries.

https://github.com/fibodevy/fpc-driver-fpcsource

## Lazarus IDE
Use your current Lazarus. Set the path to the compiler in the Project Options. Use this repo as a template.

## Windows x64
I focus on Windows x64, version 10 and newer. I will show you 2 ways to run the driver.

### The first way: Test Signing mode

As admin, run
```
bcdedit /set testsigning on
```

You still need to sign the driver, so read on. And, of course, if you want to keep running the driver on your machine, you dont want the annoyances (no wallpaper and a warning) and unsafety this method adds.

### The second way: UEFI Secure Boot with your own Platform Key

It works like this:

1. create certificates: CA (Certificate Authority), PK (Platform Key), and a code signing certificate, lets name it CS
2. in your BIOS (UEFI), enable the Secure Boot
3. still in your BIOS (UEFI), look for the option to add PK, and add it
4. start your Windows and add the CA certificate to the cert store
5. sign the driver with the CS certificate

To be continued... ;-)
