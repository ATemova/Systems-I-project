JMP MAIN
JMP isr
isr:

LOOP:
MOV A, 10000
DEC A
CMP A, 0
JE END
JMP LOOP
END:
MOV A, 7
OUT 3
MOV A, 2
OUT 2
IRET

RANDOM_NUM:
IN 10
AND A, 0x0F1E
MOV D, A
RET

MAIN:
;SP TI E ZA FUN
MOV SP, 0x0FFF
;SCREEN 
MOV A, 1
OUT 7

MOV B, 20;COUNTER

;LISTO I BOJATA
MOVB CH, 6 ;OBJ
MOVB CL, 215; BOJA

;PRINTING ON SCREEN 20 LISTA
LEVEL:
DEC B; NAMALUVASH COUNTER
CALL RANDOM_NUM
MOV A, D
OUT 8
;OBJ
MOVB AH, CH
MOVB AL, CL
OUT 9
;COUNTER CHEK
CMP B, 0
JNE LEVEL

MOV A, 2
OUT 0
MOV A, 50000 ;MISLAM DEKA E 3 SEC OVAA
OUT 0
STI
CLI

MOV A, 3
OUT 7
MOVB CH, 6 ;OBJ
MOVB CL, 215; BOJA
MOV A, 0x0407
OUT 8
MOVB AH, CH
MOVB AL, CL
OUT 9
