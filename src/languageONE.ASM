%line 1 languageONE.ASM
%assign debug 0

;   languageONE reWriter

%include 'include/BEGIN.PROGRAM'
;=======================================================================
;		PROGRAM DATA
;=======================================================================          

;-----------------------------------------------------------------------
;		WORDS
;-----------------------------------------------------------------------
%include 'include/BEGIN.DICTIONARY'

	insertword io_Buffer,				256,''
	insertword w_saveLine,				256,''
	insertword w_UBuffer,				256,''
	insertword w_Temp30,				030,''

	insertword w_Quote,					001,''
	insertword w_Brace,					001,''

	insertword w_DataType,				001,''
		%define c_Integer					'I'
		%define c_FixedPoint				'N'
		%define c_Word						'W'
		
		%define c_File						'F'
		%define c_Record					'R'
		%define c_Table						'T'
		%define c_XTable					'X'
		
	insertword x_Null,					001,0x00
	insertword x_Tab,					001,0x09
	insertword x_LF,					001,0x0A

	insertword w_FP_Picture,			021,"'99999999999999.9999'"

	insertword w_Synonym,				030,''

%include 'include/END.DICTIONARY'

;-----------------------------------------------------------------------
;		NUMBERS
;-----------------------------------------------------------------------
%include 'include/BEGIN.MATRIX'

	insertnumber I,                 	000,'999'
	insertnumber J,                 	000,'999'
	insertnumber K,                 	000,'999' 
	insertnumber L,                 	000,'999'

	insertnumber n_LineCtr,				000,'999999'
	insertnumber n_DebugCtr,			000,'99999'

	insertnumber n_LoadSynonyms,		000,'9'
		
	insertnumber n_NoOfBeginSubs,		000,'999999'
	insertnumber n_NoOfEndSubs,			000,'999999'
	insertnumber n_NoOfRepeats,			000,'999999'
	insertnumber n_NoOfEndRepeats,		000,'999999'
	insertnumber n_NoOfIfs,				000,'999999'
	insertnumber n_NoOfEndIfs,			000,'999999'

	insertnumber n_NoOfDotCommands,		000,'999999'
	insertnumber n_NoOfDotEnds,			000,'999999'
	insertnumber n_NoOfWhens,			000,'999999'
	insertnumber n_NoOfWends,			000,'999999'

	insertnumber n_NoOfBeginTests,		000,'999999'
	insertnumber n_NoOfEndTests,		000,'999999'
	insertnumber n_NoOfOpenBraces,		000,'999999'
	insertnumber n_NoOfCloseBraces,		000,'999999'
	insertnumber n_NoOfOpenSQBrackets,	000,'999999'
	insertnumber n_NoOfCloseSQBrackets,	000,'999999'

	insertnumber b_Debug,				c_FALSE
	insertnumber b_Windows,				c_FALSE
	insertnumber b_Assembler,			c_FALSE	
	insertnumber b_Procedures,			c_FALSE
	insertnumber b_Macro,				c_FALSE
	insertnumber b_ProcessRecord,		c_FALSE	
	insertnumber b_Coninuation,			c_FALSE
	insertnumber b_FoundSynonym,		c_FALSE
	
	insertnumber n_FieldPos,			000
	insertnumber n_NoOfSpaces,			000
	insertnumber n_CommandPosition,		000
	insertnumber n_CommentPosition,		000
	
	insertnumber n_Start,				000
	insertnumber n_End,					000
	insertnumber n_Length,				000


;	=============
;	TABLE RECORDS
;	=============

;		========
;		PROGRAM
;		========
		%define c_PR_reclen				0256 
	;	%define c_PR_noOfRecs			????
	begin.record c_PR_reclen,ProgramRecord
		insertword		PR_Type,			0001,''
		insertnumber	PR_CommandLength,	0000,'999'
		insertnumber	PR_LineLength,		0000,'999'
		insertword		PR_Line,			0249,'99'		
	end.record ProgramRecord
	
;		========
;		SYNONYMS
;		========
		%define c_SR_reclen				0064 
		%define c_SR_noOfRecs			0768
	begin.record c_SR_reclen,SynonymRecord								; Keyword table for synonym processing
		insertword		Synonym,		0030,''
		insertnumber	lenSynonym,		0000,'99'
		insertword		Original,		0030,''
		insertnumber	lenOriginal,	0000,'99'		
	end.record SynonymRecord
	
;		================
;		DATA DEFINITIONS
;		================
		%define c_DN_reclen				0131 
		%define c_DN_noOfRecs			1024		
	begin.record c_DN_reclen,DataNameRecord
		insertword		DN_TableType,	0001,''							; (X)Table
		insertword		DN_Table,		0030,''							; Data part of table
		insertword		DN_Record,		0030,''							; Data part of record
		insertnumber	DN_No,			0000,'999'						; Position within Record
		insertword		DN_Type,		0001,''							; 'I'=Integer,'N'=FixedPointNumber,'W'=Word
		insertword		DN_Name,		0030,''							; Data Name
		insertnumber	DN_Length,		0000,'999999'					; Length
		insertword		DN_Picture,		0030,''							; Picture
	end.record DataNameRecord	

;		====================
;		PROGRAM CREATED DATA
;		====================
		%define c_ND_reclen				0160 
		%define c_ND_noOfRecs			0512
	begin.record c_ND_reclen,NewDataRecord								; program inserts words/integers/FP Numbers
		insertword	ND_Type,			0001,'' 
		insertword	ND_ReUsable,		0001,''
	 	insertword	ND_Entry,			0062,''
		insertword	ND_Name,			0032,''
		insertword	ND_FunctionName,	0064,''
	end.record NewDataRecord

;		======================
;		SQUARE BRACKET NESTING
;		======================
		%define c_OB_reclen				0003 
		%define c_OB_noOfRecs			0032		
	begin.record c_OB_reclen,OpenBracketRecord							; variables saved for each iteration
		insertnumber OB_OpenBracket,	0000,'999'						; during recursion
	end.record OpenBracketRecord
	
;		=================
;		MACROS LINE ITEMS
;		=================		
		%define c_MR_reclen				0127
		%define c_MR_noOfRecs			1024	
	begin.record c_MR_reclen,MacroRecord								; program builds macro line items						
		insertnumber MR_MacroNo,		0000,'999'						; during macro creation	
		insertword	 MR_MacroLineItem,	0124,''
	end.record MacroRecord

;		======
;		TOKENS
;		======
		%define c_TK_reclen				0032
		%define c_TK_noOfRecs			0003	
	begin.record c_TK_reclen,TokenRecord								; to hold 3 tokens per src line	
		insertnumber TK_Length,			0000,'99'
		insertword	 TK_Token,			0030,''
	end.record TokenRecord
	
%include 'include/END.MATRIX'

;-----------------------------------------------------------------------
;		FILES
;-----------------------------------------------------------------------
%include 'include/BEGIN.FILES'

	insertfile c_LF,STDOUT

	insertfile c_LF,in_File
	insertfile c_LF,out_File
	
	insertfile c_LF,exports_File,"exports"
	insertfile c_LF,globals_File,"globals"


%include 'include/END.FILES'

;-----------------------------------------------------------------------
;		TABLES
;-----------------------------------------------------------------------
%include 'include/BEGIN.TABLES'

	INSERTXTABLE ProgramTable
	
	INSERTXTABLE SynonymTable

	INSERTTABLE  DataNameTable,c_DN_reclen*c_DN_noOfRecs
	INSERTXTABLE NewDataTable

	INSERTTABLE  OpenBracketTable,c_OB_reclen*c_OB_noOfRecs
	INSERTXTABLE MacroTable

	INSERTTABLE TokenTable,c_TK_reclen*c_TK_noOfRecs

%include 'include/END.TABLES'

;	MACROS --------------------------------------------------------------
	[section .data]
		insertnumber	n_beginAt,	0
		insertword		w_Char1,	1,''
	[section .text]
%imacro mExtractText 4-5 ' ' ; default w_Char1 to space

;	PASSED IN
	integers.eq n_beginAt,%1
	integers.eq PR_CommandLength,%2
	words.copy  %5,w_Char1
	
	$Call X_7_ExtractText
	
;	RECEIVED
	integers.eq %3,n_Start
	integers.eq %4,n_Length
	
%endmacro

	[section .data]
		insertnumber	X_1_Idx,	0
	[section .text]
%imacro mCheckQuotes 1

	integers.eq X_1_Idx,%1
	$Call X_1_CheckQuotes

%endmacro

	[section .data]
		insertnumber	X_2_Idx,	0
	[section .text]
%imacro mCheckBraces 1

	integers.eq X_2_Idx,%1
	$Call X_2_CheckBraces

%endmacro

;	MACROS --------------------------------------------------------------

;=======================================================================
;		PROGRAM INSTRUCTIONS
;       MAINLINE  
;=======================================================================
%include 'include/BEGIN.INSTRUCTIONS'

	$Call A_Initialise

	$Call B_1stPass
	$Call C_2ndPass
	$Call D_3rdPass

;	$Call Z_Debug

%include 'include/END.INSTRUCTIONS'
%include 'include/END.PROGRAM'      
;	EXIT

;=======================================================================
;		PROGRAM INITIALISATION
;=======================================================================
BEGIN.SUB A_Initialise

		push qword[StdOutHandle]
		pop  qword[STDOUT_HANDLE]

;	------
;	ERRORS
;	------
	if {w_CommandLine,1,1},=,spaces(1)
		files.write STDOUT,'01: languageONE reWriter requires a file name'
		TERMINATE 1       
	end.if

;	-----
;	DEBUG
;	-----
	if {w_CommandLine,1,2},_IN,{'-D','-d'}									; Debug
		integers.eq b_Debug,c_TRUE
		if {w_CommandLine,3,1},_IN,{'L','l'}								; Linux
			integers.eq b_Windows,c_FALSE
			integers.eq I,5
		else
			if {w_CommandLine,3,1},_IN,{'W','w'}							; Windows
				integers.eq b_Windows,c_TRUE
				integers.eq I,5
			else
				integers.eq I,4
			end.if
		end.if
	else
		integers.eq b_Debug,c_FALSE
		integers.eq I,1
	end.if

	repeat.for J,I,256														; Find the end of the program name
		if {w_CommandLine,J,1},=,spaces(1)
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat
	If J,=,257																; It may be too long 
		files.write STDOUT,'02: File name is too long'
		TERMINATE 2
	end.if

;	---------------
;	SETUP FILENAMES
;	---------------
	integers.sub J,I														; J-I gives the start position
	Words.pad {w_CommandLine,I,J},in_File									; Move in the filename
	Words.pad {w_CommandLine,I,J},out_File

	integers.add J,1														; I goes to next character
	Words.copy '.ONE',{in_File,J}											; move in the suffix
	Words.copy '.ASM',{out_File,J}											; move in the suffix

	integers.add J,4														; Bypass the suffux
	Words.copy x_Null,{in_File,J}											; move in the null [0x00]
	Words.copy x_Null,{out_File,J}											; move in the null [0x00]

;	-----------
;	BIND TABLES
;	-----------
	xtables.bind ProgramTable,ProgramRecord,64000000
	
	integers.calc I,=,c_SR_reclen,+,9,*,c_SR_noOfRecs
	xtables.bind SynonymTable,SynonymRecord,I

	tables.bind OpenBracketTable,OpenBracketRecord,c_OB_noOfRecs			; Used for macro functionality
	tables.bind DataNameTable,DataNameRecord,c_DN_noOfRecs					; Inferring DataNames

	integers.calc I,=,c_ND_reclen,+,9,*,c_ND_noOfRecs						; Used for creating New Data
	xtables.bind NewDataTable,NewDataRecord,I

	integers.calc I,=,c_MR_reclen,+,9,*,c_MR_noOfRecs
	xtables.bind MacroTable,MacroRecord,I									; Used for macro functionality

	tables.bind TokenTable,TokenRecord,c_TK_noOfRecs

;	---------------------------
;	EXPORTS/GLOBALS FOR WINDOWS
;	---------------------------
	files.open exports_File,$write+$beginning								; OPen the exports file
	files.write exports_File,"/export:_start"
	files.close exports_File

	files.open globals_File,$write+$beginning								; OPen the globals file
	files.write globals_File,"global _start"
	files.close globals_File


END.SUB A_Initialise
;	EXIT

;===============================================================================
;		1ST PASS PROCESSING
;===============================================================================
BEGIN.SUB B_1stPass

;	----------------------------
;	LOAD THE PROGRAM INTO MEMORY
;	----------------------------
	$Call  B_1_0_LoadProgramTable
	
;	--------------------------
;	LOAD SOME SYSTEM DATANAMES
;	--------------------------
	Words.copy c_Integer,DN_Type											; response from a function
	Words.pad  'RETURN_CODE',DN_Name										; It is boolean and should
	$Call X_3_PutXtable														; be either TRUE or FALSE

	Words.copy c_Integer,DN_Type											; It can be used throughout a program
	Words.pad  'ERROR_CODE',DN_Name											; and is used by the system to report
	$Call X_3_PutXtable														; the programs return code

	words.copy c_Integer,DN_Type
	words.pad 'exitRepeat',DN_Name
	$Call X_3_PutXtable

	repeat.for n_LineCtr,1,ProgramTable_UBOUND

		xtables.rget ProgramTable,n_LineCtr
		
		if PR_Type,=,"L"
				
			words.uppercase PR_Line,w_UBuffer

		;	-----------------------
		;	REMOVE THE BRACKETS 1ST
		;	-----------------------
			$Call B_1_1_removebrackets

		;	--------------------
		;	REPLACE THE SYNONYMS
		;	--------------------
			if n_LoadSynonyms,=,2	
				integers.eq b_FoundSynonym,c_TRUE
				repeat.while b_FoundSynonym,!=,c_FALSE
					$Call B_1_2_Synonyms
				end.repeat
			end.if
			
		;	------------------------
		;	BUILD THE DATANAME TABLE
		;	------------------------
			$Call B_1_3_Load_DN_Table
					
		;	----------------------------------------------------
		;	BUILD DATANAME/NEWDATANAME TABLES IF IT'S A FUNCTION
		;	----------------------------------------------------
			words.find {"BEGIN.FUNCTION",I},w_UBuffer
			words.find {":",J},w_UBuffer
		   .if  I,>,0
		   .and J,>,0
		   .end
				$Call B_1_4_Load_ND_Table					
		 	end.if	
	
		;	------------------------
		;	PROCESS THE BIND COMMAND
		;	------------------------
			$Call B_1_5_ProcessBIND
			
		;	------------------------
		;	REWRITE THE PROGRAMTABLE
		;	------------------------
			xtables.rput ProgramTable,n_LineCtr
			
		end.if
	end.repeat
	
END.SUB B_1_1stPass

;-------------------------------------------------------------------------------
;		LOAD THE PROGRAM INTO MEMORY
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_0_LoadProgramTable

	files.open in_File,$read 												; Open the Input File

	if in_File_SIZE,=,0														; If it is blank then
		files.write STDOUT,'03: [reWriter]:Input File does not exist'		; issue an error
		TERMINATE 3															; and terminate
	else																	; ELSE

		files.read in_File,io_Buffer										; Read the first record
		integers.eq n_LineCtr,1												; Start the line counter
		
		Repeat.If in_File_STATUS,=,0										; REAPEAT until end of file (or error)

		;	-------------------
		;	INITIALISE THE LINE
		;	-------------------		
			words.copy spaces(1),PR_Type									; mark the line as blank
			integers.eq PR_LineLength,0										; set the length to zero
			integers.eq PR_CommandLength,0									; set the length to zero
			integers.eq n_CommandPosition,0									; set the command position to zero
			integers.eq n_CommentPosition,0									; set the comment position to zero
			words.pad spaces(1),PR_Line										; and clear the line

		;	-----------------
		;	JUST A BLANK LINE
		;	-----------------
			integers.eq PR_LineLength,in_File_READLENGTH					; ProgramTable line length is the read length
			if in_File_READLENGTH,=,0										; If we have a blank line then
				words.copy "B",PR_Type										; mark the line as blank
			else															; ELSE			
			;	----------------------
			;	GATHER THE INFORMATION
			;	----------------------
				words.pad {io_Buffer,1,in_File_READLENGTH},PR_Line			; move the line to the ProgramTable
			
			;	-------------------------------------
			;	WORKING BACKWARDS GET THE LINE LENGTH
			;	-------------------------------------
				repeat.for PR_LineLength,in_File_READLENGTH,0				; REPEAT from the end to the beginning of the line
					if {PR_Line,PR_LineLength,1},_NIN,{' ',x_Tab}			; to determine the line length without spaces/tabs
						integers.eq exitRepeat,c_TRUE						; and exit if we have done so
					end.if													; END
				end.repeat													; END REPEAT

			;	-------------------
			;	JUST TABS OR SPACES
			;	-------------------
				if PR_LineLength,=,-1										; If we have found nothing (probably just tabs)
					words.copy "B",PR_Type									; mark the line as blank
				else														; ELSE	
				; ------------------------------
				; GET COMMAND & COMMENT POSITION
				; ------------------------------	
				  $Call s_GetCommandCommentPosition							; Get the Command and/or Comment position
				  
				; --------------
				; NASM DIRECTIVE
				; --------------
				  If f_Directives											; Check for a NASM directive
				  	 words.copy "%",PR_Type			
				  else
				  	
				  ; -------------
				  ; ITS A COMMENT
				  ; -------------
				  	if f_Comment											; If it's a comment
						words.copy "C",PR_Type								; mark it as such
						integers.eq PR_CommandLength,0						; reset command length to zero
						$Call B_1_0_2_LoadSynonyms							; and check for Synonyms
				    else						
				    ; -------------
				    ; ITS A COMMAND
				  	; -------------
				  		if f_Command										; If it's a command
				  		  words.copy "L",PR_Type							; mark it as such
					 	  $Call s_GetCommandLength							; and get the command length					  					 	  
					    end.if												; END
					    
					end.if													; END					
				  end.if													; END				  
				end.if														; END				
		    end.if															; END

		;	---------------------------------------
		;	WRITE THE TABLE AND GET THE NEXT RECORD
		;	---------------------------------------
			integers.add ProgramTable_UBOUND,1								; increment the upper boundary
			xtables.rput ProgramTable,ProgramTable_UBOUND					; write the record to the table

			if PR_Type,=,"L"												; If we have a line command
				$Call B_1_0_3_SplitLines									; do we have more than 1 command
			end.if															; END
			
			files.read in_File,io_Buffer									; Read the next record
			words.uppercase io_Buffer,w_UBuffer
			integers.add n_LineCtr,1

		end.repeat
		
	end.if
	
	files.close in_File														; Close filee - we are done
	
	exit.sub B_1_0_LoadProgramTable											; and exit

