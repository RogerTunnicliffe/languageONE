;-----------------------------------------------------------------------
;			IMACROS.ASM are macros used by the system and do not form 
;			part of the language
;           They use lowercase for names and begin with a $ sign
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;	WORDS : ALPHABETIC - Left to Right
	%define r_Function		 R8
	%define r_SrcAddress	 R9
	%define r_SrcStart		 R10
	%define r_SrcLength		 R11
	%define r_DstAddress	 R12
	%define r_DstStart		 R13
	;	When it is a Number -> Word 
		%define r_SrcPicAddress	 R10
		%define r_SrcPicLength	 R11

;	NUMBERS : NUMERIC - Right to Left
	%define r_nDstAddress	 R9
	%define r_nSrcAddress	 R12
	%define r_nSrcPicAddress R13	
	%define r_nSrcPicLength	 R14
	;	When it is alphabetic -> Number
		%define r_nSrcStart		 R13	
		%define r_nSrcLength	 R14

;	FILES
	%define r_File			R9
	%define r_FileFlags		R10
	%define r_Record		R10

;	TABLES
	%define r_Table	 		R9
	%define r_Record 		R10
	
;	WWW
	%define r_PortNo 		r9d
	%define r_ScreenName	r9
	%define r_Response		r10
	%define r_GetAddress	r11
	%define r_PostAddress	r12

		
;	%define @skipIndicator qword[SKIPSTACK+rax]

	%define @NumScale(x)		qword[x-17]
	%define @fieldIndicator(x)	 byte[x-9]
	%define @fieldLength(x)		qword[x-8] 

;***********************************************************************
;			THESE ARE NOT MACROS PARSAE but rather a simple way
;			to simulate a copy (%include) file.
;			It makes it easier to have them in here rather than
;			in a separate CPY file
;*********************************************************************** 

;=======================================================================
;      		Macro for debugging
;=======================================================================
%macro  DEBUG 0
	mov  qword[STOP],1
%endmacro	

;=======================================================================
;      		Macros to aid in stack processing (Used everywhere)
;=======================================================================
%macro $saveRegisters 4

			add qword[SX],40
			mov rbp,savedRegisters
			add rbp,qword[SX]

			mov qword[rbp-40],%1
			mov qword[rbp-32],%2
			mov qword[rbp-24],%3
			mov qword[rbp-16],%4
			mov qword[rbp-08],0
				
%endmacro

%macro $restoreRegisters 4

			mov rbp,savedRegisters
			add rbp,qword[SX]

			mov %1,qword[rbp-40]
			mov %2,qword[rbp-32]
			mov %3,qword[rbp-24]
			mov %4,qword[rbp-16]
			
%endmacro

;=======================================================================
;      		Code used in FILES.LIB and TABLES.LIB
;=======================================================================
%macro $fromRecord 0

		;	START LOOP -------------------------------------------------						
	.loop:	cmp @fieldIndicator(RSI),0x00								; Loop Here - ARE WE DONE
	;V2.05		je _FROMRECORD_EXIT
				je .Exit
				
			cmp @fieldIndicator(RSI),'9'								; If the field is a number then
				je .nos													;	Do Number

		;---WORDS ****	
			mov rcx,@fieldLength(RSI)									; Grab the length of the field
	.X:		movsb														; move the bytes
			loop .X														;
			add RSI,17													; Next Word
			jmp .loop													; and jump to end of field process
		;	END LOOP for Alpha -----------------------------------------
					
		;---NUMBERS ****	
		;	Convert the binary number to ascii (LEFT to RIGHT)
	.nos:	$pushAll r8,r9,r10,r11,r12,r13,r14,r15,rsi,rdi				; Save everything											
			mov r9,RSI													; Setup source (number)	
			xor r10,r10													; Clear picture override
			xor r11,r11													; Clear picture override
			mov r12,w_Temp												; Using w_Temp
			mov r13,[w_One]												; Start at 1
			mov r15,c_TRUE												; Tell _TOALPHA to Set length of Destination
			Call _TOALPHA												; Make the call
			$popAll rdi,rsi,r15,r14,r13,r12,r11,r10,r9,r8				; Restore everything

			PUSH RSI
			mov RSI,w_Temp												; Reset the source to w_Temp
			mov rcx,@fieldLength(w_Temp)								; Grab the length of the field
	.9:		movsb														; move the bytes
			loop .9									
			POP RSI
			
		;	Jump over stuff
			mov rax,RSI													; Address of Number
			add rax,8													; 	jump over no
			add rax,@fieldLength(RSI)									;	add length of picture
			add rax,17													;	add 17 (number)
			mov RSI,rax													; store the new offset
			jmp .loop
		;	END LOOP for Number ----------------------------------------

	.Exit:	; V2.05
	
