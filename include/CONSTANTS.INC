;========================================================================				
;	BEGIN CONSTANTS
;========================================================================	
	%define	c_TRUE  1
	%define	c_FALSE	0	

;	DECISIONS
;	=========												  	
;	Alternative A
;	-------------
	Equals					equ 00000001b
	isNOTEqualTo			equ 00000010b
	isLessThan				equ 00000100b
	isNOTLessThan 			equ 00001000b
	isGreaterThanOREqualTo	equ 00001000b

	isGreaterThan			equ 00010000b													
	isNOTGreaterThan		equ	00100000b
	isLessThanOREqualTo		equ 00100000b

;	Alternative B
; ---------------
	EQ						equ 00000001b
	N_EQ					equ 00000010b
	LT						equ 00000100b
	N_LT		 			equ 00001000b
	GT						equ 00010000b													
	N_GT					equ	00100000b
;-----------------

;	Alternative C
; ---------------
	;=						equ 00000001b
	;!=						equ 00000010b
	;<						equ 00000100b
	;!<			 			equ 00001000b
	;>						equ 00010000b													
	;!>						equ	00100000b
;----------------

;	Also can use IN
	_IN						equ 01000000b
	_NIN					equ 10000000b
;----------------

; Used in TEST macros - REDUNDANT
;	c_FIRST					equ 0x00
;	c_ALL					equ 0xFF
;------------------------------------

;	FILES
;	=====								  		
	$read 					equ	0x000
	$write	 				equ	0x001
	$readwrite				equ 0x002
	$open					equ 0x002
		$create				equ 0064	;0100octal
		$beginning			equ 0512	;1000octal
		$end				equ 1024	;2000octal
		$lock				equ	2048	;4000octal		
	$close					equ 0x003
	$start					equ 0x004
	$next					equ 0x005
	$delete					equ 0x006

	$filescopy				equ 0x007
	$rename					equ 0x008
	$remove					equ 0x009
	$chdir					equ 0x00A
	$getcwd					equ 0x00B

;	-----
;	V2.03
;	-----	
	$rlock					equ 0x00C
	$runlock				equ 0x00D

;	-----
;	V2.05
;	-----	
	$StringToRecord			equ 0x0E
	$RecordToString			equ 0x0F
	

;	Record Delimiters/CVS for INSERTFILE	
	c_NULL					equ 00000001b 
	c_LF					equ 00000010b 
	c_CSV					equ 00000100b
	c_RECORD				equ 00001000b
	c_RANDOM				equ 00010000b
	c_INDEXED				equ 00100000b
	c_DIRECTORY				equ	01000000b

;	NUMBERS
;	=======
	$add					EQU 00000001B
	$subtract				EQU 00000010B
	$multiply				EQU 00000100B
	$divide					EQU 00001000B
	$equals					EQU 00010000B
	$random					EQU 00100000B

;	(X)TABLES
;	=========
	$bind					EQU 00000001B
	$sort					EQU 00001000B
	$search					EQU	00010000B

	$rget	 				EQU	00000010B
	$fget					EQU 00000011B
	$rput	 				EQU	00000100B
	$fput					EQU 00000101B
;	XTABLES
	$del					EQU 00100000B
	$load					EQU 01000000B
	$unload					EQU 10000000B
	
;	WORDS
;	=====
	$copy					equ 00000001b
	$pad					equ 00000010b													
	$uppercase 				equ	00000100b							
	$lowercase 				equ	00001000b
	$insert					equ 00010000b
	$find					equ 00100000b
	$replace				equ 01000000b
	$environment 			equ 10000000b
;	-----
;	V2.05
;	-----
	$stringtorecord			equ 10000001b			; be careful with these
	$recordtostring			equ 10000010b			; Must use cmp NOT test

;	WWW
;	===
	$wwwOpen				equ 0000						
	$wwwProcess				equ 0001							
	$wwwClose				equ 0002
;	-----
;	V2.04
;	-----		
	$wwwSendMsg				equ 0003
	$wwwRecvMsg				equ 0004

;	-----
;	V2.13
;	-----	
;	STDIO
	
	%define RETURN			000
	%define FUNCTIONKEY1   	001
	%define FUNCTIONKEY2   	002
	%define FUNCTIONKEY3   	003
	%define FUNCTIONKEY4   	004
	%define FUNCTIONKEY5   	005
	%define FUNCTIONKEY6   	006
	%define FUNCTIONKEY7   	007
	%define FUNCTIONKEY8   	008
	%define FUNCTIONKEY9   	009
	%define FUNCTIONKEY10  	010
	%define FUNCTIONKEY11  	011
	%define FUNCTIONKEY12  	012
	%define ALT				013
	%define ARROWUP			014
	%define ARROWDOWN		015
	%define ARROWRIGHT		016
	%define ARROWLEFT		017
	%define END				018
	%define HOME			019
	%define INSERT			020
	%define ENDOFFIELD		021
	%define ESCAPE			027
	%define BACKSPACE		127
	%define NULL			999

;	WINDOWS SPECIFIC
;	================
	wc_STD_IN				equ -10		; GetStdHandle
	wc_STD_OUT				equ -11		; GetStdHandle
	wc_STD_ERR				equ -12		; GetStdHandle

;========================================================================				
;	END CONSTANTS
;========================================================================	

