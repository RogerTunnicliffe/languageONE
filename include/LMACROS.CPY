
		%assign recLen 0
		
;-----------------------------------------------------------------------
;			LMACROS.ASM are macros that form part of the language
;-----------------------------------------------------------------------

;=======================================================================
;      		Macros for basic functions
;=======================================================================
%idefine spaces(x)	{w_Spaces,1,x}

;=======================================================================
;       	Macros to create files for FILES.o
;-----------------------------------------------------------------------
;		FileStatus		+-----------+--------+-------------+----+
;	+---+---+---+---+---|	db      |  dq    | db		   |0x00|
;	| 1	|'9'|Len|Val|Pic+-----------+--------+-------------+----+
;	+---+---+---+---+---| delimiter | Handle | Int[ExtName]|    |
;		AsPer INSERTNO	+-----------+--------+-------------+----+
;				-36		-26			-25		 0
;					c_NONE			equ 00000000b
;					c_NULL			equ 00000001b 
;					c_LF			equ 00000010b 
;					c_CSV			equ 00000100b
;					c_RECORD		equ 00001000b
;					c_RANDOM		equ 00010000b
;					c_DIRECTORY		equ	01000000b
;-----------------------------------------------------------------------
;			INSERTFILE Delimiter,I-Name,'./X-Name'
;-----------------------------------------------------------------------
;=======================================================================
%define @fileHandle(x)		qword[x-025]
%define @fileDelimiter(x)    byte[x-026]
%define @fileStatus(x)		qword[x-036]
%define @fileSize(x)		qword[x-104]
%define @readLength(x)		qword[x-067]

%imacro INSERTFILE 2-3
	;========== *********
	%if debug = 2									; Windows debugging
		global %2
		global %2_STATUS
		global %2_HANDLE		
	%endif
	;========== *********

				;	(V1.01a) Number field for File Size --------------
					dq 1												; 00-121 SCALE
					db '9'												; 00-113			
					dq 12												; 00-112
%2_SIZE:			dq 0												; 00-104 File Size
					db '999999999999'										; 00-96

				;	(V1.01a) Number field for Read Length --------------
					dq 1												; 00-84 SCALE
					db '9'												; 00-76				
					dq 6												; 00-75
%2_READLENGTH:		dq 0												; 00-67 Read Length
					db '999999'											; 00-59

				;	Number field for File Status --------------
					dq 1												; 00-53	 -- New field -SCALE
					db '9'												; 00-45				
					dq 2												; 00-44
%2_STATUS:			dq 0												; 00-36 File Status
					db '99'												; 00-28
				;	Number field for File Status --------------

%2_Delimiter:		db %1												; 00-26 Delimiter
%2_HANDLE:			dq 0 												; 00-25 FileHandle

				;	File Name ---------------------------------			
					dq 0												; 00-17
					db 'X'												; 00-09
					dq 255												; 00-08 
				%if %0 = 2
%2: times 255		db ' '												; 00
				%else
%2:					db %3,0X00
    times 255-$+%2	db ' '
				%endif
				;	File Name ---------------------------------

%endmacro

;=======================================================================
;       	Macros for Records
;-----------------------------------------------------------------------
; Record Indicator
;	+---+					RecordNo	 			 			+-----
;	+---+---+---+-----------+----------+-------------+---------+|	     
;	|'R'| 1 |'9'|Length(dq) |Value(dq) |Picture(9b)  + RecLength|NAME
;	|	+---+---+-----------+----------+-------------| 			|
;	+---+				 							 +----------+-----
;	-43 -42 -34 -33			-25	       -17			 -08		0
;-----------------------------------------------------------------------
;=======================================================================
%define @recordLength(x)	qword[x-8]
%define @recordNo(x)		qword[x-25]

%imacro BEGIN.RECORD 2
	;========== *********
	%if debug = 2									; Windows debugging
		global %2_NO
	%endif
	;========== *********

			db 'R'									; [00-43] Record indicator
		;	Number field for Record No --------------
			dq 1									; [00-42] Number Scale 
			db '9'									; [00-34] Number Indicator
			dq 9									; [00-33] Picture Length
%2_NO:		dq 0									; [00-25] Record Number
			db '999999999'							; [00-17]
		;	Number field for Record No --------------
		
		;	LENGTH is a WRITE Only field without a Control Block. 
		;	It can only be used internally.
%2$LENGTH:	dq %1									; [00-08] Record Length

%2:													; [00]	  Record Name   

		%assign recLen 0
%endmacro

%imacro END.RECORD 1
			dq 0									; Allow for SCALE in number in TO/FROMRECORD
			db 0x00									; Define end of record
%1_CalcLen:	dq recLen								; Calculated Record Length
%endmacro

;=======================================================================
;       	Macros to create storage for WORDS
;			INSERTWORD w_Message,11,'Hello World'
;=======================================================================
%imacro INSERTWORD 3
	;========== *********
	%if debug = 2									; Windows debugging
		global %1
	%endif
	;========== *********


			dq 0									; Need to match no size
			db 'X'									; Define it as a string
			dq %2									; Define the length of the string
%1:			db %3									; Create the string
			times %2-$+%1 db ' '					; create trailing spaces
		%assign recLen recLen+%2	 
%endmacro

;=======================================================================
;       	Macros to create storage for NUMBERS
;			INSERTNUMBER	I,0,'##,99,999.99-'
;=======================================================================
%imacro INSERTNUMBER 2-3
	;========== *********
	%if debug = 2									; Windows debugging
		global %1
	%endif
	;========== *********

		%if %0 = 2
			dq 1									; Scaling for Fixed Point numbers with No Picture
			%assign length 26			
		%else
			dq 0									; Scaling for Fixed Point numbers
			%strlen length %3
		%Endif

			db '9'									; Define it as a number
			dq length								; and define the length
%1:			dq %2									; Using 64 bits with an initial value
		%if %0 = 2
 times 26	db ' '									; Allow for dynamic picture		
		%else
			db %3									; the editing picture
		%Endif
		%assign recLen recLen+length	
%endmacro

;=======================================================================
;       	Macros to create storage for TABLES
;			INSERTTABLE WorkTable,Record,Dim1*Dim2*Dim3...Dim8
;=======================================================================
;-----------------------------------------------------------------------
; 		TableStatus		Dimension Value	 								Table Indicator									 
;	+---+---+---+---+---+---+---+---+---+---+---+---+---+---------------+---+---------+------+---+---+---+---+---+---+---+---+	     
;	| 1	|'9'|Len|Val|Pic|Idx|Idx|Idx|Idx|Idx|Idx|Idx|Idx|Record Address	|'t'|NoOfBytes| NAME |Idx|Idx|Idx|Idx|Idx|Idx|Idx|Idx|	
;	+---+---+---+---+---+---+---+---+---+---+---+---+---+---------------+---+---------+------+---+---+---+---+---+---+---+---+ 
;	-108-100-99	-91	    -81 -73	-65	-57	-49	-41	-33	-25	-17			   -9	-8		   0	  No Of Bytes +
;															       						 	 8  16  24  32  40  48  56  64  72
;
;		INSERTTABLE WorkTable,A01_Record_Length*Idx*Idx*Idx*Idx*Idx*Idx*Idx*Idx
;-----------------------------------------------------------------------
%imacro INSERTTABLE 2

		;	Status takes normal numeric data structure
			resq 1									; (-108) Table Sastus (Scale-Always 1)
			resb 1									; (-100) Table Status Numeric indicator
			resq 1									; (-99)  Table Status length
%1_STATUS:	resq 1									; (-91)  Table Status 
			resb 2									; (-83)  Table Status Picture
		;	Dimensions
			resq 1									; Dimension Value 1
			resq 1									; Dimension Value 2
			resq 1									; Dimension Value 3
			resq 1									; Dimension Value 4
			resq 1									; Dimension Value 5
			resq 1									; Dimension Value 6
			resq 1									; Dimension Value 7
			resq 1									; Dimension Value 8
		;	Structure info
			resq 1									; Associate a Record Name (Address)
			resb 1 									; Define it as a TABLE (=T)
			resq 1									; Table size
%1:			resb %2									; Create the table
		;	Indexes
			resq 1									; Idx 1
			resq 1									; Idx 2
			resq 1									; Idx 3
			resq 1									; Idx 4
			resq 1									; Idx 5
			resq 1									; Idx 6
			resq 1									; Idx 7
			resq 1									; Idx 8

%endmacro

;=======================================================================
;       	Macros to create storage for XTABLES
;			INSERTXTABLE WorkTable,Record,Size
;=======================================================================
;-----------------------------------------------------------------------
; 	UBOUND				 STATUS 				 Table Indicator									 
;	+---+---+---+---+---+---+---+---+---+---+---------------+---+---------+------+	     
;	| 1	|'9'|Len|Val|Pic| 1	|'9'|Len|Val|Pic|Record Address	|'T'|NoOfBytes| NAME |
;	+---+---+---+---+---+---+---+---+---+---+---------------+---+---------+------+
;	-61					-27					-17				-9	-8			0	  

;		INSERTXTABLE WorkTable
;-----------------------------------------------------------------------
%imacro INSERTXTABLE 1

		;	UBOUND takes normal numeric data structure
			resq 1									; (-078) UBOUND (Scale-Always 1)
			resb 1									; (-070) UBOUND Numeric indicator
			resq 1									; (-069) UBOUND length
%1_UBOUND:	resq 1									; (-061) UBOUND 
			resb 9									; (-053) UBOUND Picture
		;	STATUS takes normal numeric data structure
			resq 1									; (-044) STATUS (Scale-Always 1)
			resb 1									; (-036) STATUS Numeric indicator
			resq 1									; (-035) STATUS length
%1_STATUS:	resq 1									; (-027) STATUS
			resb 2									; (-019) STATUS Picture
		;	Structure info
			resq 1									; (-017) Associate a Record Name (Address)
			resb 1 									; (-009) Define it as a TABLE (=T)
			resq 1									; (-008) Table size (AS END ADDRESS)
%1:			resq 1									; (-000) Start address of bss

%endmacro

;=======================================================================
;       	Macros to create storage for ARRAYS
;			INSERTARRAY WorkTable,NoOf integers (qwords)
;=======================================================================
%imacro INSERTARRAY 2
 	ALIGN 8
 	%1	resq %2
 	%1.len equ $-%1
 %endmacro
 
;=======================================================================
;	LANGUAGE KEYWORDS
;=======================================================================
%imacro $CALL 1
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	Call %1

%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.EQ 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	%ifnum %2 	
		mov rax,%2															; Need to move to register incase its a
		mov qword[%1],rax 													; immediate 64bit value
	%else
		push qword[%2]
		pop  qword[%1]
	%endif
						