%endmacro

%macro $toRecord 0

		;	START LOOP -------------------------------------------------
	.loop:	cmp @fieldIndicator(RDI),0x00								; Loop Here - ARE WE DONE
	;V2.05		je _TORECORD_EXIT
				je .Exit
				
			cmp @fieldIndicator(rdi),'9'								; If the field is a number then
				je .nos													;	Do Number

		;---WORDS	
			mov rcx,@fieldLength(RDI)									; Grab the length of the field
	.X:		movsb														; move the bytes
			loop .X						
			add RDI,17													; Next Word
			jmp .loop													; and loop back to get next field
		;	END LOOP for ALPHA -----------------------------------------
							
		;---NUMBERS	
		;	Convert the ascii number to binary (RIGHT to LEFT)		
	.nos:	$pushAll r8,r9,r10,r11,r12,r13,r14,r15,rsi,rdi				; Save everything											
			mov r9,RDI													; Set destination (binary)
			xor r10,r10													; Clear picture override
			xor r11,r11													; Clear picture override
			mov r12,RSI													; Set source (alpha)
			mov r13,[w_One]												; start at 1
			mov r14,[r9-8]												; Length (destination length)
			Call _FROMALPHA												; Make the call
			$popAll rdi,rsi,r15,r14,r13,r12,r11,r10,r9,r8				; Restore everything

		;	Jump over stuff
			add RSI,@fieldLength(RDI)									; Advance source by picture length
			mov rax,RDI													; Address of Number
			add rax,8													; 	jump over no
			add rax,@fieldLength(RDI)									;	add length of picture
			add rax,17													;	add 17 (number)
			mov RDI,rax													; store the new offset	
				
			jmp .loop
		;	END LOOP for Number ----------------------------------------

	.Exit:	; V2.05
	
%endmacro
;-----------------------------------------------------------------------
;=======================================================================
;			Replace Symbols
;=======================================================================
%macro $replaceSymbols 1

		%ifidni %1, =
			mov r8,EQ
		%elifidni %1, !=
			mov r8,N_EQ
		%elifidni %1, >
			mov r8,GT
		%elifidni %1, !>
			mov r8,N_GT

		%elifidni %1, <=
			mov r8,N_GT
		%elifidni %1, =<
			mov r8,N_GT

		%elifidni %1, <
			mov r8,LT
		%elifidni %1, !<
			mov r8,N_LT

		%elifidni %1, >=
			mov r8,N_LT
		%elifidni %1, =>
			mov r8,N_LT

		%else
			mov r8,%1
		%endif
%endmacro

;=======================================================================
;			Push/Pop ALL
;           %0 is the number of parameters passed
;           %rotate cycles thru the parameters
;=======================================================================
%macro $pushAll 1-*

	%rep	%0										; Repeat n times (No Of Parameters)
			push %1									; Push onto the stack
			%rotate 1								; Move to the next parameter
	%endrep

%endmacro
;-----------------------------------------------------------------------
%macro $popAll 1-*

	%rep	%0										; Repeat n times (No Of Parameters)
			pop %1									; Pop from the stack
			%rotate 1								; Move to the next parameter
	%endrep
				
%endmacro

;=======================================================================
;      		Simple copy data
;=======================================================================
%macro $copyBytes 3

			mov RSI,%1													; Grab the Src Address
			mov RDI,%2													; Grab the Dst Address
			mov rcx,%3													; Grab the length
	%%l:	movsb														; Move the data
			loop %%l 	

%endmacro

;=======================================================================
;      		Copy QWORDS
;			This relies on RSI,RDI and RCX all being setup
;=======================================================================
%macro $copyQwords 0
	;
	;	WARNING - Source and Destination must be the same 
	;
			cld
	%%lq:	cmp rcx,8
				jb %%lb
			movsq
			sub rcx,8
			jmp %%lq
			
	%%lb:	cmp rcx,0
			jna %%lend
			movsb
			loop %%lb
	%%lend:		

%endmacro


