JMP MAIN        				; jump to the MAIN section
JMP isr         				; jump to the interrupt service routine

;===============================================================================================|

;===============================================================================================|
string_loading1: DB "Guess the\x00"        ; define the first loading string
string_loading2: DB "bigger number\x00"    ; define the second loading string
string_loading3: DB "of symbols\x00"       ; define the third loading string
start_game_str_1: DB "Press anywhere\x00"  ; define the first string for starting the game
start_game_str_2: DB "   to START\x00"     ; define the second string for starting the game
CLUBS: DB "CLUBS -> C\x00"                 ; define the string for the CLUBS symbol
LEAVES: DB "LEAVES -> L\x00"               ; define the string for the LEAVES symbol
DIAMONDS: DB "DIAMONDS -> D\x00"           ; define the string for the DIAMONDS symbol
HEARTS: DB "HEARTS -> H\x00"               ; define the string for the HEARTS symbol
SMILE: DB "SMILE -> S\x00"                 ; define the string for the SMILE symbol
FULL_SMILE: DB "FULL SMILE -> F\x00"       ; define the string for the FULL SMILE symbol
SCORE: DB "0"                              ; define the initial score string
;===============================================================================================|

;===============================================================================================|
score2: DB "Score: \x00"         ; define the score string

QUIT: DW 0      	             ; define a variable QUIT with initial value 0
COUNTER: DW 0x0035  	         ; define a variable COUNTER with initial value 0x0035

isr:            	             ; start of the interrupt service routine
    PUSH A      	             ; push the value of register A onto the stack
    MOV C, [COUNTER]             ; move the value from memory location COUNTER to register C
    MOV [QUIT], 1  	             ; move the value 1 to the memory location QUIT to quit the program
    MOV A, 2
    OUT 2
    POP A
    IRET

random_number:
    IN 10                        ; read from port 10
    AND A, 0x0F1E                ; Mmask A with 0x0F1E
    MOV D, A
    RET

draw_text: 			             ; draw the text
   	
draw_text_loop:
    MOV A, D 			         ; screen position
    OUT 8				         ; through the VIDADDR I/O register
    MOVB AH, [B]		         ; get character
    CMPB AH, 0
    JE draw_text_end
    MOVB AL, 255		         ; color
    OUT 9				         ; print on screen
    INC B				         ; next character
    ADD D, 2			         ; next screen cell
    JMP draw_text_loop           ; repeat for the next character

draw_text_end:
    RET

draw: 				             ; draw function
    MOVB BH, [C]                 ; get the character 
    CMPB BH, 0                   ; if the character is 0, we are done 
    JE draw_return               ; jump if equal
    MOV A, D                     ; set the VRAM address for the character 
    OUT 8                        ; through the VIDADDR I/O register
    MOV A, B                     ; set the character and its color 
    OUT 9                        ; through the VIDDATA I/O register
    INC C                        ; point to the next character
    ADD D, 2                     ; set the next VRAM address
    JMP draw 
    
draw_return: 
    RET 

check_press: 		             ; function to check for key press
    IN 5 			             ; read the keyboard status 
    CMP A, 0 			         ; has anything happened? 
    JE check_press 		         ; if not, read the keyboard status again 
    MOV B, A 			         ; let the status be in register B 
    IN 6 			             ; read the key code 
    AND B, 1 			         ; mask out the keyboard bit 
    CMP B, 1 			         ; is this bit set to 1? 
    JE start_game 		         ; if yes, start the game
    JMP check_press 	         ; otherwise, keep checking for key press

start_game:
    MOV [QUIT], 1 		         ; set QUIT flag to 1 to exit the loading loop
    RET

MAIN:
    MOV SP, 0x0FFF               ; initialize stack pointer
    MOV A, 1
    OUT 7				         ; clear screen
    ; Starting screen
    MOV D, 0x0402       	     ; position
    MOV B, string_loading1       ; string
    CALL draw_text 			     ; display loading text
    MOV D, 0x0502			     ; position
    MOV B, string_loading2       ; string
    CALL draw_text			     ; display loading text
    MOV D, 0x0602			     ; position
    MOV B, string_loading3       ; string
    CALL draw_text			     ; display loading text
    MOV D, 0x0902			     ; position
    MOV B, start_game_str_1      ; string
    CALL draw_text			     ; display loading text
    MOV D, 0x0A02			     ; position
    MOV B, start_game_str_2      ; string
    CALL draw_text			     ; display loading text
;===============================================================================================|
    
