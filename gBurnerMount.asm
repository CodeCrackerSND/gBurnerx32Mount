.486
.model flat, stdcall
option casemap:none   ; Case sensitive

include  \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\shell32.inc
include \masm32\include\comctl32.inc
include \masm32\include\comdlg32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\comdlg32.lib

include dissasm.asm

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
GetTextSection PROTO   :DWORD
GetDataSection PROTO   :DWORD
GetImageSize  PROTO   :DWORD
FixCodeSection PROTO
StrLen     PROTO   :DWORD
StrCat     PROTO   :DWORD,:DWORD
UniStrLen  PROTO   :DWORD
FixImports  PROTO   :DWORD
IsUnicodeDword  PROTO   :DWORD
IsUnicodeDwordRev  PROTO   :DWORD
IsValidChar  PROTO   :DWORD


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

InstrTest   DB 46h, 00, 69h, 00

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

ModuleAddress dd 0
OldImageBase dd 0400000h
TextVirtualAddress dd 0
TextVirtualSize dd 0
TextRawSize dd 0
DataVirtualAddress dd 0
DataVirtualSize dd 0
RDataVirtualAddress dd 0
RDataVirtualSize dd 0
IMAGE_DATA_DIRECTORY_VA dd 0
ImportedModuleAddress dd 0
RelovedApiAddress dd 0
ThunkAddress dd 0
ModuleToFixAddress dd 0
EntryPointAddress dd 0
ImageSize dd 0

RCX_register dd 0
RSI_register dd 0
RDI_register dd 0
HandleWindow dd 0
HandleFileToClose dd 0
UnicodeImageName dd 0
specialinitmethodRVA dd 0
DwordFixedCount dd 0

DefaultPath db 'C:\Program Files\gBurner Virtual Drive\GCDTRAY.EXE',0
ProcessName db 'GCDTRAY.EXE',0
ProcessPathName dd 0
DlgName db "MyDialog",0
ModuleLocKeeper dd 0
ClassName db "DLGCLASS",0
MenuName db "MyMenu",0

expTxt	 	db "Wow! I'm in an edit box now",0
AppName	 	db 'Our First Dialog Box',0
Slash db '\',0

.data?
oldprotect dd ?
newprotect dd ?
ofn OPENFILENAME <>
CurrentDirectory db 2512 dup(?)
hInstance HINSTANCE ?

.const
IDC_DIALOG  equ 200
IDC_EDIT1   equ 100
IDC_BUTTON1 equ 1
IDC_BUTTON2 equ 2
IDC_BUTTON3 equ 3
CP_ACP  equ 0

.code

MountImage proc
; Mount image
push 08074h
mov ecx,ModuleAddress
add ecx,0A8768h
; 0000000001C0CDC0  58 60 BF 01 00 00 00 00 01 00 00 00 00 00 00 00
mov eax,ModuleAddress
add eax,01F6F0h
call eax

ReturnFromIt:
ret
MountImage endp

GetSecondParameter proc
invoke GetCommandLineW
invoke CommandLineToArgvW, eax, OFFSET nArgs

mov edx,eax

mov eax, dword ptr [nArgs]
cmp eax,1
ja MoreThenOne

xor eax,eax
ret

MoreThenOne:
mov ecx,01 ; second paramter
mov eax,dword ptr [edx+4*ecx]

ret
GetSecondParameter endp


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	.if uMsg == WM_INITDIALOG
	
	.elseif uMsg == WM_COMMAND

		.if wParam == IDC_BUTTON1
                   mov ofn.lStructSize,sizeof ofn 
                   mov ofn.lpstrFilter, offset SuportedExtensions ; FileDefExt
                   mov ofn.lpstrFile, offset szFileName
                   mov ofn.nMaxFile,MAX_PATH
                   mov ofn.lpstrDefExt, offset DefExt
                   mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY 
                   invoke GetOpenFileName, ADDR ofn
                   .if eax==TRUE
                   invoke SetDlgItemText,hWnd,IDC_EDIT1,ADDR szFileName
                   
                  .endif

		.elseif wParam == IDC_BUTTON2

            invoke GetDlgItem, hWnd, IDC_EDIT1
            invoke GetWindowTextW, eax,ADDR UnicodeImageName,1024
            call MountImage

		.elseif wParam == IDC_BUTTON3
		invoke SendMessage, hWnd, WM_CLOSE, 0, 0
		.endif			
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, 0
	.endif

	xor	eax,eax
	ret