;------------------------------
;	Routines called by this sub
;	---------------------------
	BEGIN.SUB s_GetCommandCommentPosition

		words.copy spaces(1),w_Quote										; Initialise w_Quote
		
		repeat.for I,1,PR_LineLength										; LOOP FORWARDS thru the line
					
			if {PR_Line,I,1},_NIN,{' ',x_Tab}								; So we have something	
					  
				mCheckQuotes (I)											; check for quotes
				If w_Quote,=,spaces(1)										; and if not quoted
						
					if {PR_Line,I,1},=,";"									; If we have found a comment
						if n_CommentPosition,=,0							; ensure it is the 1st one
							integers.eq n_CommentPosition,I					; and mark its position
						end.if												; END
						if n_CommandPosition,=,0							; If we have found a comment before a command
							integers.eq exitRepeat,c_TRUE					; we can exit
						end.if												; END
					else													; ELSE a command
					    if n_CommandPosition,=,0							; ensure it is the 1st one
					    	integers.eq n_CommandPosition,I					; and mark its position
						end.if												; END	
					end.if													; END
						  
				end.if														; END
						
			end.if															; END
					  
			.if  n_CommandPosition,>,0										; If we have found both a Command
			.and n_CommentPosition,>,0										; and a Comment
			.end															; END
				integers.eq exitRepeat,c_TRUE								; we may exit
			end.if															; END
						
		end.repeat															; END LOOP

	END.SUB s_GetCommandCommentPosition
	
	BEGIN.FUNCTION f_Directives

		words.copy spaces(1),w_Quote										; Initialise w_Quote
		
		repeat.for I,1,PR_LineLength										; LOOP FORWARDS thru the line

			.if n_CommentPosition,>,0
			.and I,!<,n_CommentPosition
			.end
				exit.function f_Directives
			end.if
		
			mCheckQuotes (I)												; check for quotes
			If w_Quote,=,spaces(1)											; and if not quoted
				begin.test c_TRUE											; Test for each case
					when {w_UBuffer,I,7},=,"%DEFINE"						; Found %DEFINE
						integers.eq exitRepeat,c_TRUE						; exit
					wend													; END
					when {w_UBuffer,I,8},=,"%IDEFINE"						; Found %IDEFINE
						integers.eq exitRepeat,c_TRUE						; exit
					wend													; END
					when {w_UBuffer,I,7},=,"%ASSIGN"						; Found %ASSIGN
						integers.eq exitRepeat,c_TRUE						; exit
					wend													; END
					when {w_UBuffer,I,8},=,"%INCLUDE"						; Found %INCLUDE
						integers.eq exitRepeat,c_TRUE						; exit
					wend													; END
				end.test													; END TEST
			end.if															; END IF
		end.repeat															; END REPEAT
		
		if I,<,PR_LineLength												; If we have found one
			integers.eq RETURN_CODE,c_TRUE									; return true
		end.if																; END
				
	END.FUNCTION f_Directives

	BEGIN.FUNCTION f_Comment

		if n_CommentPosition,>,0											; So we do actually have a comment
			.if n_CommandPosition,=,0										; If we have detected NO command						
			.or n_CommandPosition,!<,n_CommentPosition						; of the comment preceeds the command
			.end															; END
				integers.eq RETURN_CODE,c_TRUE
			end.if
		end.if

	END.FUNCTION f_Comment
	
	BEGIN.FUNCTION f_Command

		integers.eq b_Macro,c_FALSE
	
		if n_CommandPosition,>,0											; So we do actually have a command
			.if n_CommentPosition,=,0										; If we have detected NO comment					
			.or n_CommandPosition,<,n_CommentPosition						; or the command preceeds the comment
			.end															; END
				repeat.for I,1,PR_LineLength								; LOOP FORWARDS thru the line					
					if {PR_Line,I,1},=,'['									; So we have something	
						integers.eq b_Macro,c_TRUE							; set the macro flag							
					end.if													; END
				end.repeat													; END REPEAT
				integers.eq RETURN_CODE,c_TRUE								; set the command flag 
			end.if
		end.if		

	END.FUNCTION f_Command
	
	BEGIN.SUB s_GetCommandLength

		if n_CommentPosition,>,0											; If we do have a trailing comment
			integers.calc I,=,n_CommentPosition,-,1							; set the end point to it
		else																; else
			integers.eq I,PR_LineLength										; set the end point to the line length
		 end.if																; END
					  
		repeat.for PR_CommandLength,I,1										; REPEAT BACKWARDS from the end point
			if {PR_Line,PR_CommandLength,1},_NIN,{' ',x_Tab}				; to determine the length of the command						
				integers.eq exitRepeat,c_TRUE								; then exit loop
			end.if															; END
		end.repeat															; END REPEAT

	END.SUB s_GetCommandLength
	
END.SUB B_1_0_LoadProgramTable
;	Exit
;-------------------------------------------------------------------------
;		FUNCTIONS
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
;		LOAD SYNONYMS
;-------------------------------------------------------------------------
BEGIN.SUB B_1_0_2_LoadSynonyms

;	n_LoadSynonyms flag drives the logic for loading the Synonyms table
;	When the BEGIN.SYNONYM is detected it is set to 1
;	While it is 1 then Synonyms can be loaded
;	When the END.SYNONYM is detected it is set to 2
	
	begin.test n_LoadSynonyms

		when =,0
			words.find {'BEGIN.SYNONYMS',I},w_UBuffer
			if I,>,0
				integers.eq n_LoadSynonyms,1
			end.if
		wend

		when =,1
			words.find {'END.SYNONYMS',I},w_UBuffer
			if I,>,0
				integers.eq n_LoadSynonyms,2				
			else
				$Call B_1_0_2_1_GetSynonym
			end.if
		wend

	end.test

END.SUB B_1_0_2_LoadSynonyms
;	EXIT

;-----------------------------------------------------------------------
;		GET SYNONYMS
;-----------------------------------------------------------------------
BEGIN.SUB B_1_0_2_1_GetSynonym

;	Returns : 1 = Begin at, PR_LineLength = End of Text, I = start, J = length, ignore character
	mExtractText 1,PR_LineLength,I,J,';'									; Extract the properties

	if I,=,0																; If just a blank line/comment
		exit.sub B_1_0_2_1_GetSynonym										;	 then exit
	else																	; else
		words.pad {PR_Line,I,J},Synonym										;	grab the synonym
		integers.eq lenSynonym,J 											;	and its length
	end.if

	words.find {":",I},PR_Line												; Find start position
;	Returns : I = Begin at, J = start, K = length, ignore character
	mExtractText I,PR_LineLength,J,K,':'									; Extract the properties
	words.pad {PR_Line,J,K},Original										; Grab the Original Dataname or Command
	integers.eq lenOriginal,K 												; and its length
	$Call X_4_PutXtable														; Write it to the Synonyms table
	
END.SUB B_1_0_2_1_GetSynonym
;	EXIT

;-------------------------------------------------------------------------------
;		MORE THAN ONE COMMAND ON THE LINE
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_0_3_SplitLines

	[section .data]
		insertnumber n_Origin,			0
		insertnumber n_CommandLength,	0
	[section .text]

;	----------
;	INITIALISE
;	----------
	words.copy PR_Line,w_saveLine
	integers.eq n_Origin,0
	integers.eq n_CommandLength,PR_CommandLength
	integers.sub ProgramTable_UBOUND,1

;	----------
;	OUTER LOOP
;	----------	
	repeat.for I,1,n_CommandLength											; Working FORWARDS
	
	;	-------------
	;	1ST TIME THRU
	;	-------------
		if n_Origin,=,0														; If we haven't got the origin yet
			if {w_saveLine,I,1},_NIN,{' ',x_Tab}								; and we think we have it
				integers.eq n_Origin,I										; then save it
				integers.eq n_Start,I										; and the 1st start point
			end.if															; END
		end.if																; END

		if {w_saveLine,I,1},=,"|"												; If we have found a splitter
		
		;	---------------------
		;	FOUND A LINE SPLITTER
		;	---------------------		
			integers.calc n_End,=,I,-,1										; step back 1
			$Call doMove													; and do the move

		;	---------------------------
		;	GET THE NEXT STARTING POINT
		;	---------------------------
			integers.calc J,=,I,+,1											; move 1 past the splitter									
			repeat.for K,J,n_CommandLength									; and loop FORWARD to the end
				if {w_saveLine,K,1},_NIN,{' ',x_Tab}							; if we have found one			
					integers.eq n_Start,K									; grab the start point
					integers.eq exitRepeat,c_TRUE							; exit the loop
				end.if														; END
			end.repeat														; END
			if K,!<,n_CommandLength											; If we have exceeded the line
				integers.eq exitRepeat,c_TRUE								; then we are done
			end.if															; END
			
		end.if																; END

	end.repeat																; END

;	--------
;	LAST ONE
;	--------
	if n_End,>,0															; If we have split the line
		integers.eq n_End,n_CommandLength									; set up the end point
		$Call doMove														; and do the last one
	else																	; ELSE		
		integers.add ProgramTable_UBOUND,1									; restore the upper boundary				
	end.if																	; END

	exit.sub B_1_0_3_SplitLines
	
	BEGIN.SUB doMove

	  repeat.for n_End,n_End,1												; working BACKWARDS from the splitter
		if {w_saveLine,n_End,1},_NIN,{' ',x_Tab}								; When we have found the end of command
		  integers.calc n_Length,=,n_End,-,n_Start,+,1						; get its length
		  words.pad {w_saveLine,n_Start,n_Length},{PR_Line,n_Origin}			; and move it into PR_Line
		  integers.calc PR_CommandLength,=,n_End,-,n_Start,+,n_Origin		; set the new command length
		  integers.eq PR_LineLength,PR_CommandLength						; and the Line length
		  integers.add ProgramTable_UBOUND,1								; grab the next slot
		  xtables.rput ProgramTable,ProgramTable_UBOUND						; and write the table
		  integers.eq exitRepeat,c_TRUE										; exit the loop
		end.if
	  end.repeat	

	END.SUB doMove

END.SUB B_1_0_3_SplitLines

;-------------------------------------------------------------------------------
;		REMOVE BRACKETS
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_1_removebrackets

;	--------------------------------
;	DONT WANT THIS IN ASSEMBLER CODE
;	--------------------------------
	words.find {"BEGIN.ASSEMBLER",I},w_UBuffer
	if I,>,0
		integers.eq b_Assembler,c_TRUE
		exit.sub B_1_1_removebrackets
	end.if
	words.find {"END.ASSEMBLER",I},w_UBuffer
	if I,>,0
		integers.eq b_Assembler,c_FALSE
		exit.sub B_1_1_removebrackets
	end.if
	if b_Assembler,=,c_TRUE
		exit.sub B_1_1_removebrackets
	end.if
			
;	------------------
;	LOOP THRU THE LINE
;	------------------
	words.copy spaces(1),w_Quote											; Initialise w_Quote
	repeat.for I,1,PR_CommandLength											; Run from beginning to end of the command

		mCheckQuotes (I)   													; Checks Quotes		
		If w_Quote,=,spaces(1)												; Nothing to do if in quotes
					
		;	-------------------------------------------------------
		;	DO NOT STRIP BRACKETS FROM SINGLE LINE MACRO - SPACES()
		;	-------------------------------------------------------   	
			if {w_UBuffer,I,6},=,'SPACES'									; If we find a spaces
				integers.add I,1											;	go to the next character
				repeat.for I,I,PR_CommandLength								;	and look for the closing bracket
					if {w_UBuffer,I,1},=,')'								;	If we find it
						integers.add I,1									;		then step over it
						integers.eq exitRepeat,c_TRUE
					end.if
				end.repeat
			end.if

		;	--------
		;	BRACKETS
		;	------- 
			if {w_UBuffer,I,1},_IN,{'(',')'}								; Have we got a bracket
				words.copy spaces(1),{PR_Line,I,1}							; then remove it from the line			
			end.if

		end.if
		
	end.repeat

END.SUB B_1_1_removebrackets
;	EXIT

;-------------------------------------------------------------------------------
;		PROCESS SYNONYMS
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_2_Synonyms

;	--------------------------
;	RUN THRU THE SYNONYM TABLE
;	--------------------------
	repeat.for I,1,SynonymTable_UBOUND
	
		$Call B_1_2_1_GetSynonym											; So grab one
		words.find {w_Synonym,b_FoundSynonym,},{PR_Line}					; Do we have a match
		if b_FoundSynonym,>,0												; If we have one
			integers.eq n_NoOfSpaces,lenOriginal							;	save the length
		end.if		

		if b_FoundSynonym,>,1
		;	------------------------------------------------
		;	IF FOUND IT, MUST BE PROCEEDED BY A SPACE OR TAB
		;	------------------------------------------------
			integers.calc K,=,b_FoundSynonym,-,1							; move back 1
			if {PR_Line,K,1},_NIN,{' ',x_Tab}								; IF its NOT a space/tab
				integers.eq b_FoundSynonym,0								; set found to zero
			end.if
		end.if

		if b_FoundSynonym,>,0
		;	--------------------
		;	SO NOW MAKE THE SWAP
		;	--------------------		
	   		if lenOriginal,>,lenSynonym										
	   		;	--------------
	   		;	MAKE SOME ROOM
	   		;	--------------
				integers.sub n_NoOfSpaces,lenSynonym						; subtract the synonym length from the Originals length
				words.insert spaces(n_NoOfSpaces),{PR_Line,b_FoundSynonym}	; and insert the correct no of spaces
				integers.add PR_CommandLength,n_NoOfSpaces
			else
			;	------------
			;	SQUASH IT UP
			;	------------
				integers.calc K,=,b_FoundSynonym,+,lenSynonym				; Calculate the start position for the squash
				integers.calc L,=,b_FoundSynonym,+,lenOriginal				; Calculate the end position for the squash
				words.pad {PR_Line,K},{PR_Line,L}							; Now do the squashing move
				integers.calc K,=,lenSynonym,-,lenOriginal					; Get the no of bytes subtratec from the line
				integers.sub PR_CommandLength,K
			end.if

		;	----------------------
		;	AND DO THE REPLACEMENT
		;	----------------------
			words.copy {Original,1,lenOriginal},{PR_Line,b_FoundSynonym}	; Copy in the Sysnonym or Command
			Words.uppercase PR_Line,w_UBuffer								; Copy to the Uppercase Buffer
			integers.eq exitRepeat,c_TRUE									; and exit
			
		end.if	

	end.repeat

END.SUB B_1_2_Synonyms
;	EXIT

;-------------------------------------------------------------------------------
;		GET THE REQUIRED SYNONYM
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_2_1_GetSynonym

	xtables.rget SynonymTable,I

;	SET LENGTH
	begin.assembler														; Set the field
		mov qword[w_Synonym-8],30										; to its original
	end.assembler														; length

;	GRAB THE SYNONYM	
	words.pad {Synonym,1,lenSynonym},{w_Synonym}

;	AND RESET THE LENGTH	
	begin.assembler														; Reset the field
		mov rax,qword[lenSynonym]										; length so that
		mov qword[w_Synonym-8],rax										; find will work
	end.assembler

END.SUB B_1_2_1_GetSynonym
;	EXIT

;-------------------------------------------------------------------------------
;		LOAD THE DATANAMES TABLE
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_3_Load_DN_Table

;	-------------------
;	INTEGERS/FIXEDPOINT
;	-------------------
	words.find {'INSERTNUMBER',J},w_UBuffer									; INSERTNUMBER
    if J,>,0		
   		words.copy c_Integer,DN_Type										; Default to integer
		$Call B_1_3_1_StoreDataDefinitions
	end.if

;	-----
;	WORDS
;	-----
	words.find {'INSERTWORD',J},w_UBuffer									; INSERTWORD
    if J,>,0																	
		words.copy c_Word,DN_Type
		$Call B_1_3_1_StoreDataDefinitions
	end.if
		 	
;	======================
;	SYSTEM SUPPLIED FIELDS
;	======================

;	----------
;	INSERTFILE
;	----------
	words.find {'INSERTFILE',J},w_UBuffer									; INSERTFILE
    if J,>,0
		words.copy c_File,DN_Type	
		$Call B_1_3_2_StoreSystemDefinitions
	end.if

;	------------
;	BEGIN.RECORD
;	------------
	words.find {'BEGIN.RECORD',J},w_UBuffer									; BEGIN.RECORD
	  if J,>,0
		integers.eq b_ProcessRecord,c_TRUE									; Set processing record to true
		integers.calc J,=,J,+,13											; move past begin.record
		mExtractText J,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name,','	; jump over record length
		integers.calc J,=,n_StartDN_Name,+,n_LengthDN_Name,+,1
		mExtractText J,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name,' '	; find the record name
		words.pad {PR_Line,n_StartDN_Name,n_LengthDN_Name},w_SaveRecordName
	end.if

;	----------
;	END.RECORD
;	----------
	words.find {'END.RECORD',J},w_UBuffer									; END.RECORD
	  if J,>,0																; and set flag
		integers.eq b_ProcessRecord,c_FALSE									; set processing record to false
		integers.eq n_FieldPos,0											; and reset field pos to zero
		words.copy c_Record,DN_Type
		$Call B_1_3_2_StoreSystemDefinitions
		words.pad spaces(1),DN_Record										; Clear the Data Record
	end.if

;	-----------
;	INSERTTABLE
;	-----------
	words.find {'INSERTTABLE',J},w_UBuffer									; INSERTTABLE
	  if J,>,0																; and Process if not commented out
		words.copy c_Table,DN_Type	
		$Call B_1_3_2_StoreSystemDefinitions
	end.if

;	------------
;	INSERTXTABLE
;	------------
	words.find {'INSERTXTABLE',J},w_UBuffer									; INSERTXTABLE
	  if J,>,0																; and Process if not commented out
		words.copy c_XTable,DN_Type	
		$Call B_1_3_2_StoreSystemDefinitions
	end.if		 	

;	=====================
;	SUBROUTINES/FUNCTIONS
;	=====================	

;	---------
;	BEGIN.SUB
;	---------	
	words.find {"BEGIN.SUB",J},w_UBuffer									; BEGIN.SUB
	if J,>,0																; and process
		words.copy "s",DN_Type												; Add the Sub name to DataName Table
		integers.add J,10													; so that we can export it for
		words.pad {PR_Line,J},DN_Name										; debugging
		$Call X_3_PutXtable
	end.if

;	--------------
;	BEGIN.FUNCTION
;	--------------
	words.find {"BEGIN.FUNCTION",J},w_UBuffer								; BEGIN.FUNCTION
	if J,>,0																; and process
		words.copy "f",ND_Type												; Add the Function name to DataName Table
		integers.add J,15													; so that we can export it for
		words.pad {PR_Line,J},ND_Name										; debugging
		$Call X_3_PutXtable	
	end.if

END.SUB B_1_3_Load_DN_Table

;-------------------------------------------------------------------------------
;		STORE DATA DEFINITIONS
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_3_1_StoreDataDefinitions

	[section .data]
		insertnumber n_StartDN_Name,0
		insertnumber n_LengthDN_Name,0
	[section .text]

;	-----------------
;	MARK RECORD FIELD
;	-----------------
	if b_ProcessRecord,=,c_TRUE												; If we have detected we are processing a record
		integers.add n_FieldPos,1											;	increment the ctr for field position
		integers.eq DN_No,n_FieldPos										;	and store the value	
		words.copy w_SaveRecordName,DN_Record								;	and the record name			
	else																	; ELSE
		integers.eq DN_No,0													;	set the field position ctr to zero
		words.copy spaces(1),DN_Record										;	and spaces to the record name
	end.if
	words.pad spaces(1),DN_Picture											; Always clear picture
	integers.eq DN_Length,0													; and length

;	-----------
;	FIXED POINT
;	-----------
	if DN_Type,=,c_Integer													; So its a number but
		words.find {'.',J},w_UBuffer										; Is it a fixed point number
		if J,>,0
			words.copy c_FixedPoint,DN_Type
		end.if
	end.if

;	-----------------
;	SETUP FOR EXTRACT
;	-----------------
	words.find {'INSERT',I},w_UBuffer										; Locate INSERT in UBuffer	
	repeat.for I,I,PR_CommandLength											; Search until space or tab found
		if {w_UBuffer,I,1},_IN,{' ',x_Tab}
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat

;	------------
;	GET DN_NAME
;	------------
	mExtractText I,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name,','			; Extract the name	
	words.pad {PR_Line,n_StartDN_Name,n_LengthDN_Name},DN_Name					; and move it in

