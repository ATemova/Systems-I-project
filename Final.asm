JMP MAIN        				; jump to the MAIN section
JMP isr         				; jump to the interrupt service routine

;===============================================================================================|

;===============================================================================================|
string_loading1: DB "Guess the\x00"        ; Define the first loading string
string_loading2: DB "bigger number\x00"    ; Define the second loading string
string_loading3: DB "of symbols\x00"       ; Define the third loading string
start_game_str_1: DB "Press anywhere\x00"  ; Define the first string for starting the game
start_game_str_2: DB "   to START\x00"     ; Define the second string for starting the game
CLUBS: DB "CLUBS -> C\x00"                 ; Define the string for the CLUBS symbol
LEAVES: DB "LEAVES -> L\x00"               ; Define the string for the LEAVES symbol
DIAMONDS: DB "DIAMONDS -> D\x00"           ; Define the string for the DIAMONDS symbol
HEARTS: DB "HEARTS -> H\x00"               ; Define the string for the HEARTS symbol
SMILE: DB "SMILE -> S\x00"                 ; Define the string for the SMILE symbol
FULL_SMILE: DB "FULL SMILE -> F\x00"       ; Define the string for the FULL SMILE symbol
SCORE: DB "0"                              ; Define the initial score string
;===============================================================================================|

;===============================================================================================|
score2: DB "Score: \x00"         ; Define the score string

QUIT: DW 0      	             ; Define a variable QUIT with initial value 0
COUNTER: DW 0x0035  	         ; Define a variable COUNTER with initial value 0x0035

isr:            	             ; Start of the interrupt service routine
    PUSH A      	             ; Push the value of register A onto the stack
    MOV C, [COUNTER]             ; Move the value from memory location COUNTER to register C
    MOV [QUIT], 1  	             ; Move the value 1 to the memory location QUIT to quit the program
    MOV A, 2
    OUT 2
    POP A
    IRET

random_number:
    IN 10                        ; Read from port 10
    AND A, 0x0F1E                ; Mask A with 0x0F1E
    MOV D, A
    RET

draw_text: 			             ; Draw the text
   	
draw_text_loop:
    MOV A, D 			         ; Screen position
    OUT 8				         ; Through the VIDADDR I/O register
    MOVB AH, [B]		         ; Get character
    CMPB AH, 0
    JE draw_text_end
    MOVB AL, 255		         ; Color
    OUT 9				         ; Print on screen
    INC B				         ; Next character
    ADD D, 2			         ; Next screen cell
    JMP draw_text_loop           ; Repeat for the next character

draw_text_end:
    RET

draw: 				             ; Draw function
    MOVB BH, [C]                 ; Get the character 
    CMPB BH, 0                   ; If the character is 0, we are done 
    JE draw_return               ; Jump if equal
    MOV A, D                     ; Set the VRAM address for the character 
    OUT 8                        ; Through the VIDADDR I/O register
    MOV A, B                     ; Set the character and its color 
    OUT 9                        ; Through the VIDDATA I/O register
    INC C                        ; Point to the next character
    ADD D, 2                     ; Set the next VRAM address
    JMP draw 
    
draw_return: 
    RET 

check_press: 		             ; Function to check for key press
    IN 5 			             ; Read the keyboard status 
    CMP A, 0 			         ; Has anything happened? 
    JE check_press 		         ; If not, read the keyboard status again 
    MOV B, A 			         ; Let the status be in register B 
    IN 6 			             ; Read the key code 
    AND B, 1 			         ; Mask out the keyboard bit 
    CMP B, 1 			         ; Is this bit set to 1? 
    JE start_game 		         ; If yes, start the game
    JMP check_press 	         ; Otherwise, keep checking for key press

start_game:
    MOV [QUIT], 1 		         ; Set QUIT flag to 1 to exit the loading loop
    RET

MAIN:
    MOV SP, 0x0FFF               ; Initialize stack pointer
    MOV A, 1
    OUT 7				         ; Clear screen
    ; Starting screen
    MOV D, 0x0402       	     ; Position
    MOV B, string_loading1       ; String
    CALL draw_text 			     ; Display loading text
    MOV D, 0x0502			     ; Position
    MOV B, string_loading2       ; String
    CALL draw_text			     ; Display loading text
    MOV D, 0x0602			     ; Position
    MOV B, string_loading3       ; String
    CALL draw_text			     ; Display loading text
    MOV D, 0x0902			     ; Position
    MOV B, start_game_str_1      ; String
    CALL draw_text			     ; Display loading text
    MOV D, 0x0A02			     ; Position
    MOV B, start_game_str_2      ; String
    CALL draw_text			     ; Display loading text
