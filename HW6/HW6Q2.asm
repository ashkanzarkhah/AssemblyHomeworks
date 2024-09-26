section .data
    M TIMES 10000 db 0
    n dq 0
    m dq 0

section .text
    global _start

_start:
    call getMatrix

    push rax
    call findMax
    pop rax

    call writeNum

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

    NL            equ   0xA
    Space         equ   0x20
;----------------------------------------------------
;Gets matrix from the input
getMatrix:
    push rax
    push rcx
    push rdi
    push rdx

    call readNum
    mov [n], rax
    mov rdi, M

    mov rcx, rax

getMatrixL1:
    
    push rcx
    mov rcx, rax
    mov rdx, 0

getMatrixL2:
    push rax
    call getc
    sub rax, 48
    mov [rdi], al
    inc rdx
    call getc
    cmp rax, NL
    jne getMatrixL2C
    mov [m], rdx
    mov rdx, 0
getMatrixL2C:
    pop rax

    inc rdi
    dec rcx
    cmp rdx, 0
    jg getMatrixL2

    pop rcx
    dec rcx
    cmp rcx, 0
    jg getMatrixL1

    pop rdx
    pop rdi
    pop rcx
    pop rax
    ret
;----------------------------------------------------
;finds the maximum submatrix of M
findMax:
    push rbp
    mov rbp, rsp
    push rcx
    push rdx
    push rax
    push rsi
    push rdi
    push rbx

    mov rcx, [n]
    cmp rcx, [m]
    jle findMaxLT
    mov rcx, [m]
findMaxLT:
    mov rsi, rcx
findMaxLX:
    mov rdi, rcx
findMaxLY:
    mov rax, 1
    mov rbx, 0
findMaxLx:
    mov rdx, 0
findMaxLy:
    push rsi
    push rdi

    sub rsi, rbx
    sub rdi, rdx

    push rsi
    push rdi
    call getMatrixIndex
    pop rdi
    pop rsi   

    cmp byte [rsi], 1
    je findMaxLyC
    mov rax, 0

findMaxLyC:
    pop rdi
    pop rsi

    inc rdx
    cmp rdx, rcx
    jl findMaxLy

    inc rbx
    cmp rbx, rcx
    jl findMaxLx
    
    cmp rax, 0
    je findMaxLYC
    mov rax, rcx
    jmp findMaxEnd

findMaxLYC:
    inc rdi
    cmp rdi, [m]
    jle findMaxLY

    inc rsi
    cmp rsi, [n]
    jle findMaxLX

    dec rcx
    cmp rcx, 0
    jg findMaxLT

    mov rax, 0
findMaxEnd:
    mov [rbp + 16], rax
    pop rbx
    pop rdi
    pop rsi
    pop rax
    pop rdx
    pop rcx
    pop rbp
    ret
;----------------------------------------------------
getMatrixIndex:
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    push rax
    push rdx

    mov rdi, [rbp + 16]
    mov rsi, [rbp + 24]
    dec rsi
    dec rdi
    mov rax, rsi
    mov rsi, [m]
    mul rsi
    add rax, rdi
    add rax, M
    mov [rbp + 24], rax

    pop rdx
    pop rax
    pop rdi
    pop rsi
    pop rbp
    ret
;----------------------------------------------------
;Get the input string in rsi
getString:
    push rsi
    push rax
    
getStringL:
    call getc
    cmp al, NL
    jne getStringLE
    jmp getStringE
getStringLE:
    mov [rsi], al
    inc rsi
    jmp getStringL

getStringE:
    pop rax
    pop rsi
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