;	------------------------
;	GET DN_PICTURE/DN_Length
;	------------------------
	words.find {',',I},{w_UBuffer,I}										; Find the 1st comma
	integers.add I,1														; and move past it

	If DN_Type,=,c_Word														; IF Its a word

		repeat.for J,I,128													; Loop thru and 
			if {w_UBuffer,J,1},_IN,{' ',x_Tab}								; If its a space/tab 
				integers.add I,1											; advance the start of word ctr
			else
				if {w_UBuffer,J,1},=,','									; until we have found our next comma
					integers.eq exitRepeat,c_TRUE
				end.if
			end.if
		end.repeat

		integers.calc K,=,J,-,I												; Calculate position into w_Temp
		integers.calc L,=,30,-,K,+,1										; so that we may convert it onto
		words.copy {w_UBuffer,I,K},{w_Temp30,L}								; a number correctly
		numbers.eq DN_Length,w_Temp30										; CONVERT

	else																	; ELSE

		words.find {',',J},{w_UBuffer,I}									; Find the 2nd comma
		if J,>,0															; There maynot be a second comma
			integers.add J,1												; and move past it
			mExtractText J,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name	; Extract the picture
			words.pad {w_UBuffer,n_StartDN_Name,n_LengthDN_Name},DN_Picture ; and store it
		end.if																; END								
	end.if																	; END

;	------------
;	AND WRITE IT
;	------------
	$Call X_3_PutXtable														; Write it out

END.SUB B_1_3_1_StoreDataDefinitions
;	EXIT

;-------------------------------------------------------------------------------
;		STORE SYSTEM DATA DEFINITIONS
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_3_2_StoreSystemDefinitions

;	----------
;	INITIALISE 
;	----------
	words.pad spaces(1),DN_TableType
	words.pad spaces(1),DN_Table
	words.pad spaces(1),DN_Record
	integers.eq DN_No,0
	words.pad spaces(1)
	words.pad spaces(1),DN_Name
	integers.eq DN_Length,0
	words.pad spaces(1),DN_Picture

;	------------------
;	CREATE FILE FIELDS
;	------------------
;	The filename itself must be defined cuz we can set it to the external name 
;	_READLENGTH, _STATUS, _SIZE should be readonly
;	_HANDLE is Read/Write, mainly for recursive directory walk
	if DN_Type,=,c_File

		words.find {',',J},w_UBuffer										; move past macro name & delimiter
		integers.calc J,=,J,+,1	
		mExtractText J,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name,','	; Extract the file name

		words.copy c_Word,DN_Type											; define it as a word
		words.pad {PR_Line,n_StartDN_Name,n_LengthDN_Name},DN_Name			; move it into the DN_Name table
		$Call X_3_PutXtable													; write the table item

		words.copy c_Integer,DN_Type										; define it as an integer
		words.pad {w_UBuffer,n_StartDN_Name,n_LengthDN_Name},DN_Name		; move it into the DN_Name table
		integers.add n_LengthDN_Name,1										; skip to the end of it
		words.copy '_HANDLE',{DN_Name,n_LengthDN_Name}						; and append _HANDLE
		$Call X_3_PutXtable													; write the table item

	end.if

;	---------------- 
;	CREATE RECORD_NO
;	----------------
	if DN_Type,=,c_Record

		integers.add J,11													; move past the macro name
		mExtractText J,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name		; Extract the record name

		words.copy c_Integer,DN_Type										; define it as an integer
		words.pad {PR_Line,n_StartDN_Name,n_LengthDN_Name},DN_Name			; move it into the DN_Name table
		integers.add n_LengthDN_Name,1										; skip to the end of it
		words.copy '_NO',{DN_Name,n_LengthDN_Name}							; and append _NO

		$Call X_3_PutXtable													; write the table item
		
	end.if	

;	-------------------
;	CREATE TABLE FIELDS
;	-------------------
	if DN_Type,=,c_XTable

		integers.add J,12													; move past the macro name
		mExtractText J,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name,','	; Extract the record name

		words.copy c_Integer,DN_Type										; define it as an integer		
		integers.calc L,=,K,-,I
		words.pad {PR_Line,n_StartDN_Name,n_LengthDN_Name},DN_Name			; move it into the DN_Name table
		integers.add n_LengthDN_Name,1										; skip to the end of it
		
		words.copy '_UBOUND',{DN_Name,n_LengthDN_Name}						; and append _UBOUND
		$Call X_3_PutXtable													; write the table item

	end.if

END.SUB B_1_3_2_StoreSystemDefinitions
;		EXIT

;-------------------------------------------------------------------------------
;		LOAD THE NEWDATATABLE WITH FIELD DEFINED IN A FUNCTION
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_4_Load_ND_Table

	integers.add I,15
	words.find {",",J},{w_UBuffer,I}
	integers.sub J,I
	words.pad {PR_Line,I,J},ND_FunctionName
					
	words.copy "N",ND_ReUsable
		
	words.pad x_Tab,ND_Entry
	words.find {":",I},w_UBuffer
	integers.add I,1
	integers.eq K,I
	words.find {"}",J},w_UBuffer
	integers.sub J,I
	words.pad {PR_Line,I,J},{ND_Entry,2}
 	
	words.find {"WORD:",I},w_UBuffer
	if I,>,0
		words.copy c_Word,ND_Type
		words.insert "insertword ",{ND_Entry,2}
	end.if
	
	words.find {"INTEGER:",I},w_UBuffer
	if I,>,0
		words.copy c_Integer,ND_Type
		words.insert "insertnumber ",{ND_Entry,2}		
	end.if

	words.find {"NUMBER:",I},w_UBuffer
	if I,>,0
		words.copy c_FixedPoint,ND_Type
		words.insert "insertnumber ",{ND_Entry,2}		
	end.if

;	Returns : K = Begin at, returns(I = start, J = length), ignore character
	mExtractText K,PR_CommandLength,I,J,','
	words.pad {PR_Line,I,J},ND_Name
	$Call X_9_NextNewDataSlot

;	----------------------------------------------------------------------------
;	ALSO NEED ENOUGH INFO LOADED INTO THE DATANAME TABLE SO IT CAN BE RECOGNISED
;	----------------------------------------------------------------------------
	words.pad spaces(1),DN_TableType
	words.pad spaces(1),DN_Table
	words.pad spaces(1),DN_Record
	integers.eq DN_No,0
	words.pad ND_Type,DN_Type
	words.pad ND_Name,DN_Name
	integers.eq DN_Length,0
	words.pad spaces(1),DN_Picture		
	$Call X_3_PutXtable

END.SUB B_1_4_Load_ND_Table


;-------------------------------------------------------------------------------
;		PROCESS BIND COMMAND
;-------------------------------------------------------------------------------
BEGIN.SUB B_1_5_ProcessBIND

	words.find {'.BIND',J},w_UBuffer									; detect a .bind
    if J,>,0															; and Process if not commented out

		integers.calc K,=,J,+,6											; move past .bind
		mExtractText K,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name,','	; grab Table Name
		words.pad {PR_Line,n_StartDN_Name,n_LengthDN_Name},w_SaveTableName
		integers.calc K,=,n_StartDN_Name,+,n_LengthDN_Name,+,1				; Move past the Table Name

		mExtractText K,PR_CommandLength,n_StartDN_Name,n_LengthDN_Name,','	; find the record name
		words.pad {PR_Line,n_StartDN_Name,n_LengthDN_Name},w_SaveRecordName

		integers.calc K,=,J,-,7											; Step back 7 to determine what type
		if {w_UBuffer,K,7},=,'XTABLES'									; of table it is
			words.copy 'X',w_SaveTableType
		else
			words.copy spaces(1),w_SaveTableType
		end.if

		integers.eq X_5_Idx,0											; Setup for reads
		$Call X_6_SearchByRecord										; and start it
		repeat.if DataNameTable_STATUS,=,0								; If status is zero we have a match	
			words.copy w_SaveTableType,DN_TableType						;	assign the Table type		
			words.pad w_SaveTableName,DN_Table							;	and assign the Table Name
			tables.rput DataNameTable,X_5_Idx							;	write it 
			$Call X_6_SearchByRecord									;	and grab the next one
		end.repeat

	end.if
		
END.SUB B_1_5_ProcessBIND
;	Exit

;*******************************************************************************
;		2ND PASS PROCESSING
;*******************************************************************************
begin.sub C_2ndPass

	repeat.for n_LineCtr,1,ProgramTable_UBOUND								; LOOP thru the Program Table

		xtables.rget ProgramTable,n_LineCtr									; Grab a record
		Words.uppercase PR_Line,w_UBuffer									; Grab an uppercase copy
if n_LineCtr,=,85
	integers.eq I,1
end.if
		
	;	--------------------------
	;	DETECT AND FLAG PROCEDURES
	;	--------------------------
		if b_Procedures,=,c_FALSE
			words.find {'BEGIN.INSTRUCTIONS',I},PR_Line
			if I,>,0 
				integers.eq b_Procedures,c_TRUE
			end.if
		end.if	
					
	;	-----------
	;	DO THE WORK
	;	-----------					
		if PR_Type,=,"L"
			$Call C_3_Translate
		end.if

	;	-------------------------------------
	;	REMOVE COMMENTS/BLANK LINES FOR DEBUG
	;	-------------------------------------
		.If b_Debug,=,c_TRUE												; If we are running for DEBUG
		.and b_Procedures,=,c_TRUE											; and we have hit BEGIN.INSTRUCTIONS
		.and PR_Line,=,"C"													; and we have a comment line
		.end																; END
  		  	words.copy "X",PR_Type											; Flag it as such
  	  	end.if

	end.repeat

;	-------------------
;	DISPLAY THE RESULTS
;	-------------------
	$Call C_4_DisplayResults
	
END.SUB C_2ndPass
;	EXIT

;=======================================================================
;		TRANSLATE EACHLINE
;=======================================================================
BEGIN.SUB C_3_Translate

;	----------------------
;	LANGUAGEONE DIRECTIVES
;	----------------------
	if C_3_0_ProcessedDirective												; If directive, then process it
		EXIT.SUB C_3_Translate												;	and exit
	end.if

;	------------------------------------------
;	PURELY FOR NEATNESS WHEN CREATING COMMANDS
;	------------------------------------------
	repeat.for n_CommandPosition,1,PR_LineLength							; REPEAT from the beginning to the end of the line
		if {PR_Line,n_CommandPosition,1},_NIN,{' ',x_Tab}					; to determine the start of command
			integers.eq exitRepeat,c_TRUE									; exit when found
		end.if																; END
	end.repeat																; END REPEAT

;	----------------------
;	reWRITER FUNCTIONALITY
;	----------------------
	$Call C_3_2_FixedPoint													; Alter fixed point numbers (Matrix/Procedure) 
;	$Call C_3_3_SetupCalc													; change A = B to integers/numbers/word .calc/.pad
	
;	----------------
;	CREATE MACRO's ?
;	----------------
	integers.eq b_CreatedMacro,c_FALSE										; Create macro to false	
	words.copy spaces(1),w_Quote											; Initialise w_Quote
	repeat.for I,1,PR_CommandLength											; Search thru the line
		mCheckQuotes (I)													; Check for quotes
	   .if   w_Quote,=,spaces(1)											; If it is not quoted
	   .and {PR_Line,I,1},=,'['												; and we have found the open bracket
	   .end																	; END
			integers.eq exitRepeat,c_TRUE									; so exit loop
		end.if																; END	
	end.repeat																; END
	
	if I,<,PR_CommandLength													; It is not quoted
		$Call C_3_1_CreateMacro												; Create the Macro
	else																	; ELSE
		$Call C_3_3_SetupCalc												; change A = B to integers/numbers/word .calc/.pad
		$Call C_3_4_addCommas												; Now add the commas
	end.if																	; END

;	---------------
;	reWrite PR_Line
;	---------------
	if PR_CommandLength,>,PR_LineLength
		integers.eq PR_LineLength,PR_CommandLength
	end.if
	xtables.rput ProgramTable,n_LineCtr	
	words.uppercase PR_Line,w_UBuffer

;	----------------
;	Gather the stats
;	----------------
	$Call C_3_5_GetStats													; get stats

END.SUB C_3_Translate
;	EXIT

;-----------------------------------------------------------------------
;	DIRECTIVES
;-----------------------------------------------------------------------
BEGIN.FUNCTION C_3_0_ProcessedDirective

;	---------------------------
;	Fixed Point Default Picture
;	---------------------------
	words.find {'%FP_DEFAULTPICTURE',L},w_UBuffer
	if L,>,0	

		Integers.eq RETURN_CODE,c_TRUE
		integers.eq J,0														; Init our start point
		integers.eq K,0														; Init our end point
		words.copy spaces(1),w_Quote										; and init quote flag

		repeat.for I,L,PR_CommandLength										; So run thru the text
												
			mCheckQuotes (I)												; check for quotes
			If w_Quote,!=,spaces(1)											; If quote found
				if J,=,0													;	If its the 1st one
					Integers.eq J,I											;		save its position
					words.copy spaces(1),w_Quote							;		force the quote routine
				else														;	Else
					Integers.eq K,I											;		save the 2nd ones position
					integers.eq exitRepeat,c_TRUE
				end.if								
			end.if

		end.repeat

		integers.calc L,=,K,-,J,+,1											; Calculate No Of Bytes
		words.pad {w_UBuffer,J,L},w_FP_Picture								; and store the picture

		words.copy ";",PR_Line												; Comment the Line
		words.copy "C",PR_Type												; mark it as a comment
		xtables.rPut ProgramTable,n_LineCtr									; and rewrite it

	end.if

END.FUNCTION C_3_0_ProcessedDirective

;*******************************************************************************
;		COMPONENT 1 OF THE REWRITE PROCESS
;*******************************************************************************
;===============================================================================
;		CREATE MACROS
;===============================================================================
BEGIN.SUB C_3_1_CreateMacro

;	Designed to allow bracketing in an integer/FP calculation
;	ie. integers.calc I = [3 * [n_Ctr + 3]] + [2 * [n_Ctr + 5]]
;	Note the use of square brackets rather than curved brackets
;	 will create temporary integers/FPs, the macro itself
;	and will modify the procedure adding in the macro
;	A 2nd pass is made so that the created code may be inserted
;	into the source

;	Table element handling is also done using macro's. 
;	More common 'element[subscript]' coding is modified to produce the FGET
;	and FPUT system calls 
;
;	And introduced Functions handling in V2.09
;
	[section .data]
		insertnumber	b_AnyMacros,		c_FALSE
		insertnumber	b_CreatedMacro,		c_FALSE
		insertnumber	b_TableElement,		c_FALSE
		insertnumber	n_ElementNo,		0

		insertnumber	n_MacroNo,			000,'999'
		insertword		w_MacroName,		007,'m999 ; '
	;	C_3_1_3_RecurseThruLine
		insertnumber	OB_OpenBracketDepth,000
		insertnumber	n_CharPos,			000
	[section .text]

;	-------------
;	DO WE WANT IT
;	-------------
	.if b_Procedures,=,c_FALSE												; Only want stuff in the procedures
	.or b_Assembler,=,c_TRUE												; and dont want assembler stuff
	.or b_Macro,=,c_TRUE													; or stuff in a macro
	.end
		EXIT.SUB C_3_1_CreateMacro
	else

		integers.eq n_CharPos,I												; Save I (OpenBracket position)

	;	------------------------------
	;	DONT WANT [section .data/text]
	;	------------------------------
		words.find {'SECTION',I},w_UBuffer									; Also dont want [section .data]/[section .text]
		if I,>,0
			EXIT.SUB C_3_1_CreateMacro   
		end.if

	end.if

;	-------------
;	FIXED POINT ?
;	-------------
	words.copy c_Integer,w_DataType											; Initialise flag to integer
	words.find {'.',I},{PR_Line,n_CharPos}									; need to know if its fixed point
	if I,>,0																; If its a literal
		words.copy c_FixedPoint,w_DataType									; set the flag
	else																	; else
		$Call C_3_1_1_CheckMatrix											; we need to check Matrix fields
	end.if																	; END

;	-----------
;	AND INITIAL
;	-----------
	integers.add n_MacroNo,1												; and increment the macro no

;	--------------------------------------
;	CLEAR THE REUSE FLAG IN NEW DATA TABLE
;	--------------------------------------
	integers.eq I,1															; Start at the beginning
	xtables.rget NewDataTable,I												; and grab the record
	repeat.while NewDataTable_STATUS,=,0									; LOOP until end of records
		if ND_Type,!=,spaces(1)												; if record exists
			words.copy spaces(1),ND_ReUsable								; space out the reusable flag
			xtables.rput NewDataTable,I										; and rewrite the record
			integers.add I,1												; increment the record number
			xtables.rget NewDataTable,I										; and grab the next record
		else																; else
			integers.eq exitRepeat,c_TRUE									; exit
		end.if																; END
	end.repeat																; END

;	-----------------
;	RECURSE THRU LINE
;	-----------------
	words.copy spaces(1),w_Quote											; Clear quotes
	integers.eq n_CharPos,0													; Char position to zero
	integers.eq OB_OpenBracketDepth,0										; Set recursion depth to zero
	words.pad spaces(1),w_Last_MacroLineItem								; Used for last line if table access
	integers.eq n_ElementNo,0												; Initialise the Table Elements per line
	$Call C_3_1_3_RecurseThruLine											; and recurse your way thru the line
	if n_NoOfOpenSQBrackets,!=,n_NoOfCloseSQBrackets						; Error if brackets are not equal
		files.write STDOUT,"06: Square brackets are not balanced on line no=",n_LineCtr
		TERMINATE 5
	end.if

;	----------------------------------------
;	NOW ADD THE ORIGINAL LINE INTO THE MACRO
;	----------------------------------------
	$Call C_3_1_4_OriginalLine

;	----------------------------------
;	ALTER COMMAND TO MACRO IF REQUIRED
;	----------------------------------	
	if  b_CreatedMacro,=,c_TRUE												; This will insert the macro name into the
		words.copy n_MacroNo,{w_MacroName,2}								; procedure and comment the original code
		words.copy n_MacroNo,{w_mLine1,9}
		words.insert w_MacroName,{w_UBuffer,n_CommandPosition}
		words.copy w_UBuffer,PR_Line
		integers.add PR_CommandLength,7										; Adjust the length
		words.copy "M",PR_Type												; and mark it as a macro
		integers.eq PR_LineLength,PR_CommandLength
	end.if

END.SUB C_3_1_CreateMacro
;	EXIT

;-----------------------------------------------------------------------
;   Check Matrix for Fixed Point Numbers
;-----------------------------------------------------------------------
BEGIN.SUB C_3_1_1_CheckMatrix

;	----------
;	INITIALISE
;	----------
	words.pad spaces(1),w_Temp30											; Initialise FP name
	integers.eq J,0															; Initialise FP name position 
	integers.add n_CharPos,1												; Skip over 1st open bracket

;	-------
;	PROCESS
;	-------
	repeat.for I,n_CharPos,PR_CommandLength									; Now run thru the line

		if {PR_Line,I,1},!=,'['												; Skip all nested open brackets
		
			if {PR_Line,I,1},_NIN,{' ','+','-','*','/',']'}					; If it aint one of these

				integers.add J,1											; then move to next destination position				
				words.copy {PR_Line,I,1},{w_Temp30,J}						; and start building the matrix name

			else															; ELSE

				if J,>,0													; Have we found a name

					$Call X_5_SearchByName									; Search for it
				   .if DataNameTable_STATUS,=,0								; and if we find it
				  .and DN_Type,=,c_FixedPoint								; and its a fixed point number
				  .end

						words.copy DN_Type,w_DataType						; then we flag it
						integers.eq exitRepeat,c_TRUE						; exit the loop

					else													; ELSE

						words.pad spaces(1),w_Temp30						; reset save area
						integers.eq J,0										; and position

					end.if													; END
				end.if														; END
			end.if															; END
		end.if																; END
	end.repeat																; END