WndProc endp

StrLen proc  uses ebx ecx edx esi edi parm:DWORD
xor eax,eax
mov edi,parm
.if (edi==0)
ret
.endif
l1:
cmp byte ptr [edi] ,0
je l2
inc edi
inc eax
jmp l1
l2:

ret
StrLen endp

StrCat  proc uses esi edi ebx edx str1:DWORD,str2:DWORD
.if (str1==0&&str2==0)
xor eax,eax
ret
.endif

invoke StrLen,str1
mov ecx,eax
invoke StrLen,str2
add eax,ecx
inc eax ; we also need an 0 at the end

; invoke VirtualAlloc, NULL, eax, MEM_COMMIT, PAGE_READWRITE
invoke GlobalAlloc, GPTR, eax


push eax
mov edi,eax ; destination = new alocate memory
invoke StrLen,str1
mov ecx,eax
mov esi,str1
rep movsb

invoke StrLen,str2
mov ecx,eax
mov esi,str2
rep movsb
mov byte ptr [edi],0 ; mark the end of string
pop eax
ret
StrCat  endp

UniStrLen PROC str1:DWORD

    mov ecx,str1
    push ecx
    mov     eax,ecx
@@:
    add     eax,2
    cmp     WORD PTR [eax],0
    jne     @b
    pop ecx
    sub     eax,ecx
    ; shr     eax,1
    ; leave
    ret

UniStrLen ENDP

SaveRegisters proc
mov RCX_register,ecx
mov RSI_register,esi
mov RDI_register,edi
ret
SaveRegisters endp

RestoreRegisters proc
mov ecx,RCX_register
mov esi,RSI_register
mov edi,RDI_register
ret
RestoreRegisters endp

FixImports proc baseadr:DWORD

.if (baseadr==0)
ret
.endif

mov ecx,baseadr
mov ModuleToFixAddress,ecx

xor eax,eax
mov eax,dword ptr [ecx+03Ch]
add eax,ecx
add eax,080h
mov edx,dword ptr [eax]
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
invoke LoadLibrary, eax
mov ImportedModuleAddress,eax
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
mov ebx,eax
and ebx,080000000h
cmp ebx,0
jbe ImportByName  ; jump
and eax,0ffffh

jmp NextPlease

ImportByName:
add eax, dword ptr [ModuleToFixAddress]
add eax,ByNameImportOff ; here is the function name

NextPlease:

invoke GetProcAddress,ImportedModuleAddress, eax
mov RelovedApiAddress,eax

; make addresses writable:
invoke VirtualProtect, ThunkAddress, 4, PAGE_EXECUTE_READWRITE, ADDR oldprotect

mov edi,ThunkAddress
mov eax,dword ptr [RelovedApiAddress]
mov dword ptr [edi],eax  ; fix the thunk!


call RestoreRegisters

ImportByOrdinalPlease:
add ThunkAddress,4
add edi,4 ; IMAGE_IMPORT_BY_NAME_Size
jmp StartOfThunksLoop

ThunksFinished:


add esi,IMAGE_IMPORT_DESCRIPTOR_SIZE
jmp StartChecking

ImportParseFinished:

ret

FixImports endp

GetTextSection proc baseadr:DWORD

.if (baseadr==0)
ret
.endif

mov ecx,baseadr
xor eax,eax
mov eax,dword ptr [ecx+03Ch]
add eax,ecx

xor edx,edx ; edx = section index
StartLoop:
mov esi,edx
imul esi,SizeOfASection
cmp byte ptr [eax+esi+0F8h],'.'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+1],'t'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+2],'e'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+3],'x'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+4],'t'
jnz NextPlease
jmp GetSection

NextPlease:
inc edx
jmp StartLoop

GetSection:
mov esi,edx
imul esi,SizeOfASection
mov ebx,dword ptr [eax+esi+0F8h+8]
mov TextVirtualSize,ebx