;=======================================================================				
;           Initialise a string
;=======================================================================	
;-----------------------------------------------------------------------
;			No point making a call for this one
;USES:		RAX,RCX,RDX,RSI,RDI
;-----------------------------------------------------------------------
%macro $initialise 1-2 ' '

			$pushAll rax,rcx,rsi,rdi

	%%Num:	cmp byte[%1-9],'9'
				jne %%Alpha
			mov qword[%1],0
			jmp %%Exit	
				
	%%Alpha:
			mov  al, %2
			mov rdi, %1
			mov rcx,[%1-8]
			cld
	rep		stosb
		
	%%Exit:
			$popAll rdi,rsi,rcx,rax

%endmacro
;=======================================================================
;		Macro to extract sub parameters
;=======================================================================
;-----------------------------------------------------------------------
;			+-------------------+   
;			|  Parameter 4      |
;			+-------------------+   (rsp+24)
;			|  Parameter 3      |
;			+-------------------+   (rsp+16)
;			|  Parameter 2      |
;			+-------------------+   (rsp+8)
;			|  Parameter 1      |
;			+-------------------+   (rsp)
;-----------------------------------------------------------------------
%macro $extract 1-4

	[section .data]
;-----------------------------------------------------------------------												
;   Create Storage for literals in parameters
;-----------------------------------------------------------------------
		
	%if %0 > 0

		%assign NoOfParameters 1
		
		%ifstr %1
					dq 0
					db 'X'
			%strlen length %1						; Get the length of the string
					dq length						; 	and define the length 
			%%1		db %1							; 	create storage for it
		%endif
		
		%ifnum %1									; If a numeric literal has been passed then
					dq 0xffffffffffffffff
					db '9'
					dq 26
				%%1 dq %1							;	create storage for it
					db '#,###,###,###,###,###,###-'
		%endif

	%endif	

	%if %0 > 1
		%assign NoOfParameters 2										

		%ifstr %2									; If a string literal has been passed then
					dq 0
					db 'X'
			%strlen length %2						; Get the length of the string
					dq length						; 	and define the length 
			%%2		db %2							; 	create storage for it
		%endif
						
		%ifnum %2									; If a numeric literal has been passed then
					dq 0xffffffffffffffff
					db '9'
					dq 26
				%%2 dq %2							;	create storage for it
					db '#,###,###,###,###,###,###-'
		%endif
		
	%endif

	%if %0 > 2
		%assign NoOfParameters 3
		
		%ifstr %3									; If a string literal has been passed then
					dq 0
					db 'X'
			%strlen length %3						; Get the length of the string
					dq length						; 	and define the length 
			%%3		db %3							; 	create storage for it
		%endif
						
		%ifnum %3									; If a numeric literal has been passed then
					dq 0xffffffffffffffff
					db '9'
					dq 26
				%%3 dq %3							;	create storage for it
					db '#,###,###,###,###,###,###-'
		%endif
		
	%endif
				
	%if %0 > 3
		%assign NoOfParameters 4
		
		%ifstr %4									; If a string literal has been passed then
					dq 0
					db 'X'
			%strlen length %4						; Get the length of the string
					dq length						; 	and define the length 
			%%4		db %4							; 	create storage for it
		%endif
						
		%ifnum %4									; If a numeric literal has been passed then
					dq 0xffffffffffffffff
					db '9'
					dq 26
				%%4 dq %4							;	create storage for it
					db '#,###,###,###,###,###,###-'
		%endif
		
	%endif

;-----------------------------------------------------------------------
	%%Code:
;-----------------------------------------------------------------------	
	[section .text]
;-----------------------------------------------------------------------												
;   Push parameters
;-----------------------------------------------------------------------
	%if %0 > 3
	
		%ifstr %4
			push %%4								; Address of string		
		   %elifnum %4 
				push %%4							; Address of number
			%else		
				push %4								; Address of Token
		%endif
	
	%endif

	%if %0 > 2
	
		%ifstr %3
			push %%3								; Address of string		
		   %elifnum %3 
				push %%3							; Address of number
			%else		
				push %3								; Address of Token
		%endif
	
	%endif

	%if %0 > 1
	
		%ifstr %2
			push %%2								; Address of string		
		   %elifnum %2 
				push %%2							; Address of number
			%else		
				push %2								; Address of Token
		%endif
	
	%endif

	%if %0 > 0
	
		%ifstr %1
			push %%1								; Address of string		
		   %elifnum %1 
				push %%1							; Address of number
			%else	
				push %1								; Address of Token
		%endif
	
	%endif
  
	%%Exit:
%endmacro

