OPTION DOTNAME
option casemap:none
include \masm32\include\temphls.inc
include \masm32\include\win64.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\shell32.inc
 
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\shell32.lib
 
OPTION PROLOGUE:rbpFramePrologue

WinMain proto
GetTextSection PROTO
FixQwords PROTO
FixImports PROTO

IMAGE_IMPORT_DESCRIPTOR_SIZE equ 5*4
; CharacteristicsOff equ 0
OriginalFirstThunkOff equ 0
TimeDateStampOff equ 4
ForwarderChainOff equ 8
Name1Off equ 12
FirstThunkOff equ 16

IMAGE_IMPORT_BY_NAME_Size equ 2+4
HintOff equ 0
ByNameImportOff equ 2

IMAGE_ORDINAL_FLAG32 equ 80000000h
SizeOfASection equ 028h


.data
ModuleLoc db 'C:\Program Files\gBurner Virtual Drive\GCDTRAY.EXE',0
SuportedExtensions db 'All Supported Files (*.iso;*.gbi;*.gbp;*.daa;*.bin;*.cue;*.mdf;*.mds;*.ashdisc;*.bwi;*.b5i;*.lcd;*.img;*.cdi;*.cif;*.p01;*.pdi;*.nrg;*.ncd;*.pxi;*.gi;*.fcd;*.vcd;*.c2d;*.dmg;*.uif;*.isz)',0
db '*.iso;*.gbi;*.gbp;*.daa;*.bin;*.cue;*.mdf;*.mds;*.ashdisc;*.bwi;*.b5i;*.lcd;*.img;*.cdi;*.cif;*.p01;*.pdi;*.nrg;*.ncd;*.pxi;*.gi;*.fcd;*.vcd;*.c2d;*.dmg;*.uif;*.isz',0
db 'Standard ISO Images (*.iso)',0,'*.iso',0
db 'gBurner Images (*.gbi;*.gbp)',0,'*.gbi;*.gbp',0
db 'Direct Access Archive (*.daa)',0,'*.daa',0
db 'DRWin Images (*.bin;*.cue)',0,'*.bin;*.cue',0
db 'Alcohol120% Images (*.mdf;*.mds)',0,'*.mdf;*.mds',0
db 'Ashampoo Images (*.ashdisc)',0,'*.ashdisc',0
db 'BlindWrite Images (*.bwi;*.b5i)',0,'*.bwi;*.b5i',0
db 'CDSpace Images (*.lcd)',0,'*.lcd',0
db 'CloneCD Images (*.img)',0,'*.img',0
db 'DiscJugger Images (*.cdi)',0,'*.cdi',0
db 'Easy CD/DVD Creator Images (*.cif)',0,'*.cif',0
db 'Gear Images (*.p01)',0,'*.p01',0
db 'InstantCopy Images (*.pdi)',0,'*.pdi',0
db 'Nero Images (*.nrg)',0,'*.nrg',0
db 'NTI CD-Maker Images (*.ncd)',0,'*.ncd',0
db 'PlexTools Images (*.pxi)',0,'*.pxi',0
db 'RecordNow Images (*.gi)',0,'*.gi',0
db 'Virtual CD-ROM Images (*.fcd)',0,'*.fcd',0
db 'Virtual Drive Images (*.vcd)',0,'*.vcd',0
db 'WinOnCD Images (*.c2d)',0,'*.c2d',0
db 'Mac Images (*.dmg)',0,'*.dmg',0
db 'UIF Images (*.uif)',0,'*.uif',0
db 'ISZ Images (*.isz)',0,'*.isz',0
db 'All Files (*.*)',0,'*.*',0, 0

DefExt		db  "iso",0

buffer db 2512 dup(0)
szFileName db 2512 dup(0)

nArgs dq 0

ModuleAddress dq 0
OldImageBase dq 0400000h
TextVirtualAddress dd 0
TextVirtualSize dd 0
DataVirtualAddress dd 0
DataVirtualSize dd 0
RDataVirtualAddress dd 0
RDataVirtualSize dd 0
IMAGE_DATA_DIRECTORY_VA dd 0
ImportedModuleAddress dq 0
RelovedApiAddress dq 0
ThunkAddress dd 0
ModuleToFixAddress dq 0
EntryPointAddress dd 0
ImageSize dd 0

RCX_register dq 0
RSI_register dq 0
RDI_register dq 0
HandleWindow dq 0
HandleFileToClose dq 0
UnicodeImageName dq 0
specialinitmethodRVA dq 0

DefaultPath db 'C:\Program Files\gBurner Virtual Drive\GCDTRAY.EXE',0
ProcessName db 'GCDTRAY.EXE',0
ProcessPathName dd 0
DlgName db "MyDialog",0
ModuleLocKeeper dq 0

expTxt	 	db "Wow! I'm in an edit box now",0
AppName	 	db 'Our First Dialog Box',0
Slash db '\',0

.data?
oldprotect dd ?
newprotect dd ?
ofn              OPENFILENAME <>
CurrentDirectory db 2512 dup(?)


.const
IDC_DIALOG  equ 200
IDC_EDIT1   equ 100
IDC_BUTTON1 equ 1
IDC_BUTTON2 equ 2
IDC_BUTTON3 equ 3
CP_ACP  equ 0

.code