;===============================================================================================|
return_string:                   ; start of the return_string routine
    PUSH A                       ; push the value of register A onto the stack
    MOV A, score2                ; move the address of score2 into register A
    MOV D, 0x1000                ; set the destination address in D

loop_print_score:                ; start of the loop to print the score
    PUSH B                       ; push the value of register B onto the stack
    MOVB BL, [A]                 ; move the byte at address A into BL
    CMPB BL, 0                   ; check if the byte is null
    JE return_string_score       ; if null, jump to return_string_score
    MOVB [D], BL                 ; move the byte in BL to the address in D
    INC A                        ; increment the address in A
    INC D                        ; increment the address in D
    JMP loop_print_score         ; repeat the loop

return_string_score:             ; start of the return_string_score routine
    MOVB BL, [SCORE]             ; move the byte at SCORE into BL
    MOVB [SCORE], BL             ; move the byte in BL back to SCORE (redundant)
    MOVB [0x1007], BL            ; move the byte in BL to address 0x1007
    POP B                        ; pop the value of register B from the stack
    POP A                        ; pop the value of register A from the stack
;===============================================================================================|

;===============================================================================================|
wait_for_enter:                  ; start of the wait_for_enter routine
    CALL check_press             ; call the check_press routine
    MOV A, [QUIT]                ; move the value at QUIT into register A
    CMP A, 1                     ; compare the value in A with 1
    JNE wait_for_enter           ; if not equal, jump back to wait_for_enter

    MOV A, 3                     ; move the value 3 into register A
    OUT 7                        ; clear screen
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
    MOV [QUIT], 0               ; reset QUIT flag
    MOV A, 50000                ; load 50000 into register A
    OUT 3                       ; output the value to port 3
    MOV A, 2                    ; load 2 into register A
    OUT 0                       ; output the value to port 0
    STI                         ; set Interrupt Flag

wait_for_level2:
    MOV A, [QUIT]               ; load the value of QUIT into register A
    CMP A, 1                    ; compare the value in A with 1
    JE start_level2             ; if equal, jump to START_LEVEL2
    JMP wait_for_level2         ; otherwise, keep waiting

start_level2:
    MOV A, 3                    ; load 3 into register A
    OUT 7                       ; clear screen
    MOV D, 0x0602               ; set the position to 0x0602
    MOV B, LEAVES               ; load the LEAVES string into register B
    CALL draw_text              ; call draw_text to display the LEAVES string
    MOV D, 0x0702               ; set the position to 0x0702
    MOV B, CLUBS                ; load the CLUBS string into register B
    CALL draw_text              ; call draw_text to display the CLUBS string
    
wait_loop_for_choice:
    IN 5                        ; read the keyboard status
    CMP A, 0                    ; compare the status with 0
    JNE end_wait_loop_for_choice; if not equal, jump to END_WAIT_LOOP_FOR_CHOICE
    JMP wait_loop_for_choice    ; otherwise, keep waiting

end_wait_loop_for_choice:
    IN 6                        ; read the key code
    CMP A, 'l'                  ; compare the key code with 'l'
    JE print_score              ; if equal, jump to print_score
    CMP A, 'c'                  ; compare the key code with 'c'
    JE inc_score                ; if equal, jump to inc_score
    JMP wait_loop_for_choice    ; otherwise, keep waiting for a choice
    
inc_score:
    MOVB BL, [SCORE]            ; load the current score into BL
    INCB BL                     ; increment the value in BL
    MOVB [SCORE], BL            ; store the incremented value back into SCORE
    
print_score:
    MOVB BL, [SCORE]            ; load the current score into BL
    MOVB [0x1007], BL           ; display the score at address 0x1007
    
    MOV A, 3                    ; load 3 into register A
    OUT 7                       ; clear screen
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
    MOV [QUIT], 0               ; reset QUIT flag
    MOV A, 50000                ; load 50000 into register A
    OUT 3                       ; output the value to port 3
    MOV A, 2                    ; load 2 into register A
    OUT 0                       ; output the value to port 0

wait_for_level3:
    MOV A, [QUIT]               ; load the value of QUIT into register A
    CMP A, 1                    ; compare the value in A with 1
    JE start_level3             ; if equal, jump to START_LEVEL3
    JMP wait_for_level3         ; otherwise, keep waiting

start_level3:
    MOV A, 3                    ; load 3 into register A
    OUT 7                       ; clear screen
    MOV D, 0x0602               ; set the position to 0x0602
    MOV B, DIAMONDS             ; load the DIAMONDS string into register B
    CALL draw_text              ; call draw_text to display the DIAMONDS string
    MOV D, 0x0702               ; set the position to 0x0702
    MOV B, HEARTS               ; load the HEARTS string into register B
    CALL draw_text              ; call draw_text to display the HEARTS string
    
