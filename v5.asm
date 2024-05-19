JMP MAIN
JMP isr

QUIT: DW 0
COUNTER: DW 0x0039

isr:
    PUSH A
    MOV C, [COUNTER]
    
PRINT:
    MOV A, 0
    OUT 8
    MOVB AH, CL
    MOVB AL, 255
    OUT 9 ; Display the character
    DEC C
    MOV [COUNTER], C
    CMP C, 0x002F
    JNE TIMER

    MOV [QUIT], 1

TIMER:
    MOV A, 2
    OUT 2
    POP A
    IRET

RANDOM_NUM:
    IN 10
    AND A, 0x0F1E
    CMP A, 0x0004
    JBE RANDOM_NUM
    MOV D, A
    RET

MAIN:
    MOV SP, 0x0FFF
    MOV A, 1
    OUT 7
    MOV A, 1
    OUT 7

    ; LEVEL 1: 10 club symbols and 9 leaf symbols

    ; Printing 10 club symbols
    MOV B, 10 ; Counter for clubs
    MOVB CH, 5 ; Club symbol
    MOVB CL, 215 ; Club color

LEVEL1_CLUBS:
    DEC B ; Decrease counter
    CALL RANDOM_NUM ; Get random position
    MOV A, D ; Position for club
    OUT 8
    MOVB AH, CH ; Club symbol
    MOVB AL, CL ; Club color
    OUT 9 ; Display the character
    CMP B, 0
    JNE LEVEL1_CLUBS

    ; Printing 9 leaf symbols
    MOV B, 9 ; Counter for leaf
    MOVB CH, 6 ; Leaf symbol
    MOVB CL, 185 ; Leaf color

LEVEL1_LEAVES:
    DEC B ; Decrease counter
    CALL RANDOM_NUM ; Get random position
    MOV A, D ; Position for leaf
    OUT 8
    MOVB AH, CH ; Leaf symbol
    MOVB AL, CL ; Leaf color
    OUT 9 ; Display the character
    CMP B, 0
    JNE LEVEL1_LEAVES

    ; Wait for user input to proceed to Level 2
    MOV A, 5000
    OUT 3
    MOV A, 2
    OUT 0
    STI

WAIT_FOR_LEVEL2:
    MOV A, [QUIT]
    CMP A, 1
    JE CLEAR_SCREEN_FOR_LEVEL2
    JMP WAIT_FOR_LEVEL2

CLEAR_SCREEN_FOR_LEVEL2:
    CLI
    MOV A, 3
    OUT 7 ; Clear screen

    ; Reset QUIT flag for the next level
    MOV [QUIT], 0

    ; LEVEL 2: 20 heart symbols and 19 diamond symbols

    ; Printing 20 heart symbols
    MOV B, 20 ; Counter for hearts
    MOVB CH, 3 ; Heart symbol
    MOVB CL, 209 ; Heart color

LEVEL2_HEARTS:
    DEC B ; Decrease counter
    CALL RANDOM_NUM ; Get random position
    MOV A, D ; Position for heart
    OUT 8
    MOVB AH, CH ; Heart symbol
    MOVB AL, CL ; Heart color
    OUT 9
    CMP B, 0
    JNE LEVEL2_HEARTS

    ; Printing 19 diamond symbols
    MOV B, 19 ; Counter for diamonds
    MOVB CH, 4 ; Diamond symbol
    MOVB CL, 211 ; Diamond color

LEVEL2_DIAMONDS:
    DEC B ; Decrease counter
    CALL RANDOM_NUM ; Get random position
    MOV A, D ; Position for diamond
    OUT 8
    MOVB AH, CH ; Diamond symbol
    MOVB AL, CL ; Diamond color
    OUT 9
    CMP B, 0
    JNE LEVEL2_DIAMONDS

    ; Continue with the rest of the code
    MOV A, 5000
    OUT 3
    MOV A, 2
    OUT 0
    STI

LOOP:
    MOV A, [QUIT]
    CMP A, 1
    JE BREAK
    JMP LOOP

BREAK:
    CLI
    MOV A, 3
    OUT 7
    HLT