%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.ADD 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
	%ifnum %2 	
		mov rax,%2															; Need to move to register incase its a
		add qword[%1],rax 													; immediate 64bit value
	%else
		mov rax,qword[%2]
		add qword[%1],rax			
	%endif
						
%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.SUB 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	%ifnum %2 	
		mov rax,%2															; Need to move to register incase its a
		sub qword[%1],rax 													; immediate 64bit value
	%else
		mov rax,qword[%2]
		sub qword[%1],rax			
	%endif
						
%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.MUL 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
	mov rax,qword[%1]
	%ifnum %2 	
		mov  rbx,%2															; Need to move to register incase its a
		imul rbx															; immediate 64bit value
	%else
		mov  rbx,qword[%2]
		imul rbx			
	%endif
	mov qword[%1],rax
						
%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.DIV 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
		
	mov rax,qword[%1]
	cqo
	%ifnum %2 	
		mov rbx,%2
	%else
		mov rbx,qword[%2]	
	%endif
	idiv rbx
	mov qword[%1],rax
						
%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.TOGGLE 1
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	%%If:	cmp qword[%1],0
				je %%Else
				mov qword[%1],0
				jmp %%EndIf
	%%Else:	
			mov qword[%1],1
	%%EndIf:
						
%endmacro
;-----------------------------------------------------------------------
;	Integerss.calc num = num2 + num3 - num4 * num5 / num6
;-----------------------------------------------------------------------
%imacro INTEGERS.CALC 3-*
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

		mov r15,%1														; Save the destination
		
		%assign i 0			
		%rep	%0														; Repeat n times (No Of Parameters)		
			%assign i i+1

			%if i > 1													; Jump over the 1st field (destination)	
				%ifidni %1, =											; set the function
					%assign function 1						
				%elifidni %1, +											; set the function
					%assign function 2					
				%elifidni %1, -											; set the function
					%assign function 3						
				%elifidni %1, *											; set the function
					%assign function 4					
				%elifidni %1, /											; set the function
					%assign function 5
				%else
					%if function = 1
						INTEGERS.EQ r15,%1								; and make the call
					%elif function = 2
						INTEGERS.ADD r15,%1								; and make the call	
					%elif function = 3
						INTEGERS.SUB r15,%1								; and make the call	
					%elif function = 4
						INTEGERS.MUL r15,%1								; and make the call	
					%elif function = 5
						INTEGERS.DIV r15,%1								; and make the call	
					%endif	
				%endif														
			%endif	
			%rotate 1													; Move to the next parameter
		%endrep		

%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.AND 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	%ifnum %2 																; literal or not
		mov rbx,%2
	%else
		mov rbx,qword[%2]	
	%endif
	
	mov rax,qword[%1]
	and rax,rbx
	mov qword[%1],rax
						
%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.OR 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	%ifnum %2 																; literal or not
		mov rbx,%2
	%else
		mov rbx,qword[%2]	
	%endif
		
	mov rax,qword[%1]
	or  rax,rbx
	mov qword[%1],rax
						
%endmacro

;-----------------------------------------------------------------------
%imacro INTEGERS.XOR 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	%ifnum %2 																; literal or not
		mov rbx,%2
	%else
		mov rbx,qword[%2]	
	%endif
		
	mov rax,qword[%1]
	xor rax,rbx
	mov qword[%1],rax
						
%endmacro

;=======================================================================
;       	Macros for procedures
;=======================================================================
%imacro BEGIN.ASSEMBLER 0
%endmacro
%imacro END.ASSEMBLER 0
%endmacro

%imacro BEGIN.SUB 1-2
	;========== *********
	%if debug = 2									; Windows debugging
		global %1
	%endif
	;========== *********

%1:	
;	-------------------
;	SIMPLE DEBUG
;	-------------------
	%if %0 = 2
		%defstr tmp %1
		display "Entering Sub:",tmp,LF
	%endif

	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

;	So that we can use an exit.sub and restore our 
;	saveRegisters position
	push qword[SX]

%endmacro

%imacro EXIT.SUB 1
		
		jmp %1_EXIT
	
%endmacro

%imacro END.SUB 1-2
%1_EXIT:
;	-------------------
;	SIMPLE DEBUG
;	-------------------
	%if %0 = 2
		%defstr tmp %1
		display "Exiting Sub:",tmp,LF
	%endif

	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

;	So that we can use an exit.sub and restore our 
;	saveRegisters position
	pop qword[SX]

	%%Exit:	ret
%endmacro

;=======================================================================
;       	Macros for Boolean Functions
;=======================================================================
%imacro BEGIN.FUNCTION 1-3
	;========== *********
	%if debug = 2									; Windows debugging
		global %1
	%endif
	;========== *********

%1:		

	mov qword[RETURN_CODE],c_FALSE

;	-------------------
;	SIMPLE DEBUG
;	-------------------
	%if %0 = 2
		%ifidni %2,?		
			%defstr tmp %1
			display "Entering Function:",tmp,LF
		%endif
	%endif
	%if %0 = 3
		%ifidni %3,?		
			%defstr tmp %1
			display "Entering Function:",tmp,LF
		%endif
	%endif

	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

;	So that we can use an exit.sub and restore our 
;	saveRegisters position
	push qword[SX]

%endmacro	

%imacro EXIT.FUNCTION 1

		jmp %1_EXIT
	
%endmacro

%imacro END.FUNCTION 1-2
%1_EXIT:

;	-------------------
;	SIMPLE DEBUG
;	-------------------
	%if %0 = 2
		%defstr tmp %1
		display "Exiting Function:",tmp,LF
	%endif

	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

;	So that we can use an exit.sub and restore our 
;	saveRegisters position
	pop qword[SX]
					
	%%Exit:ret
%endmacro

;=======================================================================
;      		Macro to set terminal cursor position
;			Cursor Col, Row
;=======================================================================
%imacro CURSOR 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
	%ifnum %1																; If the row is a literal
		mov qword[Row9],%1													;	move to Row9
	%else																	; else
		push qword [%1]														;	get the value
		pop  qword [Row9]
	%endif
		
	%ifnum %2																; if the column is a literal
		mov qword[Col9],%2													;	move to Col9
	%else																	; else
		push qword [%2]														; 	get the value
		pop  qword [Col9]
	%endif	
		
		Call _CURSOR														; and make the call

%endmacro

;=======================================================================
;      		Macro to read line from stdout
;=======================================================================
%imacro ACCEPTLINE 1
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
											
		mov r_SrcAddress, %1
		call _ACCEPTLINE

%endmacro

;
;	Enhanced to include cursor positioning
;
%imacro ACCEPTLINE.AT 3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
				
		CURSOR %1,%2														; Automated cursor positioning
	
		mov r_SrcAddress, %3
		call _ACCEPTLINE

%endmacro

;
;	Enhanced for NON-CANONICAL mode
;	only accepts one item
;
%imacro ACCEPT.AT 3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

		CURSOR %1,%2														; Automated cursor positioning

		mov rax,@fieldLength(%3)											; Grab the passed field length
		mov @fieldLength(w_AcceptAt),rax									; for w_AcceptAt
		words.pad %3,w_AcceptAt												; copy input
		mov r_SrcAddress,w_AcceptAt											; setup R9 with address
		Call _ACCEPT.AT														; and Accept

	;	----------------------------------------------
	;	NEWER/NICER way to handle numeric/alpha fields
	; - always accept alpha then convert
	;	----------------------------------------------
		cmp @fieldIndicator(%3),'9'											; Are we numeric
			jne %%Alpha														; NO - then jump to alpha
	%%Num:numbers.eq %3,w_AcceptAt											; 	Convert to numeric
			jmp %%Exit														;	and exit

	%%Alpha:words.pad w_AcceptAt,%3											; Copy field to passed parameter
		
   %%Exit:
%endmacro

;=======================================================================
;      		Macro to display text to stdout with LF
;           This is the wrapper for $display so that more than
;			1 field can be displayed at a time
;           %0 is the number of parameters passed
;           %rotate cycles thru the parameters
;=======================================================================
%imacro  DISPLAY.LINE  0-* ' '
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
			
	%rep	%0																; Repeat n times (No Of Parameters)
			$SetupField {%1}												; Standard setup for {Name,1,64}
			Call _DISPLAY													;	and Display
			$SetupField LF													; add a LineFeed
			Call _DISPLAY													;	and Display
			%rotate 1														; Move to the next parameter
	%endrep

%endmacro

;=======================================================================
;      		Macro to display text to stdout without LF
;           This is the wrapper for $display so that more than
;			1 field can be displayed at a time
;           %0 is the number of parameters passed (fields to be displayed)
;           %rotate cycles thru the parameters
;=======================================================================
%imacro DISPLAY 0-* ' '
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	%rep	%0																; Repeat n times (No Of Parameters)
			$SetupField {%1}												; Standard setup for {Name,1,64}
			Call _DISPLAY													; and Display
			%rotate 1														; Move to the next parameter
	%endrep

%endmacro
;
;	Enhanced to include cursor positioning
;	but only to display one item.
;
%imacro DISPLAY.AT 3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
					
		CURSOR %1,%2														; Automated cursor positioning

		$SetupField {%3}													; Standard setup for {Name,1,64}
		Call _DISPLAY														; and Display

%endmacro

;=======================================================================
;       	Macro for WORDS package
;=======================================================================
;-----------------------------------------------------------------------
;			+-------------------+	  +-------------------+
;			| REPLACE value	    |	  |  FIND counter	  |
;			+-------------------+ r15 +-------------------+	
;			|  					|	  |					  |
;			+-------------------+ r14 +-------------------+	
;			|  r_DstStart		|	  |	 				  |
;			+-------------------+ r13 +-------------------+	 	
;			|  r_DstAddress     |	   	  No -> Alpha	
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

;--------------------------
%imacro WORDS.COPY 2
		WORDS $copy,{%1},{%2}
%endmacro
;--------------------------
%imacro WORDS.PAD 1-2
	%if %0 = 1
		WORDS $pad,{%1}
	%else	
		WORDS $pad,{%1},{%2}
	%endif
%endmacro
;--------------------------
%imacro WORDS.UPPERCASE 1-2
	%if %0 = 1
		WORDS $uppercase,{%1}
	%else
		WORDS $uppercase,{%1},{%2}
	%endif		
%endmacro
;--------------------------
%imacro WORDS.LOWERCASE 1-2
	%if %0 = 1
		WORDS $lowercase,{%1}
	%else
		WORDS $lowercase,{%1},{%2}
	%endif		
%endmacro
;--------------------------------
%imacro WORDS.INSERT 2
		WORDS $insert,{%1},{%2}
%endmacro
;----------------------------
%imacro WORDS.FIND 2
		WORDS $find,{%1},{%2}