wait_loop_for_choice1:
    IN 5                        ; read the keyboard status
    CMP A, 0                    ; compare the status with 0
    JNE end_wait_loop_for_choice1; if not equal, jump to END_WAIT_LOOP_FOR_CHOICE1
    JMP wait_loop_for_choice1   ; otherwise, keep waiting

end_wait_loop_for_choice1:
    IN 6                        ; read the key code
    CMP A, 'd'                  ; compare the key code with 'd'
    JE print1_score             ; if equal, jump to print1_score
    CMP A, 'h'                  ; compare the key code with 'h'
    JE incr_score               ; if equal, jump to incr_score
    JMP wait_loop_for_choice1   ; otherwise, keep waiting for a choice
    
incr_score:
    MOVB BL, [SCORE]            ; load the current score into BL
    INCB BL                     ; increment the value in BL
    MOVB [SCORE], BL            ; store the incremented value back into SCORE
    
print1_score:
    MOVB BL, [SCORE]            ; load the current score into BL
    MOVB [0x1007], BL           ; display the score at address 0x1007
    
    MOV A, 3                    ; load 3 into register A
    OUT 7                       ; clear screen
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
    MOV [QUIT], 0               ; reset QUIT flag
    MOV A, 50000                ; load 50000 into register A
    OUT 3                       ; output the value to port 3
    MOV A, 2                    ; load 2 into register A
    OUT 0                       ; output the value to port 0
    STI                         ; set Interrupt Flag

wait_for_end:
    MOV A, [QUIT]               ; load the value of QUIT into register A
    CMP A, 1                    ; compare the value in A with 1
    JE start_end                ; if equal, jump to START_END
    JMP wait_for_end            ; otherwise, keep waiting

start_end:
    MOV A, 3                    ; load 3 into register A
    OUT 7                       ; clear screen
    MOV D, 0x0602               ; set the position to 0x0602
    MOV B, SMILE                ; load the SMILE string into register B
    CALL draw_text              ; call draw_text to display the SMILE string
    MOV D, 0x0702               ; set the position to 0x0702
    MOV B, FULL_SMILE           ; load the FULL_SMILE string into register B
    CALL draw_text              ; call draw_text to display the FULL_SMILE string
    
wait_loop_for_choice2:
    IN 5                        ; read the keyboard status
    CMP A, 0                    ; compare the status with 0
    JNE end_wait_loop_for_choice2; if not equal, jump to END_WAIT_LOOP_FOR_CHOICEE1
    JMP wait_loop_for_choice2   ; otherwise, keep waiting

end_wait_loop_for_choice2:
    IN 6                        ; read the key code
    CMP A, 'f'                  ; compare the key code with 'f'
    JE print2_score             ; if equal, jump to printt1_score
    CMP A, 's'                  ; compare the key code with 's'
    JE incre_score              ; if equal, jump to increm_score
    JMP wait_loop_for_choice2   ; otherwise, keep waiting for a choice
    
incre_score:
    MOVB BL, [SCORE]            ; load the current score into BL
    INCB BL                     ; increment the value in BL
    MOVB [SCORE], BL            ; store the incremented value back into SCORE
    
print2_score:
    MOVB BL, [SCORE]            ; load the current score into BL
    MOVB [0x1007], BL           ; display the score at address 0x1007
   
    MOV A, 3                    ; load 3 into register A
    OUT 7                       ; clear screen
;===============================================================================================|

; continue with the rest of the code	
    
BREAK:
    MOV A, 3                    ; load the value 3 into register A
    OUT 7                       ; clear screen
    
wait_loop_for_choice3:
    IN 5                        ; read the keyboard status
    CMP A, 0                    ; compare the status with 0
    JNE end_wait_loop_for_choice3; if not equal, jump to END_WAIT_LOOP_FOR_CHOCIE1
    JMP wait_loop_for_choice3   ; otherwise, keep waiting

end_wait_loop_for_choice3:  
    IN 6                        ; read the key code
    CMP A, 'r'                  ; compare the key code with 'r'
    JNE wait_loop_for_choice3   ; if not equal, keep waiting for 'r'
    
; this is for resetting the score to 0 when clicking 'r'
    MOV B, 0x30                 ; load the value 0x30 into register B
    MOVB [SCORE], 0             ; reset SCORE to 0
    
    JMP MAIN                    ; jump to the start of MAIN
    HLT                         ; halt the CPU, stopping program execution