END.SUB C_3_1_1_CheckMatrix

;-----------------------------------------------------------------------
;   Recurse thru line
;-----------------------------------------------------------------------
BEGIN.SUB C_3_1_3_RecurseThruLine

	repeat.while 1,=,1																; Start of Loop

		integers.add n_CharPos,1											; Move along 1 character
		if n_CharPos,>,PR_CommandLength										; and exit if we are at the end
			EXIT.REPEAT														; EXIT
		end.if																; END	

		mCheckQuotes (n_CharPos)											; Check for quotes
		if w_Quote,=,spaces(1)												; If none

			if	{PR_Line,n_CharPos,1},=,'['									; Okay so we have found an open bracket

				integers.add n_NoOfOpenSQBrackets,1							; Count the bracket to report msimatching
				integers.add OB_OpenBracketDepth,1							; Add to the recursion depth
				integers.eq OB_OpenBracket,n_CharPos						; and push the saved variables
				tables.rput OpenBracketTable,OB_OpenBracketDepth			; by writing it to the table

				$call C_3_1_3_RecurseThruLine								; and call yourself (recurse)

			end.if															; END

			if	{PR_Line,n_CharPos,1},=,']'									; Okay so we have found a close bracket

				integers.add n_NoOfCloseSQBrackets,1						; Count the bracket to report msimatching
				$Call C_3_1_3_1_BuildIt										; Go and build the macro
	
				integers.sub OB_OpenBracketDepth,1							; Subtract from the recursion depth	
				tables.rget OpenBracketTable,OB_OpenBracketDepth			; and pop the saved variables
				if OB_OpenBracketDepth,>,1									; If we are not the 1st time
					integers.eq n_CharPos,OB_OpenBracket					; then restore saved variables
				end.if														; END
			
			end.if															; END

		end.if																; END

	end.repeat																; END

END.SUB C_3_1_3_RecurseThruLine
;	EXIT

;-----------------------------------------------------------------------
;   and Build It
;-----------------------------------------------------------------------
BEGIN.SUB C_3_1_3_1_BuildIt

	integers.eq b_CreatedMacro,c_TRUE										; set our created flag to true
	integers.eq b_AnyMacros,c_TRUE											; And set our ANY flag to true
	integers.eq b_TableElement,c_FALSE										; Table Element to false

;	------------------------
;	V2.09 - Is it a function
;	------------------------
	if  C_3_1_3_1_0_f_Function												; Do it if its a function
		EXIT.SUB C_3_1_3_1_BuildIt
	end.if
	
;	---------------------
;	IS IT A TABLE ELEMENT
;	---------------------
	if C_3_1_3_1_1_f_TableElement											; Do it if its a table element
		EXIT.SUB C_3_1_3_1_BuildIt
	end.if
	
;	-------------------------------
;	CREATE OR REUSE THE TEMP NUMBER
;	-------------------------------
	$Call X_8_NewData														; Get a data item you can use	

;	----------------------
;	CREATE THE CALCULATION
;	----------------------
	if w_DataType,=,c_FixedPoint											; If its a fixed point number
		words.pad  'NUMBERS.CALC',MR_MacroLineItem							; begin with the .calc statement
		integers.add PR_CommandLength,13									; increase the command length
	else																	; ELSE
		words.pad  'INTEGERS.CALC',MR_MacroLineItem							; begin with the .calc statement
		integers.add PR_CommandLength,14									; increase the command length	
	end.if																	; END
	words.copy {ND_Entry,15,5},{MR_MacroLineItem,15}						; insert the temporary data name
	words.copy ',=,',{MR_MacroLineItem,20}									; insert the comma/equals/comma

	
	integers.calc I,=,OB_OpenBracket,+,1									; Calculate the size of the command
;	--------------------------------------------------
;	Tries to solve the problem of getting 2 commas ???
	repeat.for I,I,124														; Try to skip any leading spaces
		if {PR_Line,I,1},_NIN,{" ",x_Tab}
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat
;	--------------------------------------------------
	integers.calc J,=,n_CharPos,-,1		
	integers.calc K,=,J,-,I,+,1
	
	words.copy {PR_Line,I,K},{MR_MacroLineItem,23}							; and insert it into the line
	integers.eq MR_MacroNo,n_MacroNo										; store the macro no for later

;	--------
;	Write it
;	--------
	$Call X_10_NextTextSlot													; next table slot

;	-------------------------------------------------------
;	AND INSERT THE NEW INTEGER/FP INTO THE ORIGINAL COMMAND
;	-------------------------------------------------------
	repeat.for I,OB_OpenBracket,n_CharPos									; Clear the space required
		words.copy spaces(1),{PR_Line,I}									; over right with spaces									
	end.repeat																; END
	words.copy {ND_Entry,15,5},{PR_Line,OB_OpenBracket}						; insert the temporary name

END.SUB C_3_1_3_1_BuildIt	
;	EXIT

;-----------------------------------------------------------------------
;   Manipulate the code for functions
;----------------------------------------------------------------------
BEGIN.FUNCTION C_3_1_3_1_0_f_Function

	[section .data]
		insertnumber n_Idx,0
	[section .text]
	
	integers.eq n_Idx,1														; Start the table at 1
	xtables.rget NewDataTable,n_Idx											; and grab the record
	repeat.while NewDataTable_STATUS,=,0									; LOOP until end of records

		if ND_FunctionName,!=,spaces(1)
	
		;	-------------------------------------------------------------------------------
		;	Find works on exact matches and sees trailing spaces as significant to the find
		;	so we determine the length of the word in ND_FunctionName and reset the length
		;	of w_Temp to the actual no of characters before moving ND_FunctionName to w_Temp. 
		;	We can then use w_Temp in the find call
	
			repeat.for I,64,1
				if {ND_FunctionName,I,1},!=,spaces(1)
					integers.eq exitRepeat,c_TRUE
				end.if
			end.repeat

			begin.assembler
				push qword[I]
				pop  qword[w_Temp-8]
				end.assembler
			words.pad ND_FunctionName,w_Temp
	;	-------------------------------------------------------------------------------
	
			words.find {w_Temp,I},PR_Line
			if I,>,0
				integers.eq MR_MacroNo,n_MacroNo

				integers.calc I,=,OB_OpenBracket,+,1				
			;	-------------------------------------------------------------
			;	Tries to solve the problem of spaces following an open bracket	
			;	This is the same code as above in C_3_1_3_1_BuildIt
			;	not really worth a sub routine
				repeat.for I,I,124											; Try to skip any leading spaces
					if {PR_Line,I,1},_NIN,{" ",x_Tab}
						integers.eq exitRepeat,c_TRUE
					end.if
				end.repeat
			;	--------------------------------------------------				
				integers.calc J,=,n_CharPos,-,1		
				integers.calc K,=,J,-,I,+,1
				
				words.pad {PR_Line,I,K},MR_MacroLineItem					; and insert it into the line
				
				integers.eq RETURN_CODE,c_TRUE		
				$Call X_10_NextTextSlot
		
				repeat.for J,OB_OpenBracket,n_CharPos						; Clear the space required
					words.copy spaces(1),{PR_Line,J}									
				end.repeat
				words.copy ND_Name,{PR_Line,OB_OpenBracket}					; insert the temporary name		

				exit.function C_3_1_3_1_0_f_Function
			
			end.if

		end.if
				
		integers.add n_Idx,1												; increment the record number
		xtables.rget NewDataTable,n_Idx										; and grab the record
		
	end.repeat

END.FUNCTION C_3_1_3_1_0_f_Function

;-----------------------------------------------------------------------
;   Process Table Elements
;----------------------------------------------------------------------
BEGIN.FUNCTION C_3_1_3_1_1_f_TableElement

	[section .data]
		insertnumber 	n_StartElementName,			000
		insertnumber 	n_ElementLength,			000
		insertnumber	n_NDIdx,					000	
		insertnumber 	n_TextIdx,					000
		insertnumber	n_HighestNDNo,				000
		insertnumber	n_NDNo,						000,'9999'
		insertword		w_Last_MacroLineItem,		124,''
		insertnumber	n_GetPut,					000

	[section .text]

;	----------------------------------
;	DOES IT HAVE A MATHEMATICAL SYMBOL
;	----------------------------------
	repeat.for I,n_CharPos,OB_OpenBracket									; Now work from the ] to the [
		if {PR_Line,I,1},_IN,{'+','-','*','/'}								; If we find a mathematical symbol
			EXIT.FUNCTION C_3_1_3_1_1_f_TableElement						;	exit routine
		end.if
	end.repeat

;	---------------------------------
;	GET THE START OF THE ELEMENT NAME										; Working backwards from the open bracket
;	---------------------------------
	integers.calc I,=,OB_OpenBracket,-,1
	if I,>,1
		repeat.for n_StartElementName,I,1
			if {PR_Line,n_StartElementName,1},_IN,{' ',x_Tab,'[',',','{'}
				integers.eq exitRepeat,c_TRUE
			end.if
		end.repeat
		integers.add n_StartElementName,1
	else
		integers.eq n_StartElementName,1
	end.if

;	---------------------------------
;	IT SHOULD BE IN THE DATANAMETABLE
;	---------------------------------
	integers.calc n_ElementLength,=,OB_OpenBracket,-,n_StartElementName		; Stick the dataname into w_Temp30 and 
	words.pad {PR_Line,n_StartElementName,n_ElementLength},w_Temp30			; dont change it cuz called routines use it
	$Call X_5_SearchByName													; and look for it
	words.copy DN_Type,w_DataType

;	----------------------
;	OKAY - we are doing it
;	----------------------
	Integers.eq RETURN_CODE,c_TRUE											; set function to true
	Integers.eq b_TableElement,c_TRUE										; set table element to true
	integers.add n_ElementNo,1												; increment element no
	integers.eq MR_MacroNo,n_MacroNo										; store the macro no for later

;	----------
;	GET or PUT
;	----------
	$Call C_3_1_3_1_1_1_GetOrPut 												; Sort out if we are getting/putting or both
	$Call C_3_1_3_1_1_2_InsertElement 										; replace the X[1] with the new field

	integers.eq RETURN_CODE,c_TRUE
	
END.FUNCTION C_3_1_3_1_1_f_TableElement
;	EXIT

;----------------------------------------------------------------------
;   Get Or Put
;----------------------------------------------------------------------
BEGIN.SUB C_3_1_3_1_1_1_GetOrPut

;	--------------
;	Decisions code
;	--------------  
	if C_3_1_3_1_1_1_0_f_Decisions											; test for code being a decision
		$Call C_3_1_3_1_1_1_2_Get												; create the required FGET
		EXIT.SUB C_3_1_3_1_1_1_GetOrPut										; and we are done 
	end.if

;	-----------------------
;	Assignments or Keywords
;	-----------------------
	words.find {'=',n_GetPut},PR_Line										; Test for equals, as in A = B[1]
	if n_GetPut,>,0															; If we find one
		if n_StartElementName,>,n_GetPut									;	are we processing the left or the right
			$Call C_3_1_3_1_1_1_2_Get											;	An FGET for the right
		else
			$Call C_3_1_3_1_1_1_3_Put											;	An FPUT for the left
		end.if
	else																	; ELSE
		$Call C_3_1_3_1_1_1_1_Keywords										;	process keywords (like ACCEPT X[1])
	end.if		

END.SUB C_3_1_3_1_1_1_GetOrPut

;-----------------------------------------------------------------------
;   Test for a decision within the equals
;----------------------------------------------------------------------
BEGIN.FUNCTION C_3_1_3_1_1_1_0_f_Decisions

;	-------------------------------------------
;	LOOP THRU CODE and test for a Decision word
;	-------------------------------------------
	words.copy spaces(1),w_Quote											; Initialise w_Quote

	repeat.for I,1,PR_CommandLength

		mCheckQuotes (I)

		if w_Quote,=,spaces(1)

		   .if {w_UBuffer,I,2},=,'IF'
		   .or {w_UBuffer,I,3},=,'.OR'
		   .or {w_UBuffer,I,4},=,'.AND'
		   .or {w_UBuffer,I,4},=,'.TEST'
		   .or {w_UBuffer,I,4},=,'WHEN '
		  .end	
				integers.eq RETURN_CODE,c_TRUE
			end.if

		end.if

	end.repeat

END.FUNCTION C_3_1_3_1_1_1_0_f_Decisions

;-----------------------------------------------------------------------
;   Identify Keywords
;----------------------------------------------------------------------
BEGIN.SUB C_3_1_3_1_1_1_1_Keywords

;	This routine will look for keywords and perform the appropriate
;	FGET/FPUT 

;	---------------------------
;	CURSOR/DISPLAY - SIMPLE GET
;	---------------------------
	words.find {'CURSOR',n_GetPut},w_UBuffer
	if n_GetPut,=,0
		words.find {'DISPLAY',n_GetPut},w_UBuffer
	end.if
	if n_GetPut,>,0
		$Call C_3_1_3_1_1_1_2_Get
		EXIT.SUB C_3_1_3_1_1_1_1_Keywords		
	end.if

;	-------------------
;	ACCEPT - SIMPLE PUT
;	-------------------
	words.find {'ACCEPT',n_GetPut},w_UBuffer
	if n_GetPut,>,0
		$Call C_3_1_3_1_1_1_3_Put
		EXIT.SUB C_3_1_3_1_1_1_1_Keywords		
	end.if

;	----------------
;	INTEGERS/NUMBERS
;	----------------
;	1st time thru, then we are working on the left. We do and GET to grab the 
;	receiving field and then do the last PUT using the same field
	words.find {'INTEGERS',n_GetPut},w_UBuffer
	if n_GetPut,=,0
		words.find {'NUMBERS',n_GetPut},w_UBuffer
	end.if
	if n_GetPut,>,0
		$Call C_3_1_3_1_1_1_2_Get
		if n_ElementNo,=,1
			words.copy {MR_MacroLineItem,52,30},w_Temp30					; Put uses w_Temp30
			$Call C_3_1_3_1_1_1_3_Put
		end.if
		EXIT.SUB C_3_1_3_1_1_1_1_Keywords	
	end.if

;	-----
;	DATES
;	-----
	words.find {'DATE.',n_GetPut},w_UBuffer
	if n_GetPut,>,0
		if n_ElementNo,=,1
			$Call C_3_1_3_1_1_1_3_Put
		else
			$Call C_3_1_3_1_1_1_2_Get
		end.if
		EXIT.SUB C_3_1_3_1_1_1_1_Keywords	
	end.if

;	---
;	WWW
;	---
	words.find {'WWW',n_GetPut},w_UBuffer
	if n_GetPut,>,0
		words.find {'PROCESS',n_GetPut},w_UBuffer
		if n_GetPut,>,0
			$Call C_3_1_3_1_1_1_3_Put
		else
			$Call C_3_1_3_1_1_1_2_Get
		end.if
		EXIT.SUB C_3_1_3_1_1_1_1_Keywords
	end.if

;	---------
;	TERMINATE
;	---------
	words.find {'TERMINATE',n_GetPut},w_UBuffer
	if n_GetPut,>,0
		$Call C_3_1_3_1_1_1_2_Get
		EXIT.SUB C_3_1_3_1_1_1_1_Keywords
	end.if

;	-----
;	WORDS
;	-----
;	NOTE:- Because the [] routines were written before the Table stuff, we default
;	to working right to left (for numbers). Here, we reverse that by use of 
;	n_ElementNo because WORDS IS WORKNG LEFT TO RIGHT.
;	NOTE:- With only a single field (WORDS.UPPERCASE w_Alpha) we can do a simple
;	GET and PUT 

	[section .data]
		insertnumber n_Comma1,0
		insertnumber n_Comma2,0

	[section .text]

;	-------------------
;	GET COMMA POSITIONS
;	-------------------
	integers.eq n_Comma1,0
	integers.eq n_Comma2,0
	words.find {'WORDS',n_GetPut},w_UBuffer

	if n_GetPut,>,0
		repeat.for I,1,PR_CommandLength
			if {w_UBuffer,I,1},=,';'
				integers.eq exitRepeat,c_TRUE
			else

				if {w_UBuffer,I,1},=,'{'
					repeat.if {w_UBuffer,I,1},!=,'}'
						integers.add I,1
					end.repeat
				end.if

				if {w_UBuffer,I,1},=,','
					if n_Comma1,=,0
						integers.eq n_Comma1,I
					else
						integers.eq n_Comma2,I
					end.if
				end.if

			end.if
		end.repeat
	end.if

;	If NO comma we are dealing with a single field (Usually UPPER/LOWERCASE
	if n_Comma1,=,0										
		$Call C_3_1_3_1_1_1_2_Get
		$Call C_3_1_3_1_1_1_3_Put
		EXIT.SUB C_3_1_3_1_1_1_GetOrPut
	end.if

;	If we are on the left of the 1st comma always do a get
	if n_StartElementName,<,n_Comma1
		integers.eq n_ElementNo,2										; reverse cuz words works left to right
		$Call C_3_1_3_1_1_1_2_Get
		EXIT.SUB C_3_1_3_1_1_1_GetOrPut
	end.if

;	If not then do a PUT
	if n_Comma2,=,0
		integers.eq n_ElementNo,1
		$Call C_3_1_3_1_1_1_3_Put											; reverse cuz words works left to right
		EXIT.SUB C_3_1_3_1_1_1_GetOrPut
	end.if

;	Process a Find
	words.find {'.FIND',I},w_UBuffer
	if I,>,0

	   .if n_StartElementName,>,n_Comma1
	  .and n_StartElementName,<,n_Comma2
	  .end
			integers.eq n_ElementNo,1									; reverse cuz words works left to right
			$Call C_3_1_3_1_1_1_3_Put
			EXIT.SUB C_3_1_3_1_1_1_GetOrPut		
		end.if

		if n_StartElementName,>,n_Comma2
			integers.eq n_ElementNo,2									; reverse cuz words works left to right
			$Call C_3_1_3_1_1_1_2_Get
		end.if

	end.if

;	Process a Replace
	words.find {'.REPLACE',I},w_UBuffer
	if I,>,0

	   .if n_StartElementName,>,n_Comma1
	  .and n_StartElementName,<,n_Comma2
	  .end
			integers.eq n_ElementNo,2									; reverse cuz words works left to right
			$Call C_3_1_3_1_1_1_2_Get
			EXIT.SUB C_3_1_3_1_1_1_GetOrPut		
		end.if

		if n_StartElementName,>,n_Comma2
			integers.eq n_ElementNo,2									; reverse cuz words works left to right
			$Call C_3_1_3_1_1_1_2_Get
			integers.eq n_ElementNo,1									; reverse cuz words works left to right
			$Call C_3_1_3_1_1_1_3_Put
		end.if

	end.if

END.SUB C_3_1_3_1_1_1_1_Keywords
;	EXIT
 
;-----------------------------------------------------------------------
;   Formt a GET request
;----------------------------------------------------------------------
BEGIN.SUB C_3_1_3_1_1_1_2_Get

	if DN_TableType,=,'X'
		words.pad 'XTABLES.fget ',MR_MacroLineItem
	else
		words.pad  'TABLES.fget ',MR_MacroLineItem
	end.if

	words.copy DN_Table,{MR_MacroLineItem,15}
	words.copy ',',{MR_MacroLineItem,46}
	words.copy DN_No,{MR_MacroLineItem,47}
	words.copy ',',{MR_MacroLineItem,51}
	words.copy DN_Type,w_DataType

	if 	n_ElementNo,>,1
		$Call X_8_NewData
		words.copy {ND_Entry,15,5},{MR_MacroLineItem,52}
	else
		words.copy DN_Name,{MR_MacroLineItem,52}
	end.if

	words.copy ',',{MR_MacroLineItem,84}

	integers.calc I,=,OB_OpenBracket,+,1
	integers.calc J,=,n_CharPos,-,OB_OpenBracket,-,1
	words.copy {PR_Line,I,J},{MR_MacroLineItem,85}

	$Call X_10_NextTextSlot	

END.SUB C_3_1_3_1_1_1_2_Get
;	EXIT

;-----------------------------------------------------------------------
;   Format a PUT request
;----------------------------------------------------------------------
BEGIN.SUB C_3_1_3_1_1_1_3_Put

;	--------
;	BUILD IT
;	--------
	if DN_TableType,=,'X'
		words.pad 'XTABLES.fput ',MR_MacroLineItem
	else
		words.pad  'TABLES.fput ',MR_MacroLineItem
	end.if

	words.copy DN_Table,{MR_MacroLineItem,15}
	words.copy ',',{MR_MacroLineItem,46}
	words.copy DN_No,{MR_MacroLineItem,47}
	words.copy ',',{MR_MacroLineItem,51}

	words.copy w_Temp30,{MR_MacroLineItem,52}
	repeat.for I,124,1
		if {MR_MacroLineItem,I,1},!=,spaces(1)
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat
	integers.add I,1
	words.copy ',',{MR_MacroLineItem,I}
	integers.add I,1

	integers.calc J,=,OB_OpenBracket,+,1
	integers.calc K,=,n_CharPos,-,OB_OpenBracket,-,1
	words.copy {PR_Line,J,K},{MR_MacroLineItem,I}

	words.copy MR_MacroLineItem,w_Last_MacroLineItem

;	-----------------------
;	Now clear the subscript
;	-----------------------
	integers.calc I,=,n_CharPos,-,OB_OpenBracket,-1
	words.copy spaces(I),{PR_Line,OB_OpenBracket}

END.SUB C_3_1_3_1_1_1_3_Put
;	EXIT

;-----------------------------------------------------------------------
;   Get Element
;----------------------------------------------------------------------
BEGIN.SUB C_3_1_3_1_1_2_InsertElement

	integers.calc I,=,n_CharPos,-,n_StartElementName,+,1					; Amount to clear
	if I,=,4																; 4 is the shortest it can be
		words.insert spaces(1),{PR_Line,n_StartElementName}				;	so push it over 1
		integers.add PR_CommandLength,1											;	and add to the end of text
	else
		words.copy spaces(I),{PR_Line,n_StartElementName}					; Clear the field
	end.if

	if 	n_ElementNo,>,1
		words.copy {ND_Entry,15,5},{PR_Line,n_StartElementName}
	else
		words.copy {DN_Name,1,I},{PR_Line,n_StartElementName}
	end.if

END.SUB C_3_1_3_1_1_2_InsertElement
;	EXIT

;-----------------------------------------------------------------------
;   Massage and write the original line into the macro
;-----------------------------------------------------------------------
BEGIN.SUB C_3_1_4_OriginalLine

;	-----------------------
;	1st setup for A = B etc
;	-----------------------
	$Call C_3_3_SetupCalc
	
;	----------------
;	Massage the line
;	----------------	
	words.copy {PR_Line,n_CommandPosition},MR_MacroLineItem					; Ready to write item
	words.find {";",I},MR_MacroLineItem										; Check for trailing comments
	if I,>,0																; If there are any
		words.pad spaces(1),{MR_MacroLineItem,I}							; remove thenm (cuz they are ugly)
	end.if																	; END

;	---------------------
;	Write it to the table
;	---------------------
	integers.eq MR_MacroNo,n_MacroNo										; Identify the macro
	$Call X_10_NextTextSlot													; next table slot

;	----------------------------------
;	A FINAL TABLE fput MAY BE REQUIRED
;	----------------------------------
	if {w_Last_MacroLineItem,1,1},!=,spaces(1)								; Do I have an entry
		integers.eq MR_MacroNo,n_MacroNo									; Identify the macro
		words.copy w_Last_MacroLineItem,MR_MacroLineItem					; Insert the last line
		$Call X_10_NextTextSlot												; next table slot		
	end.if

END.SUB C_3_1_4_OriginalLine
;	EXIT


;*******************************************************************************
;		COMPONENT 3 OF THE REWRITE PROCESS
;*******************************************************************************
;===============================================================================
;		alter fixed point stuff
;===============================================================================
BEGIN.SUB C_3_2_FixedPoint

	words.find {'INSERTNUMBER',J},w_UBuffer									; locate insertnumber
	if J,>,0																; IF found
		$Call C_3_2_1_FP_inMatrix											;	do the work
	end.if

	if b_Procedures,=,c_TRUE												; IF we are in the procedures
		if b_Assembler,=,c_FALSE											; AND Not in assembler
			$Call C_3_2_2_FP_inProcedure									; do the work
		end.if		
	end.if

END.SUB C_3_2_FixedPoint
;	EXIT

;-----------------------------------------------------------------------
;	Fixed In Matrix
;-----------------------------------------------------------------------
BEGIN.SUB C_3_2_1_FP_inMatrix
;	When nasm sees a number with a decimal place it initialises the qword
;	in floating point representation. As languageONE only works with fixed
;	point values, the number must be adjusted to suit the given picture
;		ie.  1.23,'99.9999' as adjusted to
;			12300,'99.9999'

	[section .data]
		insertnumber n_FixedPoint,	0
		insertnumber n_StartLit,	0
		insertnumber n_endLit,		0,'999'
		insertnumber n_picPlaces,	0,'999'
	[section .text]

	words.find {',',n_StartLit},PR_Line										; Grab the first comma
	integers.add n_StartLit,1												; step over it

;	Fixed Point (either Literal or Picture)
	words.find {'.',n_FixedPoint},{PR_Line,n_StartLit}						; Are we dealing with a Fixed Point No
	if n_FixedPoint,=,0														; If yes
		EXIT.SUB C_3_2_1_FP_inMatrix										; then exit
	end.if																	; END

	words.find {',',n_endLit},{PR_Line,n_StartLit}							; Grab the second comma

;	End program if no picture	
	if n_endLit,=,0
		if n_FixedPoint,>,0
			files $write,STDOUT,"04: Line No=",n_LineCtr," Fixed Point number must provide a picture"
			TERMINATE 4
		else
			EXIT.SUB C_3_2_1_FP_inMatrix
		end.if
	end.if
	
	integers.sub n_endLit,1													; Step back one

;	---------------------------------------	
;	Count the decimal places in the picture
;	---------------------------------------
	integers.eq n_picPlaces,0												; zero the places

	words.find {'.',I},{PR_Line,n_endLit}									; Look for decimal point in picture
	if I,>,0																; If ther is a decimal place in the picture	
		repeat.for I,I,PR_CommandLength										; loop from decimal place
		   .if {PR_Line,I,1},=,'9'											; IF its a 9
		   .or {PR_Line,I,1},=,'#'											; OR a hash
		  .end																; .end
				integers.add n_picPlaces,1									; then count it
			end.if															; END															
		end.repeat															; END REPEAT
	end.if																	; END

;	-----------------------------------------------
;	Count the numbers/decimal places in the literal
;	and build a new literal
;	-----------------------------------------------
	$Call C_3_2_X_BuildLiteral												; Build literal

;	Now correct the literal
	begin.test c_TRUE

		when n_litPlaces,<,n_picPlaces										; if we need to pad out the literal
			integers.sub n_picPlaces,n_litPlaces							;	how many zeroes	
			repeat.for I,1,n_picPlaces										;	loop that many times
				integers.add n_newLitlen,1									;		pad new literal
				words.copy '0',{w_newLit,n_newLitlen,1}						;		with zeroes		
			end.repeat
		wend

		when n_picPlaces,<,n_litPlaces										; if we need to truncate out the literal
			integers.sub n_litPlaces,n_picPlaces							;	how many numbers	
			repeat.for I,1,n_litPlaces										;	loop that many times
				words.copy spaces(1),{w_newLit,n_newLitlen,1}				;		pad new literal
				integers.sub n_newLitlen,1									;		with spaces
			end.repeat
		wend

	end.test

;	----------
;	And Insert
;	----------
	[section .data]
		insertnumber n_oldLitlen,	0,'999'
		insertnumber n_ofBytes,		0,'999'
	[section .text]

	integers.calc n_oldLitlen,=,n_endLit,-,n_StartLit,+,1					; Grab the old literal length

	if n_oldLitlen,<,n_newLitlen											; IF the new literal is bigger
		integers.calc n_ofBytes,=,n_newLitlen,-,n_oldLitlen					;	count by how much
		words.insert spaces(n_ofBytes),{PR_Line,n_StartLit}					;	and insert that many spaces
		integers.add PR_CommandLength,n_ofBytes								;	then lengthen the line
	end.if

	words.copy spaces(n_oldLitlen),{PR_Line,n_StartLit}						; Clear the original literal
	words.copy{w_newLit,1,n_newLitlen},{PR_Line,n_StartLit}					; and move in the new one

END.SUB C_3_2_1_FP_inMatrix
;	EXIT

;-----------------------------------------------------------------------
;		Fixed In Procedure
;-----------------------------------------------------------------------
BEGIN.SUB C_3_2_2_FP_inProcedure
;	languageONE macros require a fixed point number as a literal to be coded with
;	a picture over-ride. Not the best, so we will find all fixed point literal in
;	the procedures and 1) remove the decimal and 2] provide the picture

	[section .data]
		insertnumber n_dpPos,0
	[section .text]

