section .data
    n dq 0
    len dq 0
    ans dq 0
    input TIMES 4000 db 0
    cnt TIMES 30 dq 0
    yes db "TRUE", 0
    no db "FALSE", 0

section .text
    global _start
_start:
    mov rsi, input
    call getString

    call countChars

    call allCharsCheck

    cmp qword[ans], 1
    jl printNo

    mov rsi, yes
    call printString
    jmp VEND
printNo:
    mov rsi, no
    call printString
VEND:
    mov rax, 60
    mov rdi, 0
    syscall
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mkdir       equ 83
    sys_makenewdir  equ 0q777


    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
	PROT_NONE	  equ   0x0
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000


    BEG_FILE_POS    equ     0
    CURR_POS        equ     1
    END_FILE_POS    equ     2
    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0x2A
    Space         equ   0x20
;----------------------------------------------------
allCharsCheck:
    push rax
    push rcx

    mov rax, 0
allCharsCheckL:
    cmp qword [cnt + rax], 0
    je allCharsCheckLC
    inc rcx
allCharsCheckLC:
    add rax, 8
    cmp rax, 208
    jl allCharsCheckL

    cmp rcx, 26
    jl allCharsCheckE
    mov qword [ans], 1
allCharsCheckE:
    pop rax
    pop rcx
    ret
;----------------------------------------------------
countChars:
    push rax
    push rdx
    push rcx

    mov rcx, 0
countCharsL:
    mov rax, 0
    mov al, [input + rcx]
    sub rax, 97

    shl rax, 3
    mov rdx, [cnt + rax]
    inc rdx
    mov [cnt + rax], rdx

    inc rcx
    cmp rcx, [len]
    jl countCharsL

    pop rcx
    pop rdx
    pop rax
    ret
;----------------------------------------------------
getString:
    push rax
    push rcx

getStringL:
    call getc
    cmp al, 97
    jge getStringLC
    add al, 32
getStringLC:
    mov [rsi + rcx], al
    inc rcx
    cmp al, NL
    jne getStringL

    dec rcx
    mov [len], rcx

    pop rcx
    pop rax
    ret
;----------------------------------------------------
GetNumber:
    push rcx
    push rdx
    mov rcx, 3
    mov rax, 0
    
GetNumberLOP1:
    push rcx
    mov rcx, 4
    
    mov rdx, 10
    mul rdx
    push rax
    mov rax, 0
    
    GetNumberLOP2:
        mov rdx, 2
        mul rdx
        
        push rax
        mov rax, 0
        call getc
        SUB rax, 48
        mov rdx, rax
        pop rax
        
        add rax, rdx
        
        dec rcx
        JNZ GetNumberLOP2
    
    mov rdx, rax
    pop rax
    
    add rax, rdx
    
    pop rcx
    dec rcx
    JNZ GetNumberLOP1
GetNumberEND:   
    pop rdx
    pop rcx
    ret
;----------------------------------------------------
PrintNumber:
    push rcx
    push rdx
    mov rcx, 1
    
PrintNumberLOP1:
    push rax
    mov rax, rcx
    mov rdx, 2
    mul rdx
    mov rcx, rax
    pop rax
    
    CMP rcx, rax
    jle PrintNumberLOP1
    
    push rax
    mov rax, rcx
    mov rdx, 0
    mov rcx, 2
    div rcx
    mov rcx, rax
    pop rax
    
PrintNumberLOP2:
    CMP rax, rcx
    jge PrintNumberhave
PrintNumberdonthave:
    push rax
    mov rax, 48
    call putc
    pop rax
    jmp PrintNumberLOP2END
PrintNumberhave:
    push rax
    mov rax, 49
    call putc
    pop rax
    SUB rax, rcx
PrintNumberLOP2END:
    push rax
    mov rax, rcx
    mov rdx, 0
    mov rcx, 2
    div rcx
    mov rcx, rax
    pop rax
    
    CMP rcx, 0
    jne PrintNumberLOP2
    
PrintNumberEND:
    pop rdx
    pop rcx
    ret
;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx, rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
   push    rax
   push    rcx
   push    rsi
   push    rdx
   push    rdi

   mov     rdi, rsi
   call    GetStrlen
   mov     rax, sys_write  
   mov     rdi, stdout
   syscall 
   
   pop     rdi
   pop     rdx
   pop     rsi
   pop     rcx
   pop     rax
   ret
;-------------------------------------------
; rdi : zero terminated string start 
GetStrlen:
   push    rbx
   push    rcx
   push    rax  

   xor     rcx, rcx
   not     rcx
   xor     rax, rax
   cld
         repne   scasb
   not     rcx
   lea     rdx, [rcx -1]  ; length in rdx

   pop     rax
   pop     rcx
   pop     rbx
   ret
;-------------------------------------------