ORG 100H
jmp start
prompt DB 'Please enter a number (signed or unsigned)(up to 6 digits): $'
binarymsg DB 'Your number presented in binary: $'
hexmsg DB 'Your number presented in hex: $'
negmsg DB 'number is negative$'
res DB DUP('0')
tt DW 10
negative db 0

newline PROC
  mov dx,0AH
  mov ah,2
  int 21h
  mov dx,13
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

printbx PROC
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

MOV CX, 6
L1:
MOV AH, 1;
int 21h
CMP AL, 13
JE return
CMP AL, 45
JE store
SUB AL, 30H
store: STOSB
end: LOOP L1


return: MOV DI, 6
SUB DI, CX
MOV CX , DI
LEA BX, res
CMP [BX], 45
JNE nonneg
inc BX
DEC CX


nonneg:
XOR DI, DI
XOR SI, SI


L2:
PUSH CX
MOV AL, [BX]
XOR AH, AH
XOR DX, DX
L3:
CMP CX,1
JE exit
PUSH BX
MOV BX, 10
MUL BX
POP BX
Loop L3;
exit:
POP CX
ADD SI, AX
ADC DI, DX
INC BX
LOOP L2


LEA BX, res
CMP [BX], 45
JNE skipNegate
NEG SI
ADC DI, 0
NEG DI

LEA DX, negmsg
MOV AH, 9
int 21h

skipNegate: MOV DL, 0AH
MOV AH, 2
int 21h

CALL newline
LEA DX, binarymsg
MOV AH, 9
INT 21H



CMP DI, 0FFH
JE skipDI
CMP DI, 0
JE skipDI

MOV CX, 16
L4:
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
endl1: Loop L4

skipDI: MOV CX, 16
L5:
ROL SI,1
JC print1n
MOV DL, 30H
MOV AH, 2
INT 21H
JMP endl2
print1n:
MOV DL, 31H
MOV AH,2
INT 21H
endl2: Loop L5

CALL newline
LEA DX, hexmsg
MOV AH, 9
INT 21H

MOV BX, DI
CALL printbx


MOV BX, SI
CALL printbx

CALL newline