;	-----------
;	AND PROCESS
;	-----------
	integers.eq n_dpPos,0
	words.copy spaces(1),w_Quote											; Initialise w_Quote

	repeat.for I,1,PR_CommandLength											; So run thru the buffer again

		mCheckQuotes (I)
		mCheckBraces (I)
	   .if w_Quote,=,spaces(1)												; We dont want anything quoted
	  .and w_Brace,=,spaces(1)												; and We dont want to change anything in braces
	  .end

			if {PR_Line,I,1},=,'.'											; So we have found one
				integers.eq n_dpPos,I										; so grab the position
										
				integers.calc J,=,n_dpPos,-,1								; Get left character
				if f_validAdjacentChar										; and check it

					integers.add J,2										; Get right character
					if f_validAdjacentChar									; and check it

						$Call C_3_2_2_1_FP_Expand							; Transform and add picture
						
					end.if
				end.if
			end.if
		end.if
	end.repeat

END.SUB C_3_2_2_FP_inProcedure
;	EXIT

;-----------------------------------------------------------------------
;	Valid Adjacent Character
;-----------------------------------------------------------------------
BEGIN.FUNCTION f_validAdjacentChar

   .if {PR_Line,J,1},_IN,{'0','1','2','3','4','5','6','7','8','9'}
   .or {PR_Line,J,1},_IN,{' ',',','-',x_Tab,x_LF}
  .end
		integers.eq RETURN_CODE,c_TRUE
	end.if

END.FUNCTION f_validAdjacentChar
;	EXIT

;------------------------------------------------------------------------
;		Insert the picture
;------------------------------------------------------------------------
BEGIN.SUB C_3_2_2_1_FP_Expand

;	--------------------
;	Get start of literal
;	--------------------
	repeat.for n_StartLit,n_dpPos,1											; Working backwards
		if {PR_Line,n_StartLit,1},_NIN,{'.','-','0','1','2','3','4','5','6','7','8','9'}
			integers.add n_StartLit,1										; locate the start of the literal
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat

;	------------------
;	Get end of literal
;	------------------	
	repeat.for n_endLit,n_dpPos,PR_CommandLength							; Working forwards
		if {PR_Line,n_endLit,1},_NIN,{'.','0','1','2','3','4','5','6','7','8','9'}
			integers.sub n_endLit,1											; locate the end of the literal
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat

	if n_endLit,>,PR_CommandLength											; IF we are at the end
		integers.eq n_endLit,PR_CommandLength								; reset to endof Literal
	end.if

;	------------------
;	Build new literal
;	------------------		
	$Call C_3_2_X_BuildLiteral												; Build the literal

;	-------------
;	Build picture - this runs from right to left
;	-------------
	[section .data]
		insertnumber n_bufPos,		0
		insertnumber n_DPFlag,		0
		insertword	 w_newPic,	   31,''
		insertnumber n_newPicPos,	0
		insertnumber n_numCtr,		0
		insertnumber n_newPos,		0
	[section .text]
		words.pad 	spaces(1),		w_newPic
		integers.eq n_DPFlag,		0
		integers.eq n_bufPos,		0
		integers.eq n_newPicPos,	0
		integers.eq n_numCtr,		0
		integers.eq n_newPos,		0

	words.copy "'}",{w_newPic,30}											; Setup tail of picture
	if {PR_Line,n_StartLit,1},=,"-"										; IF we have a sign
		integers.eq n_newPicPos,28											; 	Allow room for it
	else																	; ELSE
		integers.eq n_newPicPos,29											;	dont
	end.if

	repeat.for n_bufPos,n_endLit,n_StartLit									; Working from right to left

		if {PR_Line,n_bufPos,1},=,"-"										; IF it has a sign
			words.copy "-",{w_newPic,29}	  								;	then move one in
		else

			if {PR_Line,n_bufPos,1},=,"."									; IF we have hit the decimal place
				integers.eq n_DPFlag,1										;	flag it as so
				words.copy '.',{w_newPic,n_newPicPos}						;	move it in
				integers.sub n_newPicPos,1									;	take 1 step to the left
			else															; ELSE
				begin.test n_DPFlag											;	check the decimal place flag

					when =,0												; IF not found yet
						words.copy "9",{w_newPic,n_newPicPos}				;	then we use '9's
						integers.sub n_newPicPos,1							;	take 1 step to the left
					wend

					when =,1												; IF we initially found the decimal
						words.copy "9",{w_newPic,n_newPicPos}				;	we want the 1st number to show
						integers.sub n_newPicPos,1							;	take 1 step to the left
						integers.eq n_DPFlag,2								;	now we will do the left side of the decimal place
						integers.eq n_numCtr,1					
					wend

					when =,2												; IF working on the left side of the decimal place
						integers.add n_numCtr,1								;	count the number of digits
						if n_numCtr,=,4										;	IF we are up to 4 
							words.copy ",",{w_newPic,n_newPicPos}			;		then we are going to insert a comma
							integers.sub n_newPicPos,1						;		take 1 step to the left
							integers.eq  n_numCtr,1							;		and restart the digit count
						end.if				
						words.copy "#",{w_newPic,n_newPicPos}				;	Move in a hash
						integers.sub n_newPicPos,1							;	take 1 step to the left
					wend

				end.test
			end.if
		end.if
	end.repeat

	integers.sub n_newPicPos,1												; Setup the head of the picture	
	words.copy ",'",{w_newPic,n_newPicPos}

;	---------------
;	Expand the line
;	---------------
;	This works easily cuz - remove '.' then add '{' still the same length 
	integers.eq  n_newPos,n_StartLit										; So grab the destination position
	words.copy "{",{PR_Line,n_newPos}										; Enclose in braces
	integers.add n_newPos,1													; move along 1
	words.copy {w_newLit,1,n_newLitlen},{PR_Line,n_newPos}					; move in the new literal
	integers.add n_newPos,n_newLitlen										; add in the literal length	
	words.insert {w_newPic,n_newPicPos},{PR_Line,n_newPos}					; and insert the picture

	integers.calc PR_CommandLength,=,PR_CommandLength,+,31,-,n_newPicPos,+,1; Now increase the length of the text		
	integers.calc I,=,n_newPos,+,31,-,n_newPicPos,+,1						; and advance the character position
	
	words.uppercase PR_Line,w_UBuffer										; and replace the copy in UBuffer

END.SUB C_3_2_2_1_FP_Expand
;	EXIT

;-----------------------------------------------------------------------
;	Build Literal
;	$Called by:-C_3_3_1_FP_inMatrix
;				C_3_3_2_1_FP_Expand
;------------------------------------------------------------------------		
BEGIN.SUB C_3_2_X_BuildLiteral

	[section .data]
		insertword	 w_newLit,	   19,''
		insertword   w_litPlace,	1,''
		insertnumber n_newLitlen,	0,'999'
		insertnumber n_litNumbers,	0,'999'
		insertnumber n_litPlaces,	0,'999'
	[section .text]
		words.pad   spaces(1),		w_newLit								; Initialise the new literal
		words.copy  spaces(1),		w_litPlace								; Initialise place flag	
		integers.eq n_newLitlen,	0										; and zero its length
		integers.eq n_litNumbers,	0										; zero the numbers
		integers.eq n_litPlaces,	0										; zero the places

	repeat.for K,n_StartLit,n_endLit										; loop from start to end

		begin.test {PR_Line,K,1}

			when =,'-'														; IF we have a sign
				integers.add n_newLitlen,1									;	 build new literal
				words.copy '-',{w_newLit,n_newLitlen,1}
			wend

			when =,'.'														; IF we have a decimal place
				words.copy '.',w_litPlace									;	then set the flag
			wend

			when _IN,{'0','1','2','3','4','5','6','7','8','9'}				; IF its a number;
				integers.add n_litNumbers,1									;	accumulate the numbers
				if w_litPlace,=,'.'											;	IF they are decimal places
					integers.add n_litPlaces,1								;		accumulate them
				end.if
				integers.add n_newLitlen,1									;	build new literal
				words.copy {PR_Line,K,1},{w_newLit,n_newLitlen}
			wend

		end.test

	end.repeat

END.SUB C_3_2_X_BuildLiteral
;	EXIT

;*******************************************************************************
;		COMPONENT 3 of the reWrite Process
;*******************************************************************************
;===============================================================================
;  		alter A = B stuff
;===============================================================================
BEGIN.SUB C_3_3_SetupCalc

	[section .data]
		insertword	w_SaveTableName,	30,''
		insertword	w_SaveTableType,	01,''
		insertword	w_SaveRecordName,	30,''
	[section .text]

;	-------------
;	IF WE WANT IT
;	-------------
	.if  b_Assembler,=,c_FALSE
	.and b_Procedures,=,c_TRUE
	.end
		words.find {'=',I},PR_Line
		if I,>,0
			Call C_3_3_1_CompareDataDefinitions
		end.if
	end.if
	
END.SUB C_3_3_SetupCalc
;	EXIT

;-------------------------------------------------------------------------------
;	Compare Data Definitions
;-------------------------------------------------------------------------------
BEGIN.SUB C_3_3_1_CompareDataDefinitions

	[section .data]
		insertnumber n_dstStart,	0,'999'
		insertnumber n_dstEnd,		0,'999'
		insertnumber n_dstLen,		0,'999'
		insertnumber n_dstBrace,	0,'999'	
		insertnumber n_srcStart,	0,'999'
		insertnumber n_srcEnd,		0,'999'
		insertnumber n_srcLen,		0,'999'
	[section .text]

;	-----------------
;	GET 1st CHARACTER
;	-----------------
	integers.eq n_dstBrace,0

	repeat.for n_dstStart,1,PR_CommandLength								; Now search until letter found
		if {PR_Line,n_dstStart,1},_IN,{' ','{',x_Tab}
			if {PR_Line,n_dstStart,1},=,'{'									; Flag a brace 
				integers.eq n_dstBrace,n_dstStart
			else
				integers.eq n_dstBrace,0			
			end.if
		else
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat

	if n_dstStart,!>,0														; and Process if not commented out
		EXIT.SUB C_3_3_1_CompareDataDefinitions
	end.if

