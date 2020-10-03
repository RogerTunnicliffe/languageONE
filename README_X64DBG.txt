YOU HAVE A MACRO IN w_FILES.LIB for printing from a .LIB

x64dbg instructions.

1] You must /export sysmbols from the link command line. ie:-
C:\Users\roger\_dev1\source\languageONE\_GOLINK\golink /Console /entry _start /debug coff /export _NEXT %1.obj @w.golink.libraries

2] Enter the COMMAND LINE options each time and remember there are TWO spaces befor the 1st parameter
