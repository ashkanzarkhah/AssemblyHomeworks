section .data
    carry dw 0
    bitsum dw 0

section .text
    global _start

_start:

;To do so, we write 3 functions
;1. toBin, this function gets a number in ax,
;and returns its binary representation in rbx
;for example if there is 20 in ax, we will have 10100 in rbx
;2. sumBin, this function gets two numbers in rbx and rcx
;and returns their binary sum in rax
;for example if rbx = 101 and rcx = 111, it returns 1100 in ax
;3. toDec, this function gets a binary represented number in rax,
;and returns its decimal in bx
;for example if there is 10100 in rax, we will have 20 in bx


;Getting binary representation of first number
    call readNum
    call toBin

    mov rcx, rbx

;Getting binary representation of second number
    call readNum
    call toBin

;Getting their sum in rax
    call sumBin

;Getting decimal of the sum in bx
    call toDec

;Printing the output
    mov ax, bx
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
;We calculate the binary representation by 
;deviding the input by 2 and saving its reminder untill it reaches zero
;But this algorithm finds the binary representation reversed, so we
;reverse the representation and then we print it
toBin:
    push rcx
    push rdx
;Presetting output variable to 1 so we don't loos ending zeros
    mov rcx, 0x1

toBinL1:
;multiplying rcx by 10
    push rax
    mov rax, rcx
    mov rcx, 0xA
    mul rcx
    mov rcx, rax
    pop rax

;deviding rax by 2
    mov rdx, 0x0
    mov rbx, 0x2
    div rbx

;adding the reminder to rcx
    add rcx, rdx

    cmp rax, 0x0
    jg toBinL1

;Now we mov rcx into rax and
    mov rax, rcx
    mov rcx, 0

;now we reverse rax back into rcx untill we reach the first 1 digit
toBinL2:
;multiplying rcx by 10
    push rax
    mov rax, rcx
    mov rcx, 0xA
    mul rcx
    mov rcx, rax
    pop rax

;deviding rax by 10
    mov rdx, 0x0
    mov rbx, 0xA
    div rbx

;adding the reminder to cx
    add rcx, rdx

    cmp rax, 0x1
    jg toBinL2

;Now we return rcx in rbx
    mov rbx, rcx

    pop rdx
    pop rcx
    ret
;-------------------------------------------
;We calculate rbx and rcx binary sum by 
;deviding the inputs by 2 and saving their reminders sum with carry
;untill they both reach zero
;But this algorithm finds the binary sum reversed, so we
;reverse the sum and then we print it

sumBin:
    push rdx

    mov dx, 0x0
    mov rax, 0x1

sumBinL1:
;multplying rax by 10
    push rcx
    mov rcx, 0xA
    mul rcx
    pop rcx

;deviding rcx by ten and adding the reminder to bitsum
    push rax
    mov rdx, 0
    mov rax, rcx
    mov rcx, 0xA
    div rcx
    mov rcx, rax
    pop rax

    push ax
    mov ax, [bitsum]
    add ax, dx
    mov [bitsum], ax
    pop ax

;deviding rbx by ten and adding the reminder to bitsum
    push rax
    mov rdx, 0
    mov rax, rbx
    mov rbx, 0xA
    div rbx
    mov rbx, rax
    pop rax
    
    push ax
    mov ax, [bitsum]
    add ax, dx
    mov [bitsum], ax
    pop ax

;Adding carry to bitsum
    push ax
    mov ax, [bitsum]
    add ax, [carry]
    mov [bitsum], ax
    pop ax

;Checking for new carry
    push ax
    mov ax, 0
    mov [carry], ax
    pop ax

    push ax
    mov ax, [bitsum]
    cmp ax, 1
    pop ax

    jng sumBinContinue
    
    push ax
    mov ax, 0x1
    mov [carry], ax
    pop ax

    push ax
    mov ax, [bitsum]
    sub ax, 0x2
    mov [bitsum], ax
    pop ax

;Adding the new bit
sumBinContinue:
    add rax, [bitsum]
    
    push ax
    mov ax, 0
    mov [bitsum], ax
    pop ax

;Cheking if all rcx and rbx and carry are zero

    cmp rcx, 0x0
    jg sumBinL1
    cmp rbx, 0x0
    jg sumBinL1

    push ax
    mov ax, [carry]
    cmp ax, 0x0
    pop ax
    jg sumBinL1


;now we reverse rax into rcx untill we reach the first 1 digit
sumBinL2:
;multiplying rcx by 10
    push rax
    mov rax, rcx
    mov rcx, 0xA
    mul rcx
    mov rcx, rax
    pop rax

;deviding rax by 10
    mov rdx, 0x0
    mov rbx, 0xA
    div rbx

;adding the reminder to rcx
    add rcx, rdx

    cmp rax, 0x1
    jg sumBinL2

;Now we return rcx in rax
    mov rax, rcx

    pop rdx
    ret
;-------------------------------------------
;We calculate original value of the binary representation
;By first reversing it and then
;By deviding the input by 10 and adding the reminder to output
;and multiplying the output by two each time

toDec:
    push rcx
    push rdx

;Reversing the input into rcx
    mov rcx, 0x1
toDecL1:
;multiplying rcx by ten
    push rax
    mov rax, rcx
    mov rcx, 0xA
    mul rcx
    mov rcx, rax
    pop rax
;Deviding rax by ten
    push rcx
    mov rdx, 0
    mov rcx, 0xA
    div rcx
    pop rcx
    add rcx, rdx

    cmp rax, 0x0
    jg toDecL1

    mov rax, rcx
    mov bx, 0
toDecL2:
;Multiplying bx by two
    push rax
    mov ax, bx
    mov bx, 0x2
    mul bx
    mov bx, ax
    pop rax

;Deviding rax by ten and adding the reminder to bx
    mov rcx, 0xA
    mov rdx, 0
    div rcx
    add bx, dx

    cmp rax, 0x1
    jg toDecL2

    pop rdx
    pop rcx
    ret