;=======================================================================
;	COMMON code.
;=======================================================================
;-----------------------------------------------------------------------
;	The following code is used for IF/.IF, OR/.OR & AND/AND 
;-----------------------------------------------------------------------
;
;			+-------------------+	  +-------------------+
;			|     				|	  |  	  			  |
;			+-------------------+ r15 +-------------------+	
;			|  r_DstLength		|	  |	 r_DstPicLength	  |
;			+-------------------+ r14 +-------------------+	
;			|  r_DstStart		|	  |	 r_DstPicAddress  |
;			+-------------------+ r13 +-------------------+	 	
;			|  r_DstAddress     |	   	  	
;			+-------------------+ r12 +-------------------+
;			|  r_SrcLength      |	  |  r_SrcPicLength   |
;			+-------------------+ r11 +-------------------+
;			|  r_SrcStart       |	  |  r_SrcPicAddress  |
;			+-------------------+ r10 +-------------------+
;			|  r_SrcAddress     |
;			+-------------------+ r9  
;			|  r_Function       |
;			+-------------------+ r8 
;-----------------------------------------------------------------------
%macro $SetupCompare 3

			mov r_Function,%2											; Get compare function

		;   Get DESTINATION parameters
			$pushAll r9,r10,r11
			$SetupField {%3}											; Grab the Destination field 1st
			mov r12,r9													; and copy to destination registers
			mov r13,r10
			mov r14,r11
			$popAll r11,r10,r9
			
		;   Get SOURCE parameters
			$SetupField {%1}											; Grab the Source fields	
		
%endmacro

;=======================================================================
;			GENERIC ROUTINE FOR SETTING UP A FIELD's registers
;=======================================================================
;-----------------------------------------------------------------------

;			+-------------------+ 	  +-------------------+
;			|  r_SrcLength      |	  |  r_SrcPicLength   | 
;			+-------------------+ r11 +-------------------+
;			|  r_SrcStart       |	  |  r_SrcPicAddress  | 
;			+-------------------+ r10 +-------------------+
;			|  r_SrcAddress     |
;			+-------------------+ r9  
;			|  r_Function       |
;			+-------------------+ r8 
;-----------------------------------------------------------------------
%macro $SetupField 1

	$extract %1
			pop r9														; address of word/number
								
			cmp @fieldIndicator(r9),'X'									; If it is not alpha then
				jne %%Number											; 	jump to numeric code

;-----------------------------------------------------------------------
;           Code for alphas
;-----------------------------------------------------------------------
		;	Defaults
			mov r10,w_One												; (Default) address of start position	
			mov r11,r9													; (Default) address of No Of Bytes
			sub r11,8

		%if NoOfParameters > 1							
			pop r10														; address of start position
			%if NoOfParameters > 2										
				pop r11													; address of No Of Bytes
			%endif
		%endif

			mov r10,[r10]												; Start position
			mov r11,[r11]												; No Of Bytes	

			Call _VALIDATE_SRC
			
			jmp %%Exit	

;-----------------------------------------------------------------------
;			Code for numerics
;-----------------------------------------------------------------------						
	%%Number:
		;	Defaults
			xor r10,r10													; Zero Override field
			xor r11,r11													; Zero Override field
		%if NoOfParameters > 1											; {I,'####'}													
			pop r10														; Picture Address
			mov r11, @fieldLength(r10)									; Picture Length
		%endif		
			
	%%Exit:
%endmacro

;=======================================================================				
;           Calculate the Scale from the No Of Decimal PLaces
;			%1 - Field Address
;			%2 - No Of Places
;=======================================================================	
%macro $PlacesToScale 2

			mov qword[%1-17],1						; Setup the default
				
			cmp %2,0								; We have found one (but it could be 123456.) 	
				je %%Exit							; then exit

			cmp %2,19								; Overflow [Underflow actually]
				ja %%err			

			mov qword[%1-17],10						; setup default (10) for 1 decimal place
			dec %2									; Decrement
			
		;	so now	Places = 0 and Scale = 10
			cmp %2,0								; If one decimal place only
				je %%Exit							;	then exit
				
			mov rax,10								; setup for multiplies
			mov rbx,10								; by 10
			mov rcx,%2								; Ready Counter
		;	------------------------------------------------------------	
	%%l:	mul rbx									; Multiply	
			loop %%l								; and loop
		;	------------------------------------------------------------
			mov qword[%1-17],rax					; store the scalling factor
			jmp %%Exit

	%%err:	xor rax,rax
			mov r14,err02
			Call _SYSERROR	

	%%Exit:
%endmacro
;=======================================================================				
;           Calculate the No Of Decimal Places from the Scale
;			%1 - Scale
; RETURN RCX as No Of Places
;=======================================================================	
%macro $ScaleToPlaces 1

			$pushAll rax,rbx,rdx
			
			mov rcx,0								; Ready Counter
			cmp %1,1								; 1 indicates an integer
				je %%Exit
				
			mov rax,%1								; Load the Scales
		;	xor rdx,rdx								; Prepare for divide
			cqo
			mov rbx,10								; by 10
	%%l:	div rbx									; Multiply
			inc rcx
			cmp rax,1
				jne %%l
				
	%%Exit:
			$popAll rdx,rbx,rax
			
%endmacro

;=======================================================================
;       	Utilities
;=======================================================================
;       	Macro to test if two items are zero
;=======================================================================
%macro $And 3
			cmp %1, %3
				jne %%NotEqual
			cmp %2, %3
			
	%%NotEqual:
%endmacro
		
;=======================================================================
;       	Get position of last non-space in word
;USES:		RAX,RCX			
;RETURNS:	RDI,RCX
;=======================================================================	
%macro $EndOfWord 3

			mov  al,0x20												; set al as space
			mov RDI,%1													; get start of source
			add RDI,%2													; add the start position
			add RDI,%3													; add the No Of Bytes
			sub RDI, 2													; Subtract 2
			mov rcx,%3													; Set the counter
			std															; from end to start
	repe	scasb														; and scan
			inc RDI														; cuz scasb has dec it
			inc rcx														; gives the No Of Bytes from beginning (Length of Field)
			
%endmacro

;=======================================================================
;       	Converts c_LF (010b) to 0X0A
;USES:		%1
;RETURNS:	%1
;=======================================================================	
%macro $delimiter 2
; Record Delimiters/CVS for INSERTFILE	
;	c_NULL			equ 00000001b 
;	c_LF			equ 00000010b 
;	c_CSV			equ 00000100b
;	c_Record		equ 00001000b
;	c_Random		equ 00010000b
;	We need this cuz we need to TEST and do stuff like c_CSV+c_LF

			mov %1,@fileDelimiter(r9)				; Delimiter

	%%01:	cmp %1,1								; c_NULL
				jne %%02
			mov %1,0x00
			jmp %%03	
		
	%%02:	cmp %1,4								; c_LF or c_CSV
				ja %%03

		%if %2 = 'L'		
			mov %1,0x0A
		%endif
		%if %2 = 'W'		
			mov %1,0x0D
		%endif

	%%03:
	
%endmacro
		
;=======================================================================
;       	Get memory
;=======================================================================				
%macro $getmem 1

		;	Save Parameter. I have noticed syscall kills R11 and seeing as it is sometimes
		;	passed into here, we need to save it ??
			mov r15,%1

		;	Get bottom of BBS section
			xor rdi,rdi								; rdi is 0
			mov rax,12								; Syscall code is 12				
			syscall
			mov qword[w_TopOfBSS],rax				; Save old BBS

		;	Add the required memory
			mov rdi,rax								; starting address to RDI
			add rdi,r15								; Ammount to add (in bytes)
			mov rax,12								; Syscall code is 12
			syscall
			cmp	rax,rdi								; Is the BBS now what we asked for
				je	%%Save							; then go and save i

			mov rax,-12								; error (Out of Memory)
			Call _SYSERROR							; Call System Error (will terminate)
	
	%%Save:	mov qword[w_BottomOfBSS],rax			; Save new BBS
			
%endmacro

;=======================================================================
;       	Windows Get memory
;=======================================================================	
%macro $w_getmem 1

			mov r15,%1								; R11 may get trashed

			xor rcx,rcx								; Should be zero						
			mov rdx,r15								; Minimum Size
			xor r8,r8								; Maximum Size [0 MEANS IT CAN GROW]
		sub rsp,32
			cld
			Call HeapCreate							; Get a Handle
		add rsp,32
			
			mov rcx,rax								; Use the Handle
			mov rdx,0x00000004						; generate an exception if fails
			or  rdx,0x00000008						; zero fill
			mov r8,r15								; Size
		sub rsp,32
			cld
			Call HeapAlloc
		add rsp,32
	
		mov qword[w_TopOfBSS],rax					; Save the address
		mov qword[w_BottomOfBSS],rax				; Calc Bottom 
		add qword[w_BottomOfBSS],r15

		
%endmacro