mov ebx,dword ptr [eax+esi+0F8h+8+4]
mov TextVirtualAddress,ebx

mov ebx,dword ptr [eax+esi+0F8h+8+4+4]
mov TextRawSize,ebx


ret
GetTextSection endp

GetDataSection proc baseadr:DWORD

.if (baseadr==0)
ret
.endif

mov ecx,baseadr
xor eax,eax
mov eax,dword ptr [ecx+03Ch]
add eax,ecx

xor edx,edx ; edx = section index
StartLoop:
mov esi,edx
imul esi,SizeOfASection
cmp byte ptr [eax+esi+0F8h],'.'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+1],'d'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+2],'a'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+3],'t'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+4],'a'
jnz NextPlease
jmp GetSection

NextPlease:
inc edx
jmp StartLoop

GetSection:
mov esi,edx
imul esi,SizeOfASection
mov ebx,dword ptr [eax+esi+0F8h+8]
mov DataVirtualSize,ebx

mov ebx,dword ptr [eax+esi+0F8h+8+4]
mov DataVirtualAddress,ebx

ret
GetDataSection endp

GetRDataSection proc baseadr:DWORD

.if (baseadr==0)
ret
.endif

mov ecx,baseadr

xor eax,eax
mov eax,dword ptr [ecx+03Ch]
add eax,ecx

xor edx,edx ; edx = section index
StartLoop:
mov esi,edx
imul esi,SizeOfASection
cmp byte ptr [eax+esi+0F8h],'.'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+1],'r'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+2],'d'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+3],'a'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+4],'t'
jnz NextPlease
cmp byte ptr [eax+esi+0F8h+5],'a'
jnz NextPlease
jmp GetSection

NextPlease:
inc edx
jmp StartLoop

GetSection:
mov esi,edx
imul esi,SizeOfASection
mov ebx,dword ptr [eax+esi+0F8h+8]
mov RDataVirtualSize,ebx

mov ebx,dword ptr [eax+esi+0F8h+8+4]
mov RDataVirtualAddress,ebx

ret

GetRDataSection endp

GetEntryPoint proc baseadr:DWORD

.if (baseadr==0)
ret
.endif

xor eax,eax
mov eax,dword ptr [ecx+03Ch]
add eax,ecx

mov eax,dword ptr [eax+028h]
mov EntryPointAddress,eax

ret

GetEntryPoint endp

GetOldImageBase proc baseadr:DWORD

.if (baseadr==0)
ret
.endif

xor eax,eax
mov eax,dword ptr [ecx+03Ch]
add eax,ecx

mov eax,dword ptr [eax+034h]
mov OldImageBase,eax
 
ret

GetOldImageBase endp


GetImageSize proc baseadr:DWORD

.if (baseadr==0)
ret
.endif

xor eax,eax
mov eax,dword ptr [ecx+03Ch]
add eax,ecx

mov eax,dword ptr [eax+050h]
mov ImageSize,eax
 
ret

GetImageSize endp

FixDataDwords proc

cmp DataVirtualSize,0
jz ReturnFromIt
cmp DataVirtualAddress,0
jz ReturnFromIt

xor ecx,ecx
mov ecx,DataVirtualSize
xor ebx,ebx
mov ebx, DataVirtualAddress
add ebx,ModuleAddress

BeginOfLoop:
mov eax,OldImageBase
cmp dword ptr [ebx],eax
jl NextOnePlease

mov eax,OldImageBase
add eax,ImageSize
cmp dword ptr [ebx],eax
ja NextOnePlease

mov edx,dword ptr [ebx]
sub edx, OldImageBase
add edx, ModuleAddress ; now we have the new address

invoke IsUnicodeDword, ebx ; check for both normal and reverse way
.if (eax==0)
invoke IsUnicodeDwordRev, ebx
.if (eax==0)
mov dword ptr [ebx],edx ; fix it!
.endif
.endif

NextOnePlease:
inc ebx
dec ecx
test ecx,ecx
jnz BeginOfLoop

ReturnFromIt:
ret

FixDataDwords endp

IsUnicodeDword proc uses ebx parm:DWORD

mov ebx,parm

