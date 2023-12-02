ORG 100H
jmp start
prompt DB 'Please enter a number (signed or unsigned)(up to 6 digits): $'
binarymsg DB 'Your number presented in binary: $'
hexmsg DB 'Your number presented in hex: $'
res DB DUP('0')
tt DW 10
negative db 0

newline PROC ; Procedure to print a newline
  XOR DX, DX
  XOR AX, AX
  mov dx,10
  mov ah,2
  int 21h
  mov dx,0013
  mov ah,2
  int 21h
  ret
newline ENDP

hexnum PROC
    ADD DL, 30H
    MOV AH, 2
    INT 21H
    RET
hexnum ENDP


hexlet PROC
    ADD DL, 41H
    SUB DL, 0AH
    MOV AH, 2
    INT 21H
    RET
hexlet ENDP

printbx PROC; Procedure to print BX in hex
    CLC
    PUSH BX
    SHR BH, 4
    MOV DL, BH
    CMP DL, 10
    JB number
    CALL hexlet
    JMP printhexskip
    number: CALL hexnum
    printhexskip:
    POP BX
    PUSH BX
    SHL BH, 4
    SHR BH, 4
    MOV DL, BH
    CMP DL, 10
    JB number2
    CALL hexlet
    JMP printhexskip2
    number2: CALL hexnum
    printhexskip2:
    POP BX
    CLC
    PUSH BX
    SHR BL, 4
    MOV DL, BL
    CMP DL, 10
    JB number3
    CALL hexlet
    JMP printhexskip3
    number3: CALL hexnum
    printhexskip3:
    POP BX
    PUSH BX
    SHL BL, 4
    SHR BL, 4
    MOV DL, BL
    CMP DL, 10
    JB number4
    CALL hexlet
    JMP printhexskip4
    number4: CALL hexnum
    printhexskip4:
    POP BX
    ret
printbx ENDP

start:
LEA DX, prompt
MOV AH,9h
int 21H

LEA DI, res

MOV CX, 6; Get Character Input
char_in_loop:
MOV AH, 1;
int 21h
CMP AL, 13
JE return_button
CMP AL, 45
JE store
SUB AL, 30H
store: STOSB
LOOP char_in_loop


return_button:
MOV DI, 6
SUB DI, CX
MOV CX , DI
LEA BX, res
CMP [BX], 45; Check if negative
JNE nonneg
inc BX; Skip first character (-)
DEC CX


nonneg:
XOR DI, DI
XOR SI, SI


; Calculate number from characters
outer_char_loop:
PUSH CX
MOV AL, [BX]
XOR AH, AH
XOR DX, DX
inner_char_loop:
CMP CX,1
JE exit
PUSH BX
MOV BX, 10
MUL BX
POP BX
Loop inner_char_loop
exit:
POP CX
ADD SI, AX
ADC DI, DX
INC BX
LOOP outer_char_loop


LEA BX, res
CMP [BX], 45
JNE skipNegate
NEG SI
ADC DI, 0; To properly negate the full 32-bit value
NEG DI


skipNegate: MOV DL, 0AH
MOV AH, 2
int 21h

CALL newline
LEA DX, binarymsg
MOV AH, 9
INT 21H



CMP DI, 0FFFFH ; Dont print DI if it's 0 or FF
JE skipDI
CMP DI, 0
JE skipDI

MOV CX, 16
print_di_loop:
ROL DI,1
JC print1
MOV DL, 30H
MOV AH, 2
INT 21H
JMP endl1
print1:
MOV DL, 31H
MOV AH,2
INT 21H
endl1: Loop print_di_loop

skipDI: MOV CX, 16
print_si_loop:
ROL SI,1
JC print2
MOV DL, 30H
MOV AH, 2
INT 21H
JMP endl2
print2:
MOV DL, 31H
MOV AH,2
INT 21H
endl2: Loop print_si_loop

CALL newline


LEA DX, hexmsg
MOV AH, 9
INT 21H

MOV BX, DI
CALL printbx


MOV BX, SI
CALL printbx

CALL newline


MOV AH, 01H
INT 10H
infloop:
mov AX, 03h
int 33h
cmp BX, 0
JE infloop
cmp BX, 1
JE leftpress
CMP BL, 02H
JE rightpress
cmp bx,3
JE Exitprogram
leftpress:
mov ax, 0xb800
mov es, ax;
MOV AX, CX 
MOV DI, 4
PUSH DX
XOR DX, DX
DIV DI
POP DX
MOV SI, AX

MOV AX, DX
MOV CX, 8
XOR DX, DX
DIV CX
MOV DI, AX

MOV CX, DI
LLLI: ADD SI, 160
LOOP LLLI

ROR SI ,1
JC addcarry
ROL SI,1
MOV ES:[SI+1], 1FH
JMP infloop
addcarry:
ROL SI,1
MOV ES:[SI], 1FH
JMP infloop
rightpress:
mov ax, 0xb800
mov es, ax;
MOV AX, CX 
MOV DI, 4
PUSH DX
XOR DX, DX
DIV DI
POP DX
MOV SI, AX

MOV AX, DX
MOV CX, 8
XOR DX, DX
DIV CX
MOV DI, AX

MOV CX, DI
LLLI2: ADD SI, 160
LOOP LLLI2

ROR SI ,1
JC addcarry2
ROL SI,1
MOV ES:[SI+1], 6FH
JMP infloop
addcarry2:
ROL SI,1
MOV ES:[SI], 6FH
JMP infloop
Exitprogram:
HLT