;	------------------
;	GET last CHARACTER
;	------------------	
	repeat.for n_dstEnd,n_dstStart,PR_CommandLength							; Search until space,comma,tab, or '['
		if {PR_Line,n_dstEnd,1},_IN,{' ',',',x_Tab,x_LF,'['}
			integers.sub n_dstEnd,1											; and save end of word when found
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat

	integers.calc n_dstLen,=,n_dstEnd,-,n_dstStart,+,1
	words.pad {PR_Line,n_dstStart,n_dstLen},w_Temp30

;	----------------
;	Is It a DN_Name
;	----------------
	$Call X_5_SearchByName
	if DataNameTable_STATUS,!=,0
		EXIT.SUB C_3_3_1_CompareDataDefinitions 
	end.if

;	-------------------------------------
;	Build replacement
;	-------------------------------------
	if DN_Type,=,c_Word														; If destination is a word
		$Call C_3_3_1_1_SwapFields											;	then build words.pad
		exit.sub C_3_3_1_CompareDataDefinitions 
	end.if

	if DN_Type,=,c_Integer													; if Destination is an integer
		words.find {'.',I},PR_Line											; Look for any fixed point numbers
		if I,>,0															; If we find one
			words.copy c_FixedPoint,DN_Type									;	then swap to numbers.calc
		else
		
		;	-------------------------------------------------------------------------------
		;	If the source is an alpha [NUMBER = "123"] then we need to swap to NUMBERS.CALC
		;	-------------------------------------------------------------------------------
			repeat.for n_srcStart,n_dstEnd,PR_CommandLength					; first we have to find the equals			
				if {PR_Line,n_srcStart,1},=,'='
					integers.add n_srcStart,1								; and step over it
					integers.eq exitRepeat,c_TRUE
				end.if
			end.repeat
			repeat.for n_srcStart,n_srcStart,PR_CommandLength				; and then find the beginning of the source
				if {PR_Line,n_srcStart,1},_NIN,{' ',x_Tab}
					integers.eq exitRepeat,c_TRUE
				end.if
			end.repeat

			repeat.for n_srcEnd,n_srcStart,PR_CommandLength					; Loop from start of source to end of text
				if {PR_Line,n_srcEnd,1},_IN,{"{","'",'"'}					;	if we found these its an Alpha
					words.copy c_FixedPoint,DN_Type							;
					integers.eq exitRepeat,c_TRUE						
				end.if
					
				.if {PR_Line,n_srcEnd,1},_IN,{' ',x_Tab}					; If found end
				.or n_srcEnd,=,PR_CommandLength
				.end
					integers.calc n_srcLen,=,n_srcEnd,-,n_srcStart,+,1		;	calculate the length
							
					words.pad {PR_Line,n_srcStart,n_srcLen},w_Temp30		;	load it into w_Temp30
					$Call X_5_SearchByName									;	look for it in Data Table
					if DataNameTable_STATUS,!=,0							;	if NOT there (assume a literal)
						words.copy c_Integer,DN_Type						;		reset back to I
					end.if	
					if DN_Type,=,c_Word										; 	if destination is a word
						words.copy c_FixedPoint,DN_Type						;		then swap to numbers.calc
					end.if													;
					integers.eq exitRepeat,c_TRUE							; 		and exit
				end.if				
			end.repeat
			
		end.if		
	end.if

;	-------------------------------------------------------------------------------
;	So now we can insert our macro
;	-------------------------------------------------------------------------------
	if DN_Type,=,c_Integer													; If destination is a fixed point number 
		words.insert 'INTEGERS.CALC ',{PR_Line,n_dstStart}					;	build integers.calc
		integers.add PR_CommandLength,14	
	end.if
	
	if DN_Type,=,c_FixedPoint												; If destination is a fixed point number 
		words.insert 'NUMBERS.CALC ', {PR_Line,n_dstStart}					;	then build numbers.calc
		integers.add PR_CommandLength,13			
	end.if

END.SUB C_3_3_1_CompareDataDefinitions
;		EXIT

;-------------------------------------------------------------------------------
;	Swap fields for Word.Pad
;-------------------------------------------------------------------------------
BEGIN.SUB C_3_3_1_1_SwapFields

	[section .data]
		insertnumber n_tmpPos,	  0,'999'
	[section .text]

	if n_dstBrace,>,0														; If we have detected a leading brace
		integers.eq n_dstStart,n_dstBrace									; reset the destination start
		repeat.for n_dstEnd,n_dstStart,PR_CommandLength						; and recalculate the end by					
			if {PR_Line,n_dstEnd,1},=,"}"									; Loop until we find the end brace								
				integers.eq exitRepeat,c_TRUE								; and exit
			end.if															; END
		end.repeat															; END REPEAT
		integers.calc n_dstLen,=,n_dstEnd,-,n_dstStart,+,1					; and recalculate the length				
	end.if																	; END

;	-----------------
;	Insert macro name
;	-----------------
	integers.calc I,=,n_dstStart,-,1										; set our start position
	words.pad {PR_Line,1,I},w_saveLine										; move in leading spaces/tabs
	if n_dstBrace,>,0														; If we have a brace
		words.copy 'WORDS.COPY ',{w_saveLine,n_dstStart}					; add the leading macro name
		integers.calc n_tmpPos,=,n_dstStart,+,11							; and set the position in Temp
	else																	; ELSE
		words.copy 'WORDS.PAD ',{w_saveLine,n_dstStart}						; add the leading macro name
		integers.calc n_tmpPos,=,n_dstStart,+,10							; and set the position in Temp
	end.if 

;	------------------
;	Move in the source
;	------------------
	repeat.for n_srcStart,n_dstEnd,PR_CommandLength							; Loop from end of destination to end of text
		if {PR_Line,n_srcStart,1},=,'='										; If we have found the '='
			integers.add n_srcStart,1										;	then step over it
			repeat.for n_srcStart,n_srcStart,PR_CommandLength
				if {PR_Line,n_srcStart,1},_NIN,{" ",x_Tab}
					integers.eq exitRepeat,c_TRUE
				end.if
			end.repeat
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat

	repeat.for n_srcEnd,PR_CommandLength,1									; Now work backwards to get end of source
		if {PR_Line,n_srcEnd,1},_IN,{' ',';',x_Tab}							; V2.05 - added comment character
		else
			integers.eq exitRepeat,c_TRUE
		end.if
	end.repeat
	
	integers.calc n_srcLen,=,n_srcEnd,-,n_srcStart,+,1						; Source length is EOsrc - SOsrc + 1
	words.pad {PR_Line,n_srcStart,n_srcLen},{w_saveLine,n_tmpPos}			; Copy the source into temp

;	---------
;	the comma
;	---------
	integers.add n_tmpPos,n_srcLen											; Prepare for the comma
	words.copy ',',{w_saveLine,n_tmpPos}									; and move it in

;	---------------
;	the destination
;	---------------
	integers.add n_tmpPos,1													; Move along 2
	words.copy {PR_Line,n_dstStart,n_dstLen},{w_saveLine,n_tmpPos}			; and write the destination	

;	----------------------
;	repopulate the buffers
;	----------------------
	words.pad w_saveLine,PR_Line												; Result into buffer
	integers.calc PR_CommandLength,=,n_tmpPos,+,n_dstLen					; and extend the line

END.SUB C_3_3_1_1_SwapFields
;		EXIT

;*******************************************************************************
;		COMPONENT 4 OF THE REWRITE PROCESS
;*******************************************************************************
;===============================================================================
;		ADD COMMAS THAT NASM REQUIRES
;===============================================================================
BEGIN.SUB C_3_4_addCommas

	[section .data]															; Although there are no local variables in languageONE
		insertnumber n_StartOfCommand,  0,'999'								; you can define variables outside the DICTIONARY or 
		insertnumber n_EndOfCommand,    0,'999'								; the MATRIX. I use this as convenience cuz the definitions 
		insertnumber n_NoOfCommas,      0,'999'								; are close at hand.
		insertnumber C_3_4_b_Found,     0,'9'								; Open with 'section.data' & close with 'section .text'
	[section .text]

	if b_Procedures,=,c_FALSE
		exit.sub C_3_4_addCommas
	end.if
	
;	------------------------------
;	INITIALISE
;	------------------------------
	words.copy spaces(1),w_Quote											; Initialise w_Quote
	integers.eq C_3_4_b_Found,c_FALSE
	words.uppercase PR_Line,w_Temp30

;	---------------------
;	FIND START OF COMMAND
;	---------------------
	words.copy spaces(1),w_Quote											; Initialise w_Quote

	repeat.for n_StartOfCommand,1,PR_CommandLength							; Run from beginning to end of the input buffer

		mCheckQuotes (n_StartOfCommand)

		If w_Quote,=,spaces(1) 
			begin.test c_TRUE

			;	Allow for NASM preprocessor stuff
				when {w_Temp30,n_StartOfCommand,3},=,'%IF'					; %if - a NASM preprocessor token
					integers.eq n_StartOfCommand,PR_CommandLength			
				wend
			
				when {w_Temp30,n_StartOfCommand,3},=,'IF '					; Have we found an IF
					integers.toggle C_3_4_b_Found							;	then toggle the found flag
					integers.add n_StartOfCommand,2							;	and advance past the IF
				wend

				when {w_Temp30,n_StartOfCommand,4},=,'.IF '					; Have we found an .IF
					integers.toggle C_3_4_b_Found							;	then toggle the found flag
					integers.add n_StartOfCommand,3							;	and advance past the .IF
				wend

				when {w_Temp30,n_StartOfCommand,6},=,'WHILE '				; Have we found an IF
					integers.toggle C_3_4_b_Found							;	then toggle the found flag
					integers.add n_StartOfCommand,5							;	and advance past the WHILE
				wend

				when {w_Temp30,n_StartOfCommand,4},=,'.OR '					; Have we found an .OR
					integers.toggle C_3_4_b_Found							;	then toggle the found flag
					integers.add n_StartOfCommand,3							;	and advance past the .OR
				wend

				when {w_Temp30,n_StartOfCommand,5},=,'.AND '				; Have we found an .AND
					integers.toggle C_3_4_b_Found							;	then toggle the found flag
					integers.add n_StartOfCommand,4							;	and advance past the .AND
				wend

				when {w_Temp30,n_StartOfCommand,5},=,'WHEN '				; Have we found an WHEN
					integers.toggle C_3_4_b_Found							;	then toggle the found flag
					integers.add n_StartOfCommand,4							;	and advance past the WHEN
				wend

				when {w_Temp30,n_StartOfCommand,6},=,'.WHEN '				; Have we found an .WHEN
					integers.toggle C_3_4_b_Found							;	then toggle the found flag
					integers.add n_StartOfCommand,5							;	and advance past the .WHEN
				wend
	
				when {w_Temp30,n_StartOfCommand,6},=,'.CALC '				; Have we found an CALC		
					integers.toggle C_3_4_b_Found							;	then toggle the found flag
					integers.add n_StartOfCommand,5							;	and advance past the .CALC
				wend
	
			end.test
		end.if

		if C_3_4_b_Found,=,c_TRUE

			repeat.for n_StartOfCommand,n_StartOfCommand,PR_CommandLength		; Continue searching
				if {PR_Line,n_StartOfCommand,1},_NIN,{' ',x_Tab}
					integers.eq exitRepeat,c_TRUE
				end.if
			end.repeat

			integers.eq exitRepeat,c_TRUE
		end.if

	end.repeat

;	------------
;	NOT REQUIRED
;	------------
	if C_3_4_b_Found,=,c_FALSE												; Exit if not IF found
		EXIT.SUB C_3_4_addCommas
	end.if 

;	-------------------------------------------------------------------------    
;	WE KNOW HAVE THE START AND END POSITION OF THE COMMAND - So Insert commas
;	-------------------------------------------------------------------------
	words.copy spaces(1),w_Quote											; Initialise w_Quote

	repeat.for I,n_StartOfCommand,PR_CommandLength							; Scan the command from start to end

		mCheckQuotes (I)   													; Checks Quotes		
		If w_Quote,=,spaces(1)												; Nothing to do if in quotes					

		;	---------------------------------------
		;	cuz it hits the end sometimes   
			if I,!>,PR_CommandLength
				if {PR_Line,I,1},_IN,{' ',x_Tab}							; If we have a space/tab
					Words.copy ',',{PR_Line,I,1}							;   replace it with a comma

					repeat.while 1,=,1										; and skip over any more spaces/tabs
						integers.add I,1
						if I,>,PR_CommandLength
							exit.Repeat
						end.if

						if {PR_Line,I,1},_NIN,{' ',x_Tab}
							integers.sub I,1
							integers.eq exitRepeat,c_TRUE
						end.if
					end.repeat

				end.if
			end.if

		end.if

	end.repeat  

END.SUB C_3_4_addCommas
;		EXIT

;*******************************************************************************
;		COMPONENT 5 of the reWrite Process
;*******************************************************************************
;===============================================================================
;		remove brackets that nasm does not allow for.
;		spaces is one of the exceptions being a sigle line macro
;===============================================================================
BEGIN.SUB C_3_5_GetStats

	words.copy spaces(1),w_Quote											; Initialise w_Quote

	repeat.for I,1,PR_CommandLength											; Run from beginning to end of the input buffer
		mCheckQuotes (I)   													; Checks Quotes		
		If w_Quote,=,spaces(1)												; Nothing to do if in quotes					
			$Call C_3_5_1_GetStats											; Get statistics
		end.if		
	end.repeat

END.SUB C_3_5_GetStats
;	EXIT

;-------------------------------------------------------------------------------
;   Count the occurences
;-------------------------------------------------------------------------------
BEGIN.SUB C_3_5_1_GetStats

	begin.test c_TRUE														; Determine if we have a countable item
	
		when {w_UBuffer,I,15},=,'BEGIN.ASSEMBLER'
			integers.eq b_Assembler,c_TRUE
		wend

		when {w_UBuffer,I,13},=,'END.ASSEMBLER'
			integers.eq b_Assembler,c_FALSE
		wend

		when b_Assembler,=,c_TRUE											; Do nothing within assembler
		wend
																			; and count it
		when {w_UBuffer,I,9},=,'BEGIN.SUB'
			integers.add n_NoOfBeginSubs,1
		wend

		when {w_UBuffer,I,7},=,'END.SUB'
			integers.add n_NoOfEndSubs,1
		wend

		when {w_UBuffer,I,6},=,'REPEAT'
			words.find {'END.REPEAT',J},w_UBuffer
			if J,>,0
				integers.add n_NoOfEndRepeats,1
			else
				words.find {'EXIT.REPEAT',J},w_UBuffer
				if J,=,0
					words.find {'EXITREPEAT',J},w_UBuffer
					if J,=,0
						if I,=,1
							integers.add n_NoOfRepeats,1
						else
							integers.calc J,=,I,-,1
							if {w_UBuffer,J,1},_IN,{' ',x_Tab}		
								integers.add n_NoOfRepeats,1
							end.if
						end.if
					end.if
				end.if
			end.if
		wend
		
		when {w_UBuffer,I,2},=,'IF'		
			words.find {'REPEAT.IF',J},w_UBuffer
			if J,=,0
				words.find {'END.IF',J},w_UBuffer
				if J,>,0
					integers.add n_NoOfEndIfs,1	
				else
				;	V2.10
					words.find {'ARRAYS.IF',J},w_UBuffer
					if J,>,0
						integers.add n_NoOfIfs,1
					else
				;	V2.10	
						words.find {'.IF',J},w_UBuffer						
						if J,>,0				
							integers.add n_NoOfDotCommands,1
							integers.add n_NoOfIfs,1
						else				
							if I,=,1
								integers.add n_NoOfIfs,1
							else
								integers.calc J,=,I,-,1
								if {w_UBuffer,J,1},_IN,{' ',x_Tab}	
									integers.add n_NoOfIfs,1
								end.if
							end.if							
						end.if
					end.if
				end.if	
			end.if
		wend
	
		when {w_UBuffer,I,4},=,'.END'
			integers.add n_NoOfDotEnds,1
		wend

		when {w_UBuffer,I,10},=,'BEGIN.TEST'
			integers.add n_NoOfBeginTests,1
		wend

		when {w_UBuffer,I,8},=,'END.TEST'
			integers.add n_NoOfEndTests,1
		wend

		when {w_UBuffer,I,4},=,'WHEN'
			words.find {'.WHEN',J},w_UBuffer
			if J,>,0
				integers.add n_NoOfDotCommands,1
				integers.add n_NoOfWhens,1
			else
				if I,=,1
					integers.add n_NoOfWhens,1
				else
					integers.calc J,=,I,-,1
					if {w_UBuffer,J,1},_IN,{' ',x_Tab}		
						integers.add n_NoOfWhens,1
					end.if
				end.if
			end.if
		wend

		when {w_UBuffer,I,4},=,'WEND'
			integers.add n_NoOfWends,1
		wend

		when {w_UBuffer,I,1},=,'{'
			integers.add n_NoOfOpenBraces,1
		wend

		when {w_UBuffer,I,1},=,'}'
			integers.add n_NoOfCloseBraces,1
		wend

		.when {w_UBuffer,I,3},=,'%IF'
		.or   {w_UBuffer,I,6},=,'%ENDIF'
		.end
		;	NASM will take of this
		wend

		otherwise
			.if {w_UBuffer,I,6},=,'%MACRO'
 			.or {w_UBuffer,I,7},=,'%IMACRO'
			.end
				integers.eq b_Macro,c_TRUE
			end.if
	
			if {w_UBuffer,I,9},=,'%ENDMACRO'
 				integers.eq b_Macro,c_FALSE
			end.if
	
	end.test

END.SUB C_3_5_1_GetStats
;	EXIT

;=======================================================================
;   Display Results of 2nd Pass
;=======================================================================
BEGIN.SUB C_4_DisplayResults

	files $write,STDOUT,"  [",n_NoOfBeginSubs,     "] Begin Subs      [",n_NoOfEndSubs,"] End Subs"
	files $write,STDOUT,"  [",n_NoOfRepeats,       "] Begin Repeats   [",n_NoOfEndRepeats,"] End Repeats"
	files $write,STDOUT,"  [",n_NoOfIfs,           "] IF's            [",n_NoOfEndIfs,"] End Ifs"
	files $write,STDOUT,"  [",n_NoOfDotCommands,   "] Dot Commands    [",n_NoOfDotEnds,"] Dot Ends"
	files $write,STDOUT,"  [",n_NoOfBeginTests,    "] Begin Test's    [",n_NoOfEndTests,"] End Tests"
	files $write,STDOUT,"  [",n_NoOfWhens,         "] When's          [",n_NoOfWends,"] Wend's"
	files $write,STDOUT,"  [",n_NoOfOpenBraces,    "] Open Braces     [",n_NoOfCloseBraces,"] Close Braces"
	files $write,STDOUT,"  [",n_NoOfOpenSQBrackets,"] Open SqBrackets [",n_NoOfCloseSQBrackets,"] Close SqBrackets"
	
	files.write STDOUT,''
	
	if n_NoOfBeginSubs,!=,n_NoOfEndSubs
		files.write STDOUT,"    11: Begin/End Subs are not balanced"
		integers.eq ERROR_CODE,11
	end.if

	if n_NoOfRepeats,!=,n_NoOfEndRepeats
		files.write STDOUT,"    12: Begin/End Repeats are not balanced"
		integers.eq ERROR_CODE,12
	end.if

	if n_NoOfIfs,!=,n_NoOfEndIfs
		files.write STDOUT,"    13: Begin/End Ifs are not balanced"
		integers.eq ERROR_CODE,13
	end.if

	if n_NoOfDotCommands,!=,n_NoOfDotEnds
		files.write STDOUT,"    14: Begin/End dot commands are not balanced"
		integers.eq ERROR_CODE,14
	end.if

	if n_NoOfBeginTests,!=,n_NoOfEndTests
		files.write STDOUT,"    15: Begin/End Tests are not balanced"
		integers.eq ERROR_CODE,15
	end.if

	if n_NoOfWhens,!=,n_NoOfWends
		files.write STDOUT,"    16: When/Wends are not balanced"
		integers.eq ERROR_CODE,16
	end.if

	if n_NoOfOpenBraces,!=,n_NoOfCloseBraces
		files.write STDOUT,"    17: Braces are not balanced"
		integers.eq ERROR_CODE,17
	end.if

	if n_NoOfOpenSQBrackets,!=,n_NoOfCloseSQBrackets
		files.write STDOUT,"    18: Square Brackets are not balanced"
		integers.eq ERROR_CODE,18
	end.if
		