.if (word ptr [ebx]!=0)

invoke IsValidChar,ebx
.if (eax==0) ; if char 0 not a valid char
xor eax,eax
ret
.endif

.if (byte ptr [ebx+1]!=0)
xor eax,eax
ret
.endif

.endif


add ebx,02
.if (word ptr [ebx]!=0)
invoke IsValidChar,ebx
.if (eax==0) ; if char 0 not a valid char
xor eax,eax
ret
.endif

.if (byte ptr [ebx+1]!=0)
xor eax,eax
ret
.endif

.endif


mov eax,01
ret

IsUnicodeDword endp

IsUnicodeDwordRev proc uses ebx parm:DWORD

mov ebx,parm

.if (word ptr [ebx]!=0)

.if (byte ptr [ebx]!=0)
xor eax,eax
ret
.endif

inc ebx

invoke IsValidChar,ebx
.if (eax==0) ; if char 0 not a valid char
xor eax,eax
ret
.endif

.endif


inc ebx

.if (word ptr [ebx]!=0)

.if (byte ptr [ebx]!=0)
xor eax,eax
ret
.endif

inc ebx

invoke IsValidChar,ebx
.if (eax==0) ; if char 0 not a valid char
xor eax,eax
ret
.endif

.endif

mov eax,01
ret

IsUnicodeDwordRev endp

IsValidChar proc parm:DWORD

mov ebx,parm

.if (byte ptr [ebx]==' '||byte ptr [ebx]=='/'||byte ptr [ebx]==':')
mov eax,01
ret
.endif

.if (byte ptr [ebx]=='['||byte ptr [ebx]==']'||byte ptr [ebx]=='@')
mov eax,01
ret
.endif

.if ((byte ptr [ebx]>=030h)&&(byte ptr [ebx]<=039h)) ; is number
mov eax,01
ret
.endif

.if ((byte ptr [ebx]>=041h)&&(byte ptr [ebx]<=05Ah)) ; is low letter
mov eax,01
ret
.endif

.if ((byte ptr [ebx]>=061h)&&(byte ptr [ebx]<=07Ah)) ; is upper letter
mov eax,01
ret
.endif

xor eax,eax
ret

IsValidChar endp


FixRDataDwords proc

cmp RDataVirtualSize,0
jz ReturnFromIt
cmp RDataVirtualAddress,0
jz ReturnFromIt


; make addresses writable:
mov ecx, RDataVirtualAddress ; RCX = lpAddress
add ecx,ModuleAddress
invoke VirtualProtect, ecx, RDataVirtualSize, PAGE_EXECUTE_READWRITE, ADDR oldprotect

xor ecx,ecx
mov ecx,RDataVirtualSize
sub ecx,04
xor ebx,ebx
mov ebx, RDataVirtualAddress
add ebx,ModuleAddress

BeginOfLoop:
mov eax,OldImageBase
cmp dword ptr [ebx],eax
jl NextOnePlease

mov eax,OldImageBase
add eax,ImageSize
cmp dword ptr [ebx],eax
ja NextOnePlease

; cmp ebx,049A7E0h
; jnl MyStuf2

mov edx,dword ptr [ebx]
sub edx, OldImageBase
add edx, ModuleAddress ; now we have the new address

mov dword ptr [ebx],edx ; fix it!

NextOnePlease:
inc ebx
dec ecx
test ecx,ecx
jnz BeginOfLoop

mov ecx, RDataVirtualAddress ; RCX = lpAddress
add ecx,ModuleAddress
invoke VirtualProtect, ecx, RDataVirtualSize, oldprotect, ADDR newprotect

ReturnFromIt:
ret


MyStuf2:
mov eax,022h

FixRDataDwords endp

FixCodeSection proc

; We first need to make this page writeable
mov ecx, TextVirtualAddress ; RCX = lpAddress
add ecx,ModuleAddress
invoke VirtualProtect, ecx, TextRawSize, PAGE_EXECUTE_READWRITE, ADDR oldprotect

; 00000000001D91BF | FF 15 6B FF 01 00   call qword ptr ds:[1F9130]
; the value = just relative offset

