%line 1 w.LinuxToWindows.ASM
%assign debug 0
%include 'include/BEGIN.PROGRAM'

;		Convert Linux text files(LF=0x0A)
;		to WIndows text files 	(CRLF=0x0D0A)
;		Delete Non w. files in root directory

;=======================================================================
;		  PROGRAM DATA
;=======================================================================
;-----------------------------------------------------------------------
;			CONSTANTS
;-----------------------------------------------------------------------
%assign cNoOfDirs 4

;-----------------------------------------------------------------------
;			WORDS
;-----------------------------------------------------------------------
%include 'include/BEGIN.DICTIONARY'

	insertword x_Null,			0001,0x00
	insertword w_dirEntry,		0260,''
	insertword w_Linux,			0007,{'.linux',0x00}
	insertword w_Buffer,		0256,''
	
	insertword w_common,		0015,{'src\COMMON.LIB',0x00}
	insertword w_files,			0014,{'src\FILES.LIB',0x00}
	insertword w_stdio,			0014,{'src\STDIO.LIB',0x00}
	insertword w_www,			0012,{'src\WWW.LIB',0x00}
	insertword w_xtables,		0016,{'src\XTABLES.LIB',0x00}

	insertword w_V1_16_ONE_l,	0029,{'src\examples\V1.16.ONE.linux',0x00}
	insertword w_V1_16_ONE_w,	0031,{'src\examples\V1.16.ONE.windows',0x00}
	insertword w_V1_16_ONE,		0023,{'src\examples\V1.16.ONE',0x00}
	

%include 'include/END.DICTIONARY'

;-----------------------------------------------------------------------
;			NUMBERS
;-----------------------------------------------------------------------
%include 'include/BEGIN.MATRIX'

	insertnumber I,0
	insertnumber J,0
	insertnumber K,0
	
%include 'include/END.MATRIX'

;-----------------------------------------------------------------------
;			FILES
;-----------------------------------------------------------------------
%include 'include/BEGIN.FILES'

	insertfile c_DIRECTORY,In_Dir
	insertfile 0x0A,In_File
	insertfile c_LF,Out_File	

	begin.record 20,t_Record
		insertword 	t_Directory,20,''
	end.record t_Record
	
%include 'include/END.FILES'

;-----------------------------------------------------------------------
;			TABLES
;-----------------------------------------------------------------------
%include 'include/BEGIN.TABLES'

	inserttable t_Directories,20*cNoOfDirs
	
%include 'include/END.TABLES'

;-----------------------------------------------------------------------
;			MACROS
;-----------------------------------------------------------------------
%macro m_MarkEnd 2

	repeat.for %2,260,0
		.if {%1,%2,1},!=,spaces(1)
	   .and {%1,%2,1},!=,x_Null
	   .end
	  		integers.eq exitRepeat,c_TRUE
	  	end.if
	end.repeat 
	
	integers.add %2,1
	words.copy x_Null,{%1,%2,1}

%endmacro

;=======================================================================
;		PROGRAM INSTRUCTIONS
;		Mainline  
;=======================================================================
%include 'include/BEGIN.INSTRUCTIONS'

	$Call A_1_Initial

	repeat.for I,1,cNoOfDirs
	
		tables.rget t_Directories,I
		words.pad t_Directory,In_Dir
		m_MarkEnd In_Dir,J

		files.open In_Dir,$read
		files.read In_Dir,w_dirEntry
		repeat.while In_Dir_STATUS,=,0
		   .if RETURN_CODE,=,8 
		  .and {w_dirEntry,1,02},!=,'w_' 
		  .and {w_dirEntry,1,09},!=,'V1.16.ONE'
		  .and {w_dirEntry,1,20},!=,'w.LinuxToWindows.ASM'
		  .and {w_dirEntry,1,08},!=,'logo.jpg'
		  .and {w_dirEntry,1,16},!=,'LinuxPenguin.jpg'
		  .and {w_dirEntry,1,11},!=,'Windows.jpg'
		  .end
				$Call B_1_Process
			end.if
			files.read In_Dir,w_dirEntry
		end.repeat
		
	end.repeat