END.SUB C_4_DisplayResults
;	EXIT

;*******************************************************************************
;   3rd Pass Processing
;*******************************************************************************
BEGIN.SUB D_3rdPass

	[section .data]
		insertnumber	b_FoundDictionary,	c_FALSE
		insertnumber	b_FoundMatrix,		c_FALSE
		insertnumber	b_FoundProcedure,	c_FALSE
	[section .text]	


;	---------------
;	EXPORTS/GLOBALS from DataNames Table
;	---------------
	$Call D_1_WindowsDEBUG													; For Windows debugging
	
	
;	----------
;	OPEN FILES
;	----------
	files.open out_File,$write+$beginning									; and open the new output file for writing
	files.open exports_File,$write+$end										; the exports
	files.open globals_File,$write+$end										; and the globals

	.if  b_Debug,=,c_TRUE													; and the debug line
	.and b_Windows,=,c_FALSE
	.end
		Files.write out_File,"%assign debug 1"
	else
		Files.write out_File,"%assign debug 0"
		Files.write out_File,"%include 'globals'"
	end.if
	
;	-------
;	PROCESS
;	-------
	repeat.for n_LineCtr,1,ProgramTable_UBOUND								; LOOP thru the Program Table
	
		xtables.rget ProgramTable,n_LineCtr									; Grab a record
		words.uppercase PR_Line,w_UBuffer									; and an uppercase copy

		if PR_Type,=,"B"													; If its a blank line
			if b_Debug,=,c_FALSE											; but not for debug	
				files.write out_File,""										; Write out the original record
			end.if															; END
		else																; ELSE
			if PR_Type,=,"C"												; If its a comment
				if b_Debug,=,c_FALSE										; but not for debug
					files.write out_File,{PR_Line,1,PR_LineLength}			; Write out the original line	
				end.if														; END
			else															; ELSE
			
				begin.test c_TRUE											; 4 things to look for

					when b_FoundDictionary,=,c_FALSE						; If we have not found BEGIN.DICTIONARY yet
						files.write out_File,{PR_Line,1,PR_CommandLength}	; Write out the original line					
						words.find {'BEGIN.DICTIONARY',I},w_UBuffer			; Look for the start of the dictionary
						if  I,>,0											; If we have found it
							integers.eq b_FoundDictionary,c_TRUE			; flag it as found
							integers.eq J,1									; flag it for Write New Data
							$Call D_2_WriteNewData							; and write out the created words
						end.if												; END
					wend													; WEND

					when b_FoundMatrix,=,c_FALSE							; If we have not found BEGIN.MATRIX yet
						files.write out_File,{PR_Line,1,PR_CommandLength}	; Write out the original line 	
						words.find {'BEGIN.MATRIX',I},w_UBuffer				; Look for the start of the matrix
						if  I,>,0											; If we have found it
							integers.eq b_FoundMatrix,c_TRUE				; flag it as found
							integers.eq J,2									; flag it for Write New Data
							$Call D_2_WriteNewData							; and write out the created integers
							integers.eq J,3									; flag it for Write New Data
							$Call D_2_WriteNewData							; and write out the created FP
						end.if												; END
					wend													; WEND

					when b_FoundProcedure,=,c_FALSE							; but not found the procedures yet
						words.find {'BEGIN.INSTRUCTIONS',I},w_UBuffer		; look for the start of the procedures
						if  I,>,0											; If we have found it
							integers.eq b_FoundProcedure,c_TRUE				; flag it as found
							$Call D_3_WriteMacros							; and write out the macro
							files.write out_File,{PR_Line,1,PR_CommandLength}	; Write out the original line
						else
							files.write out_File,{PR_Line,1,PR_CommandLength}	; Write out the original line
						end.if
					wend													; WEND

					otherwise												; Otherwise
						if  b_FoundProcedure,=,c_TRUE						; If we are in the procedures	
							$Call D_4_LinuxDEBUG							; add debug lines
							$Call D_5_WindowsDEBUG							; add debug lines
							$Call E_1_Compile								; Call the new compile function
						end.if												; END
						files.write out_File,{PR_Line,1,PR_CommandLength}	; Write out the original line		
				end.test
			end.if
		end.if
		
	end.repeat

;	-----------
;	CLOSE FILES
;	-----------
	files.close out_File
	files.close exports_File
	files.close globals_File

END.SUB D_3rdPass
;	EXIT

;=======================================================================
;   Now write the debug exports/globals files with Datanames
;=======================================================================
BEGIN.SUB D_1_WindowsDEBUG

;	-----
;	EXITS
;	-----
    .if  b_Debug,=,c_TRUE													; If debug has been requested 
	.and b_Windows,=,c_TRUE													; and its Windows
	.end																	; continue
	else																	; ELSE
		EXIT.SUB D_1_WindowsDEBUG											; EXIT		
	end.if																	; END

	
	files.open exports_File,$write+$end										; Open the exports file
	files.open globals_File,$write+$end										; Open the globals file
		
	repeat.for I,1,c_DN_noOfRecs											; REPEAT for as many DataNames we have collected

		tables.rget DataNameTable,I											; get the record
		if DataNameTable_STATUS,=,0											; if we have one

			mov qword[w_Temp30-8],30										; reset the length of w_Temp30
			words.pad "/export:",w_Temp30									; move in the export literal
			words.pad DN_Name,{w_Temp30,9}									; move it into w_Temp30
			files.write exports_File,w_Temp30								; and write it out

			words.pad "global ",w_Temp30									; move in the global literal
			words.pad DN_Name,{w_Temp30,8}									; move it into w_Temp30
			Files.write globals_File,w_Temp30								; and write the record

		else																; ELSE
			integers.eq exitRepeat,c_TRUE									; we are done
		end.if																; END
	end.repeat																; END REPEAT
	
	files.close exports_File												; and close the file
	files.close globals_File												; and close the file
	
END.SUB D_1_WindowsDEBUG

;-----------------------------------------------------------------------
;		  Write New Data
;-----------------------------------------------------------------------
BEGIN.SUB D_2_WriteNewData

	files.write out_File,''													; Write out a blank line
	begin.test J															; and comments
		when =,1
			files.write out_File,';(BEGIN):Temporary Words by languageONE'
		wend

		when =,2
			files.write out_File,';(BEGIN):Temporary Integers by languageONE'
		wend

		when =,3
			files.write out_File,';(BEGIN):Temporary FixedPoint numbers by languageONE'
		wend

	end.test

	integers.eq K,c_FALSE
	integers.eq n_NDIdx,1													; Start the table at 1
	xtables.rget NewDataTable,n_NDIdx										; and grab the record

	repeat.while NewDataTable_STATUS,=,0									; LOOP until end of records
	   .if J,=,1
	   .and ND_Type,=,c_Word
	   .end
			integers.eq K,c_TRUE
		end.if
	   .if J,=,2
	   .and ND_Type,=,c_Integer
	   .end
			integers.eq K,c_TRUE
		end.if
	    .if J,=,3
	    .and ND_Type,=,c_FixedPoint
	    .end
			integers.eq K,c_TRUE
		end.if

		if K,=,c_TRUE
			files.write out_File,ND_Entry									; write out the record
			integers.eq K,c_FALSE
		end.if
		integers.add n_NDIdx,1												; increment the record number
		xtables.rget NewDataTable,n_NDIdx									; and grab the record

	end.repeat

	begin.test J															; and comments
		when =,1
			files.write out_File,';(END..):Temporary Words by languageONE'
		wend
		
		when =,2
			files.write out_File,';(END..):Temporary Integers by languageONE'
		wend

		when =,3
			files.write out_File,';(END..):Temporary FixedPoint numbers by languageONE'
		wend

	end.test

END.SUB D_2_WriteNewData
;	EXIT

;-----------------------------------------------------------------------
;		  Write Macros
;-----------------------------------------------------------------------
BEGIN.SUB D_3_WriteMacros

	[section .data]
		insertnumber	n_CurrentMacroNo,	0
		insertword		w_mLine1,		013,'%macro m999 0'
		insertword		w_mLine9,		009,'%endmacro'
	[section .text]
		
	files.write out_File,''													; write out a blank line
	files.write out_File,';(BEGIN):Macros created by languageONE'			; and comment the macro
		
;	------------
;	PROCESS LOOP
;	------------
	words.pad PR_Line,w_saveLine											; Save the line 1st
	integers.eq n_Length,PR_CommandLength									; Save the line length
	
	if MacroTable_UBOUND,>,0												; If we created any macros
	
		repeat.for n_TextIdx,1,MacroTable_UBOUND							; LOOP until end of records
		;	---------------
		;	NEXT MACRO LINE
		;	----------------
			xtables.rGet MacroTable,n_TextIdx								; Get the Macro entry 
		;	ADD COMMAS	
			words.pad MR_MacroLineItem,PR_Line								; Move it to PR_Line	
			repeat.for PR_CommandLength,124,1								; REPEAT using Line length for C_3_4_addCommas
				if {PR_Line,PR_CommandLength,1},!=,spaces(1)				; If we have found something 
					integers.eq exitRepeat,c_TRUE							; then exit
				end.if														; END
			end.repeat														; END REPEAT
			$Call C_3_4_addCommas											; add the commas
			words.pad PR_Line,MR_MacroLineItem								; and return it to the Macro Line
		
			if n_CurrentMacroNo,=,0											; STANDARD TAB LOGIC
				$Call D_3_1_BeginMacro										; Each record contains a macro no so that
			end.if															; mutiliple macros are detailed 
																			; Just use standard logic to manage control
			if MR_MacroNo,!=,n_CurrentMacroNo								; breaks
				$Call D_3_2_EndMacro										;
				$Call D_3_1_BeginMacro										;
			end.if															; STANDARD TAB LOGIC

			$Call D_3_3_CompressLine										; Make the line look pretty
			files.write out_File,MR_MacroLineItem							; and write out the record
			
		end.repeat															; END REPEAT

	end.if																	; END 

	words.pad w_saveLine,PR_Line											; Restore the line
	integers.eq PR_CommandLength,n_Length									; Restore the line length

;	---
;	END
;	---
	if n_CurrentMacroNo,!=,0
		$Call D_3_2_EndMacro
	end.if

	files.write out_File,';(END)..:Macros created by languageONE'			; comment the macro
	files.write out_File,''													; and write out a blank line

END.SUB D_3_WriteMacros
;	EXIT

;-----------------------------------------------------------------------
;		  Begin Macro
;-----------------------------------------------------------------------
BEGIN.SUB D_3_1_BeginMacro

	integers.eq n_CurrentMacroNo,MR_MacroNo									; Save the new macro no

	words.copy MR_MacroNo,{w_mLine1,9}										; write out the macro definition line
		
	files.write out_File,''													; write out a blank line 
	files.write out_File,w_mLine1											; then standard macro lines

END.SUB D_3_1_BeginMacro
;	EXIT

;-----------------------------------------------------------------------
;		  End Macro
;-----------------------------------------------------------------------
BEGIN.SUB D_3_2_EndMacro

	files.write out_File,w_mLine9											; and the end macro line

END.SUB D_3_2_EndMacro
;	EXIT

;-----------------------------------------------------------------------
;		  Compress Line
;-----------------------------------------------------------------------
BEGIN.SUB D_3_3_CompressLine

	[section .data]
		insertnumber n_Source,	0
		insertnumber n_Target,	0
	[section .text]


	words.find {" ",I},MR_MacroLineItem										; Locate the 1st space
	integers.add I,1														; and jump over it
	repeat.for I,I,124														; REPEAT for the length of the line
	
		repeat.while I,<,125												; REPEAT while we traversing the line
			if {MR_MacroLineItem,I,1},_IN,{' ',x_Tab}						; If we have found a space of a tab
				integers.eq exitRepeat,c_TRUE								; we are done
			else															; ELSE
				integers.add I,1											; next character
			end.if															; END
		end.repeat															; END REPEAT
		integers.eq n_Target,I												; Store the target

		if I,<,125															; If we are still in the line
			repeat.while I,<,125											; REPEAT while we are
				if {MR_MacroLineItem,I,1}, _NIN,{' ',x_Tab}					; If we have found a valid character
					integers.eq exitRepeat,c_TRUE							; we are done
				else														; ELSE
					integers.add I,1										; next character
				end.if														; END
			end.repeat														; END REPEAT
			integers.eq n_Source,I											; Store the source

			if I,<,125														; If we are still in the line
				if n_Source,>,n_Target										; and there is something to move 
					words.pad {MR_MacroLineItem,n_Source},{MR_MacroLineItem,n_Target}
					integers.eq I,n_Target									; and reset I
				end.if														; END
			end.if															; END
		end.if																; END
		
	end.repeat																; END REPEAT
	
	words.insert x_Tab,MR_MacroLineItem										; stick in a TABS
	xtables.rput MacroTable,n_TextIdx										; and rewrite the record

END.SUB D_3_3_CompressLine
;	EXIT

;=======================================================================
;		INSERT DEBUG CODE
;=======================================================================
BEGIN.SUB D_4_LinuxDEBUG

	[section .data]
		insertnumber b_Continuation,c_FALSE
		insertnumber b_firstLine,	c_FALSE
		insertnumber b_Procede,		c_FALSE
	[section .text]

;	-----
;	EXITS
;	-----
	.if  b_Debug,=,c_TRUE													; If debug has been requested 
	.and b_Windows,=,c_FALSE												; if its Linux
	.end
	else																	; ELSE
		EXIT.SUB D_4_LinuxDEBUG												; exit
	end.if																	; END

;	--------------------------------
;	DONT WANT THIS IN ASSEMBLER CODE
;	--------------------------------
	words.find {"BEGIN.ASSEMBLER",I},w_UBuffer
	if I,>,0
		integers.eq b_Assembler,c_TRUE
		words.pad spaces(1),w_saveLine										; clear the buffer
		words.copy 'DEBUG',{w_saveLine,123}									; move the literal to the end of the line
		files.write out_File,w_saveLine										; and write the record
		exit.sub D_4_LinuxDEBUG
	end.if
	words.find {"END.ASSEMBLER",I},w_UBuffer
	if I,>,0
		integers.eq b_Assembler,c_FALSE
		exit.sub D_4_LinuxDEBUG
	end.if	
	if b_Assembler,=,c_TRUE 
		exit.sub D_4_LinuxDEBUG
	end.if	
		
;	-----------------------------------------
;	IS THE LINE CONTINUED
;	-----------------------------------------
	integers.eq b_Continuation,c_FALSE										; Set continuation flag to false
	repeat.for I,1,PR_CommandLength											; run thru from start to end of text

		;	----------------------------------------------------
		;	Piggy back this loop to check for %endmacro/.or/.and
		;	----------------------------------------------------
			integers.calc J,=,I,-,1
			if {w_UBuffer,I,4},=,'.OR '										; We dont want a DEBUG prior
		   	  .if J,=,0														; to an OR
		      .or {w_UBuffer,J,1},_IN,{' ','(',x_Tab}
		     .end
				EXIT.SUB D_4_LinuxDEBUG										
			  end.if
			end.if
			if {w_UBuffer,I,5},=,'.AND '									; We dont want a DEBUG prior
		   	  .if J,=,0														; to an AND
		      .or {w_UBuffer,J,1},_IN,{' ','(',x_Tab}
		     .end
				EXIT.SUB D_4_LinuxDEBUG
			  end.if
			end.if
		;	--------------------------

			if {PR_Line,I,1},=,'\'											; If we have a continuation character
				integers.eq J,I												; grab the next character
				integers.add J,1	
				if {PR_Line,J,1},_IN,{' ',x_Tab,x_LF}
					integers.eq b_Continuation,c_TRUE						; then we got it
					integers.eq exitRepeat,c_TRUE
				end.if
			end.if
	
;		end.if
	end.repeat

;	-----------------------------------
;	WE HAVE A CONTINUATION CHARACTER
;	-----------------------------------
	if b_Continuation,=,c_TRUE												; If we have one
		if b_firstLine,=,c_FALSE											; and its the 1st one
			integers.eq b_firstLine,c_TRUE									;	set 1st to true (drop thru)
		else																; ELSE
			EXIT.SUB D_4_LinuxDEBUG											;	we dont want to write DEBUG
		end.if
	end.if

	if b_Continuation,=,c_FALSE												; If we DONT have one
		if b_firstLine,=,c_TRUE												; and we have already found a first line
			integers.eq b_firstLine,c_FALSE									;	set first line to false
			EXIT.SUB D_4_LinuxDEBUG											;	we dont want to write DEBUG
		end.if
	end.if

;	-----------------------------------------
;	PROCCESS - add DEBUG macro
;	-----------------------------------------    
	words.pad spaces(1),w_saveLine											; clear the buffer
	words.copy 'DEBUG',{w_saveLine,123}										; move the literal to the end of the line
	files.write out_File,w_saveLine											; and write the record
	
END.SUB D_4_LinuxDEBUG
;		EXIT

;=======================================================================
;   Insert Line Labels and write the exports/globals files
;=======================================================================
BEGIN.SUB D_5_WindowsDEBUG

