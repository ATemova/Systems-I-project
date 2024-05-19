MOV A, 1 ; Set up the text mode
OUT 7 ; through register VIDMODE .
MOVB CL , 0 ; ASCII code .
MOV D, 0 ; Pointer to screen cells .
LOOP:
MOV A, D ; Activate the screen cell
OUT 8 ; through register VIDADDR .
MOVB AH , CL ; Set the character .
MOVB AL , 255 ; Set it ’s color to white .
OUT 9 ; Display the character .
INCB CL ; Next character .
CMPB CL , 0 ; Have we cycled through the whole ASCII ?
JE BREAK ; If yes , break the loop .
ADD D, 2 ; Next screen cell .
MOV B, D ; Examine the cell address .
AND B, 0x00FF ; Mask out the column bytes .
CMP B, 32 ; Check if past the 16 - th column .
JB LOOP ; If not , continue .
ADD D, 224 ; Otherwise skip the rest of the line .
JMP LOOP ; Repeat for the next character .
BREAK:
HLT
