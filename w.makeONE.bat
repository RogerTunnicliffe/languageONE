set dw=%1
set dw=%dw:D=D%
set dw=%dw:W=W%
if [%dw%]==[-DW] goto debug

set prog=%1
C:\Users\roger\_dev1\source\languageONE\bin\languageONE %prog%
goto assemble

:debug
set prog=%2
C:\Users\roger\_dev1\source\languageONE\bin\languageONE -DW %prog%

:assemble
if errorlevel 1 goto end
Call C:\Users\roger\_dev1\source\languageONE\w.assemble %prog%.ASM
if errorlevel 1 goto end
Call C:\Users\roger\_dev1\source\languageONE\w.PellesClink %prog%

:end