GetTextSection proc

.if (rcx==0)
LEAVE
ret
.endif

xor rax,rax
mov eax,dword ptr [rcx+03Ch]
add rax,rcx

xor rdx,rdx ; edx = section index
StartLoop:
mov rsi,rdx
imul rsi,SizeOfASection
cmp byte ptr [rax+rsi+0108h],'.'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+1],'t'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+2],'e'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+3],'x'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+4],'t'
jnz NextPlease
jmp GetSection

NextPlease:
inc edx
jmp StartLoop

GetSection:
mov rsi,rdx
imul rsi,SizeOfASection
mov ebx,dword ptr [rax+rsi+0108h+8]
mov TextVirtualSize,ebx

mov ebx,dword ptr [rax+rsi+0108h+8+4]
mov TextVirtualAddress,ebx

LEAVE
 
ret

GetTextSection endp

GetDataSection proc

.if (rcx==0)
LEAVE
ret
.endif

xor rax,rax
mov eax,dword ptr [rcx+03Ch]
add rax,rcx

xor rdx,rdx ; edx = section index
StartLoop:
mov rsi,rdx
imul rsi,SizeOfASection
cmp byte ptr [rax+rsi+0108h],'.'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+1],'d'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+2],'a'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+3],'t'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+4],'a'
jnz NextPlease
jmp GetSection

NextPlease:
inc edx
jmp StartLoop

GetSection:
mov rsi,rdx
imul rsi,SizeOfASection
mov ebx,dword ptr [rax+rsi+0108h+8]
mov DataVirtualSize,ebx

mov ebx,dword ptr [rax+rsi+0108h+8+4]
mov DataVirtualAddress,ebx

LEAVE
 
ret

GetDataSection endp

GetRDataSection proc

.if (rcx==0)
LEAVE
ret
.endif

xor rax,rax
mov eax,dword ptr [rcx+03Ch]
add rax,rcx

xor rdx,rdx ; edx = section index
StartLoop:
mov rsi,rdx
imul rsi,SizeOfASection
cmp byte ptr [rax+rsi+0108h],'.'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+1],'r'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+2],'d'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+3],'a'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+4],'t'
jnz NextPlease
cmp byte ptr [rax+rsi+0108h+5],'a'
jnz NextPlease
jmp GetSection

NextPlease:
inc edx
jmp StartLoop

GetSection:
mov rsi,rdx
imul rsi,SizeOfASection
mov ebx,dword ptr [rax+rsi+0108h+8]
mov RDataVirtualSize,ebx

mov ebx,dword ptr [rax+rsi+0108h+8+4]
mov RDataVirtualAddress,ebx

LEAVE
 
ret

GetRDataSection endp


GetEntryPoint proc

.if (rcx==0)
LEAVE
ret
.endif

xor rax,rax
mov eax,dword ptr [rcx+03Ch]
add rax,rcx

mov eax,dword ptr [rax+028h]
mov EntryPointAddress,eax
LEAVE
 
ret

GetEntryPoint endp

GetOldImageBase proc

.if (rcx==0)
LEAVE
ret
.endif

xor rax,rax
mov eax,dword ptr [rcx+03Ch]
add rax,rcx

mov rax,qword ptr [rax+030h]
mov OldImageBase,rax
LEAVE
 
ret

GetOldImageBase endp


GetImageSize proc

.if (rcx==0)
LEAVE
ret
.endif

xor rax,rax
mov eax,dword ptr [rcx+03Ch]
add rax,rcx

mov eax,dword ptr [rax+050h]
mov ImageSize,eax
LEAVE
 
ret

GetImageSize endp


FixDataQwords proc

cmp rcx,0
jz ReturnFromIt
cmp DataVirtualSize,0
jz ReturnFromIt
cmp DataVirtualAddress,0
jz ReturnFromIt

xor rcx,rcx
mov ecx,DataVirtualSize
sub rcx,08
xor rbx,rbx
mov ebx, DataVirtualAddress
add rbx,ModuleAddress

BeginOfLoop:
mov rax,OldImageBase
cmp qword ptr [rbx],rax
jl NextOnePlease

mov rax,OldImageBase
add eax,ImageSize
cmp qword ptr [rbx],rax
ja NextOnePlease

mov rdx,qword ptr [rbx]
sub rdx, OldImageBase
add rdx, ModuleAddress ; now we have the new address

mov qword ptr [rbx],rdx ; fix it!

NextOnePlease:
inc rbx
dec rcx
test rcx,rcx
jnz BeginOfLoop

ReturnFromIt:
LEAVE
ret
 
FixDataQwords endp


FixRDataQwords proc

cmp rcx,0
jz ReturnFromIt
cmp RDataVirtualSize,0
jz ReturnFromIt
cmp RDataVirtualAddress,0
jz ReturnFromIt


  ; We first need to make this page writeable
  lea r9, oldprotect        ; R9  = lpflOldProtect
  mov r8d, 40h              ; R8D = flNewProtect
  xor rdx,rdx
  mov edx, RDataVirtualSize  ; RDX = dwSize
  xor rcx,rcx
  mov ecx, RDataVirtualAddress ; RCX = lpAddress
  add rcx,ModuleAddress
  call VirtualProtect