cmp TextRawSize,0
jz ReturnFromIt
cmp TextVirtualAddress,0
jz ReturnFromIt

mov ebx,TextVirtualAddress
add ebx,ModuleAddress

LoopBegin1:

.if (ebx>=0A675C0h)
mov eax,12345678h
.endif

pushad ; save all registers - recommanded
invoke Dissasm, ebx, 0
popad ; restore all registers - recommanded

mov edx, DisplOffset
call FixOneDword

mov edx, DisplOffset2
call FixOneDword

NextOnePlease:
add ebx,InstructionSize

mov eax,TextVirtualAddress
add eax,ModuleAddress
add eax,TextRawSize
cmp ebx,eax
jl LoopBegin1

; restore old protection:
mov ecx, TextVirtualAddress ; RCX = lpAddress
add ecx,ModuleAddress
invoke VirtualProtect, ecx, TextRawSize, oldprotect, ADDR newprotect

ReturnFromIt:

ret


SecretPlace:
mov eax,03

FixCodeSection endp

FixOneDword proc
; input: edx = offset to be fixed
; ebx = address of instruction

.if (edx!=0)
add edx,ebx
mov eax,OldImageBase
cmp dword ptr [edx],eax ; is it > OldImageBase ?
jl ReturnPlease

mov eax,OldImageBase ; is it < OldImageBase+ImageSize ?
add eax,ImageSize
cmp dword ptr [edx],eax
ja ReturnPlease

FixItPlease:
mov esi,dword ptr [edx]
sub esi, OldImageBase
add esi, ModuleAddress ; now we have the new address

mov dword ptr [edx],esi ; fix it!

; here fix dwords from code section
mov DwordFixedCount,0

mov edi,dword ptr [edx] ; the address pointer - dword ptr [edx] is already checked before

BeginOfDwordsFixing:
inc DwordFixedCount

mov esi,dword ptr [edi] ; the actual pointer value which will be incremented by 4
; edi = pointer, esi = value

.if ((esi<OldImageBase)&&(DwordFixedCount>1)) ; first one should not skipp the loop
jmp ReturnPlease ; skipp these bogus values
.endif

mov eax,OldImageBase
add eax,ImageSize

.if ((esi>eax)&&(DwordFixedCount>1)) ; first one should not skipp the loop
jmp ReturnPlease ; skipp these bogus values
.endif

.if ((esi>OldImageBase)&&(esi<eax)&&(byte ptr [edi+1]!=0E8h)&&(byte ptr [edi+1]!=0E9h))
; make sure once again we have a right dword - here are reverse

invoke IsUnicodeDword, edi
.if (eax==0)
sub esi, OldImageBase
add esi, ModuleAddress ; now we have the new address
mov dword ptr [edi],esi ; fix it!
.endif
.endif

add edi,04 ; next dword
jmp BeginOfDwordsFixing

.endif

ReturnPlease:
ret

FixOneDword endp

PatchesOnCodeSection proc

; We first need to make this page writeable
mov ecx, TextVirtualAddress ; RCX = lpAddress
add ecx,ModuleAddress
invoke VirtualProtect, ecx, TextRawSize, PAGE_EXECUTE_READWRITE, ADDR oldprotect

; 00A91F99  |.  56            PUSH ESI                                 ; /pModule
; 00A91F9A  |.  FF15 B461AA00 CALL DWORD PTR DS:[AA61B4]               ; \GetModuleHandleA
; 00A91FA0  |.  50            PUSH EAX
; 00A91FA1  |.  E8 D1A20000   CALL 00A9C277                            ;  GCDTRAY.00A9C277
; to Address=00A70000
; 00A91F99      B8 34120000     MOV EAX,1234
; 00A91F9E      90              NOP
; 00A91F9F      90              NOP

mov ebx,ModuleAddress ; the program - fix image base
add ebx,021F99h
mov byte ptr [ebx], 0B8h
mov eax,ModuleAddress
mov dword ptr [ebx+1], eax
mov word ptr [ebx+1+4], 9090h