%endmacro
;----------------------------
%imacro WORDS.REPLACE 2
		WORDS $replace,{%1},{%2}
%endmacro
;----------------------------
%imacro WORDS.ENVIRONMENT 2
		WORDS $environment,{%1},{%2}
%endmacro
;----------------------------
%imacro WORDS.LENGTH 2
		mov rax,@fieldLength(%1)
		mov qword[%2],rax
%endmacro
;----------------------------
%imacro WORDS.STRINGTORECORD 2
		WORDS $stringtorecord,{%1},%2
%endmacro
;----------------------------
%imacro WORDS.RECORDTOSTRING 2
		WORDS $recordtostring,%1,{%2}
%endmacro
;***********************************************************************
%imacro WORDS 2-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
		mov r_Function,%1													; Load the Function Code

	;	------------------------------------------------------------
	;	V2.05 - words.StringToRecord {w_Description,start},coaRecord
	;	------------------------------------------------------------
		%ifidni %1,$stringtorecord
			mov r10,%3
			$extract %2
			pop r12
			%if NoOfParameters > 1
				pop r13
				mov r13,[r13]
			%else
				xor r13,r13
			%endif

	;	------------------------------------------------------------
	;	V2.05 - words.RecordToString coaRecord,{w_Description,start}
	;	------------------------------------------------------------
		%elifidni %1,$recordtostring
			mov r10,%2
			$extract %3
			pop r12
			%if NoOfParameters > 1
				pop r13
				mov r13,[r13]
			%else
				xor r13,r13
			%endif
			
		%else	
	;	-----
	;	V2.05
	;	-----

	
;	Get DESTINATION parameters
;	Allows for nicer code if you do this 1st	

		%if %0 = 3															; THIS will be a destination
			$extract %3														; 	get the parameters
			pop r_DstAddress												; Destination address
			mov r_DstStart,w_One											; (Default) address of start position	
			%if NoOfParameters > 1											; Words copy, word1, {word2,5}
				pop r_DstStart												; address of start position
				%if NoOfParameters > 2										; Words copy, word1, {word2,5,10}
					add rsp, 8												; No of Byes IS DUMPED
				%endif
			%endif
		%endif
			
;	Get SOURCE parameters	
			$extract %2
;	Numeric to Alpha move
			pop r_SrcAddress												; address of word
			cmp @fieldIndicator(r_SrcAddress),'X'							; If it is not numeric then
				je %%Alpha						

;	====================================================================	
	%%Numeric:
