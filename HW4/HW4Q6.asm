section .data
    rej db "reject", 0
    acc db "accept", 0
    input TIMES 5000 db 0
    tokens TIMES 5000 db 0
    n dq 0
    lm dq 0
    tn dq 0

    term db "term", 0
    term1 db "term1", 0
    term2 db "term2", 0
    term3 db "term3", 0
    expr db "expr", 0
    expr1 db "expr1", 0
    expr2 db "expr2", 0
    rdp db "rdp", 0
    match db "match", 0

section .text
    global _start

;To do so, we develop all production rules and all
;non-terminal functions and RDP and the match functions
;Also we first start by developing the lexer function
_start:
; First we get the input and check if there is any 
; undefined characters
    push rax
    call GetString
    pop rax
    cmp rax, 0
    je reject

;Second we use the lexer function to tokenize the input
;into I/P/M/L/R tokens
    call lexer

;Third we develop all the rdp functions and call RDP
    push rax
    call RDP
    pop rax
    cmp rax, 0
    je reject

accept:
    mov rsi, acc
    call printString
    jmp VEND
reject:
    mov rsi, rej
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
GetString:
    push rax
    push rsi
    push rcx

    mov rcx, 1
    mov rsi, 0
    mov rax, 0
GetStringL:
    call getc
    mov [input + rsi], al
    inc rsi

    cmp al, 10
    je GetStringLE
    cmp al, 40
    jl GetStringfalse
    cmp al, 57
    jg GetStringfalse
    cmp al, 48
    jge GetStringLE
    cmp al, 43
    jle GetStringLE
GetStringfalse:
    mov rcx, 0
GetStringLE:  
    cmp al, NL
    jne GetStringL

    mov al, 0
    dec rsi
    mov [input + rsi], al
    mov [n], rsi
    mov [rsp + 32], rcx

    pop rcx
    pop rsi
    pop rax
    ret
;----------------------------------------------------
lexer:
    push rsi
    push rdi
    push rax

    mov rsi, 0
    mov rdi, 0
lexerL:
    mov al, [input + rsi]
    cmp rax, 48
    jge AddI
    cmp rax, 43
    je AddP
    cmp rax, 42
    je AddM
    cmp rax, 41
    je AddR
    cmp rax, 40
    je AddL
    jmp lexerLE
AddI:
    mov al, 73
    cmp rdi, 0
    je AddIE
    cmp [tokens + rdi - 1], al
    jne AddIE
    dec rdi
AddIE:
    mov [tokens + rdi], al
    inc rdi
    jmp lexerLE
AddP:
    mov al, 80
    mov [tokens + rdi], al
    inc rdi
    jmp lexerLE
AddM:
    mov al, 77
    mov [tokens + rdi], al
    inc rdi
    jmp lexerLE
AddR:
    mov al, 82
    mov [tokens + rdi], al
    inc rdi
    jmp lexerLE
AddL:
    mov al, 76
    mov [tokens + rdi], al
    inc rdi
lexerLE:
    inc rsi
    cmp rsi, [n]
    jl lexerL

    mov [tn], rdi
    pop rax
    pop rdi
    pop rsi
    ret
;----------------------------------------------------
Match:
    push rax
    push rbx
    push rdi

    mov rax, [rsp + 32]
    mov rdi, [lm]
    mov bl, [tokens + rdi]
    cmp al, bl
    jne MatchNo

;Matched
    inc rdi
    mov [lm], rdi
    mov rax, 1
    mov [rsp + 32], rax
    jmp MatchE

;Not matched
MatchNo:
    mov rax, 0
    mov [rsp + 32], rax
MatchE:
    pop rdi
    pop rbx
    pop rax
    ret
;----------------------------------------------------
RDP:
    push rax
    push rbx

    push rax
    call Expr
    pop rax
    cmp rax, 0
    je RDPE

    mov rax, [lm]
    mov rbx, [tn]
    cmp rax, rbx
    jne RDPN
    mov rax, 1
    jmp RDPE
RDPN:
    mov rax, 0
RDPE:
    mov [rsp + 24], rax
    pop rbx
    pop rax
    ret
;----------------------------------------------------
Expr:
    push rax

    push rax
    call Expr1
    pop rax
    cmp rax, 1
    je ExprE

    push rax
    call Expr2
    pop rax

ExprE:
    mov [rsp + 16], rax
    pop rax
    ret
;----------------------------------------------------
Expr1:
    push rax
    push rdx
    mov rdx, [lm]
    
    push rax
    call Term
    pop rax
    cmp rax, 0
    je Expr1E

    mov rax, 80
    push rax
    call Match
    pop rax
    cmp rax, 0
    je Expr1E

    push rax
    call Expr
    pop rax
Expr1E:
    cmp rax, 0
    jg Expr1EY
    mov [lm], rdx
Expr1EY:
    mov [rsp + 24], rax
    pop rdx
    pop rax
    ret
;----------------------------------------------------
Expr2:
    push rax
    push rdx
    mov rdx, [lm]

    push rax
    call Term
    pop rax
Expr2E:
    cmp rax, 0
    jg Expr2EY
    mov [lm], rdx
Expr2EY:
    mov [rsp + 24], rax
    pop rdx
    pop rax
    ret
;----------------------------------------------------
Term:
    push rax

    push rax
    call Term1
    pop rax
    cmp rax, 1
    je TermE

    push rax
    call Term2
    pop rax
    cmp rax, 1
    je TermE

    push rax
    call Term3
    pop rax

TermE:
    mov [rsp + 16], rax
    pop rax
    ret
;----------------------------------------------------
Term1:
    push rax
    push rdx
    mov rdx, [lm]
    
    mov rax, 73
    push rax
    call Match
    pop rax
    cmp rax, 0
    je Term1E


    mov rax, 77
    push rax
    call Match
    pop rax
    cmp rax, 0
    je Term1E

    push rax
    call Term
    pop rax
Term1E:
    cmp rax, 0
    jg Term1EY
    mov [lm], rdx
Term1EY:
    mov [rsp + 24], rax
    pop rdx
    pop rax
    ret
;----------------------------------------------------
Term2:
    push rax

    mov rax, 73
    push rax
    call Match
    pop rax

    mov [rsp + 16], rax
    pop rax
    ret
;----------------------------------------------------
Term3:
    push rax
    push rdx
    mov rdx, [lm]
    
    mov rax, 76
    push rax
    call Match
    pop rax
    cmp rax, 0
    je Term3E

    push rax
    call Expr
    pop rax
    cmp rax, 0
    je Term3E

    mov rax, 82
    push rax
    call Match
    pop rax
Term3E:
    cmp rax, 0
    jg Term3EY
    mov [lm], rdx
Term3EY:
    mov [rsp + 24], rax
    pop rdx
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