xor rcx,rcx
mov ecx,RDataVirtualSize
sub rcx,08
xor rbx,rbx
mov ebx, RDataVirtualAddress
add rbx,ModuleAddress

BeginOfLoop:
mov rax,OldImageBase
cmp qword ptr [rbx],rax
jl NextOnePlease

mov rax,OldImageBase
add eax,ImageSize
cmp qword ptr [rbx],rax
ja NextOnePlease

mov rdx,qword ptr [rbx]
sub rdx, OldImageBase
add rdx, ModuleAddress ; now we have the new address

mov qword ptr [rbx],rdx ; fix it!

NextOnePlease:
inc rbx
dec rcx
test rcx,rcx
jnz BeginOfLoop

  ; restore old protection:
  lea r9, newprotect        ; R9  = lpflOldProtect
  mov r8d, oldprotect       ; R8D = flNewProtect
  xor rdx,rdx
  mov edx, RDataVirtualSize  ; RDX = dwSize
  xor rcx,rcx
  mov ecx, RDataVirtualAddress ; RCX = lpAddress
  add rcx,ModuleAddress
  call VirtualProtect

ReturnFromIt:
LEAVE
ret
 
FixRDataQwords endp

SaveRegisters proc
mov RCX_register,rcx
mov RSI_register,rsi
mov RDI_register,rdi
leave
ret
SaveRegisters endp

RestoreRegisters proc
mov rcx,RCX_register
mov rsi,RSI_register
mov rdi,RDI_register
leave
ret
RestoreRegisters endp

FixQwords proc

  ; We first need to make this page writeable
  lea r9, oldprotect        ; R9  = lpflOldProtect
  mov r8d, 40h              ; R8D = flNewProtect
  xor rdx,rdx
  mov edx, TextVirtualSize  ; RDX = dwSize
  xor rcx,rcx
  mov ecx, TextVirtualAddress ; RCX = lpAddress
  add rcx,ModuleAddress
  call VirtualProtect

; 00000000001D91BF | FF 15 6B FF 01 00   call qword ptr ds:[1F9130]
; the value = just relative offset

cmp TextVirtualSize,0
jz ReturnFromIt
cmp TextVirtualAddress,0
jz ReturnFromIt

xor rcx,rcx
mov ecx,TextVirtualSize
sub rcx,02
xor rbx,rbx
mov ebx, TextVirtualAddress
add rbx,ModuleAddress

BeginOfLoop:

cmp byte ptr [rbx],0FFh
jnz NextOnePlease

cmp byte ptr [rbx+1],015h
jnz NextOnePlease

mov edx,dword ptr [rbx+2]
add edx,ebx
add edx,06 ; the size of instruction

sub edx, dword ptr [OldImageBase]
add edx, dword ptr [ModuleAddress] ; now we have the new address

; mov dword ptr [rbx+2],edx ; fix it!

NextOnePlease:
inc rbx
dec rcx
test rcx,rcx
jnz BeginOfLoop


  ; restore old protection:
  lea r9, newprotect        ; R9  = lpflOldProtect
  mov r8d, oldprotect       ; R8D = flNewProtect
  xor rdx,rdx
  mov edx, TextVirtualSize  ; RDX = dwSize
  xor rcx,rcx
  mov ecx, TextVirtualAddress ; RCX = lpAddress
  add rcx,ModuleAddress
  call VirtualProtect

ReturnFromIt:
LEAVE
ret
FixQwords endp

FixImports proc

.if (rcx==0)
LEAVE
ret
.endif

mov ModuleToFixAddress,rcx

xor rax,rax
mov eax,dword ptr [rcx+03Ch]
add rax,rcx
add rax,090h
mov edx,dword ptr [rax]
add edx,ecx
mov IMAGE_DATA_DIRECTORY_VA,edx
mov esi,edx

StartChecking:
cmp dword ptr [esi+OriginalFirstThunkOff],0
jnz ImportProcessing
cmp dword ptr [esi+TimeDateStampOff],0
jnz ImportProcessing
cmp dword ptr [esi+ForwarderChainOff],0
jnz ImportProcessing
cmp dword ptr [esi+FirstThunkOff],0
jnz ImportProcessing
jmp ImportParseFinished ; if all zero we finished

ImportProcessing:

call SaveRegisters
mov eax,dword ptr [esi+Name1Off]
add eax,ecx
mov rcx,rax
call LoadLibrary
mov ImportedModuleAddress,rax
call RestoreRegisters

mov edi,[esi+FirstThunkOff]
add edi,dword ptr [ModuleToFixAddress]
mov ThunkAddress,edi

.if dword ptr [esi+OriginalFirstThunkOff]==0
mov edi,[esi+FirstThunkOff]
.else
mov edi,[esi+OriginalFirstThunkOff]
.endif

add edi,dword ptr [ModuleToFixAddress]

StartOfThunksLoop:
cmp dword ptr [edi],0
jz ThunksFinished

;test dword ptr [edi],IMAGE_ORDINAL_FLAG32
;jnz ImportByOrdinalPlease

call SaveRegisters
; process image import by name:
mov eax,dword ptr [edi]
add eax, dword ptr [ModuleToFixAddress]
add eax,ByNameImportOff ; here is the function name

invoke GetProcAddress,ImportedModuleAddress, eax
mov RelovedApiAddress,rax

