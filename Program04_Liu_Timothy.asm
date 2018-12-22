TITLE Composite Numbers     (Program04_Liu_Timothy.asm)

; Author: Timothy Liu
; Last Modified: November 3, 2018
; Description: This program will introduce the program and programmer, prompt the user for
;   a number from 1 to 10000, inclusive, verify that the number is in range, calculate and
;   display that many composite numbers, and say farewell.

; Implementation notes: This program is implemented using procedures. All variables are
;	global, and there is no parameter passing.

INCLUDE Irvine32.inc

LOWER_LIMIT = 1			; Lowest valid input
UPPER_LIMIT = 10000		; Highest valid input
TAB = 9					; ASCII code for horizontal tab to align output (Extra Credit #1)
FIRST_NUM = 4			; First composite number is 4
NUM_PER_LINE = 10		; Number of composites allowed per line
LINES_PER_PAGE = 30		; Number of lines allowed to display per page (Extra Credit #2)
INVALID_NUM = 0			; Value for invalid input
ARRAY_SIZER = 1371		; This value plus two is max size of array holding primes

.data
progIntro		BYTE	"Composite Numbers", 9h, "Programmed by "
				BYTE	"Timothy Liu", 0dh, 0ah, 0dh, 0ah, 0		; Program and programmer introduction
ec_1			BYTE	"EC #1: Output columns are aligned"
				BYTE	0dh, 0ah, 0									; Description of Extra Credit #1
ec_2			BYTE	"EC #2: Displays up to 300 composites per "
				BYTE	"page and prompts user to view more "
				BYTE	"pages", 0dh, 0ah, 0						; Description of Extra Credit #2
ec_3			BYTE	"EC #3: Checks against prime divisors "
				BYTE	"found so far", 0dh, 0ah, 0dh, 0ah, 0		; Description of Extra Credit #3
instructions	BYTE	"Enter the number of composite numbers "
				BYTE	"you would like to see.", 0dh, 0ah, "I'll "
				BYTE	"accept orders for up to 10000 "
				BYTE	"composites.", 0dh, 0ah, 0dh, 0ah, 0		; Program instructions
promptText		BYTE	"Enter the number of composites to "
				BYTE	"display [1 .. 10000]: ", 0					; Prompt user for value
numTerms		DWORD	?											; Number of composite numbers provided by user
invalidText		BYTE	"Out of range. Try again.", 0dh, 0ah, 0		; Text for out-of-range input
arrayPrime		DWORD	2, 3, ARRAY_SIZER DUP(?)							; Array of prime numbers, starting with 2 and 3 (Extra Credit #3)
arraySize		DWORD	2											; Number of primes stored in array (Extra Credit #3)
numOnLine		BYTE	0											; Counter for number of values on current line
lineNum			BYTE	0											; Counts number of lines printed (Extra Credit #2)
showMore		BYTE	"Show next page? 1 for yes, 0 for no: ", 0	; Ask user if want to display next page of numbers (Extra Credit #2)
showMoreInput	DWORD	?											; User response to showing next page (Extra Credit #2)
farewellText	BYTE	0dh, 0ah, "Results certified by "
				BYTE	"Timothy Liu. Goodbye.", 0dh, 0ah, 0		; Farewell text

.code
main PROC
	call	introduction
promptUser:
	call	getUserData
	cmp		numTerms, INVALID_NUM	; Check if user input was determined to be valid
	je		promptUser				; Re-prompt user if input was invalid
	call	showComposites
	call	farewell
	exit							; Exit to operating system
main ENDP

; Description: Procedure to introduce the program, extra credit descriptions, and instructions
; Receives: none
; Returns: none
; Preconditions: none
; Registers changed: edx

introduction	PROC
; Introduce program and programmer
	mov		edx, OFFSET progIntro
	call	WriteString

; Display extra credit descriptions
	mov		edx, OFFSET ec_1
	call	WriteString
	mov		edx, OFFSET ec_2
	call	WriteString
	mov		edx, OFFSET ec_3
	call	WriteString

; Display program instructions
	mov		edx, OFFSET instructions
	call	WriteString
	ret
introduction	ENDP

; Description: Procedure to get number of composite numbers from the user
; Receives: none
; Returns: global numTerms from sub-procedure validate
; Preconditions: none
; Registers changed: eax, edx

getUserData	PROC
; Ask user for number of composite numbers to display
	mov		edx, OFFSET promptText
	call	WriteString	
	call	ReadDec

; Data validation: Ensure input is in range [1 .. 10000]
	call	validate
	ret
getUserData	ENDP

; Description: Sub-procedure to validate user input is in range [1 .. 10000]
; Receives: value stored in eax
; Returns: global numTerms with valid user input or 0 to indicate invalid input
; Preconditions: none
; Registers changed: none

validate	PROC
; Check if user input is less than 1
	cmp		eax, LOWER_LIMIT
	jl		invalidInput

; Check if user input is greater than 10000
	cmp		eax, UPPER_LIMIT
	jg		invalidInput

; Store valid user input
	mov		numTerms, eax		
	jmp		endValidate

; Handle invalid input
invalidInput:
	mov		numTerms, INVALID_NUM
	call	declareInvalid

endValidate:
	ret
validate	ENDP

; Description: Sub-sub-procedure to tell user the input was invalid
; Receives: none
; Returns: none
; Preconditions: none
; Registers changed: edx

declareInvalid	PROC
	mov		edx, OFFSET invalidText
	call	WriteString
	ret
declareInvalid	ENDP

; Description: Procedure to display composite numbers
; Receives: global numTerms with valid user input
; Returns: none
; Preconditions: none
; Registers changed: eax, ebx, ecx, edx

showComposites	PROC
	call	Crlf
	mov		ecx, numTerms			; Set up loop counter
	mov		ebx, FIRST_NUM			; Set up starting term
forEachNumber:
; Check if number is composite
	call	isComposite				
	cmp		eax, INVALID_NUM		
	je		notComposite
; Print composite with horizontal tab
	inc		numOnLine				; Update number of values on current line
	call	WriteDec				; Display composite
	mov		al, TAB
	call	WriteChar				; Insert horizontal tab
	cmp		numOnLine, NUM_PER_LINE	; Check number of values on current line
	jne		yesComposite
	call	Crlf					; Go to next line if reached max values per line
	mov		numOnLine, 0			; Reset counter for number of values on line
	inc		lineNum					; Update counter for number of lines
	cmp		lineNum, LINES_PER_PAGE	; Check if reached max lines per page
	jne		yesComposite
	mov		lineNum, 0				; Reset line number counter
	mov		edx, OFFSET showMore	; Ask if user wants to see next page of numbers
	call	WriteString
	call	ReadDec					; Get response from user
	cmp		eax, 0
	je		endShow
	call	Clrscr					; Clear current screen and show next page of numbers
	jmp		yesComposite
notComposite:	
	inc		ecx						; Cancel loop decrement since value not found
yesComposite:
	inc		ebx						; Go to next value to test
	loop	forEachNumber
endShow:
	ret
showComposites	ENDP

; Description: Sub-procedure to check if a number is a composite number
; Receives: value in ebx from showComposites
; Returns: eax holds either composite number or 0 to indicate not a composite number
; Preconditions: none
; Registers changed: eax, edx, esi

isComposite	PROC
	push	ecx						; Save outer loop counter
; Loop through each prime number found so far
	mov		ecx, arraySize
	mov		esi, OFFSET arrayPrime	; Index first element in list of prime numbers
arrayLoop:
; Set up division operation
	mov		edx, 0					; Clear remainder
	mov		eax, ebx				; Set up dividend
	push	ebx						; Save value being tested
	mov		ebx, [esi]				; Set up divisor
	add		esi, TYPE DWORD			; Move array pointer to next value
	div		ebx						; Perform division
	pop		ebx						; Retrieve value being tested
	cmp		edx, 0					; Check if no remainder
	je		foundComposite
	loop	arrayLoop
; Value is prime if go through entire array 
	mov		[esi], ebx				; Store prime in array
	inc		arraySize
	mov		eax, INVALID_NUM		; Store value to indicate value is not composite
	jmp		endIsComposite
foundComposite:
	mov		eax, ebx				; Store composite to be returned
endIsComposite:
	pop		ecx						; Restore outer loop counter
	ret
isComposite	ENDP

; Description: Procedure to say farewell to the user
; Receives: none
; Returns: none
; Preconditions: none
; Registers changed: edx

farewell	PROC
	call	Crlf
	mov		edx, OFFSET farewellText
	call	WriteString
	ret
farewell	ENDP

END main