;===============================================================================================|
    
;===============================================================================================|
return_string:                   ; Start of the return_string routine
    PUSH A                       ; Push the value of register A onto the stack
    MOV A, score2                ; Move the address of score2 into register A
    MOV D, 0x1000                ; Set the destination address in D

loop_print_score:                ; Start of the loop to print the score
    PUSH B                       ; Push the value of register B onto the stack
    MOVB BL, [A]                 ; Move the byte at address A into BL
    CMPB BL, 0                   ; Check if the byte is null
    JE return_string_score       ; If null, jump to return_string_score
    MOVB [D], BL                 ; Move the byte in BL to the address in D
    INC A                        ; Increment the address in A
    INC D                        ; Increment the address in D
    JMP loop_print_score         ; Repeat the loop

return_string_score:             ; Start of the return_string_score routine
    MOVB BL, [SCORE]             ; Move the byte at SCORE into BL
    MOVB [SCORE], BL             ; Move the byte in BL back to SCORE (redundant)
    MOVB [0x1007], BL            ; Move the byte in BL to address 0x1007
    POP B                        ; Pop the value of register B from the stack
    POP A                        ; Pop the value of register A from the stack
;===============================================================================================|

;===============================================================================================|
wait_for_enter:                  ; Start of the wait_for_enter routine
    CALL check_press             ; Call the check_press routine
    MOV A, [QUIT]                ; Move the value at QUIT into register A
    CMP A, 1                     ; Compare the value in A with 1
    JNE wait_for_enter           ; If not equal, jump back to wait_for_enter

    MOV A, 3                     ; Move the value 3 into register A
    OUT 7                        ; Clear screen
;===============================================================================================|

;===============================================================================================|  
; LEVEL 1: 10 club symbols and 9 leaf symbols

; printing 10 club symbols
    MOV B, 10 					; counter for clubs
    MOVB CH, 5 					; club symbol
    MOVB CL, 148 				; club color

level1_clubs:
    DEC B 						; decrease counter
    CALL random_number 			; get random position
    MOV A, D 					; position for club
    OUT 8						; through the VIDADDR I/O register
    MOVB AH, CH 				; club symbol
    MOVB AL, CL 				; club color
    OUT 9 						; display the character
    CMP B, 0
    JNE level1_clubs

; printing 9 leaf symbols
    MOV B, 9 					; counter for leaves
    MOVB CH, 6 					; leaf symbol
    MOVB CL, 196 				; leaf color

level1_leaves:
    DEC B 						; decrease counter
    CALL random_number 			; get random position
    MOV A, D 					; position for leaf
    OUT 8						; through the VIDADDR I/O register
    MOVB AH, CH 				; leaf symbol
    MOVB AL, CL 				; leaf color
    OUT 9 						; display the character
    CMP B, 0
    JNE level1_leaves

; proceed to Level 2
    MOV [QUIT], 0               ; Reset QUIT flag
    MOV A, 50000                ; Load 50000 into register A
    OUT 3                       ; Output the value to port 3
    MOV A, 2                    ; Load 2 into register A
    OUT 0                       ; Output the value to port 0
    STI                         ; Set Interrupt Flag

wait_for_level2:
    MOV A, [QUIT]               ; Load the value of QUIT into register A
    CMP A, 1                    ; Compare the value in A with 1
    JE start_level2             ; If equal, jump to START_LEVEL2
    JMP wait_for_level2         ; Otherwise, keep waiting

start_level2:
    MOV A, 3                    ; Load 3 into register A
    OUT 7                       ; Clear screen
    MOV D, 0x0602               ; Set the position to 0x0602
    MOV B, LEAVES               ; Load the LEAVES string into register B
    CALL draw_text              ; Call draw_text to display the LEAVES string
    MOV D, 0x0702               ; Set the position to 0x0702
    MOV B, CLUBS                ; Load the CLUBS string into register B
    CALL draw_text              ; Call draw_text to display the CLUBS string
    
wait_loop_for_choice:
    IN 5                        ; Read the keyboard status
    CMP A, 0                    ; Compare the status with 0
    JNE end_wait_loop_for_choice; If not equal, jump to END_WAIT_LOOP_FOR_CHOICE
    JMP wait_loop_for_choice    ; Otherwise, keep waiting