; make addresses writable:
  ; We first need to make this page writeable
  lea r9, oldprotect        ; R9  = lpflOldProtect
  mov r8d, 40h              ; R8D = flNewProtect
  xor rdx,rdx
  mov edx, 08 ; TextVirtualSize  ; RDX = dwSize
  xor rcx,rcx
  mov ecx, ThunkAddress ; RCX = lpAddress
  call VirtualProtect
  

mov edi,ThunkAddress
mov rax,qword ptr [RelovedApiAddress]
mov qword ptr [edi],rax  ; fix the thunk!


call RestoreRegisters

ImportByOrdinalPlease:
add ThunkAddress,8
add edi,8 ; IMAGE_IMPORT_BY_NAME_Size
jmp StartOfThunksLoop

ThunksFinished:


add esi,IMAGE_IMPORT_DESCRIPTOR_SIZE
jmp StartChecking

ImportParseFinished:

leave
ret

FixImports endp



PatchesOnCodeSection proc

  ; We first need to make this page writeable
  lea r9, oldprotect        ; R9  = lpflOldProtect
  mov r8d, 40h              ; R8D = flNewProtect
  xor rdx,rdx
  mov edx, TextVirtualSize  ; RDX = dwSize
  xor rcx,rcx
  mov ecx, TextVirtualAddress ; RCX = lpAddress
  add rcx,ModuleAddress
  call VirtualProtect

; v4.1 Address=0000000000410000
; 00000000004458E0 | 49 8B 06                                 | mov rax,qword ptr ds:[r14]                                       |
; 00000000004458E3 | 49 8B CE                                 | mov rcx,r14                                                      |
; 00000000004458E6 | FF 90 08 01 00 00                        | call qword ptr ds:[rax+108]                                      |
; 00000000004458EC | 85 C0                                    | test eax,eax                                                     |
; 00000000004458EE | 74 46                                    | je gcdtray.445936                                                |
; v4.3: Address=0000000001B30000
; 0000000001B659F0 | 49 8B 06                                 | mov rax,qword ptr ds:[r14]                                       |
; 0000000001B659F3 | 49 8B CE                                 | mov rcx,r14                                                      |
; 0000000001B659F6 | FF 90 08 01 00 00                        | call qword ptr ds:[rax+108]                                      |
; 0000000001B659FC | 85 C0                                    | test eax,eax                                                     |
; 0000000001B659FE | 74 46                                    | je gcdtray.1B65A46                                               |

mov rdi,ModuleAddress
cmp byte ptr [rdi+0358EEh],074h ; v4.1
jnz NextPatch_v43
mov byte ptr [rdi+0358EEh],0EBh

mov specialinitmethodRVA,0B5E4h

NextPatch_v43:
mov rdi,ModuleAddress
cmp byte ptr [rdi+0359FEh],074h ; v4.3
jnz NextPatch1
mov byte ptr [rdi+0359FEh],0EBh

mov specialinitmethodRVA,0B56Ch

NextPatch1:
; Address=0000000000310000
; 00000000003301C8 | 41 B9 0A 00 00 00                        | mov r9d,A                                                        |
; 00000000003301CE | 4C 8B C0                                 | mov r8,rax                                                       |
; 00000000003301D1 | 33 D2                                    | xor edx,edx                                                      |
; 00000000003301D3 | 48 8B CF                                 | mov rcx,rdi                                                      |
; 00000000003301D6 | E8 3D DC 00 00                           | call gcdtray.33DE18                                              |
; 00000000003301DB | 8B F8                                    | mov edi,eax                                                      |
; 00000000003301DD | 89 44 24 20                              | mov dword ptr ss:[rsp+20],eax                                    |
; 00000000003301E1 | 85 DB                                    | test ebx,ebx                                                     |
; 00000000003301E3 | 75 07                                    | jne gcdtray.3301EC                                               |
; v4.3 
; 0000000001B502D8 | 41 B9 0A 00 00 00                        | mov r9d,A                                                        |
; 0000000001B502DE | 4C 8B C0                                 | mov r8,rax                                                       |
; 0000000001B502E1 | 33 D2                                    | xor edx,edx                                                      |
; 0000000001B502E3 | 48 8B CF                                 | mov rcx,rdi                                                      |
; 0000000001B502E6 | E8 3D DC 00 00                           | call gcdtray.1B5DF28                                             |
; 0000000001B502EB | 8B F8                                    | mov edi,eax                                                      |
; 0000000001B502ED | 89 44 24 20                              | mov dword ptr ss:[rsp+20],eax                                    | [rsp+20]:"C:\\Program Files\\gBurner Virtual Drive\\GCDTRAY.EXE"
; 0000000001B502F1 | 85 DB                                    | test ebx,ebx                                                     | ebx:"wExtEx"
; 0000000001B502F3 | 75 07                                    | jne gcdtray.1B502FC                                              |


mov rdi,ModuleAddress
cmp byte ptr [rdi+0201E3h],075h
jnz NextPatch1_v43
mov byte ptr [rdi+0201E3h],0EBh

NextPatch1_v43:

mov rdi,ModuleAddress
cmp byte ptr [rdi+0202F3h],075h
jnz NextPatch2
mov byte ptr [rdi+0202F3h],0EBh


NextPatch2:

; 000000000030B673 | 4C 8D 05 CE 69 07 00                     | lea r8,qword ptr ds:[382048]                                     | 382048:L".mzp"
; 000000000030B67A | 48 8B D0                                 | mov rdx,rax                                                      | rax:L"D:\\DownloadedCraps\\ToKeep1\\UnimportantCDs\\JVC.UIF"
; 000000000030B67D | 49 8B CC                                 | mov rcx,r12                                                      |
; 000000000030B680 | E8 3B 5D FE FF                           | call gcdtray.2F13C0                                              |
; 000000000030B685 | 48 8B F8                                 | mov rdi,rax                                                      | rax:L"D:\\DownloadedCraps\\ToKeep1\\UnimportantCDs\\JVC.UIF"
; 000000000030B688 | 48 3B C3                                 | cmp rax,rbx                                                      | rax:L"D:\\DownloadedCraps\\ToKeep1\\UnimportantCDs\\JVC.UIF"
; 000000000030B68B | 74 27                                    | je gcdtray.30B6B4                                                |
; RAX : 000000000039CE70     L"D:\\DownloadedCraps\\ToKeep1\\UnimportantCDs\\JVC.UIF"
; Address=00000000002F0000  RVA: ACE70
; 0000000001B31443 | FF 15 9F 84 03 00                        | call qword ptr ds:[<&GetOpenFileNameW>]                          |
; Address=0000000001B30000

; Address=0000000001B30000
; 0000000001B3143F | FF 15 A3 94 03 00                        | call qword ptr ds:[<&GetOpenFileNameW>]                          |
; 0000000001B31445 | 83 F8 01                                 | cmp eax,1                                                        | eax:L"All Supported Files (*.iso;*.gbi;*.gbp;*.daa;*.bin;*.cue;*.mdf;*.mds;*.ashdisc;*.bwi;*.b5i;*.lcd;*.img;*.cdi;*.cif;*.p01;*.pdi;*.nrg;*.ncd;*.pxi;*.gi;*.fcd;*.vcd;*.c2d;*.dmg;*.uif;*.isz)"
; 0000000001B31448 | 75 05                                    | jne gcdtray.1B3144F                                              |
; 0000000001B3144A | 48 8B C3                                 | mov rax,rbx                                                      | rax:L"All Supported Files (*.iso;*.gbi;*.gbp;*.daa;*.bin;*.cue;*.mdf;*.mds;*.ashdisc;*.bwi;*.b5i;*.lcd;*.img;*.cdi;*.cif;*.p01;*.pdi;*.nrg;*.ncd;*.pxi;*.gi;*.fcd;*.vcd;*.c2d;*.dmg;*.uif;*.isz)"

mov rdi,ModuleAddress
cmp word ptr [rdi+1443h],015FFh
jnz NextPatch2_v43
mov dword ptr [rdi+1443h],90909090h
mov word ptr [rdi+1443h+4],9090h

; 0000000001C11449   80 3B 00    cmp byte ptr ds:[rbx],0
mov word ptr [rdi+1443h+4+2],3B80h
mov word ptr [rdi+1443h+4+2+2],7400h ; jz

mov rax,ModuleAddress
add rax,0ACE70h
mov UnicodeImageName,rax

NextPatch2_v43:
mov rdi,ModuleAddress
cmp word ptr [rdi+143Fh],015FFh
jnz NextPatch3
mov dword ptr [rdi+143Fh],90909090h
mov word ptr [rdi+143Fh+4],9090h

; 0000000001C11449   80 3B 00    cmp byte ptr ds:[rbx],0
mov word ptr [rdi+143Fh+4+2],3B80h
mov word ptr [rdi+143Fh+4+2+2],7400h ; jz

mov rax,ModuleAddress
add rax,0AFFB0h
mov UnicodeImageName,rax

NextPatch3:

; 0000000000411401 | 66 89 05 68 BA 0A 00                     | mov word ptr ds:[4BCE70],ax                                      |
mov rdi,ModuleAddress
cmp word ptr [rdi+1401h],08966h
jnz NextPatch3_v43

mov dword ptr [rdi+1401h],090909090h
mov word ptr [rdi+1401h+4],09090h
mov byte ptr [rdi+1401h+4+2],090h

NextPatch3_v43:

; 0000000000411401 | 66 89 05 68 BA 0A 00                     | mov word ptr ds:[4BCE70],ax                                      |
mov rdi,ModuleAddress
cmp word ptr [rdi+13FDh],08966h
jnz NextPatch4

mov dword ptr [rdi+13FDh],090909090h
mov word ptr [rdi+13FDh+4],09090h
mov byte ptr [rdi+13FDh+4+2],090h

NextPatch4:
  ; restore old protection:
  lea r9, newprotect        ; R9  = lpflOldProtect
  mov r8d, oldprotect       ; R8D = flNewProtect
  xor rdx,rdx
  mov edx, TextVirtualSize  ; RDX = dwSize
  xor rcx,rcx
  mov ecx, TextVirtualAddress ; RCX = lpAddress
  add rcx,ModuleAddress
  call VirtualProtect

leave
ret

PatchesOnCodeSection endp


WinMain proc

invoke GetCurrentDirectory, sizeof CurrentDirectory, ADDR CurrentDirectory
lea rcx,CurrentDirectory
lea rdx,Slash
call StrCat
mov rcx,rax
lea rdx,ProcessName
call StrCat
mov ModuleLocKeeper,rax

