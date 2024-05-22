JMP MAIN        		; jump to the MAIN section
JMP isr         		; jump to the interrupt service routine

;===============================================================================================|

;===============================================================================================|
str_loading1: DB "Guess the\x00"
str_loading2: DB "bigger number\x00"
str_loading3: DB "of symbols..\x00"
start_game_str_1: DB "Press tab\x00"
start_game_str_2: DB "to START\x00"
CLUBS: DB "CLUBS -> C\x00"
LEAVES: DB "LEAVES -> L\x00"
DIAMONDS: DB "DIAMONDS -> D\x00"
HEARTS: DB "HEARTS -> H\x00"
EMPTY_SMILE: DB "SMILE -> E\x00"
FULL_SMILE: DB "FULL SMILE -> F\x00"
SCORE: DB "0"
;===============================================================================================|

;===============================================================================================|
score2: DB "Score: \x00"

QUIT: DW 0      		; define a variable QUIT with initial value 0
COUNTER: DW 0x0035  	; define a variable COUNTER with initial value 0x0039

isr:            		; start of the interrupt service routine
    PUSH A      		; push the value of register A onto the stack
    MOV C, [COUNTER]    ; move the value from memory location COUNTER to register C
    MOV [QUIT], 1  		; move the value 1 to the memory location QUIT to quit the program
    MOV A, 2
    OUT 2
    POP A
    IRET

RANDOM_NUM:
    IN 10
    AND A, 0x0F1E
    MOV D, A
    RET

draw_text: 				; draw the text
   	
DRAW_TEXT_LOOP:
    MOV A, D 			; screen position
    OUT 8				; through the VIDADDR I/O register
    MOVB AH, [B]		; get character
    CMPB AH, 0
    JE DRAW_TEXT_END
    MOVB AL, 255		; color
    OUT 9				; print on screen
    INC B				; next character
    ADD D, 2			; next screen cell
    JMP DRAW_TEXT_LOOP  ; repeat for the next character

DRAW_TEXT_END:
    RET

draw: 					; draw function
    MOVB BH, [C]        ; get the character 
    CMPB BH, 0          ; if the character is 0, we are done 
    JE draw_return      ; jump if equal
    MOV A, D            ; set the VRAM address for the character 
    OUT 8               ; through the VIDADDR I/O register
    MOV A, B            ; set the character and its color 
    OUT 9               ; through the VIDDATA I/O register
    INC C               ; point to the next character
    ADD D, 2            ; set the next VRAM address
    JMP draw 
draw_return: 
    RET 

check_press: 			; function to check for key press
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
    MOV [QUIT], 1 		; set QUIT flag to 1 to exit the loading loop
    RET

MAIN:
    MOV SP, 0x0FFF
    MOV A, 1
    OUT 7					; clear screen
    ; starting screen
    MOV D, 0x0502       	; position
    MOV B, str_loading1 	; string
    CALL draw_text 			; display loading text
    MOV D, 0x0602			; position
    MOV B, str_loading2 	; string
    CALL draw_text			; display loading text
    MOV D, 0x0702			; position
    MOV B, str_loading3 	; string
    CALL draw_text			; display loading text
    MOV D, 0x0902			; position
    MOV B, start_game_str_1 ; string
    CALL draw_text			; display loading text
    MOV D, 0x0A02			; position
    MOV B, start_game_str_2 ; string
    CALL draw_text			; display loading text
;===============================================================================================|
    
;===============================================================================================|
return_string:																
    PUSH A																	
    MOV A, score2															
    MOV D, 0x1000															
loop_print_score:														
    PUSH B																
    MOVB BL , [A]														
    CMPB BL , 0				;print score on text display					
    JE return_string_score												
    MOVB [D], BL														
    INC A																
    INC D																
    JMP loop_print_score												
																				
return_string_score:		;print the values on the text display			
    MOVB BL, [SCORE]														
  	MOVB [SCORE], BL														
   	MOVB [0x1007], BL														
    POP B																	
    POP A																	
;===============================================================================================|

;===============================================================================================|
WAIT_FOR_ENTER:
    CALL check_press
    MOV A, [QUIT]
    CMP A, 1
    JNE WAIT_FOR_ENTER

    MOV A, 3
    OUT 7 				; clear screen
;===============================================================================================|

