JMP MAIN        		; Jump to the MAIN section
JMP isr         		; Jump to the interrupt service routine

QUIT: DW 0      		; Define a variable QUIT with initial value 0
COUNTER: DW 0x0039  	; Define a variable COUNTER with initial value 0x0039

isr:            		; Start of the interrupt service routine
    PUSH A      		; Push the value of register A onto the stack
    MOV C, [COUNTER]    ; Move the value from memory location COUNTER to register C
    
PRINT:
    MOV A, 0    		; Move the value 0 to register A
    OUT 8       		; Output the value in register A to port 8
    MOVB AH, CL 		; Move the high byte of register CL to register AH
    MOVB AL, 255    	; Move the value 255 to the low byte of register AL
    OUT 9       		; Output the value in register AL to port 9 to display the character
    DEC C       		; Decrement the value in register C
    MOV [COUNTER], C    ; Move the value in register C to the memory location COUNTER
    CMP C, 0x002F  		; Compare the value in register C with 0x002F
    JNE TIMER   		; Jump to the TIMER section if not equal to 0x002F

    MOV [QUIT], 1  		; Move the value 1 to the memory location QUIT to quit the program

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

str_loading1: DB "Guess\x00"
str_loading2: DB " the bigger\x00"
str_loading3: DB " number of\x00"
str_loading4: DB " symbols..\x00"
start_game_str_1: DB " Press tab\x00"
start_game_str_2: DB "to START\x00"

draw_text: 				; draw the text
    MOV B, 25           ; Set the color of the text to 25
    MOV D, 0x100C       ; The VRAM position of the text

DRAW_TEXT_LOOP:
    MOV C, [D]          ; Load the character from the string
	MOV A, [D]          ; Load the byte from memory into register A
	CMP A, 0            ; Compare the byte in register A to 0
    JE DRAW_TEXT_END    ; If it's the end, exit the loop
    CALL draw           ; Call function to actually draw the character 
    ADD D, 1            ; Move to the next character in the string
    JMP DRAW_TEXT_LOOP  ; Repeat for the next character

DRAW_TEXT_END:
    RET

draw: 					; draw function
    MOVB BH, [C]        ; Get the character 
    CMPB BH, 0          ; If the character is 0, we are done 
    JE draw_return      ; Jump if equal
    MOV A, D            ; Set the VRAM address for the character 
    OUT 8               ; through the VIDADDR I/O register
    MOV A, B            ; Set the character and its color 
    OUT 9               ; through the VIDDATA I/O register
    INC C               ; Point to the next character
    ADD D, 2            ; Set the next VRAM address
    JMP draw 
draw_return: 
    RET 

check_press: 			; Function to check for key press
    IN 5 				; read the keyboard status 
    CMP A, 0 			; has anything happened? 
    JE check_press 		; if not, read the keyboard status again 
    MOV B, A 			; let the status be in register B 
    IN 6 				; read the key code 
    AND B, 1 			; mask out the keyboard bit 
    CMP B, 1 			; is this bit set to 1? 
    JE start_game 		; if yes, start the game
    JMP check_press 	; otherwise, keep checking for key press

start_game:
    MOV [QUIT], 1 		; Set QUIT flag to 1 to exit the loading loop
    RET

MAIN:
    MOV SP, 0x0FFF
    MOV A, 1
    OUT 7
    CALL draw_text 		; Display loading text

WAIT_FOR_ENTER:
    CALL check_press
    MOV A, [QUIT]
    CMP A, 1
    JNE WAIT_FOR_ENTER

    MOV A, 3
    OUT 7 				; Clear screen
    
; LEVEL 1: 10 club symbols and 9 leaf symbols

    ; Printing 10 club symbols
    MOV B, 10 			; Counter for clubs
    MOVB CH, 5 			; Club symbol
    MOVB CL, 148 		; Club color

LEVEL1_CLUBS:
    DEC B 				; Decrease counter
    CALL RANDOM_NUM 	; Get random position
    MOV A, D 			; Position for club
    OUT 8
    MOVB AH, CH 		; Club symbol
    MOVB AL, CL 		; Club color
    OUT 9 				; Display the character
    CMP B, 0
    JNE LEVEL1_CLUBS

    ; Printing 9 leaf symbols
    MOV B, 9 			; Counter for leaves
    MOVB CH, 6 			; Leaf symbol
    MOVB CL, 196 		; Leaf color