; invoke CreateFile, ModuleLocKeeper, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
     mov rcx, ModuleLocKeeper
     mov rdx, GENERIC_READ
     xor r8, r8
     xor r9, r9
     push 0
     push FILE_ATTRIBUTE_NORMAL
     push OPEN_EXISTING
     sub rsp, 32
     call CreateFile
     mov HandleFileToClose,rax

     cmp rax,-1
     jz NextTest

     invoke CloseHandle, HandleFileToClose
    
NextTest:
lea rcx, DefaultPath
; mov rcx, ModuleLocKeeper
mov ModuleLocKeeper, rcx
mov rdx, GENERIC_READ
xor r8, r8
xor r9, r9
push 0
push FILE_ATTRIBUTE_NORMAL
push OPEN_EXISTING
sub rsp, 32
call CreateFile
mov HandleFileToClose,rax

cmp rax,-1
jz LoadLibraryNow

mov ModuleLocKeeper,offset DefaultPath
invoke CloseHandle, HandleFileToClose

LoadLibraryNow:
invoke LoadLibrary,ModuleLocKeeper
test rax,rax
jz ExitProcessLoc
mov ModuleAddress,rax

; imports fixing
mov rcx,ModuleAddress
call FixImports

mov rcx,ModuleAddress
call GetTextSection

mov rcx,ModuleAddress
call GetDataSection

mov rcx,ModuleAddress
call GetEntryPoint

mov rcx,ModuleAddress
call GetOldImageBase

mov rcx,ModuleAddress
call GetImageSize

mov rcx,ModuleAddress
call FixDataQwords

mov rcx,ModuleAddress
call GetRDataSection
mov rcx,ModuleAddress
call FixRDataQwords

mov rcx,ModuleAddress
call PatchesOnCodeSection

mov rax,ModuleAddress
add eax,EntryPointAddress
call rax  ; cal entry point!

mov rax,ModuleAddress
add rax,specialinitmethodRVA
call rax  ; cal special init method

; 0000000001B6B5E4 | 48 83 EC 28                              | sub rsp,28                                                       |
; 0000000001B6B5E8 | 48 83 3D F8 2F 0A 00 00                  | cmp qword ptr ds:[1C0E5E8],0                                     |
; 0000000001B6B5F0 | 75 16                                    | jne gcdtray.1B6B608                                              |
; 0000000001B6B5F2 | B9 02 00 04 00                           | mov ecx,40002                                                    |
; 0000000001B6B5F7 | E8 0C 2D 01 00                           | call gcdtray.1B7E308                                             |
; 0000000001B6B5FC | 48 85 C0                                 | test rax,rax                                                     |
; 0000000001B6B5FF | 48 89 05 E2 2F 0A 00                     | mov qword ptr ds:[1C0E5E8],rax                                   |
; 0000000001B6B606 | 74 05                                    | je gcdtray.1B6B60D                                               |
; 0000000001B6B608 | B8 01 00 00 00                           | mov eax,1                                                        |
; 0000000001B6B60D | 48 83 C4 28                              | add rsp,28                                                       |
; 0000000001B6B611 | C3                                       | ret                                                              |

; v4.3
; 0000000001B3B56C | 48 83 EC 28                              | sub rsp,28                                                       |
; 0000000001B3B570 | 48 83 3D B0 61 0A 00 00                  | cmp qword ptr ds:[1BE1728],0                                     |
; 0000000001B3B578 | 75 16                                    | jne gcdtray.1B3B590                                              |
; 0000000001B3B57A | B9 02 00 04 00                           | mov ecx,40002                                                    |
; 0000000001B3B57F | E8 90 2E 01 00                           | call gcdtray.1B4E414                                             |
; 0000000001B3B584 | 48 85 C0                                 | test rax,rax                                                     |
; 0000000001B3B587 | 48 89 05 9A 61 0A 00                     | mov qword ptr ds:[1BE1728],rax                                   |
; 0000000001B3B58E | 74 05                                    | je gcdtray.1B3B595                                               |
; 0000000001B3B590 | B8 01 00 00 00                           | mov eax,1                                                        |
; 0000000001B3B595 | 48 83 C4 28                              | add rsp,28                                                       |
; 0000000001B3B599 | C3                                       | ret                                                              |


call GetSecondParameter
test eax,eax
jz ShowMainDialog

mov rsi,rax

mov rcx,rax ; parameter for UniStrLen
call UniStrLen
mov rcx,rax
mov rdi,UnicodeImageName
rep movsb

call MountImage

jmp ExitProcessLoc

ShowMainDialog:
call WinMain2


ExitProcessLoc:
invoke ExitProcess,NULL


WinMain endp

MountImage proc
mov rdx,08074h
mov rcx,ModuleAddress
add rcx,0ACDC0h
; 0000000001C0CDC0  58 60 BF 01 00 00 00 00 01 00 00 00 00 00 00 00
mov rax,ModuleAddress
add rax,1FD0h

cmp byte ptr [rax],048h
jz CallIt

mov rax,ModuleAddress
add rax,1FCCh
cmp byte ptr [rax],048h
jnz ReturnFromIt
mov rcx,ModuleAddress
add rcx,0AFF00h