; Fix browse for image:
mov ebx,ModuleAddress
add ebx,073E2h
mov byte ptr [ebx], 0B8h
lea eax,UnicodeImageName
mov dword ptr [ebx+1], eax
mov dword ptr [ebx+1+4], 90909090h
mov word ptr [ebx+1+4+4], 9090h
mov byte ptr [ebx+1+4+4+2], 90h

; 00A673F0  |.  83C4 0C             ADD ESP,0C
mov ebx,ModuleAddress
add ebx,073F0h
mov word ptr [ebx], 9090h
mov byte ptr [ebx+2], 90h

mov ebx,ModuleAddress
add ebx,031F81h
mov word ptr [ebx], 9090h
mov byte ptr [ebx+2], 90h

; 00A930E0  /$  57                 PUSH EDI
; 00A930E1  |.  E8 9F000000        CALL 00A93185                            ;  GCDTRAY.00A93185
; 00A930E6  |.  6A 01              PUSH 1
; 00A930E8  |.  5F                 POP EDI
; 00A930E9  |.  393D 64B3B100      CMP DWORD PTR DS:[B1B364],EDI
; 00A930EF  |.  75 11              JNZ SHORT 00A93102                       ;  GCDTRAY.00A93102
; 00A930F1  |.  FF7424 08          PUSH DWORD PTR SS:[ESP+8]                ; /ExitCode
; 00A930F5  |.  FF15 1C62AA00      CALL DWORD PTR DS:[AA621C]               ; |[GetCurrentProcess
; 00A930FB  |.  50                 PUSH EAX                                 ; |hProcess
; 00A930FC  |.  FF15 3C61AA00      CALL DWORD PTR DS:[AA613C]               ; \TerminateProcess

mov ebx,ModuleAddress  ; don't kill process or delete critical sections
add ebx,0230E0h
mov byte ptr [ebx], 0C3h

mov ebx,ModuleAddress ; just return from called ep!
add ebx,021FAFh
mov dword ptr [ebx], 0C35DE58Bh

; restore old protection:
mov ecx, TextVirtualAddress ; RCX = lpAddress
add ecx,ModuleAddress
invoke VirtualProtect, ecx, TextRawSize, oldprotect, ADDR newprotect

ret

PatchesOnCodeSection endp

start:

invoke IsUnicodeDword, ADDR InstrTest

invoke GetCurrentDirectory, sizeof CurrentDirectory, ADDR CurrentDirectory
invoke StrCat, ADDR CurrentDirectory, ADDR Slash
invoke StrCat, eax, ADDR ProcessName
mov ModuleLocKeeper,eax

invoke CreateFile, ModuleLocKeeper, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
mov HandleFileToClose, eax
cmp eax,-1
jnz LoadLibraryNow
invoke CloseHandle, HandleFileToClose

NextTest:
invoke CreateFile, ADDR DefaultPath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
mov HandleFileToClose, eax

cmp eax,-1
jz LoadLibraryNow

mov ModuleLocKeeper,offset DefaultPath
invoke CloseHandle, HandleFileToClose

LoadLibraryNow:
invoke LoadLibrary,ModuleLocKeeper
test eax,eax
jz ExitProcessLoc
mov ModuleAddress,eax

; imports fixing
invoke FixImports, ModuleAddress

invoke GetTextSection, ModuleAddress
invoke GetDataSection, ModuleAddress

invoke GetEntryPoint, ModuleAddress
invoke GetOldImageBase, ModuleAddress
invoke GetImageSize, ModuleAddress

call FixDataDwords

invoke GetRDataSection, ModuleAddress
call FixRDataDwords

call FixCodeSection

call PatchesOnCodeSection

mov eax,ModuleAddress
add eax,EntryPointAddress
call eax  ; cal entry point!

call GetSecondParameter
test eax,eax
jz ShowMainDialog

mov esi,rax

; mov ecx,eax ; parameter for UniStrLen
invoke UniStrLen,eax
mov ecx,eax
lea edi,UnicodeImageName
rep movsb

call MountImage

jmp ExitProcessLoc

ShowMainDialog:

invoke GetModuleHandle, NULL
mov    hInstance,eax
invoke DialogBoxParam, hInstance, IDC_DIALOG, 0, addr WndProc, TRUE

ExitProcessLoc:
invoke ExitProcess,NULL

end start



end