LEVEL1_LEAVES:
    DEC B 				; Decrease counter
    CALL RANDOM_NUM 	; Get random position
    MOV A, D 			; Position for leaf
    OUT 8
    MOVB AH, CH 		; Leaf symbol
    MOVB AL, CL 		; Leaf color
    OUT 9 				; Display the character
    CMP B, 0
    JNE LEVEL1_LEAVES

    ; Proceed to Level 2
    MOV [QUIT], 0  		; Reset QUIT flag
    MOV A, 5000
    OUT 3
    MOV A, 2
    OUT 0
    STI

WAIT_FOR_LEVEL2:
    MOV A, [QUIT]
    CMP A, 1
    JE START_LEVEL2
    JMP WAIT_FOR_LEVEL2

START_LEVEL2:
    CLI
    MOV A, 3
    OUT 7 				; Clear screen

; LEVEL 2: 20 heart symbols and 19 diamond symbols

    ; Printing 20 heart symbols
    MOV B, 20			; Counter for hearts
    MOVB CH, 3 			; Heart symbol
    MOVB CL, 196 		; Heart color

LEVEL2_HEARTS:
    DEC B 				; Decrease counter
    CALL RANDOM_NUM 	; Get random position
    MOV A, D 			; Position for heart
    OUT 8
    MOVB AH, CH 		; Heart symbol
    MOVB AL, CL 		; Heart color
    OUT 9 				; Display the character
    CMP B, 0
    JNE LEVEL2_HEARTS

    					; Printing 19 diamond symbols
    MOV B, 19 			; Counter for diamonds
    MOVB CH, 4 			; Diamond symbol
    MOVB CL, 252 		; Diamond color

LEVEL2_DIAMONDS:
    DEC B 				; Decrease counter
    CALL RANDOM_NUM 	; Get random position
    MOV A, D 			; Position for diamond
    OUT 8
    MOVB AH, CH 		; Diamond symbol
    MOVB AL, CL 		; Diamond color
    OUT 9 				; Display the character
    CMP B, 0
    JNE LEVEL2_DIAMONDS

    ; Proceed to Level 3
    MOV [QUIT], 0  		; Reset QUIT flag
    MOV A, 5000
    OUT 3
    MOV A, 2
    OUT 0
    STI

WAIT_FOR_LEVEL3:
    MOV A, [QUIT]
    CMP A, 1
    JE START_LEVEL3
    JMP WAIT_FOR_LEVEL3

START_LEVEL3:
    CLI
    MOV A, 3
    OUT 7 			    ; Clear screen

; LEVEL 3: 30 empty smile emojis and 29 full smile emojis

    ; Printing 30 empty smile emojis
    MOV B, 30 			; Counter for empty smiles
    MOVB CH, 1 			; Empty smile symbol
    MOVB CL, 3 			; Empty smile color

LEVEL3_EMPTY_SMILE:
    DEC B 				; Decrease counter
    CALL RANDOM_NUM 	; Get random position
    MOV A, D 			; Position for empty smile
    OUT 8
    MOVB AH, CH 		; Empty smile symbol
    MOVB AL, CL 		; Empty smile color
    OUT 9 				; Display the character
    CMP B, 0
    JNE LEVEL3_EMPTY_SMILE

    ; Printing 29 full smile emojis
    MOV B, 29 			; Counter for full smiles
    MOVB CH, 2 			; Full smile symbol
    MOVB CL, 7 			; Full smile color

LEVEL3_FULL_SMILE:
    DEC B 				; Decrease counter
    CALL RANDOM_NUM 	; Get random position
    MOV A, D 			; Position for full smile
    OUT 8
    MOVB AH, CH 		; Full smile symbol
    MOVB AL, CL 		; Full smile color
    OUT 9 				; Display the character
    CMP B, 0 			; Compare counter to 0
    JNE LEVEL3_FULL_SMILE ; Jump back to LEVEL3_FULL_SMILE if counter is not zero

    ; Continue with the rest of the code
LOOP:
    MOV A, [QUIT] 		; Move the value from memory location QUIT to register A
    CMP A, 1       		; Compare the value in register A with 1
    JE BREAK       		; Jump to BREAK if equal to 1
    JMP LOOP       		; Otherwise, jump back to LOOP to continue the loop

BREAK:
    CLI            		; Clear the interrupt flag
    MOV A, 3       		; Move the value 3 to register A
    OUT 7          		; Output the value in register A to port 7 to clear the screen
    HLT            		; Halt the CPU, stopping program execution