;	-----
;	EXITS
;	-----
    .if  b_Debug,=,c_TRUE													; If debug has been requested 
	.and b_Windows,=,c_TRUE													; and its Windows
	.end																	; continue
	else																	; ELSE
		EXIT.SUB D_5_WindowsDEBUG											; EXIT		
	end.if																	; END


	words.find {"BEGIN.SUB",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if
	
	words.find {"END.SUB",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

	words.find {"BEGIN.FUNCTION",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

	words.find {"END.FUNCTION",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

	words.find {"%INCLUDE",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

	words.find {"%MACRO",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

	words.find {"%ENDMACRO",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

	words.find {":",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

	words.find {".DATA",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if
	
	words.find {".TEXT",I},w_UBuffer
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

	words.find {"INSERT",I},w_UBuffer										;	insertnumber/word in procedure
	if I,>,0
		exit.sub D_5_WindowsDEBUG
	end.if

;	---------
;	Now do it
;	---------
	integers.add n_DebugCtr,1
	words.pad 'D',w_Temp30		
	words.copy n_DebugCtr,{w_Temp30,2}
	words.copy ':',{w_Temp30,7}
	words.insert {w_Temp30,1,7},PR_Line
	integers.add PR_CommandLength,7


	words.pad "/export:",w_Temp30											; move in the export literal
	words.copy {PR_Line,1,6},{w_Temp30,9}									; copy back the label
	files.write exports_File,w_Temp30										; and write the record	

	words.pad "global",w_Temp30												; move in the global literal
	words.copy {PR_Line,1,6},{w_Temp30,8}									; copy back the label
	Files.write globals_File,w_Temp30										; and write the record

END.SUB D_5_WindowsDEBUG
;		EXIT

;***************** V2.12 Tuning Modifications ******************
;=======================================================================
;		  This could begin the process of actual real compiling
;=======================================================================
BEGIN.SUB E_1_Compile 		

;gotta do this for macros too

	[section .data]
		insertnumber	n_Started,		0
		insertnumber	n_StartPoint,	0
		insertnumber 	n_tokenNo,		0
		insertnumber	n_Len,			0,'999999'
		insertnumber	n_Len1,			0,'999999'
		insertnumber	n_Len2,			0,'999999'
	[section .text]

;	----------
;	Initialise
;	----------T
	integers.eq n_tokenNo,0													; Initialise work fields
	integers.eq n_Started,0													; Initialise fields
	
	words.pad 	spaces(1),TK_Token
	integers.eq TK_Length,0
	tables.rput TokenTable,1
	tables.rput TokenTable,2
	tables.rput TokenTable,3	
	
;	--------------------
;	Extract the 3 tokens
;	--------------------
	repeat.for I,1,PR_CommandLength											; START loop thru record
	
;		if {PR_Line,I,1},_IN,{'"',"'"}										; Cannot work with literals as yet
;			exit.sub E_1_Compile
;		end.if
		
		if {PR_Line,I,1},_IN,{' ',x_Tab,x_LF,','}							; Have we hit a delimiter

			if  n_Started,=,c_TRUE											; If we have already started a token
				integers.eq   n_Started,c_FALSE								; set the start flag to false
				integers.calc TK_Length,=,I,-,J								; calculate the length
				words.pad     {PR_Line,J,TK_Length},TK_Token				; copy it to token field
				tables.rput   TokenTable,n_tokenNo							; and save it
			end.if															; END

		else																; ELSE

			if {PR_Line,I,1},_IN,{'{','}'}									; if the word is qualified
				exit.sub E_1_Compile										; we are out
			else															; ELSE
				if n_Started,=,c_FALSE										; if we are starting a new token
					integers.add n_tokenNo,1								; indicate which one it is
					if n_tokenNo,=,1										; if its the 1st one 
						integers.eq n_StartPoint,I							; save its location
					else													; ELSE
						if n_tokenNo,>,3									; if we already have 3
							exit.sub E_1_Compile							; we are out
						end.if												; END
					end.if													; END
					integers.eq n_Started,c_TRUE							; set the start token flag to true
					integers.eq J,I											; save the start location
				end.if														; END
			end.if															; END
	
		end.if																; END
	end.repeat																; END loop	

	if  n_Started,=,c_TRUE													; If we have already started a token
	;	Here if you hit End Of Line
		integers.calc TK_Length,=,I,-,J										; calculate the length
		words.pad     {PR_Line,J,TK_Length},TK_Token						; copy it to token field
		tables.rput   TokenTable,3											; and save it
	end.if																	; END

;	----------------------------------
;	Only looking for words.copy or pad
;	----------------------------------
	tables.rget TokenTable,1
	words.uppercase TK_Token
	.if  TK_Token,!=,"WORDS.COPY"
	.and TK_Token,!=,"WORDS.PAD"
	.end
		exit.sub E_1_Compile
	end.if

;	------------------------
;	Compare length of fields
;	------------------------
	tables.rget TokenTable,3												; Grab the 3rd Token	
	words.pad TK_Token,w_Temp30												; copy it to w_Temp30 for DataName search
	Call X_5_SearchByName													; make the call
	if  DataNameTable_STATUS,=,0											; Cannot work with literals
		integers.eq n_Len2,DN_Length										; and store the length
	
		tables.rget TokenTable,2											; Grab the 2nd Token	
		words.pad TK_Token,w_Temp30											; copy it to w_Temp30 for DataName search
		Call X_5_SearchByName												; make the call
		if  DataNameTable_STATUS,=,0										; Cannot work with literals		
			integers.eq n_Len1,DN_Length									; and store the length
		else																; ELSE
			exit.sub E_1_Compile											; EXIT
		end.if																; END
	else																	; ELSE
		exit.sub E_1_Compile												; EXIT
	end.if																	; END			

	if n_Len1,!<,n_Len2
		integers.eq n_Len,n_Len2
	else
		integers.eq n_Len,n_Len1
	end.if
	 
;	-------------------------
;	Comment the original Line
;	-------------------------
	words.copy ";",{PR_Line,n_StartPoint}									; Comment out the original record
	files.write out_File,{PR_Line,1,PR_CommandLength}						; and write it out

;	----------------------
;	Setup the source field
;	----------------------	
	words.pad "mov RSI,",{PR_Line,n_StartPoint}								; Enter the assembler code for RSI
	integers.calc I,=,n_StartPoint,+,8										; Calculate the insertion point
	words.copy {TK_Token,1,TK_Length},{PR_Line,I}							; Insert the source field
	integers.calc J,=,I,+,TK_Length,+,1										; Calculate line length
	files.write out_File,{PR_Line,1,J}										; and write it out

;	---------------------------
;	Setup the destination field
;	---------------------------	
	words.pad "mov RDI,",{PR_Line,n_StartPoint}								; Enter the assembler code for RDI 
	tables.rget TokenTable,3												; Grab the 3rd Token	
	words.copy {TK_Token,1,TK_Length},{PR_Line,I}							; Insert the destination field
	integers.calc J,=,I,+,TK_Length,+,1										; Calculate line length
	files.write out_File,{PR_Line,1,J}										; and write it out

;	----------------
;	Setup the length
;	----------------		
	words.pad "mov rcx,",{PR_Line,n_StartPoint}								; Enter the assembler code for RCX
	words.copy n_Len,{PR_Line,I}											; Insert the Length
	integers.calc J,=,I,+,6													; Calculate line length
	files.write out_File,{PR_Line,1,J}										; and write it out

;***The caller will write this one out	
	words.pad "Call _MOVSTR",{PR_Line,n_StartPoint}						; Enter the assembler code for the Call

;	-----------------
;	PAD or Not 
;	-----------------	
	tables.rget TokenTable,1
	words.uppercase TK_Token
	if TK_Token,=,"WORDS.COPY"
	;	-----------------
	;	Code for the Call 
	;	-----------------	

	else
		if n_Len2,>,n_Len1
			files.write out_File,{PR_Line,1,J}								; and write it out

		;	---------------------------
		;	Setup the destination field
		;	---------------------------	
			words.pad "mov RDI,",{PR_Line,n_StartPoint}								; Enter the assembler code for RDI 
			tables.rget TokenTable,3												; Grab the 3rd Token	
			words.copy {TK_Token,1,TK_Length},{PR_Line,I}							; Insert the destination field
			integers.calc J,=,I,+,TK_Length,+,1										; Calculate line length
			files.write out_File,{PR_Line,1,J}										; and write it out

			words.pad "add RDI,",{PR_Line,n_StartPoint}								; Enter the assembler code for RDI
			integers.calc I,=,n_StartPoint,+,8 
			words.copy n_Len1,{PR_Line,I}
			integers.calc J,=,I,+,6													; Calculate line length
			files.write out_File,{PR_Line,1,J}										; and write it out

			words.pad "mov RCX,",{PR_Line,n_StartPoint}								; Enter the assembler code for RDI
			words.copy n_Len2,{PR_Line,I}
			integers.calc J,=,I,+,6													; Calculate line length
			files.write out_File,{PR_Line,1,J}										; and write it out

			words.pad "sub RCX,",{PR_Line,n_StartPoint}								; Enter the assembler code for RDI
			words.copy n_Len1,{PR_Line,I}
			integers.calc J,=,I,+,6													; Calculate line length
			files.write out_File,{PR_Line,1,J}										; and write it out

			words.pad "Call _PADSTR",{PR_Line,n_StartPoint}						; Enter the assembler code for the Call
		;***The caller will write this one out	
		end.if
	end.if
	
END.SUB E_1_Compile

;-------------------------------------------------------------------------------
;   $Call from multiple places
;-------------------------------------------------------------------------------
BEGIN.SUB X_1_CheckQuotes

;   A quote could contain a "spaces(n)" or "(" or ")" or "|" or "[" or "]"
;   so ensure it is not processed

   .If {PR_Line,X_1_Idx,1},=,'"'
   .or {PR_Line,X_1_Idx,1},=,"'"
  .end
		If  w_Quote,=,spaces(1)
			Words.copy {PR_Line,X_1_Idx,1},w_Quote
		else
			if {PR_Line,X_1_Idx,1},=,w_Quote
				Words.copy spaces(1),w_Quote
			end.if
		end.if
	end.if

END.SUB X_1_CheckQuotes
;	EXIT

;   -------------------------------
;   Maybe $Call from multiple places
;	but onlyC_3_2_2_FP_inProcedure 
;	at present
;   -------------------------------
BEGIN.SUB X_2_CheckBraces

	If {PR_Line,X_2_Idx,1},=,'{'
		words.copy '{',w_Brace
	else
		If {PR_Line,X_2_Idx,1},=,'}'
			words.copy '}',w_Brace 
		else
			If w_Brace,=,'}'
				words.copy spaces(1),w_Brace
			end.if
		end.if 	
	end.if

END.SUB X_2_CheckBraces
;	EXIT

;   -------------------------------
;   Maybe $Call from multiple places
;		C_3_4_1_StoreDataDefinitions
;		C_3_4_2_StoreSystemDefinitions
;   -------------------------------
BEGIN.SUB X_3_PutXtable

	integers.add DataNameRecord_NO,1										; Increment the record number
	if DataNameRecord_NO,>,c_DN_noOfRecs
		files.write STDOUT,'10: X_3_PutXtable:DataNameRecord Table Overflow'
		TERMINATE 09
	else
		tables.rput DataNameTable,DataNameRecord_NO							; write the table entry
	end.if
	
END.SUB X_3_PutXtable
;	EXIT

;   -------------------------------
;	$Called by
;		C_3_2_1_1_GetSynonym
;   -------------------------------
BEGIN.SUB X_4_PutXtable

	integers.add SynonymRecord_NO,1											; Increment the record number
	integers.eq SynonymTable_UBOUND,SynonymRecord_NO
	if SynonymRecord_NO,>,c_SR_noOfRecs
		files.write STDOUT,'10: X_4_PutXtable:SynonymRecord Table Overflow'
		TERMINATE 10
	else
		xtables.rput SynonymTable,SynonymRecord_NO							; write the table entry
	end.if

END.SUB X_4_PutXtable
;	EXIT

;	---------------------------
;	Called from numerous places
;	---------------------------
BEGIN.SUB X_5_SearchByName

	[section .data]
		insertnumber X_4_Idx,0
	[section .text]

	integers.eq X_4_Idx,1
	tables.rget DataNameTable,X_4_Idx

	repeat.while DataNameTable_STATUS,=,0

		if DN_Name,=,w_Temp30
			words.copy DN_Type,w_DataType
			integers.eq exitRepeat,c_TRUE
		else
			integers.add X_4_Idx,1
			tables.rget DataNameTable,X_4_Idx

		end.if

	end.repeat
	
END.SUB X_5_SearchByName
;	EXIT

;	---------------------------------------
;	Only Called from C_3_4_SetupCalc so far
;	Used to matcha table to a record
;	---------------------------------------
BEGIN.SUB X_6_SearchByRecord

;	AS THIS CAN RETURN MULTIPLE RECORDS (1 per CAll)
;	set the Record_No (0 if beginning) and keep calling it until
;	Status is non zero

	[section .data]
		insertnumber X_5_Idx,0
	[section .text]

	integers.add X_5_Idx,1
	tables.rget DataNameTable,X_5_Idx

	repeat.while DataNameTable_STATUS,=,0
		if DN_Record,=,w_SaveRecordName
			integers.eq exitRepeat,c_TRUE
		else
			integers.add X_5_Idx,1
			tables.rget DataNameTable,X_5_Idx
		end.if
	end.repeat

END.SUB X_6_SearchByRecord
;	EXIT

;   -------------------------------
;   Maybe $Call from multiple places
;	$Called via macro mExtractText
;   -------------------------------
BEGIN.SUB X_7_ExtractText

	[section .data]
		insertnumber Z,0
	[section .text]

	integers.eq n_Start,0													; Initialise the start position
	integers.eq n_Length,0														; Initialise the length
	
	repeat.for Z,n_beginAt,PR_CommandLength										; From beginning to end of text
	
		if {PR_Line,Z,1},_IN,{' ',x_Tab,x_LF,w_Char1}						; These are our delimiters (ignore leading ones)
			if n_Start,>,0													; and (terminate on trailing ones) 
				integers.eq exitRepeat,c_TRUE
			end.if
		else																; ELSE
			if n_Start,=,0													;	IF we havent started yet		
				integers.eq n_Start,Z										;		mark the beginning
			end.if															; END
			integers.add n_Length,1											; Count the No Of Characters
		end.if

	end.repeat

END.SUB X_7_ExtractText
;	EXIT

;-----------------------------------------------------------------------
;   Reuse new data or create new field
;----------------------------------------------------------------------
BEGIN.SUB X_8_NewData

;	-------------------------
;	SEARCH FOR EXISTING MATCH
;	-------------------------
	integers.eq J,c_FALSE													; Using J as found flag
	integers.eq I,1															; Start the table at 1
	xtables.rget NewDataTable,I												; and grab the record

	repeat.while NewDataTable_STATUS,=,0									; LOOP until end of records

		begin.test w_DataType

			when =,c_Integer												; looking for integer
			   .if  ND_Type,=,c_Integer										; If found
			  .and  ND_ReUsable,=,spaces(1)									; and its free
			  .and {ND_Entry,23,30},=,DN_Picture							; and picture matches
			  .end
					integers.eq J,c_TRUE									;	set found to true
				end.if
			wend

			when =,c_FixedPoint												; looking for FP Number
			   .if  ND_Type,=,c_FixedPoint									; If found
			  .and  ND_ReUsable,=,spaces(1)									; and its free
			  .and {ND_Entry,23,30},=,DN_Picture							; and picture matches
			  .end
					integers.eq J,c_TRUE									;	set found to true
				end.if
			wend

			when =,c_Word													; Looking for a Word (Table entries only)
			   .if ND_Type,=,c_Word											; If found
			  .and ND_ReUsable,=,spaces(1)									; and its free
			  .end
					numbers.eq J,{ND_Entry,21,6}							;	convert to number
					if J,=,DN_Length										; 	if a match
						integers.eq J,c_TRUE								;		set found to true
					end.if
				end.if
			wend

		end.test 

		if J,=,c_TRUE
			words.copy 'N',ND_ReUsable										;	set it to inUse
			xtables.rput NewDataTable,I										;	rewrite the record
			EXIT.SUB X_8_NewData											;	then exit subroutine
		else
			integers.add I,1												; increment the record number
			xtables.rget NewDataTable,I										; and grab the record
		end.if

	end.repeat

;	-----------------
;	BUILD A NEW ENTRY
;	----------------- 
	words.pad spaces(1),ND_FunctionName										; Clear this one out
	words.pad spaces(1),ND_Name												; Clear this out
	
	words.copy w_DataType,ND_Type											; Set Data Type
	words.copy 'N',ND_ReUsable												; Set as being NON-reUseable for his line
	words.pad x_Tab,ND_Entry												; Give it a tab first
	begin.test w_DataType

		when =,c_Integer													; looking for integer
			words.pad "insertnumber i0000,0",{ND_Entry,2}					;	then insert the integer
			if b_TableElement,=,c_TRUE										;	If table element
				words.copy ',',{ND_Entry,22}								;		stick in a comma
				words.copy DN_Picture,{ND_Entry,23}							;		grab the picture
			end.if
		wend

		when =,c_FixedPoint													; looking for FP Number
			words.pad "insertnumber n0000,0,",{ND_Entry,2}					;	then insert the FP
			if b_TableElement,=,c_TRUE										;	If table element
				words.copy DN_Picture,{ND_Entry,23}							;		grab picture
			else															;	else
				words.copy w_FP_Picture,{ND_Entry,23}						; 		Default Picture if numbers.calc
			end.if
		wend

		when =,c_Word														; looking for Word
			words.pad "insertword   a0000,000000,''",{ND_Entry,2}			;	then insert the Alpha
			words.copy DN_Length,{ND_Entry,21}								;	and its length			
		wend

	end.test

	integers.add n_NDNo,1													; increment the new data number
	words.copy n_NDNo,{ND_Entry,16}											; pop into the insert statement

	if n_NDNo,>,n_HighestNDNo												; If we need to create another one
		integers.eq n_HighestNDNo,n_NDNo									;	reset highest
		$Call X_9_NextNewDataSlot										;	next table slot
	end.if

END.SUB X_8_NewData
;	EXIT

;-----------------------------------------------------------------------
;   Grab the next slot in the New Data table
;----------------------------------------------------------------------
BEGIN.SUB X_9_NextNewDataSlot

	integers.add n_NDIdx,1
	if n_NDIdx,>,c_ND_noOfRecs
		files.write STDOUT,'08: D_X_1_NextNewDataSlot:New Data Table Overflow'
		TERMINATE 7
	else
		integers.eq NewDataTable_UBOUND,n_NDIdx								; increment the table UBOUND
		xtables.rput NewDataTable,n_NDIdx									; and write it
	end.if

END.SUB X_9_NextNewDataSlot
;	EXIT

;-----------------------------------------------------------------------
;   Grab the next slot in the Macro table
;----------------------------------------------------------------------
BEGIN.SUB X_10_NextTextSlot

	integers.add n_TextIdx,1
	if n_TextIdx,>,c_MR_noOfRecs	
		files.write STDOUT,'09: X_10_NextTextSlot:MacroRecord Table Overflow'
		TERMINATE 8
	else
		integers.eq MacroTable_UBOUND,n_TextIdx								; increment the table UBOUND
		xtables.rput MacroTable,n_TextIdx									; and write it
	end.if

END.SUB X_10_NextTextSlot
;	EXIT


;-----------------------------------------------------------------------
;   Used for debugging
;----------------------------------------------------------------------
BEGIN.SUB Z_Debug

	repeat.for n_LineCtr,1,ProgramTable_UBOUND
		xtables.rget ProgramTable,n_LineCtr	
		display n_LineCtr," ",PR_Type," ",PR_CommandLength," ",PR_LineLength," ",{PR_Line,1,128},LF
	end.repeat
	
	repeat.for I,1,c_DN_noOfRecs
		tables.rget DataNameTable,I
		if DataNameTable_STATUS,=,0
			files $write,STDOUT, {I,'99'},	' ',	\
					 DN_TableType,			' ',	\
					{DN_Table,1,20},		' ',	\
					{DN_Record,1,20},		' ',	\
					{DN_No,'999'},			' ',	\
					 DN_Type,				' ',	\
					{DN_Name,1,20},			' ',	\
					 DN_Length,				' ',	\
					{DN_Picture,1,20}
		end.if
	end.repeat
	
	repeat.for I,1,c_ND_noOfRecs
		xtables.rget NewDataTable,I
		if NewDataTable_STATUS,=,0
			files $write,STDOUT,{I,'99'},	' ',	\
				ND_Type,					' ',	\
				ND_ReUsable,				' ',	\
				ND_Entry,					' ',	\
				{ND_Name,1,20},				' ',	\
				{ND_FunctionName,1,20}
		end.if
	end.repeat

	repeat.for I,1,c_SR_noOfRecs
		xtables.rget SynonymTable,I
		if SynonymTable_STATUS,=,0
			display I," ",Synonym,' ',lenSynonym,' ',Original,' ',lenOriginal,LF
		end.if
	end.repeat
	
	repeat.for I,1,c_MR_noOfRecs
		xtables.rget MacroTable,I
		if MacroTable_STATUS,=,0
			display I," ",MR_MacroNo,' ',{MR_MacroLineItem,1,64},LF
		end.if
	end.repeat

END.SUB Z_Debug