end_wait_loop_for_choice:
    IN 6                        ; Read the key code
    CMP A, 'l'                  ; Compare the key code with 'l'
    JE print_score              ; If equal, jump to print_score
    CMP A, 'c'                  ; Compare the key code with 'c'
    JE inc_score                ; If equal, jump to inc_score
    JMP wait_loop_for_choice    ; Otherwise, keep waiting for a choice
    
inc_score:
    MOVB BL, [SCORE]            ; Load the current score into BL
    INCB BL                     ; Increment the value in BL
    MOVB [SCORE], BL            ; Store the incremented value back into SCORE
    
print_score:
    MOVB BL, [SCORE]            ; Load the current score into BL
    MOVB [0x1007], BL           ; Display the score at address 0x1007
    
    MOV A, 3                    ; Load 3 into register A
    OUT 7                       ; Clear screen
;===============================================================================================|
    
;===============================================================================================|
; LEVEL 2: 20 heart symbols and 19 diamond symbols

; printing 20 heart symbols
    MOV B, 20					; counter for hearts
    MOVB CH, 3 					; heart symbol
    MOVB CL, 196 				; heart color

level2_hearts:
    DEC B 						; decrease counter
    CALL random_number 			; get random position
    MOV A, D 					; position for heart
    OUT 8						; through the VIDADDR I/O register
    MOVB AH, CH 				; heart symbol
    MOVB AL, CL 				; heart color
    OUT 9 						; display the character
    CMP B, 0
    JNE level2_hearts

; printing 19 diamond symbols
    MOV B, 19 					; counter for diamonds
    MOVB CH, 4 					; diamond symbol
    MOVB CL, 15 				; diamond color
	
    level2_diamonds:
    DEC B 						; decrease counter
    CALL random_number 			; get random position
    MOV A, D 					; position for diamond
    OUT 8						; through the VIDADDR I/O register
    MOVB AH, CH 				; diamond symbol
    MOVB AL, CL 				; diamond color
    OUT 9 						; display the character
    CMP B, 0
    JNE level2_diamonds

; proceed to Level 3
    MOV [QUIT], 0               ; Reset QUIT flag
    MOV A, 50000                ; Load 50000 into register A
    OUT 3                       ; Output the value to port 3
    MOV A, 2                    ; Load 2 into register A
    OUT 0                       ; Output the value to port 0

wait_for_level3:
    MOV A, [QUIT]               ; Load the value of QUIT into register A
    CMP A, 1                    ; Compare the value in A with 1
    JE start_level3             ; If equal, jump to START_LEVEL3
    JMP wait_for_level3         ; Otherwise, keep waiting

start_level3:
    MOV A, 3                    ; Load 3 into register A
    OUT 7                       ; Clear screen
    MOV D, 0x0602               ; Set the position to 0x0602
    MOV B, DIAMONDS             ; Load the DIAMONDS string into register B
    CALL draw_text              ; Call draw_text to display the DIAMONDS string
    MOV D, 0x0702               ; Set the position to 0x0702
    MOV B, HEARTS               ; Load the HEARTS string into register B
    CALL draw_text              ; Call draw_text to display the HEARTS string
    
wait_loop_for_choice1:
    IN 5                        ; Read the keyboard status
    CMP A, 0                    ; Compare the status with 0
    JNE end_wait_loop_for_choice1; If not equal, jump to END_WAIT_LOOP_FOR_CHOICE1
    JMP wait_loop_for_choice1   ; Otherwise, keep waiting

end_wait_loop_for_choice1:
    IN 6                        ; Read the key code
    CMP A, 'd'                  ; Compare the key code with 'd'
    JE print1_score             ; If equal, jump to print1_score
    CMP A, 'h'                  ; Compare the key code with 'h'
    JE incr_score               ; If equal, jump to incr_score
    JMP wait_loop_for_choice1   ; Otherwise, keep waiting for a choice
    
incr_score:
    MOVB BL, [SCORE]            ; Load the current score into BL
    INCB BL                     ; Increment the value in BL
    MOVB [SCORE], BL            ; Store the incremented value back into SCORE
    
print1_score:
    MOVB BL, [SCORE]            ; Load the current score into BL
    MOVB [0x1007], BL           ; Display the score at address 0x1007
    
    MOV A, 3                    ; Load 3 into register A
    OUT 7                       ; Clear screen
;===============================================================================================|

;===============================================================================================|
; LEVEL 3: 30 smile emojis and 29 full smile emojis

