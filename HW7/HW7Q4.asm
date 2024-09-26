section .data
    input TIMES 1000 db 0
    output TIMES 1000 db 0
    cnt1 dq 0
    cnt0 dq 0
    n dq 0

section .text
    global _start

_start:
    mov rsi, input
    call getString
    
    call readNum

    push rax
    mov rcx, 2
    mov rdx, 0
    div rcx
    pop rax

    cmp rdx, 0
    jne ODD
EVEN:
    cmp rax, [cnt0]
    jg EVENC
    push rax
    call CFKZ
    pop rax
    jmp writeAns
EVENC:
    sub rax, [cnt0]
    div rcx
    cmp rdx, 0
    je EVENE
    call AOE
    jmp writeAns
EVENE:
    call AO
    jmp writeAns
ODD:
    cmp rax, [cnt1]
    jg ODDC
    push rax
    call SFKO
    pop rax
    jmp writeAns
ODDC:
    sub rax, [cnt1]
    div rcx
    cmp rdx, 0
    je ODDE
    call AOE
    jmp writeAns
ODDE:
    call AO

writeAns:
    mov rsi, output
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

    NL            equ   0xA
    Space         equ   0x20
;----------------------------------------------------
;All one output
AO:
    push rcx

    mov rcx, 0
AOL:
    mov byte [output + rcx], 49
    inc rcx
    cmp rcx, [n]
    jl AOL

    pop rcx
    ret
;----------------------------------------------------
;Change first k zeros
CFKZ:
    push rbp
    mov rbp, rsp
    push rax
    mov rax, [rbp + 16]
    push rcx
    mov rcx, 0

CFKZL:
    cmp byte [input + rcx], 49
    je CFKZLO
    cmp rax, 0
    je CFKZLZ
    dec rax
CFKZLO:
    mov byte [output + rcx], 49
    jmp CFKZLE
CFKZLZ:
    mov byte [output + rcx], 48
CFKZLE:
    inc rcx
    cmp rcx, [n]
    jl CFKZL

    pop rcx
    pop rax
    pop rbp
    ret
;----------------------------------------------------
;Save first K ones
SFKO:

    push rbp
    mov rbp, rsp
    push rax
    mov rax, [rbp + 16]
    push rcx
    mov rcx, 0

SFKOL:
    cmp byte [input + rcx], 49
    jne SFKOLO
    cmp rax, 0
    je SFKOLZ
    dec rax
SFKOLO:
    mov byte [output + rcx], 49
    jmp SFKOLE
SFKOLZ:
    mov byte [output + rcx], 48
SFKOLE:
    inc rcx
    cmp rcx, [n]
    jl SFKOL

    pop rcx
    pop rax
    pop rbp
    ret
;----------------------------------------------------
;All one except last output
AOE:
    
    push rcx

    mov rcx, 1
AOEL:
    mov byte [output + rcx - 1], 49
    inc rcx
    cmp rcx, [n]
    jl AOEL

    mov byte [output + rcx - 1], 48

    pop rcx
    ret
;----------------------------------------------------
;Get the input string in rsi
getString:
    push rsi
    push rax
    push rcx

    mov rcx, 0
getStringL:
    call getc
    cmp al, NL
    je getStringE
    cmp al, Space
    je getStringE
    mov [rsi], al
    inc rcx

    cmp al, 48
    jne getStringOne
    mov rax, [cnt0]
    inc rax
    mov [cnt0], rax
    jmp getStringLE

getStringOne:
    mov rax, [cnt1]
    inc rax
    mov [cnt1], rax

getStringLE:
    inc rsi
    jmp getStringL

getStringE:
    mov [n], rcx
    pop rcx
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