;	Words $copy,w_Num, word0
;	Words $copy,{w_Num,'99.999},word0
;	Words $copy,{12345,'##,##9'},word0		

		%if NoOfParameters = 1	
			xor r_SrcPicAddress,r_SrcPicAddress								;_TOALPHA in _WORDS will sort this out
			xor r_SrcPicLength,r_SrcPicLength								;_TOALPHA in _WORDS will sort this out
		%else				
			pop r_SrcPicAddress												; Picture Address
			mov r_SrcPicLength,@fieldLength(r_SrcPicAddress)				; Picture Length	
		%endif
		mov r15,c_FALSE														; No Need to Resize	
		jmp %%preCall	
;	====================================================================

;	====================================================================
	%%Alpha:
;   		Words copy, word, ....		
			mov r_SrcStart,w_One											; (Default) address of start position
			mov r_SrcLength,r_SrcAddress									; (Default) address of No Of Bytes
			sub r_SrcLength,8												;	its the string length
	
;	Test for exceptions
			test r_Function,replace											; Test for replace
				jnz %%ReplaceFind											;	jump if so
			test r_Function,find											; Test for find
				jnz %%ReplaceFind											;	jump if so	
			jmp %%Others

;	--------------------------------------------------------------------		
	%%ReplaceFind:
;			Words replace {'JES','ROG',.,.}
;			Words find {'JES',counter,.,.}
			pop r15															; Get replace value/find counter
		%if NoOfParameters > 2
			pop r_SrcStart
		%endif
		%if NoOfParameters > 3
			pop r_SrcLength
		%endif
			jmp %%XpreCall
;	--------------------------------------------------------------------

;	--------------------------------------------------------------------		
	%%Others:			  						
		%if NoOfParameters > 1
			pop r_SrcStart													; address of start position
		%endif	
		%if NoOfParameters > 2
			pop r_SrcLength													; address of No Of Bytes
		%endif
;	====================================================================	

	%%XpreCall:
		mov r_SrcStart,[r_SrcStart]											; Get source start
		mov r_SrcLength,[r_SrcLength]										; get No Of Bytes

	%%preCall:
		%if %0 = 3															; If destination has been passed
			mov r_DstStart,[r_DstStart]										;	get start position
		%else
			mov r_DstAddress,r_SrcAddress									; Copy the source address
			mov r_DstStart,r_SrcStart										; Copy the source start point
		%endif	

;	-----
;	V2.05
;	-----		
	%endif
	
;-----------------------------------------------------------------------				
	%%DoCall:	
;-----------------------------------------------------------------------
		call _WORDS
			
%endmacro

;=======================================================================
;       	NUMBERS
;=======================================================================
;-----------------------------------------------------------------------
;				   	R8			R9	R12		 
;			NUMBERS	add,		#1,	#2
;			NUMBERS subtract,	#1,	#2
;			NUMBERS multiply,	#1,	#2
;			NUMBERS divide,		#1,	#2
;			NUMBERS.CALC A,=,10,+,3,+,32.456,-,12.456
;			NUMBERS.RANDOM,		#1
;
;			NUMBERS equals,		#1, NoField
;			NUMBERS equals,		#1,{NoField/Literal,'99.99'}
;			NUMBERS equals,		#1, w_Alpha
;			NUMBERS equals,		#1,{w_Alpha,1,99}
;-----------------------------------------------------------------------
;			 
;			+-------------------+
;			|  				    |
;			+-------------------+ r15 +-------------------+	
;			|  r_nSrcPicLength  | 	  |	 r_nSrcBytes	  |
;			+-------------------+ r14 +-------------------+	
;			|  r_nSrcPicAddress	|	  |	 r_nSrcStart	  |
;			+-------------------+ r13 +-------------------+	 	
;			|  r_nSrcAddress    |	   		
;			+-------------------+ r12 +-------------------+
;			|  				    |	  |  				  |
;			+-------------------+ r11 +-------------------+
;			| 			        |	  |  				  |
;			+-------------------+ r10 +-------------------+
;			|  r_nDstAddress    |
;			+-------------------+ r9  
;			|  r_Function       |
;			+-------------------+ r8 
;
;-----------------------------------------------------------------------
%imacro NUMBERS.EQ 2
		NUMBERS $equals,%1,{%2}
%endmacro
%imacro NUMBERS.ADD 2
		NUMBERS $add,%1,{%2}
%endmacro
%imacro NUMBERS.SUB 2
		NUMBERS $subtract,%1,{%2}
%endmacro
%imacro NUMBERS.MUL 2
		NUMBERS $multiply,%1,{%2}
%endmacro
%imacro NUMBERS.DIV 2
		NUMBERS $divide,%1,{%2}
%endmacro
%imacro NUMBERS.RANDOM 2
		NUMBERS $random,%1,%2
%endmacro

;-----------------------------------------------------------------------
;			Numbers.calc num = num2 + num3 - num4 * num5 / num6
;-----------------------------------------------------------------------
%imacro NUMBERS.CALC 3-*
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

		mov qword[w_SaveAddress],%1											; Save the destination
		
		%assign i 0			
		%rep	%0															; Repeat n times (No Of Parameters)		
			%assign i i+1

			%if i > 1														; Jump over the 1st field (destination)	
				%ifidni %1, =												; set the function
					mov r8,$equals						
				%elifidni %1, +												; set the function
					mov r8,$add					
				%elifidni %1, -												; set the function
					mov r8,$subtract						
				%elifidni %1, *												; set the function
					mov r8,$multiply					
				%elifidni %1, /												; set the function
					mov r8,$divide
				%else	
					NUMBERS r8,qword[w_SaveAddress],{%1}					; and make the call
				%endif														
			%endif	
			%rotate 1														; Move to the next parameter
		%endrep		

%endmacro


%imacro NUMBERS 2-*
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
		mov r_Function,%1													; Get Function					
		mov r_nDstAddress,%2												; Get [destination]result field

		%ifidni %1,$random													; Random Numbers are handle in COMMOM.LIB
			$extract %2														; Byte/Word/Dword/Qword
			pop r9
			mov r10,%3														; so that I do not have to split NUMBERS.LIB
			Call _RANDOM													; ino OS Versions and as they use date
																			; functions kinda ok in COMMON
		%else
		;	The call to [COMMON.o]No_Assist is necessary because we must detect whether there
		;	is an Alpha or Numeric field passed and as such cannot make a jmp within the rep
		;	preprocessor directive (labels would be duplicated)
			%assign i 0			
			%rep	%0														; Repeat n times (No Of Parameters)
				%assign i i+1
				%if i > 2													; Rotate thru fields to write
					$extract %1												; Grab the field											

					mov r15,1												; Init parameter flag
					%if NoOfParameters = 2									; If we have 2 parameters set r15
						mov r15,2
					%elif NoOfParameters = 3								; If we have 3 parameters set r15
						mov r15,3
					%endif	
								
					pop r_nSrcAddress										; Grab the source
					xor r13,r13												; Clear the dual use registers
					xor r14,r14
					Call No_Assist											; get assistance to get other 1/2
				
					%if NoOfParameters > 1									; If more than 1 parameter
						pop rax												; pop at least 1
						%if NoOfParameters > 2
							pop rax											; and pop if 2
						%Endif
					%Endif
				
					Call _NUMBERS											; Call numbers
				%endif												
				%rotate 1													; Move to the next parameter
			%endrep
		%endif		

%endmacro

;=======================================================================
;			CONTROL statements
;=======================================================================

;=======================================================================
;       	Macros for IF
;       	COMPARE - Compare 2 items
;			r08 = Request
;				  Equals			equ 00000001b
;				  isNOTEqualTo	    equ 00000010b
;				  isLessThan	    equ 00000100b
;				  isNOTLessThan	    equ 00001000b
;				  isGreaterThan		equ 00010000b													
;				  isNOTGreaterThan	equ	00100000b
;							_IN		equ 01000000b
;							_NIN	equ 10000000b
;			r09 = 1st items address,r11,r12	
;			r13  = 2nd items address,r14
;
;			b_Result = RESULT
;				  1 True
;				  0 False
;=======================================================================

%imacro IF 1-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
  %push IF

	;	Replace symbols
		%if %0 > 1															; NOT testing a function
			$replaceSymbols %2
		%endif		

		%if %0 = 1															; IF uses a function
			push qword[RETURN_CODE]
			Call %1															; Call the function
			push qword[RETURN_CODE]
			pop  qword[b_Result]
			pop qword[RETURN_CODE]
		%else
			%ifidni %2, _IN													; IF uses an _IN			
				mov r8,Equals												; Setup r8 as equals 
				$SetupField {%1}											; Setup the 1st field (r9,r10,r11)
				$orlist %3													; Process the list				
			;	--------------
			%elifidni %2, _NIN												; IF uses an _NIN			
				mov r8,Equals												; Setup r8 as equals 
				$SetupField {%1}											; Setup the 1st field (r9,r10,r11)
				$orlist %3													; Process the list				
				xor qword[b_Result],c_TRUE
			;	----------------					
			%else
				$SetupCompare {%1},r8,{%3}									; Setup the compare
				Call _COMPARE												;	and call it
			%endif
		%endif
		
		cmp qword[b_Result],0
			je %$IFNOT

%endmacro

;-----------------------------------------------------------------------
;	COMPOUND IF
;-----------------------------------------------------------------------
%imacro .IF 1-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
  %push IF

	;	Replace symbols
		%if %0 > 1															; NOT testing a function
			$replaceSymbols %2
		%endif
		
		%if %0 = 1															; IF uses a function
			push qword[RETURN_CODE]
			Call %1															; Call the function
			push qword[RETURN_CODE]
			pop  qword[b_Result]
			pop qword[RETURN_CODE]
		%else
			%ifidni %2, _IN													; IF uses an _IN			
				mov r8,Equals												; Setup r8 as equals 
				$SetupField {%1}											; Setup the 1st field (r9,r10,r11)
				$orlist %3													; Process the list				
			;	--------------
			%elifidni %2, _NIN												; IF uses an _NIN			
				mov r8,Equals												; Setup r8 as equals 
				$SetupField {%1}											; Setup the 1st field (r9,r10,r11)
				$orlist %3													; Process the list				
				xor qword[b_Result],c_TRUE
			;	----------------					
			%else
				$SetupCompare {%1},r8,{%3}									; Setup the compare
				Call _COMPARE												;	and call it
			%endif
		%endif
		
%endmacro

;-----------------------------------------------------------------------
;	SEE ALSO $whenlist
;-----------------------------------------------------------------------
;	Although this is an internal routine and strictly speaking would
;	normally be coded in IMACRO.CPY it makes sense to have it here
;	cuz it is only ever referenced from the IF macro.
;	IT is used when the _IN parameter is used in an IF which is
;	refering to a list (Compund OR)[Kinda similar to overloading a macro
;-----------------------------------------------------------------------
%macro $orlist 1-*
;	IF {w_Name,1,3},_IN,{"ROGER","JESSICA","KRYSTAL","TIFFANI"}
;
		
		%assign i 0
		%rep %0																; Repeat n times (No Of Parameters)
				
			$pushAll r9,r10,r11												; Save the already used registers (SOURCE)
			$SetupField {%1}												; Grab the Destination field 1st
			mov r12,r9														; and copy to destination registers
			mov r13,r10
			mov r14,r11
			$popAll r11,r10,r9												; Restore the already used registers
			Call _COMPARE													; Do the compare
			cmp qword[b_Result],c_TRUE
				je %%Exit													;	exit					
												
			%rotate 1														; Move to the next parameter
		%endrep

	%%Exit:
%endmacro

;-----------------------------------------------------------------------
;			.OR
;-----------------------------------------------------------------------	
%imacro .OR 1-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	; Only need one TRUE (so make sure subsequent FALSES don't hide it) 
	;	Store result
	%ifctx WHEN
		mov rbp,savedRegisters
		add rbp,qword[SX]
		push qword[rbp-08]
		pop  qword[b_Result]
	%endif

		cmp qword[b_Result],c_TRUE
			je %%Exit

		;	FUNCTION
		%if %0 = 1															; IF uses a function
			push qword[RETURN_CODE]
			Call %1															; Call the function
			push qword[RETURN_CODE]
			pop  qword[b_Result]
			pop  qword[RETURN_CODE]

		%endif

		;	WHEN IN/NIN or WHEN = 1	
		%if %0 = 2
			%ifidni %1, _IN
				mov r8,Equals												; Setup for equals 
				$whenlist %2												; and do when list	
			;	-------------
			%elifidni %1, _NIN												
				mov r8,Equals												; Setup for equals 
				$whenlist %2												; and do when list	
				xor qword[b_Result],c_TRUE									; and reverse the result
			;	-----------------					
			%else
				$replaceSymbols %1											; If two parameters passed and not an _IN
			;	WHEN %1,{%2}												; then it must be =1 (or suchlike)
				$replaceSymbols %1
				$SetupCompare 0,r8,{%2}										; We are doing a TEST Variable	
				$restoreRegisters r9,r10,r11,rax
				call _COMPARE
			%endif
		%endif
		
		;	STANDARD IF's OR
		%if %0 = 3	
			%ifidni %2, _IN													; IF uses an _IN		
				mov r8,Equals												; Setup r8 as equals 
				$SetupField {%1}											; Setup the 1st field (r9,r10,r11)
				$orlist %3													; Process the list
			;	-------------------
			%elifidni %2, _NIN												; IF uses a _NIN		
				mov r8,Equals												; Setup r8 as equals 
				$SetupField {%1}											; Setup the 1st field (r9,r10,r11)
				$orlist %3													; Process the list
				xor qword[b_Result],c_TRUE									; and reverse the result
			;	--------------------				
			%else	
				$replaceSymbols %2											; 3 parameters - standard IF/OR
				$SetupCompare {%1},r8,{%3}
				Call _COMPARE
			%endif		
		%endif

	;	Store result
	%ifctx WHEN
		mov rax, qword[b_Result]
		mov rbp,savedRegisters
		add rbp,qword[SX]
		mov qword[rbp-08],rax
	%endif

	%%Exit:
%endmacro

;-----------------------------------------------------------------------
;			.AND
;-----------------------------------------------------------------------
%imacro .AND 1-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
	; Only go ahead if we have a previous TRUE 
	%ifctx WHEN
		mov rbp,savedRegisters
		add rbp,qword[SX]
		push qword[rbp-08]
		pop  qword[b_Result]
	%endif
		cmp qword[b_Result],c_FALSE
			je %%Exit
				
		;	FUNCTION
		%if %0 = 1															; IF uses a function
			push qword[RETURN_CODE]
			Call %1															; Call the function
			push qword[RETURN_CODE]
			pop  qword[b_Result]
			pop  qword[RETURN_CODE]
		%endif

		;	WHEN IN or WHEN = 1	
		%if %0 = 2
			%ifidni %1, _IN
				mov r8,Equals												; Setup for equals 
				$whenlist %2												; and do when list
			;	--------------				
			%elifidni %1, _IN
				mov r8,Equals												; Setup for equals 
				$whenlist %2												; and do when list
				xor qword[b_Result],c_TRUE									; and reverse the result
			;	----------------
			%else
				$replaceSymbols %1											; If two parameters passed and not an _IN
			;	WHEN %1,{%2}												; then it must be =1 (or suchlike)
				$replaceSymbols %1
				$SetupCompare 0,r8,{%2}										; We are doing a TEST Variable	
				$restoreRegisters r9,r10,r11,rax
				call _COMPARE
			%endif
		%endif
		
		;	STANDARD IF's OR
		%if %0 = 3	
			%ifidni %2, _IN													; IF uses an _IN		
				mov r8,Equals												; Setup r8 as equals 
				$SetupField {%1}											; Setup the 1st field (r9,r10,r11)
				$orlist %3													; Process the list
			;	--------------------				
			%elifidni %2, _NIN												; IF uses a _NIN		
				mov r8,Equals												; Setup r8 as equals 
				$SetupField {%1}											; Setup the 1st field (r9,r10,r11)
				$orlist %3													; Process the list
				xor qword[b_Result],c_TRUE									; and reverse the result
			;	--------------------												
			%else	
				$replaceSymbols %2											; 3 parameters - standard IF/OR
				$SetupCompare {%1},r8,{%3}
				Call _COMPARE
			%endif		
		%endif

	;	Store result
	%ifctx WHEN
		mov rax, qword[b_Result]
		mov rbp,savedRegisters
		add rbp,qword[SX]
		mov qword[rbp-08],rax
	%endif

	%%Exit:
%endmacro

;-----------------------------------------------------------------------
;			.END
;-----------------------------------------------------------------------
%imacro .END 0
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

 %ifctx IF
		cmp qword[b_Result],c_FALSE
			je %$IFNOT
 %elifctx WHEN
		mov rbp,savedRegisters
		add rbp,qword[SX]
		cmp qword[rbp-08],c_FALSE
			je %$WEND
 %endif

%endmacro

;-----------------------------------------------------------------------
;			ELSE
;-----------------------------------------------------------------------
%imacro ELSE 0
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
  %repl ELSE

		jmp %$IFEND
  %$IFNOT:

%endmacro

;-----------------------------------------------------------------------
;			END.IF
;-----------------------------------------------------------------------
%imacro END.IF 0
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

 %ifctx IF
	%$IFNOT:
 %elifctx ELSE
	%$IFEND:
 %endif
 %pop

%endmacro

;-----------------------------------------------------------------------
;			BEGIN.TEST
;-----------------------------------------------------------------------
;	BEGIN.TEST %1 where
;		%1 may be:-
;			BEGIN.TEST 'Hello'				a Alphabetic Literal
;			BEGIN.TEST 1					a Numeric Literal
;			BEGIN.TEST w_Alpha				a Word from the Dictionary
;			BEGIN.TEST w_Num				a Number from the Matrix
;			BEGIN.TEST c_TRUE				the system constant c_TRUE
;-----------------------------------------------------------------------
%imacro BEGIN.TEST 1
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
  %PUSH TEST

		$SetupField {%1}													; Get 1st parameter			
		$saveRegisters r9,r10,r11,0
			
%endmacro

;-----------------------------------------------------------------------
;			WHEN
;-----------------------------------------------------------------------
;	WHEN %1,%2,[%3]
;		WHEN c_TRUE is coded in the BEGIN.TEST keyword
;			%1,%2,%3 take the form of the standard IF keyword
;	WHEN %1,%2
;		%1 = Comparison (=,<,>,!=,!<,!>)
;		%2 = The thing to be compared
;				BEGIN.TEST number
;	`				WHEN = 1
;					WHEN _IN {1,2,3,4,5}
;	WHEN %1
;		WHEN function_name
;-----------------------------------------------------------------------
%imacro WHEN 1-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
 %PUSH WHEN

		%if %0 = 1															; IF uses a function
			push qword[RETURN_CODE]
			Call %1															; Call the function
			push qword[RETURN_CODE]
			pop  qword[b_Result]
			pop qword[RETURN_CODE]			
		%else
			%ifidni %1, _IN
				mov r8,Equals												; Setup for equals 
				$whenlist %2												; Process the list
			%elifidni %1, _NIN
				mov r8,Equals												; Setup for equals 
				$whenlist %2												; and do when list
				xor qword[b_Result],c_TRUE									; and reverse the result
			%else
				%if %0 = 2
					$replaceSymbols %1
					$SetupCompare 0,r8,{%2}									; We are doing a TEST Variable	
					$restoreRegisters r9,r10,r11,rax
				%else
					$replaceSymbols %2										; We are doing a TEST TRUE
					$SetupCompare {%1},r8,{%3}		
				%endif
				call _COMPARE
			%endif
		%endif

	;	Store result
		mov rax,qword[b_Result]
		mov rbp,savedRegisters
		add rbp,qword[SX]
		mov qword[rbp-08],rax

		cmp  qword[b_Result],c_FALSE
 			 je %$WEND

%endmacro

%imacro .WHEN 1-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
  %PUSH WHEN

		%if %0 = 1															; IF uses a function
			push qword[RETURN_CODE]
			Call %1															; Call the function
			push qword[RETURN_CODE]
			pop  qword[b_Result]
			pop qword[RETURN_CODE]			
		%else
			%ifidni %1, _IN
				mov r8,Equals												; Setup for equals 
				$whenlist %2												; Process the list
			%elifidni %1, _NIN
				mov r8,Equals												; Setup for equals 
				$whenlist %2												; and do when list
				xor qword[b_Result],c_TRUE									; and reverse the result
			%else
				%if %0 = 2
					$replaceSymbols %1
					$SetupCompare 0,r8,{%2}									; We are doing a TEST Variable	
					$restoreRegisters r9,r10,r11,rax
				%else
					$replaceSymbols %2										; We are doing a TEST TRUE
					$SetupCompare {%1},r8,{%3}		
				%endif
				call _COMPARE
			%endif
		%endif

	;	Store result
		mov rax, qword[b_Result]
		mov rbp,savedRegisters
		add rbp,qword[SX]
		mov qword[rbp-08],rax

%endmacro

;-----------------------------------------------------------------------
;	SEE ALSO $orlist
;-----------------------------------------------------------------------
;	Although this is an internal routine and strictly speaking would
;	normally be coded in IMACRO.CPY it makes sense to have it here
;	cuz it is only ever referenced from the IF macro.
;	IT is used when the _IN parameter is used in an IF which is
;	refering to a list (Compund OR)[Kinda similar to overloading a macro
;-----------------------------------------------------------------------
%macro $whenlist 1-*
;	WHEN _IN,{"ROGER","JESSICA","KRYSTAL","TIFFANI"}
;		
		%assign i 0
		%rep %0																; Repeat n times (No Of Parameters)
				
			$SetupField {%1}												; Grab the Destination field 1st
			mov r12,r9														; and copy to destination registers
			mov r13,r10
			mov r14,r11

			$restoreRegisters r9,r10,r11,rax
			Call _COMPARE													; Do the compare
			cmp qword[b_Result],c_TRUE
				je %%Exit													;	exit					
												
			%rotate 1														; Move to the next parameter
		%endrep

	%%Exit:
%endmacro

;-----------------------------------------------------------------------
;			OTHERWISE - needed to terminate WHEN's
;-----------------------------------------------------------------------
%imacro WEND 0
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

	  %$WEND:
	  %POP

	;	Get result
		mov rbp,savedRegisters
		add rbp,qword[SX]

		cmp qword[rbp-08],c_TRUE
			je %$END.TEST

%endmacro

;-----------------------------------------------------------------------
;			OTHERWISE
;-----------------------------------------------------------------------
%imacro OTHERWISE 0
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

%endmacro

;-----------------------------------------------------------------------
;			END.TEST same as END.IF
;-----------------------------------------------------------------------
%imacro END.TEST 0	
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********					
	  %$END.TEST:
	  %POP					

		sub qword[SX],40
		
%endmacro
	
;=======================================================================
;       	Macros for looping (REPEAT)
;=======================================================================
%imacro REPEAT 1
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
  %PUSH REPEAT.NAME

	;	So that we can use an exit.sub and restore our 
	;	saveRegisters position
		push qword[SX]
	
		mov qword[exitRepeat],c_FALSE
%$START.REPEAT:
		cmp qword[exitRepeat],c_TRUE
			je %$END.REPEAT
	
%endmacro

;=======================================================================
;       	Macros for looping (REPEAT.IF)
;=======================================================================
%imacro REPEAT.WHILE 1-3
		%if %0 = 1
			REPEAT.IF %1
		%else
			REPEAT.IF {%1},%2,{%3}
		%endif
%endmacro

%imacro REPEAT.IF 1-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
  %push REPEAT
  
	;	Replace symbols
		%if %0 > 1
			$replaceSymbols %2
		%endif	

	;	%if %0 > 1	  		
			$saveRegisters r8,0,0,0
	;	%endif

		mov qword[exitRepeat],c_FALSE

		  ; Loop begins here
	%$START.REPEAT:															; Define ths start label within the context stack
		cmp qword[exitRepeat],c_TRUE
			je %$END.REPEAT
			
		%if %0 > 1
			$restoreRegisters r8,rax,rax,rax
			$SetupCompare {%1},r8,{%3}
			Call _COMPARE													; Do the compare
		%else
			push qword[RETURN_CODE]
			Call %1															; Call the FUNCTION
			push qword[RETURN_CODE]
			pop  qword[b_Result]
			pop qword[RETURN_CODE]		
		%endif		
		
		  ; Are we done
			cmp qword[b_Result],c_FALSE
				je %$END.REPEAT												; Exit the REPEAT of compare returns false
				
	%%Exit:	
%endmacro

;=======================================================================
;       	Macros for looping (REPEAT.FOR)
;=======================================================================
;			+-------------------+	 	
;			|  EndValueAddress  |	   		
;			+-------------------+ r12 (%3)
;			|  				    |	
;			+-------------------+ r11 
;			|  			        |
;			+-------------------+ r10 
;			|  Counter Address  |
;			+-------------------+ r9  (%1)  
;			|  GT/LT	        |
;			+-------------------+ r8 
;-----------------------------------------------------------------------
%imacro REPEAT.FOR 3-4
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
  %push REPEAT
  
	$extract %1																; get the address of the source
		pop r9
		xor r10,r10
		xor r11,r11
	$extract %3
		pop r12																; get the address of the destination
		xor r13,r13
		xor r14,r14
	%if %0 = 4
		$extract %4
			pop r15															; If step is coded then
			mov r15,[r15]													;	get the VALUE of the step
	%else
			mov r15,1
	%endif
	
;	Start value
	$extract %2
		pop rax																; Set up the counter with the start value
		mov rax,[rax]
		mov qword[r9],rax
				
		  ; Counting up or counting down
			mov r8,isNOTEqualTo
			mov rax,[r9]
			cmp rax,qword[r12]
				je %%cont
				jb %%gt
				ja %%lt
	%%gt:	mov r8,isGreaterThan
			jmp %%cont
	%%lt:	mov r8,isLessThan
			neg r15	

		  ; Setup & save Compare values
	%%cont:	
			$saveRegisters r8,r9,r12,r15
			mov qword[exitRepeat],c_FALSE
			jmp %%Exit														; go and process

		  ; Loop begins here
	%$START.REPEAT:		
		cmp qword[exitRepeat],c_TRUE
			je %$END.REPEAT

			$restoreRegisters r8,r9,r12,r15								
			xor r10,r10
			xor r11,r11
			xor r13,r13
			xor r14,r14
			add [r9],r15													; add to the counter			
			Call _COMPARE													; Do the compare

			cmp qword[b_Result],c_TRUE
				je %$END.REPEAT

	%%Exit:	
%endmacro

;=======================================================================
;       	Macros for looping (EXIT.REPEAT)
;=======================================================================
%imacro EXIT.REPEAT 1
			
		;	Jump to the end of the loop
			jmp %1_EXIT	
								
%endmacro

;=======================================================================
;       	Macros for looping (END.REPEAT)
;=======================================================================
%imacro END.REPEAT 0-1
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
		jmp %$START.REPEAT													; Within the context stack
			
	%$END.REPEAT:															; Within the Context Stack
		mov qword[exitRepeat],c_FALSE

	%ifctx REPEAT.NAME
		%1_EXIT:
		pop qword[SX]
	%else	
		sub qword[SX],40
	%endif
			
	%POP																	; End the Context Stack		
%endmacro

;=======================================================================
;       	Macro for FILES package
;=======================================================================
;-----------------------------------------------------------------------
;			+-------------------+  
;			| Open for | Record | 	  (OPEN) RW+[Beginning/End] | Record No | String,String,String
;			+-------------------+ r10 
;			|  FileName         | 	  I-Name/X-Name
;			+-------------------+ r9  
;			|  Function         | 	  Open/Close/Read/Write
;			+-------------------+ r8  1st Parameter
;-----------------------------------------------------------------------
;		FileStatus		+-----------+--------+-------------+----+
;	+---+---+---+---+---|	db      |  dq    | db		   |0x00|
;	| 1	|'9'|Len|Val|Pic+-----------+--------+-------------+----+
;	+---+---+---+---+---| delimiter | Handle | Int[ExtName]|    |
;		AsPer INSERTNO	+-----------+--------+-------------+----+
;				-19		-9			-8		 0
;					c_NONE			equ 00000000b
;					c_NULL			equ 00000001b 
;					c_LF			equ 00000010b 
;					c_CSV			equ 00000100b
;					c_RECORD		equ 00001000b
;					c_Random		equ 00010000b 
;-----------------------------------------------------------------------
;			INSERTFILE Delimiter,I-Name,'./X-Name'
;					   c_NONE,c_NULL,c_LF,c_CSV,c_RECORD,c_Random
;-----------------------------------------------------------------------
;							  R8	 		R9		R10									
;			OPEN	*	FILES $open,		I_Name, R/W/RW[Beginning/End]/Lock
;			READ	*	FILES $read,  		I_Name, record/{String,1,1},{String,1,1},etc
;			WRITE	*	FILES $write, 		I_Name, record/{String,1,1},{String,1,1},etc
;			DELETE	*	FILES $delete,		I_Name, record
;			CLOSE	*	FILES $close, 		I_Name
;			START	*	FILES $start, 		I_Name, record
;			NEXT	*	FILES $next,  		I_Name, record
;			COPY	*	FILES $filescopy,	I-from,	I-to
;			RENAME	*	FILES $rename,		X-from,	X-to
;			REMOVE	*	FILES $remove,		X-Name
;			CHDIR	*	FILES $chdir,		X-Name
;			GETCWD	*	FILES $getcwd,		X-Name
;			LOCK	*	FILES $lock,		I_NAME,	record
;			UNLOCK	*	FILES $unlock,		I_NAME,	record
;-----------------------------------------------------------------------

%imacro FILES.OPEN 1-2
	%if %0 = 1
		FILES $open,%1
	%else
		FILES $open,%1,%2
	%endif
%endmacro
;--------------------------
%imacro FILES.READ 2-3
	%if %0 = 2
		FILES $read,%1,{%2}
	%else
		FILES $read,%1,{%2},{%3}
	%endif
%endmacro
;--------------------------
%imacro FILES.WRITE 2-3
	%if %0 = 2
		FILES $write,%1,{%2}
	%else
		FILES $write,%1,{%2},{%3}
	%endif
%endmacro
;--------------------------
%imacro FILES.DELETE 2-3
	%if %0 = 2
		FILES $delete,%1,{%2}
	%else
		FILES $delete,%1,{%2},{%3}
	%endif
%endmacro
;--------------------------
%imacro FILES.CLOSE 1
		FILES $close,%1
%endmacro
;--------------------------
%imacro FILES.START 2-3
	%if %0 = 2
		FILES $start,{%1},{%2}
	%else
		FILES $start,{%1},{%2},{%3}
	%endif
%endmacro
;--------------------------
%imacro FILES.NEXT 2
		FILES $next,{%1},{%2}
%endmacro
;--------------------------
%imacro FILES.LOCK 2-3
	%if %0 = 2
		FILES $rlock,%1,{%2}
	%else
		FILES $rlock,%1,{%2},{%3}
	%endif
%endmacro
;--------------------------
%imacro FILES.UNLOCK 2-3
	%if %0 = 2
		FILES $runlock,%1,{%2}
	%else
		FILES $runlock,%1,{%2},{%3}
	%endif
%endmacro
;--------------------------
%imacro FILES.COPY 2
		FILES $filescopy,%1,%2
%endmacro
;--------------------------
%imacro FILES.RENAME 2
		FILES $rename,%1,%2
%endmacro
;--------------------------
%imacro FILES.REMOVE 1
		FILES $remove,%1
%endmacro
;--------------------------
%imacro FILES.CHDIR 1
		FILES $chdir,%1
%endmacro
;--------------------------
%imacro FILES.GETCWD 1
		FILES $getcwd,%1
%endmacro
;--------------------------


%define @fileDelimiter(x)    byte[x-26]
%define @fileStatus(x)		qword[x-36]

%imacro FILES 2-*
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
		mov r_Function,%1													; Function
		mov r_File,%2														; File address

	;	----------------------------------
	;	Consolidate the readwrite function
	;	----------------------------------	
		%assign ReadWrite 0
		%ifidni %1,$read
			%assign ReadWrite 1
		%endif
		%ifidni %1,$write
			%assign ReadWrite 1
		%endif
		%ifidni %1,$start
			%assign ReadWrite 1
		%endif
		%ifidni %1,$next
			%assign ReadWrite 1
		%endif

;		----------------------------------------------------
;		COPY
;		----------------------------------------------------			
		%ifidni %1,$filescopy
			mov	r10,%3														; Outfile name
			Call _FILEIO
		%endif
	
;		----------------------------------------------------
;		RENAME
;		----------------------------------------------------
		%ifidni %1,$rename
			mov r10,%3														; New Name
			Call _FILEIO
		%endif

;		----------------------------------------------------
;		REMOVE
;		----------------------------------------------------
		%ifidni %1,$remove
			Call _FILEIO
		%endif

;		----------------------------------------------------
;		CHDIR
;		----------------------------------------------------			
		%ifidni %1,$chdir
			$extract %2	
			pop r9
			Call _FILEIO
		%endif

;		----------------------------------------------------
;		GETCWD
;		----------------------------------------------------			
		%ifidni %1,$getcwd
			$extract %2	
			pop r9															; setup rdi
			Call _FILEIO
		%endif

;		----------------------------------------------------
;		OPEN FILE
;		----------------------------------------------------			
		%ifidni %1,$open
			%if %0 > 2														; If 3 parameters passed				 
				mov r_FileFlags,%3											;	then setup File Flags
			%else															; ELSE
				mov r_FileFlags,beginning									;	default to beginning
			%endif											
			Call _FILEIO
		%endif
		
;		----------------------------------------------------------------
;		CLOSE FILE
;		----------------------------------------------------------------					
		%ifidni %1,$close
			Call _FILEIO
		%endif

;		----------------------------------------------------
;		DELETE
;		----------------------------------------------------			
		%ifidni %1,$delete
			mov	r10,%3
			%if %0 > 3
				$extract %4
				pop r15
				mov r15,[r15]
				mov @recordNo(r_Record),r15
			%endif
			Call _FILEIO
		%endif

;		----------------------------------------------------
;		LOCK
;		----------------------------------------------------			
		%ifidni %1,$rlock
			mov	r10,%3
			%if %0 > 3
				$extract %4
				pop r15
				mov r15,[r15]
				mov @recordNo(r_Record),r15
			%endif
			Call _FILEIO
		%endif
		
;		----------------------------------------------------
;		UNLOCK
;		----------------------------------------------------			
		%ifidni %1,$runlock
			mov	r10,%3
			%if %0 > 3
				$extract %4
				pop r15
				mov r15,[r15]
				mov @recordNo(r_Record),r15
			%endif
			Call _FILEIO
		%endif		
		
;		----------------------------------------------------------------
;		DIRECTORY
;		----------------------------------------------------------------
		%ifidni %1,$read					
	%%If1:	cmp @fileDelimiter(r_File),c_DIRECTORY
				jne %%EndIf1
			mov r10,%3
			call _FILEIO
			jmp %%Exit
	%%EndIf1:
		%endif

;		----------------------------------------------------
;		RECORDS OR FIELDS
;		----------------------------------------------------	
	%if ReadWrite = 1

			cmp @fileDelimiter(r_File),c_RECORD
				je %%Records
			cmp @fileDelimiter(r_File),c_RANDOM			
				je %%Records
			cmp @fileDelimiter(r_File),c_INDEXED			
				je %%Records
				
			jmp %%Fields
				
		%%Records:			
			%if %0 > 2	
				$extract %3
				pop r_Record
				%if %0 > 3
					$extract %4
					pop r15
					mov r15,[r15]
					mov @recordNo(r_Record),r15
				%endif
			%endif
				
			Call _FILEIO
			jmp  %%Exit

		%%Fields:
				
	%endif

;		------------------------------------------------------------
;		READ/WRITE FIELDS
;		------------------------------------------------------------		

		;	----
		;	READ
		;	----				
	%ifidni %1,$read
			call _FILEIO
			cmp @fileStatus(r_File),10										; End of File	
				je %%Exit
	%endif

	%if ReadWrite = 1							

		;	------------------
		;	LOAD/UNLOAD FIELDS
		;	------------------				
			mov RSI,w_RecordBuffer											; FROM FIELDS-Offset of Record Buffer
			mov RDI,w_RecordBuffer											; TO FIELDS-Offset of Record Buffer
			mov r15,%2														; (FileName) To pass to _FIELDS

	;	Loop thru the fields and build w_RecordBuffer				
		%assign i 0
		%rep	%0															; Repeat n times (No Of Parameters)
			%assign i i+1		
			%if i > 2														; Rotate thru fields to write
				$SetupField {%1}											; Standard setup for {Name,1,64}
				Call _FIELDS
				mov qword[w_SaveAddress],r9									; Need to save the last field for CSV process				
			%endif												
			%rotate 1														; Move to the next parameter
		%endrep

	%endif	

		;	-----
		;	WRITE
		;	-----
	%ifidni %1,$write
			Call _DELIMITER													; Adds the delimeter/Remove comma from CSV										
			mov r_File,%2													; RE-get filename (is crapped on in above code)
			mov r_Record,w_RecordBuffer										; Offset of Record Buffer
			call _FILEIO	
	%endif

	%%Exit:
%endmacro

;=======================================================================
;       	Macro for TABLES package
;			TABLES bind,WorkTable,A01_Record,Idx,Idx,...
;=======================================================================
;-----------------------------------------------------------------------
; 		TableStatus		Dimension Value	 								Table Indicator									 
;	+---+---+---+---+---+---+---+---+---+---+---+---+---+---------------+---+---------+------+---+---+---+---+---+---+---+---+	     
;	| 1	|'9'|Len|Val|Pic|Idx|Idx|Idx|Idx|Idx|Idx|Idx|Idx|Record Address	|'T'|NoOfBytes| NAME |Idx|Idx|Idx|Idx|Idx|Idx|Idx|Idx|	
;	+---+---+---+---+---+---+---+---+---+---+---+---+---+---------------+---+---------+------+---+---+---+---+---+---+---+---+ 
;	-108-100-99	-91	    -81 -73	-65	-57	-49	-41	-33	-25	-17			   -9	-8		   0	  No Of Bytes +
;															       						 	 8  16  24  32  40  48  56  64  72
;
;		INSERTTABLE WorkTable,A01_Record_Length*Idx*Idx*Idx*Idx*Idx*Idx*Idx*Idx
;-----------------------------------------------------------------------
;				   R8		R9		  R10		 
;			TABLES bind,	WorkTable,A01_Record,Idx1,Idx2,Idx3....Idx8
;			TABLES rget,	WorkTable,Idx1,Idx2,Idx3....Idx8
;			TABLES rput,	WorkTable,Idx1,Idx2,Idx3....Idx8
;			TABLES sort,	WorkTable,Start,End
;			TABLES search,	WorkTable,Start,End,SearchItem,Index
;				   R8		R9		  R10	  R11
;			TABLES fget, 	WorkTable,FieldNo,FieldName,Idx1,Idx2,Idx3....Idx8
;			TABLES fput, 	WorkTable,FieldNo,FieldName,Idx1,Idx2,Idx3....Idx8
;-----------------------------------------------------------------------
%imacro TABLES.BIND 3-10
	%if %0 = 3
		TABLES $bind,{%1},{%2},{%3}
	%endif
	%if %0 = 4
		TABLES $bind,{%1},{%2},{%3},{%4}
	%endif
	%if %0 = 5
		TABLES $bind,{%1},{%2},{%3},{%4},{%5}
	%endif
	%if %0 = 6
		TABLES $bind,{%1},{%2},{%3},{%4},{%5},{%6}
	%endif
	%if %0 = 7
		TABLES $bind,{%1},{%2},{%3},{%4},{%5},{%6},{%7}
	%endif
	%if %0 = 8
		TABLES $bind,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8}
	%endif
	%if %0 = 9
		TABLES $bind,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9}
	%endif
	%if %0 = 10
		TABLES $bind,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9},{%10}
	%endif

%endmacro
;--------------------------
%imacro TABLES.rGET 2-9
	%if %0 = 2
		TABLES $rget,{%1},{%2}
	%endif
	%if %0 = 3
		TABLES $rget,{%1},{%2},{%3}
	%endif
	%if %0 = 4
		TABLES $rget,{%1},{%2},{%3},{%4}
	%endif
	%if %0 = 5
		TABLES $rget,{%1},{%2},{%3},{%4},{%5}
	%endif
	%if %0 = 6
		TABLES $rget,{%1},{%2},{%3},{%4},{%5},{%6}
	%endif
	%if %0 = 7
		TABLES $rget,{%1},{%2},{%3},{%4},{%5},{%6},{%7}
	%endif
	%if %0 = 8
		TABLES $rget,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8}
	%endif
	%if %0 = 9
		TABLES $rget,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9}
	%endif
		
%endmacro
;--------------------------
%imacro TABLES.rPUT 2-9
	%if %0 = 2
		TABLES $rput,{%1},{%2}
	%endif
	%if %0 = 3
		TABLES $rput,{%1},{%2},{%3}
	%endif
	%if %0 = 4
		TABLES $rput,{%1},{%2},{%3},{%4}
	%endif
	%if %0 = 5
		TABLES $rput,{%1},{%2},{%3},{%4},{%5}
	%endif
	%if %0 = 6
		TABLES $rput,{%1},{%2},{%3},{%4},{%5},{%6}
	%endif
	%if %0 = 7
		TABLES $rput,{%1},{%2},{%3},{%4},{%5},{%6},{%7}
	%endif
	%if %0 = 8
		TABLES $rput,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8}
	%endif
	%if %0 = 9
		TABLES $rput,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9}
	%endif
			
%endmacro
;--------------------------
%imacro TABLES.fGET 4-11
	%if %0 = 4
		TABLES $fget,{%1},{%2},{%3},{%4}
	%endif
	%if %0 = 5
		TABLES $fget,{%1},{%2},{%3},{%4},{%5}
	%endif
	%if %0 = 6
		TABLES $fget,{%1},{%2},{%3},{%4},{%5},{%6}
	%endif
	%if %0 = 7
		TABLES $fget,{%1},{%2},{%3},{%4},{%5},{%6},{%7}
	%endif
	%if %0 = 8
		TABLES $fget,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8}
	%endif
	%if %0 = 9
		TABLES $fget,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9}
	%endif
	%if %0 = 10
		TABLES $fget,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9},{%10}
	%endif
	%if %0 = 11
		TABLES $fget,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9},{%10},{%11}
	%endif
		
%endmacro
;--------------------------
%imacro TABLES.fPUT 4-11
	%if %0 = 4
		TABLES $fput,{%1},{%2},{%3},{%4}
	%endif
	%if %0 = 5
		TABLES $fput,{%1},{%2},{%3},{%4},{%5}
	%endif
	%if %0 = 6
		TABLES $fput,{%1},{%2},{%3},{%4},{%5},{%6}
	%endif
	%if %0 = 7
		TABLES $fput,{%1},{%2},{%3},{%4},{%5},{%6},{%7}
	%endif
	%if %0 = 8
		TABLES $fput,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8}
	%endif
	%if %0 = 9
		TABLES $fput,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9}
	%endif
	%if %0 = 10
		TABLES $fput,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9},{%10}
	%endif
	%if %0 = 11
		TABLES $fput,{%1},{%2},{%3},{%4},{%5},{%6},{%7},{%8},{%9},{%10},{%11}
	%endif
		
%endmacro

;--------------------------
;		TABLES sort,WorkTable,Start,End
%imacro TABLES.SORT 3
		TABLES $sort,%1,%2,%3
%endmacro
;--------------------------
;		TABLES search,WorkTable,Start,End,SearchItem,Index (returned)
%imacro TABLES.SEARCH 5
		TABLES $search,%1,%2,%3,%4,%5
%endmacro

%imacro TABLES 3-12
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
		
		;	Function and table address
			mov r_Function,%1												; Function
			mov r_Table,%2													; Load Table Address

		;---------------------------------------------------------------
		;	Function = SORT
		;---------------------------------------------------------------
	%ifidni %1, $sort
			$extract %3
			pop r10
			mov r10,[r10]
			$extract %4
			pop r11
			mov r11,[r11]
	%endif

		;	------------------------------------------------------------
		;	Function = BIND	
		;	------------------------------------------------------------
	%ifidni %1, $bind									
			mov r_Record,%3													; Load Record Address
		;	Setup to store indexes
			mov r11,r_Table
			sub r11,89
			
		%assign i 0
		%rep	%0															; Repeat n times (No Of Parameters)
			%assign i i+1		
			%if i > 3														; If its an Index			
				add r11,8													;	next slot
				$extract %1
				pop rax
				mov rax,[rax]
				mov qword[r11],rax 
			%endif												
			%rotate 1														; Move to the next parameter
		%endrep
			add r11,8
			mov qword[r11],1												; 1 in the first unused slot
			
	%endif
		
		;	------------------------------------------------------------
		;	Function = SEARCH	
		;	------------------------------------------------------------
	%ifidni %1, $search
			$extract %3														; Grab the Start of Key
			pop r10
			mov r10,[r10]
			$extract %4														; Grab the End Of Key
			pop r11
			mov r11,[r11]
			$extract %5														; and grab the key
			pop r12	
			mov r13,%6
	%endif

		;---------------------------------------------------------------
		;	Function = rPUT/rGET
		;---------------------------------------------------------------
		;	rPUT and rGET are the same code but cannot find a way to do an OR
		;	for this pre-processor directive
	%ifidni %1, $rget

		;	Setup to store indexes
			mov r11,r9
			add r11,qword[r9-8]
			xor r12,r12
	
		%assign i 0
		%rep	%0															; Repeat n times (No Of Parameters)
			%assign i i+1		
			%if i > 2														; If its an Index
				add r12,8													;	next slot 
				$extract %1
				pop rax
				mov rax,[rax]
				mov qword[r11+r12],rax
			%endif													
			%rotate 1														; Move to the next parameter
		%endrep

	%endif
		
		;---------------------------------------------------------------
		;	Function = rPUT/rGET
		;---------------------------------------------------------------
	%ifidni %1, $rput

		;	Setup to store indexes
			mov r11,r9
			add r11,qword[r9-8]
			xor r12,r12
	
		%assign i 0
		%rep	%0															; Repeat n times (No Of Parameters)
			%assign i i+1		
			%if i > 2														; If its an Index
				add r12,8													;	next slot 
				$extract %1
				pop rax
				mov rax,[rax]
				mov qword[r11+r12],rax
			%endif												
			%rotate 1														; Move to the next parameter
		%endrep

	%endif


		;---------------------------------------------------------------
		;	Function = fPUT/fGET
		;---------------------------------------------------------------
		;	fPUT and fGET are the same code but cannot find a way to do an OR
		;	for this pre-processor directive. 
		;	And the same as rPUR/rGET
		;	---------------------------------------------------------------
		;							  R8	R9		  R11	  R12		ControlBlock
		;	Function = fGET : XTABLES fget,	WorkTable,FieldNo,Fieldname,Idx,Idx,Idx..
		;	---------------------------------------------------------------
	%ifidni %1, $fget

		;	Setup to store indexes
			mov r11,r9
			add r11,qword[r9-8]
			xor r12,r12
	
		%assign i 0
		%rep	%0															; Repeat n times (No Of Parameters)
			%assign i i+1		
			%if i > 4														; If its an Index
				add r12,8													;	next slot 
				$extract %1
				pop rax
				mov rax,[rax]
				mov qword[r11+r12],rax
			%endif												
			%rotate 1														; Move to the next parameter
		%endrep

			$extract %3														; grab the Field No
			pop r11
			mov r11,[r11]
			mov r12,%4														; Setup Field Address												

	%endif

		;	---------------------------------------------------------------
		;							  R8	R9		  R11	  R12		ControlBlock
		;	Function = rPUT : XTABLES fget,	WorkTable,FieldNo,Fieldname,Idx,Idx,Idx..
		;	---------------------------------------------------------------
		;	R13/R14 (Picture Over-ride or qualified alpha)
	%ifidni %1, $fput

		;	Setup to store indexes
			mov r11,r9
			add r11,qword[r9-8]
			xor r12,r12
	
		%assign i 0
		%rep	%0															; Repeat n times (No Of Parameters)
			%assign i i+1		
			%if i > 4														; If its an Index
				add r12,8													;	next slot 
				$extract %1
				pop rax
				mov rax,[rax]
				mov qword[r11+r12],rax
			%endif												
			%rotate 1														; Move to the next parameter
		%endrep

			$pushAll r9,r10
			$SetupField {%4}												; grab the Field Address
			mov r12,r9
			mov r13,r10
			mov r14,r11	
			$popAll r10,r9

			$extract %3														; grab the Field No
			pop r11
			mov r11,[r11]

	%endif
	
		Call _TABLES	
	
%endmacro

;=======================================================================
;       	Macro for XTABLES package
;=======================================================================
;-----------------------------------------------------------------------
; 	UBOUND				 STATUS 				 			Table Indicator									 
;	+---+---+---+---+---+---+---+---+---+---+---------------+---+---------+------+	     
;	| 1	|'9'|Len|Val|Pic| 1	|'9'|Len|Val|Pic|Record Address	|'T'|NoOfBytes| NAME |
;	+---+---+---+---+---+---+---+---+---+---+---------------+---+---------+------+
;	-61					-27					-17				-9	-8			0	  
;
;-----------------------------------------------------------------------
;				   	R8		R9		  R10		R11,R12			R13
;			XTABLES bind,	WorkTable,Record,	Size
;			XTABLES sort,  	WorkTable,Start,	End,Divisor
;			XTABLES search,	WorkTable,Start,	End,SearchItem,	Index
;			XTABLES load,	WorkTable,File,		IncludeDeletedRecs
;			XTABLES unload,	WorkTable,File,		IncludeDeletedRecs
;			XTABLES rget, 	WorkTable,Idx
;			XTABLES rput, 	WorkTable,Idx
;			XTABLES delete,	WorkTable,Idx,		Initialise
;					R8		R9		  R11	  R12		R10
;			XTABLES fget,	WorkTable,FieldNo,Fieldname,Idx
;			XTABLES fput,	WorkTable,FieldNo,Fieldname,Idx R13/R14 (Picture Over-ride or qualified alpha)
;-----------------------------------------------------------------------
%imacro XTABLES.BIND 3
		XTABLES $bind,{%1},{%2},{%3}
%endmacro
;--------------------------
%imacro XTABLES.SORT 3
		XTABLES $sort,%1,%2,%3
%endmacro
;--------------------------
;		TABLES search,WorkTable,Start,End,SearchItem
%imacro XTABLES.SEARCH 5
		XTABLES $search,%1,%2,%3,%4,%5
%endmacro
;--------------------------
%imacro XTABLES.LOAD 3
		XTABLES $load,%1,%2,%3
%endmacro
;--------------------------
%imacro XTABLES.UNLOAD 3
		XTABLES $unload,%1,%2,%3
%endmacro
;--------------------------
%imacro XTABLES.rGET 2
		XTABLES $rget,{%1},{%2}
%endmacro
;--------------------------
%imacro XTABLES.rPUT 2
		XTABLES $rput,{%1},{%2}
%endmacro
;--------------------------
%imacro XTABLES.DELETE 3
		XTABLES $del,{%1},{%2},{%3}
%endmacro
;--------------------------
%imacro XTABLES.fGET 4
		XTABLES $fget,{%1},{%2},{%3},{%4}
%endmacro
;--------------------------
%imacro XTABLES.fPUT 4
		XTABLES $fput,{%1},{%2},{%3},{%4}
%endmacro

%imacro XTABLES 2-6
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
		
	;	Function and table address
		mov r_Function,%1													; Function
		mov r_Table,%2														; Load Table Address

		;	------------------------------------------------------------
		;	Function = BIND	
		;	------------------------------------------------------------
	%ifidni %1, $bind
			$extract %3														; Record Address
			pop r10														
			$extract %4														; Table Size
			pop r11
			mov r11,[r11]
	%endif

		;---------------------------------------------------------------
		;	Function = SORT
		;---------------------------------------------------------------
	%ifidni %1, $sort
			$extract %3														; Start position
			pop r10
			mov r10,[r10]
			$extract %4														; End Position
			pop r11
			mov r11,[r11]
	%endif

		;	------------------------------------------------------------
		;	Function = SEARCH	
		;	------------------------------------------------------------
	%ifidni %1, $search
			$extract %3														; Grab the Start of Key
			pop r10
			mov r10,[r10]
			$extract %4														; Grab the End Of Key
			pop r11
			mov r11,[r11]
			$extract %5														; and grab the key address
			pop r12	
			mov r13,%6														; and the Index address
	%endif

		;	------------------------------------------------------------
		;	Function = LOAD
		;	------------------------------------------------------------
	%ifidni %1, $load
			mov r10,%3														; Filename
			mov r11,%4														; Include deleted records
	%endif

		;	------------------------------------------------------------
		;	Function = UNLOAD
		;	------------------------------------------------------------
	%ifidni %1, $unload
			mov r10,%3														; Filename
			mov r11,%4														; Include deleted records
	%endif

		;	------------------------------------------------------------
		;	Function = rGET
		;	------------------------------------------------------------
	%ifidni %1, $rget
			$extract %3														; grab the Index
			pop r10
			mov r10,[r10]
	%endif

		;	------------------------------------------------------------
		;	Function = rPUT
		;	------------------------------------------------------------
	%ifidni %1, $rput														; Index has been provided														
			$extract %3
			pop r10
			mov r10,[r10]
	%endif

		;	------------------------------------------------------------
		;	Function = DELETE
		;	------------------------------------------------------------
	%ifidni %1, $del
			$extract %3														; grab the Index
			pop r10
			mov r10,[r10]
			mov r11,%4
	%endif

		;	---------------------------------------------------------------
		;							  R8	R9		  R11	  R12		R10
		;	Function = fGET : XTABLES fget,	WorkTable,FieldNo,Fieldname,Idx
		;	---------------------------------------------------------------
	%ifidni %1, $fget
			$extract %5														; grab the Index
			pop r10
			mov r10,[r10]
			$extract %3														; grab the Field No
			pop r11
			mov r11,[r11]
			mov r12,%4														; Setup Field Address
	%endif

		;	---------------------------------------------------------------
		;							  R8	R9		  R11	  R12		R10
		;	Function = rPUT : XTABLES fget,	WorkTable,FieldNo,Fieldname,Idx
		;	---------------------------------------------------------------
		;	R13/R14 (Picture Over-ride or qualified alpha)

	%ifidni %1, $fput
			$pushAll r9,r10
			$SetupField {%4}												; grab the Field Address
			mov r12,r9
			mov r13,r10
			mov r14,r11	
			$popAll r10,r9
										
			$extract %5														; grab the Index
			pop r10
			mov r10,[r10]
			$extract %3														; grab the Field No
			pop r11
			mov r11,[r11]
	%endif

		
		;	----------------------------------------------------------------
		;	Make the call
		;	----------------------------------------------------------------
			Call _XTABLES	
	
%endmacro


;=======================================================================
;       	Macro for ARRAYS package
;======================================================================= 
%imacro Arrays.Get 3
	$extract %2					; Source
	pop rax
	mov rax,[rax]
	mov r15,qword[%1+(rax*8)]
	mov qword[%3],r15			; Destination			
%endmacro
	
%imacro Arrays.Put 3
	$extract %3					; Source
	pop rbx
	mov rbx,[rbx]
	$extract %2					; Destination
	pop rax
	mov rax,[rax]		
	mov qword[%1+(rax*8)],rbx		
%endmacro
	
%imacro Arrays.Swap 3
	$extract %2					; Source/Destination
	pop rax
	mov rax,[rax]	
	mov r14,qword[%1+(rax*8)]
	$extract %3					; Source/Destination
	pop rbx
	mov rbx,[rbx]			
	mov r15,qword[%1+(rbx*8)]
	mov qword[%1+(rax*8)],r15
	mov qword[%1+(rbx*8)],r14	
%endmacro

%imacro Arrays.If 4
	$replaceSymbols %3			; Evaluator		
	$extract %2					; 1st Comparitor
	pop r15
	mov r15,[r15]
	mov rax,qword[%1+(r15*8)]
	$extract %4					; 2nd Comparitor
	pop r15
	mov r15,[r15]
	mov rbx,qword[%1+(r15*8)]	
	IF _ARRAYCOMPARE
%endmacro
	
;-----------------------------------------------------------------------
;				   R8   R9 	
;			ARRAYS sort,Array
;-----------------------------------------------------------------------
%imacro ARRAYS.SORT 1
		ARRAYS $sort,%1
%endmacro

%imacro ARRAYS 2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
		
	;	Function and table address
		mov r_Function,%1													; Function
		mov r_Table,%2														; Load Table Address
		mov r10,%2.len/8-1

		;---------------------------------------------------------------
		;	Function = SORT
		;---------------------------------------------------------------
	%ifidni %1, $sort
	%endif

		;	----------------------------------------------------------------
		;	Make the call
		;	----------------------------------------------------------------
			Call _ARRAYS	
	
%endmacro



;=======================================================================
;       	Macro for DATE routines (COMMON.LIB)
;			GET (String*10)
;			DATE_TO_DAYS (Number,String*10)
;			DAYS_TO_DATE (Number,String*10)
;=======================================================================
;--------------------------
%imacro DATE.SECONDS 1
		DATE -1,%1,0
%endmacro
%imacro DATE.GET 2
		DATE 0,%1,%2
%endmacro
%imacro DATE.DATEFROMDAYS 2
		DATE 1,%1,%2
%endmacro
%imacro DATE.DAYSFROMDATE 2
		DATE 2,%1,%2
%endmacro
%imacro DATE.TIMER 2
		DATE 3,%1,%2
%endmacro
;--------------------------
%imacro DATE 2-3
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
		;	Function and table address
			mov r_Function,%1												; Function
			$extract %2
			pop r9
			$extract %3
			pop r10
			Call _DATE
	
%endmacro	

;=======================================================================
;       	Macro for web access (WWW.LIB)
;				R8			R9				R10			R11,		R12		
;			WWW $wwwOpen,	n_PortNo	
;			WWW $wwwProcess,w_ScreenName,	w_Response,	GetAddress,	PostAddress
;			WWW $wwwClose,	n_PortNo (Cosmetic)
;=======================================================================
;--------------------------
%imacro WWW.OPEN 1
		WWW $wwwOpen,%1
%endmacro
%imacro WWW.PROCESS 4
		WWW $wwwProcess,%1,%2,%3,%4
%endmacro
%imacro WWW.CLOSE 1
		WWW $wwwClose,%1
%endmacro
%imacro WWW.SENDMSG 3
		WWW $wwwSendMsg,%1,%2,%3
%endmacro
%imacro WWW.RECVMSG 3
		WWW $wwwRecvMsg,%1,%2,%3
%endmacro
;--------------------------
%imacro WWW 2-5
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********
	
		;	Function and table address
			mov r_Function,%1												; Function

	%ifidni %1,$wwwOpen			
			$extract %2														; Parameter 2
			pop r9
	%endif
	
	%ifidni %1,$wwwProcess
			mov r9,%2														; Parameter 2
			mov r10,%3														; Parameter 3
			mov r11,%4														; Parameter 4
			mov r12,%5														; Parameter 5
	%endif

	%ifidni %1,$wwwClose
			$extract %2														; Parameter 2
			pop r9
	%endif
	
	%ifidni %1,$wwwSendMsg
			$extract %2														; Parameter 2
			pop r9
			$extract %3														; Parameter 3
			pop r10
			$extract %4														; Parameter 4
			pop r11
	%endif	

	%ifidni %1,$wwwRecvMsg
			$extract %2														; Parameter 2
			pop r9
			$extract %3														; Parameter 3
			pop r10
			$extract %4														; Parameter 4
			pop r11
	%endif	

			Call _WWW
	
%endmacro	

;=======================================================================
;      		Macro to call a program (COMMON.LIB)
;           Passes program path/name in r9
;			Passes R10 to receive read handle
;=======================================================================
%imacro  RUN 1-2
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

		$extract %1															; Grab the field/literal
		pop r9																; Address in R9

	%if %0 = 1
		Call _RUN_INTERACTIVE												; Call
	%else					
		$extract %1															; Grab the field/literal
		pop r9																; Address in R9
		mov r10,%2															; To receive Read Handle
		Call _RUN_BATCH														; and Call
	%endif

%endmacro

;-------------------------------------------------------------------------------
;	WAIT FOR CHILD_PID - No Library call required
;-------------------------------------------------------------------------------
%imacro  WAIT 1
	;========== *********
	%if debug = 1
		mov qword[STOP],0
	%endif
	;========== *********

		mov r9,%1
		Call _WAIT

%endmacro

;-------------------------------------------------------------------------------
;	TERMINATE - No Library call required
;-------------------------------------------------------------------------------
%imacro  TERMINATE 1

		mov qword[ERROR_CODE],%1
		jmp EndInstructions
	
	%%Exit:
%endmacro