; printing 30 smile emojis
    MOV B, 30 					; counter for empty smiles
    MOVB CH, 1 					; smile symbol
    MOVB CL, 100 				; smile color

level3_smile:
    DEC B 						; decrease counter
    CALL random_number 			; get random position
    MOV A, D 					; position for empty smile
    OUT 8						; through the VIDADDR I/O register
    MOVB AH, CH 				; smile symbol
    MOVB AL, CL 				; smile color
    OUT 9 						; display the character
    CMP B, 0
    JNE level3_smile

; printing 29 full smile emojis
    MOV B, 29 					; counter for full smiles
    MOVB CH, 2 					; full smile symbol
    MOVB CL, 64					; full smile color

level3_full_smile:
    DEC B 						; decrease counter
    CALL random_number 			; get random position
    MOV A, D 					; position for full smile
    OUT 8						; through the VIDADDR I/O register
    MOVB AH, CH 				; full smile symbol
    MOVB AL, CL 				; full smile color
    OUT 9 						; display the character
    CMP B, 0 					; compare counter to 0
    JNE level3_full_smile 		; jump back to LEVEL3_FULL_SMILE if counter is not zero
    
; proceed to the end
    MOV [QUIT], 0               ; Reset QUIT flag
    MOV A, 50000                ; Load 50000 into register A
    OUT 3                       ; Output the value to port 3
    MOV A, 2                    ; Load 2 into register A
    OUT 0                       ; Output the value to port 0
    STI                         ; Set Interrupt Flag

wait_for_end:
    MOV A, [QUIT]               ; Load the value of QUIT into register A
    CMP A, 1                    ; Compare the value in A with 1
    JE start_end                ; If equal, jump to START_END
    JMP wait_for_end            ; Otherwise, keep waiting

start_end:
    MOV A, 3                    ; Load 3 into register A
    OUT 7                       ; Clear screen
    MOV D, 0x0602               ; Set the position to 0x0602
    MOV B, SMILE                ; Load the SMILE string into register B
    CALL draw_text              ; Call draw_text to display the SMILE string
    MOV D, 0x0702               ; Set the position to 0x0702
    MOV B, FULL_SMILE           ; Load the FULL_SMILE string into register B
    CALL draw_text              ; Call draw_text to display the FULL_SMILE string
    
wait_loop_for_choice2:
    IN 5                        ; Read the keyboard status
    CMP A, 0                    ; Compare the status with 0
    JNE end_wait_loop_for_choice2; If not equal, jump to END_WAIT_LOOP_FOR_CHOICEE1
    JMP wait_loop_for_choice2  ; Otherwise, keep waiting

end_wait_loop_for_choice2:
    IN 6                        ; Read the key code
    CMP A, 'f'                  ; Compare the key code with 'f'
    JE print2_score            ; If equal, jump to printt1_score
    CMP A, 's'                  ; Compare the key code with 's'
    JE incre_score             ; If equal, jump to increm_score
    JMP wait_loop_for_choice2  ; Otherwise, keep waiting for a choice
    
incre_score:
    MOVB BL, [SCORE]            ; Load the current score into BL
    INCB BL                     ; Increment the value in BL
    MOVB [SCORE], BL            ; Store the incremented value back into SCORE
    
print2_score:
    MOVB BL, [SCORE]            ; Load the current score into BL
    MOVB [0x1007], BL           ; Display the score at address 0x1007
   
    MOV A, 3                    ; Load 3 into register A
    OUT 7                       ; Clear screen
;===============================================================================================|

; continue with the rest of the code	
    
BREAK:
    MOV A, 3                    ; Load the value 3 into register A
    OUT 7                       ; Clear screen
    
wait_loop_for_choice3:
    IN 5                        ; Read the keyboard status
    CMP A, 0                    ; Compare the status with 0
    JNE end_wait_loop_for_choice3; If not equal, jump to END_WAIT_LOOP_FOR_CHOCIE1
    JMP wait_loop_for_choice3   ; Otherwise, keep waiting

end_wait_loop_for_choice3:  
    IN 6                        ; Read the key code
    CMP A, 'r'                  ; Compare the key code with 'r'
    JNE wait_loop_for_choice3   ; If not equal, keep waiting for 'r'
    
; this is for resetting the score to 0 when clicking 'r'
    MOV B, 0x30                 ; Load the value 0x30 into register B
    MOVB [SCORE], 0             ; Reset SCORE to 0
    
    JMP MAIN                    ; Jump to the start of MAIN
    HLT                         ; Halt the CPU, stopping program execution