%include 'include/END.INSTRUCTIONS'
%include 'include/END.PROGRAM'      

;-----------------------------------------------------------------------
;	
;-----------------------------------------------------------------------
BEGIN.SUB A_1_Initial

;	------------------------------------------
;	Delete Files in languageONE Root Directory
;	------------------------------------------
	words.pad '.\*',In_Dir
	words.copy x_Null,{In_Dir,4,1}
	files.open In_Dir,$read
	files.read In_Dir,w_dirEntry
	repeat.while In_Dir_STATUS,=,0
	   .if RETURN_CODE,=,8 
	  .and {w_dirEntry,1,2},!=,'w.'
	  .end
	  		m_MarkEnd w_dirEntry,I
	  		files.remove w_dirEntry
		end.if
		files.read In_Dir,w_dirEntry
	end.repeat
	files.close In_Dir

;	-----------------------------------------
;	Delete Files in languageONE src Directory
;	-----------------------------------------
	files.remove w_common
	files.remove w_files
	files.remove w_stdio
	files.remove w_www
	files.remove w_xtables

;	--------------------------------------------------
;	Delete/Rename src\examples\V1.16.ONE.linux|windows
;	--------------------------------------------------
	files.remove w_V1_16_ONE_l
	files.rename w_V1_16_ONE_w,w_V1_16_ONE
	
;	----------------------------
;	Setup for File Modifications
;	----------------------------
	tables.bind t_Directories,t_Record,cNoOfDirs
	
	words.pad 'include\*',t_Directory		
		tables.rput t_Directories,1
	words.pad 'src\*',t_Directory			
		tables.rput t_Directories,2	
	words.pad 'src\examples\*',t_Directory	
		tables.rput t_Directories,3
	words.pad 'html\*',t_Directory	
		tables.rput t_Directories,4
		
END.SUB A_1_Initial

;-----------------------------------------------------------------------
;	
;-----------------------------------------------------------------------
BEGIN.SUB B_1_Process
	
;	-------------------
;	GRAB DIRECTORY NAME
;	-------------------
	tables.rget t_Directories,I 
	m_MarkEnd 	t_Directory,J
	words.pad 	t_Directory,In_File

;	-------------------------
;	SETUP FILE NAMES & RENAME
;	-------------------------
	integers.calc K,=,J,-,1
	words.pad w_dirEntry,{In_File,K}
	m_MarkEnd In_File,J
	words.pad In_File,Out_File
	words.pad w_Linux,{In_File,J} 
		
	files.rename Out_File,In_File

;	----
;	COPY
;	----
	display c_ClearScreen
	display.at 01,01,"Converting "
	display.at 01,12,{Out_File,1,32}
	
	files.open In_File,$read
	files.open Out_File,$write+$beginning

	integers.eq J,0
	files.read In_File,w_Buffer

	repeat.while In_File_STATUS,=,0

		if In_File_READLENGTH,=,0
			files.write Out_File,''
		else
			if {In_Dir,1,4},=,'html'
				Call B_1_1_Html
			end.if
			files.write Out_File,{w_Buffer,1,In_File_READLENGTH}
		end.if
		integers.add J,1
		display.at 01,45,{J,'9999'}

		files.read In_File,w_Buffer

	end.repeat
	
	files.close  In_File
	files.remove In_File
	files.close  Out_File

END.SUB B_1_Process


BEGIN.SUB B_1_1_Html

	words.find {'LinuxPenguin.jpg',K},w_Buffer
	if K,>,0
		words.pad '<img src="Windows.jpg" width="15%" height="15%"/>',{w_Buffer,4}
		integers.eq In_File_READLENGTH,52
	end.if	
	
END.SUB B_1_1_Html