CallIt:
call rax ; finnaly browse for image!

; 0000000001B61FD0 | 48 53                                    | push rbx                                                         |
; 0000000001B61FD2 | 57                                       | push rdi                                                         |
; 0000000001B61FD3 | 48 83 EC 28                              | sub rsp,28                                                       |
; 0000000001B61FD7 | 8D 82 8C 7F FF FF                        | lea eax,dword ptr ds:[rdx-8074]                                  |
; 0000000001B61FDD | 48 8B F9                                 | mov rdi,rcx                                                      |
; 0000000001B61FE0 | 83 F8 16                                 | cmp eax,16                                                       |
; 0000000001B61FE3 | 77 35                                    | ja gcdtray.1B6201A                                               |
; 0000000001B61FE5 | 8B 05 8D B4 0A 00                        | mov eax,dword ptr ds:[1C0D478]                                   |
; 0000000001B61FEB | 8D 9A 8C 7F FF FF                        | lea ebx,dword ptr ds:[rdx-8074]                                  |
; 0000000001B61FF1 | 85 C0                                    | test eax,eax                                                     |
; 0000000001B61FF3 | 7F FC                                    | jg gcdtray.1B61FF1                                               |
; 0000000001B61FF5 | FF C8                                    | dec eax                                                          |
; 0000000001B61FF7 | 89 05 7B B4 0A 00                        | mov dword ptr ds:[1C0D478],eax                                   |
; 0000000001B61FFD | E8 06 78 01 00                           | call gcdtray.1B79808                                             |
; 0000000001B62002 | 85 C0                                    | test eax,eax                                                     |
; 0000000001B62004 | 74 0E                                    | je gcdtray.1B62014                                               |
; 0000000001B62006 | 48 8B 4F 38                              | mov rcx,qword ptr ds:[rdi+38]                                    |
; 0000000001B6200A | 45 33 C0                                 | xor r8d,r8d                                                      |
; 0000000001B6200D | 8B D3                                    | mov edx,ebx                                                      |
; 0000000001B6200F | E8 0C 96 01 00                           | call gcdtray.1B7B620                                             |
; 0000000001B62014 | FF 0D 5E B4 0A 00                        | dec dword ptr ds:[1C0D478]                                       |
; 0000000001B6201A | 48 83 C4 28                              | add rsp,28                                                       |
; 0000000001B6201E | 5F                                       | pop rdi                                                          |
; 0000000001B6201F | 5B                                       | pop rbx                                                          |
; 0000000001B62020 | C3                                       | ret                                                              |

; v4.3 Address=00000000001E0000
; 00000000001E1FCC | 48 53                                    | push rbx                                                         |
; 00000000001E1FCE | 57                                       | push rdi                                                         |
; 00000000001E1FCF | 48 83 EC 28                              | sub rsp,28                                                       |
; 00000000001E1FD3 | 8D 82 8C 7F FF FF                        | lea eax,dword ptr ds:[rdx-8074]                                  |
; 00000000001E1FD9 | 48 8B F9                                 | mov rdi,rcx                                                      |
; 00000000001E1FDC | 83 F8 16                                 | cmp eax,16                                                       |
; 00000000001E1FDF | 77 35                                    | ja gcdtray.1E2016                                                |
; 00000000001E1FE1 | 8B 05 D1 E5 0A 00                        | mov eax,dword ptr ds:[2905B8]                                    |
; 00000000001E1FE7 | 8D 9A 8C 7F FF FF                        | lea ebx,dword ptr ds:[rdx-8074]                                  |
; 00000000001E1FED | 85 C0                                    | test eax,eax                                                     |
; 00000000001E1FEF | 7F FC                                    | jg gcdtray.1E1FED                                                |
; 00000000001E1FF1 | FF C8                                    | dec eax                                                          |
; 00000000001E1FF3 | 89 05 BF E5 0A 00                        | mov dword ptr ds:[2905B8],eax                                    |
; 00000000001E1FF9 | E8 16 79 01 00                           | call gcdtray.1F9914                                              |
; 00000000001E1FFE | 85 C0                                    | test eax,eax                                                     |
; 00000000001E2000 | 74 0E                                    | je gcdtray.1E2010                                                |
; 00000000001E2002 | 48 8B 4F 38                              | mov rcx,qword ptr ds:[rdi+38]                                    |
; 00000000001E2006 | 45 33 C0                                 | xor r8d,r8d                                                      |
; 00000000001E2009 | 8B D3                                    | mov edx,ebx                                                      |
; 00000000001E200B | E8 1C 97 01 00                           | call gcdtray.1FB72C                                              |
; 00000000001E2010 | FF 0D A2 E5 0A 00                        | dec dword ptr ds:[2905B8]                                        |
; 00000000001E2016 | 48 83 C4 28                              | add rsp,28                                                       |
; 00000000001E201A | 5F                                       | pop rdi                                                          |
; 00000000001E201B | 5B                                       | pop rbx                                                          |
; 00000000001E201C | C3                                       | ret                                                              |

ReturnFromIt:
leave
ret
MountImage endp

GetSecondParameter proc
invoke GetCommandLineW
invoke CommandLineToArgvW, eax, OFFSET nArgs

mov rdx,rax