;===============================================================================================|  
; LEVEL 1: 10 club symbols and 9 leaf symbols

; printing 10 club symbols
    MOV B, 10 			; counter for clubs
    MOVB CH, 5 			; club symbol
    MOVB CL, 148 		; club color

LEVEL1_CLUBS:
    DEC B 				; decrease counter
    CALL RANDOM_NUM 	; get random position
    MOV A, D 			; position for club
    OUT 8				; through the VIDADDR I/O register
    MOVB AH, CH 		; club symbol
    MOVB AL, CL 		; club color
    OUT 9 				; display the character
    CMP B, 0
    JNE LEVEL1_CLUBS

; printing 9 leaf symbols
    MOV B, 9 			; counter for leaves
    MOVB CH, 6 			; leaf symbol
    MOVB CL, 196 		; leaf color

LEVEL1_LEAVES:
    DEC B 				; decrease counter
    CALL RANDOM_NUM 	; get random position
    MOV A, D 			; position for leaf
    OUT 8				; through the VIDADDR I/O register
    MOVB AH, CH 		; leaf symbol
    MOVB AL, CL 		; leaf color
    OUT 9 				; display the character
    CMP B, 0
    JNE LEVEL1_LEAVES

; proceed to Level 2
    MOV [QUIT], 0  		; reset QUIT flag
    MOV A, 50000
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
	
    MOV A, 3
    OUT 7 				; clear screen
    MOV D, 0x0602
    MOV B, LEAVES
    CALL draw_text
    MOV D, 0x0702
    MOV B, CLUBS
    CALL draw_text
    
    WAIT_LOOP_FOR_CHOICE:
    IN 5
    CMP A, 0
    JNE END_WAIT_LOOP_FOR_CHOICE
	JMP WAIT_LOOP_FOR_CHOICE
    END_WAIT_LOOP_FOR_CHOICE:
    
    IN 6
    CMP A, 'l'
    JE print_score
    CMP A, 'c'
    JE inc_score
    JMP WAIT_LOOP_FOR_CHOICE
    
    inc_score:
    MOVB BL, [SCORE]
    INCB BL
    MOVB [SCORE], BL
    print_score:
    MOVB BL, [SCORE]
    MOVB [0x1007], BL
    
    MOV A, 3
    OUT 7               ; clear screen
;===============================================================================================|
    
;===============================================================================================|
; LEVEL 2: 20 heart symbols and 19 diamond symbols

; printing 20 heart symbols
    MOV B, 20			; counter for hearts
    MOVB CH, 3 			; heart symbol
    MOVB CL, 196 		; heart color

LEVEL2_HEARTS:
    DEC B 				; decrease counter
    CALL RANDOM_NUM 	; get random position
    MOV A, D 			; position for heart
    OUT 8				; through the VIDADDR I/O register
    MOVB AH, CH 		; heart symbol
    MOVB AL, CL 		; heart color
    OUT 9 				; display the character
    CMP B, 0
    JNE LEVEL2_HEARTS

    					; printing 19 diamond symbols
    MOV B, 19 			; counter for diamonds
    MOVB CH, 4 			; diamond symbol
    MOVB CL, 252 		; diamond color

LEVEL2_DIAMONDS:
    DEC B 				; decrease counter
    CALL RANDOM_NUM 	; get random position
    MOV A, D 			; position for diamond
    OUT 8				; through the VIDADDR I/O register
    MOVB AH, CH 		; diamond symbol
    MOVB AL, CL 		; diamond color
    OUT 9 				; display the character
    CMP B, 0
    JNE LEVEL2_DIAMONDS

; proceed to Level 3
    MOV [COUNTER], 0x0035
    MOV [QUIT], 0  		; reset QUIT flag
    MOV A, 50000
    OUT 3
    MOV A, 2
    OUT 0
   

WAIT_FOR_LEVEL3:
    MOV A, [QUIT]
    CMP A, 1
    JE START_LEVEL3
    JMP WAIT_FOR_LEVEL3