mov rax, qword ptr [nArgs]
cmp rax,1
ja MoreThenOne

xor rax,rax
leave
ret

MoreThenOne:
mov rcx,01 ; second paramter
mov rax,qword ptr [rdx+8*rcx]

leave
ret
GetSecondParameter endp

StrLen proc
xor rax,rax
mov rdi,rcx ;  parm:DWORD

test rdi,rdi
jnz l1
leave
ret

l1:
cmp byte ptr [rdi] ,0
je l2
inc rdi
inc rax
jmp l1
l2:

leave
ret
StrLen endp

StrCat  proc

LOCAL str1:QWORD         ;; local variables
LOCAL str2:QWORD         ;; local variables
LOCAL str1_len:QWORD         ;; local variables
LOCAL str2_len:QWORD         ;; local variables

test rcx,rcx ; str1
jnz NextTest1
xor rax,rax
leave
ret
NextTest1:

test rdx,rdx ; str2
jnz NextTest2
xor rax,rax
leave
ret

NextTest2:
mov str1,rcx
mov str2,rdx

mov rcx,str1
call StrLen
mov str1_len,rax

mov rcx,rdx ; str2
call StrLen
mov str2_len,rax

add rax,rcx
inc rax ; we also need an 0 at the end

; invoke VirtualAlloc, NULL, rax, MEM_COMMIT, PAGE_READWRITE
invoke GlobalAlloc, GPTR, eax

push rax
mov rdi,rax ; destination = new alocate memory
mov rsi,str1
mov rcx,str1_len
rep movsb

mov rcx,str2_len
mov rsi,str2
rep movsb
mov byte ptr [rdi],0 ; mark the end of string
pop rax
ret
StrCat  endp

UniStrLen PROC ; rcx = _string:QWORD

    push rcx
    mov     rax,rcx
    mov     rcx,2
    sub     rax,rcx
@@:
    add     rax,rcx
    cmp     WORD PTR [rax],0
    jne     @b
    pop rcx
    sub     rax,rcx
    ; shr     rax,1
    leave
    ret

UniStrLen ENDP

WinMain2 proc 
	; enter 30h,0
	xor ebx,ebx
	mov rcx,400000h
	mov edx,IDC_DIALOG
	mov r8,rbx
	mov r9d,offset dialog_procedure
	; mov qword ptr [esp+20h],IDC_MENU
	call DialogBoxParam
      leave
      ret
WinMain2 endp

dialog_procedure:
size_of_buffer	equ 96
buffer2	equ [rbp-size_of_buffer]
	enter 20h+size_of_buffer,0
      mov HandleWindow,rcx ; first parameter
	cmp edx,WM_CLOSE
	je wmCLOSE
	cmp edx,WM_INITDIALOG
	je wmINITDIALOG
	cmp edx,WM_COMMAND
	jne wmBYE
wmCOMMAND:movzx eax,r8w	;movzx eax,word ptr wParam
	; cmp r9,rbx	;cmp lParam,0
	; jnz @f
	; jmp [menu_handlers+eax*8]
@@:	dec eax 	;cmp eax,IDC_BUTTON=1
	jne @f

BrowseForFile:
      mov r8d,offset expTxt
	invoke RtlZeroMemory, ADDR ofn, sizeof ofn

	mov ofn.lStructSize,sizeof ofn
	mov rax,HandleWindow
	mov  ofn.hwndOwner,rax
	lea rax, SuportedExtensions ; FileDefExt
	mov ofn.lpstrFilter,rax
	lea rax,szFileName
	mov ofn.lpstrFile,rax
	mov ofn.nMaxFile,MAX_PATH
	lea rax,DefExt
	mov ofn.lpstrDefExt,rax
	mov ofn.Flags,OFN_EXPLORER OR OFN_PATHMUSTEXIST OR OFN_HIDEREADONLY OR OFN_OVERWRITEPROMPT
    
	lea rcx,ofn
	call GetOpenFileNameA ;,rcx
	   .if rax
		invoke GetDlgItem, HandleWindow, IDC_EDIT1
		invoke SetWindowText, eax, ADDR szFileName

	   .endif

	jmp @0

@@:	dec eax 	;cmp eax,IDC_Button=2
	jne @f

invoke GetDlgItem, HandleWindow, IDC_EDIT1
invoke GetWindowTextW, eax,UnicodeImageName,1024

call MountImage

@@:	dec eax 	;cmp eax,IDC_Button=3 - Exit
	jne wmBYE

	mov edx,WM_CLOSE
	mov r8,rbx
	mov r9,rbx
	call SendMessage
	jmp wmBYE

wmINITDIALOG:xor edx,edx
      call GetDlgItem
      mov HandleWindow,rax
	mov ecx,eax
	call SetFocus
	jmp wmBYE

CLEAR:	mov r8,rbx
@0:	xor edx,edx 
	call SetDlgItemText
	jmp wmBYE

GETTEXT:
	xor edx,edx
	lea r8d,buffer2
	mov r9d,size_of_buffer
	call GetDlgItemText
	xor ecx,ecx
	mov r9,rcx
	mov r8d,offset AppName
	lea edx,buffer
	call MessageBox
	jmp wmBYE

wmCLOSE:xor edx,edx
	call EndDialog	
wmBYE:  xor eax,eax
	leave
	retn


end