START_LEVEL3:
    MOV A, 3
    OUT 7 			    ; clear screen
    MOV D, 0x0602
    MOV B, DIAMONDS
    CALL draw_text
    MOV D, 0x0702
    MOV B, HEARTS
    CALL draw_text
    
    WAIT_LOOP_FOR_CHOICE1:
    IN 5
    CMP A, 0
    JNE END_WAIT_LOOP_FOR_CHOICE1
	JMP WAIT_LOOP_FOR_CHOICE1
    END_WAIT_LOOP_FOR_CHOICE1:
    
    IN 6
    CMP A, 'd'
    JE print1_score
    CMP A, 'h'
    JE incr_score
    JMP WAIT_LOOP_FOR_CHOICE1
    
    incr_score:
    MOVB BL, [SCORE]
    INCB BL
    MOVB [SCORE], BL
    print1_score:
    MOVB BL, [SCORE]
    MOVB [0x1007], BL
    
    MOV A, 3
    OUT 7    			; clear screen
;===============================================================================================|

;===============================================================================================|
; LEVEL 3: 30 empty smile emojis and 29 full smile emojis

; printing 30 empty smile emojis
    MOV B, 30 			; counter for empty smiles
    MOVB CH, 1 			; empty smile symbol
    MOVB CL, 3 			; empty smile color

LEVEL3_EMPTY_SMILE:
    DEC B 				; decrease counter
    CALL RANDOM_NUM 	; get random position
    MOV A, D 			; position for empty smile
    OUT 8				; through the VIDADDR I/O register
    MOVB AH, CH 		; empty smile symbol
    MOVB AL, CL 		; empty smile color
    OUT 9 				; display the character
    CMP B, 0
    JNE LEVEL3_EMPTY_SMILE

; printing 29 full smile emojis
    MOV B, 29 			; counter for full smiles
    MOVB CH, 2 			; full smile symbol
    MOVB CL, 7 			; full smile color

LEVEL3_FULL_SMILE:
    DEC B 				; decrease counter
    CALL RANDOM_NUM 	; get random position
    MOV A, D 			; position for full smile
    OUT 8				; through the VIDADDR I/O register
    MOVB AH, CH 		; full smile symbol
    MOVB AL, CL 		; full smile color
    OUT 9 				; display the character
    CMP B, 0 			; compare counter to 0
    JNE LEVEL3_FULL_SMILE ; jump back to LEVEL3_FULL_SMILE if counter is not zero
    
; proceed to Level 4
    MOV [COUNTER], 0x0035
    MOV [QUIT], 0       ; reset QUIT flag
    MOV A, 50000
    OUT 3
    MOV A, 2
    OUT 0
    STI

WAIT_FOR_LEVEL4:
    MOV A, [QUIT]
    CMP A, 1
    JE START_LEVEL4
    JMP WAIT_FOR_LEVEL4

START_LEVEL4:
    MOV A, 3
    OUT 7 			    ; clear screen
    MOV D, 0x0602
    MOV B, EMPTY_SMILE
    CALL draw_text
    MOV D, 0x0702
    MOV B, FULL_SMILE
    CALL draw_text
    
    WAIT_LOOP_FOR_CHOICEE1:
    IN 5
    CMP A, 0
    JNE END_WAIT_LOOP_FOR_CHOICEE1
	JMP WAIT_LOOP_FOR_CHOICEE1
    END_WAIT_LOOP_FOR_CHOICEE1:
    
    IN 6
    CMP A, 'e'
    JE printt1_score
    CMP A, 'f'
    JE increm_score
    JMP WAIT_LOOP_FOR_CHOICEE1
    
    increm_score:
    MOVB BL, [SCORE]
    INCB BL
    MOVB [SCORE], BL
    printt1_score:
    MOVB BL, [SCORE]
    MOVB [0x1007], BL
   
    MOV A, 3
    OUT 7    			; clear screen
;===============================================================================================|

;===============================================================================================|
; continue with the rest of the code	
    
BREAK:
 
    MOV A, 3       		; move the value 3 to register A
    OUT 7          		; clear screen
    
    WAIT_LOOP_FOR_CHOCIE1:
    IN 5
    CMP A, 0
    JNE END_WAIT_LOOP_FOR_CHOCIE1
	JMP WAIT_LOOP_FOR_CHOCIE1
    END_WAIT_LOOP_FOR_CHOCIE1:  
    IN 6
    CMP A, 'r'
    JNE WAIT_LOOP_FOR_CHOCIE1
    
    ; this is for reseting the score to 0 when clicking 'r'
    ;MOV B, 0x30
    ;MOVB [SCORE], AL 
    
    JMP MAIN
    HLT            		; halt the CPU, stopping program execution
