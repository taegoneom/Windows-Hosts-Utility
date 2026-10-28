@echo off
if /i "%~1"=="--hu-run" goto HU_MAIN
"%ComSpec%" /d /a /c ""%~f0" --hu-run %*"
exit /b

:HU_MAIN
setlocal EnableExtensions EnableDelayedExpansion
set "HU_WORK="

title Windows Hosts Utility
set "HU_MSG_TARGET=Hosts path:"
set "HU_MSG_MENU1=1. Add a new mapping"
set "HU_MSG_MENU2=2. View current entries"
set "HU_MSG_MENU3=3. Remove one entry by number"
set "HU_MSG_MENU4=4. Usage"
set "HU_MSG_MENU0=0. Exit"
set "HU_MSG_SELECT=Select [1/2/3/4/0]:"
set "HU_MSG_TABLE=--- Registered entries ---"
set "HU_MSG_EMPTY=No entries found. Address lookups use the DNS server configured on the IPv4 adapter or router."
set "HU_MSG_IP_FIELD=IP:"
set "HU_MSG_NOTE_FIELD=Description:"
set "HU_MSG_NO_NOTE=No description was entered for this entry."
set "HU_MSG_NOTE_INPUT=Comment (optional, Enter to skip):"
set "HU_MSG_NAME=Hostname, e.g. app.test [Enter: cancel]:"
set "HU_MSG_IP=IP address [Enter: 127.0.0.1]:"
set "HU_MSG_BAD_HOST=Enter a hostname using letters, numbers, dots and hyphens. Example: app.test"
set "HU_MSG_BAD_IP=Enter a valid IP address."
set "HU_MSG_PREVIEW_ADD=Will add:"
set "HU_MSG_LOOPBACK_HINT=Without a local server at this address and port, the connection will fail."
set "HU_MSG_SERVER_HINT=Check that this IP address belongs to the server you want to connect to."
set "HU_MSG_PREVIEW_REMOVE=Will remove:"
set "HU_MSG_REMOVE_SCOPE=Only this hostname will be removed. Other names and comments on the same line are kept."
set "HU_MSG_REMOVE_CONFIRM=Check the entry above before deleting. [1: delete / anything else: cancel]:"
set "HU_MSG_CONFIRM=Execute this change? [1: execute / anything else: cancel]:"
set "HU_MSG_REMOVE_NUMBER=Number to remove [0: cancel]:"
set "HU_MSG_SUCCESS=Done."
set "HU_MSG_CACHE_OK=DNS cache refreshed. Changes apply to new address lookups."
set "HU_MSG_CACHE_FAIL=Changes were saved, but the DNS cache could not be refreshed."
set "HU_MSG_RESTART=Check menu 2. If needed, restart the application or reboot your PC."
set "HU_MSG_DUPLICATE=This entry already exists."
set "HU_MSG_CONFLICT=This hostname has another IP address. Review the current entries."
set "HU_MSG_CHANGED=The file has changed. View the entries again."
set "HU_MSG_READ_ONLY=The file is read-only and cannot be edited."
set "HU_MSG_UNSUPPORTED=This file format cannot be edited. Viewing is available."
set "HU_MSG_WRITE_FAILED=Could not save. Check whether another program is using the file."
set "HU_MSG_ADMIN=Please run this utility as administrator."
set "HU_MSG_READ_FAILED=Could not read hosts."
set "HU_MSG_CANCEL=Cancelled."
set "HU_MSG_AGAIN=[1: main menu / Enter: close]:"
set "HU_MSG_MISSING=The hosts file was not found."
set "HU_MSG_TEMP_FAILED=Could not start. Please run the utility again."
set "HU_MSG_EXIT=Press Enter to close this window."
for /f "tokens=2 delims=:" %%C in ('chcp') do for %%N in (%%C) do set "HU_UI_CP=%%N"
if not defined HU_UI_CP set "HU_UI_CP=949"
set "HU_TAB=	"
set "HU_TARGET=%SystemRoot%\System32\drivers\etc\hosts"
if exist "%SystemRoot%\Sysnative\drivers\etc\hosts" set "HU_TARGET=%SystemRoot%\Sysnative\drivers\etc\hosts"
set "HU_ADMIN_TOOL=%SystemRoot%\System32\fltmc.exe"
if exist "%SystemRoot%\Sysnative\fltmc.exe" set "HU_ADMIN_TOOL=%SystemRoot%\Sysnative\fltmc.exe"
"!HU_ADMIN_TOOL!" >nul 2>&1
if errorlevel 1 goto HU_ADMIN_REQUIRED
echo === Windows Hosts Utility ===
echo !HU_MSG_TARGET! !HU_TARGET!
if not exist "!HU_TARGET!" goto HU_MISSING
for %%D in ("%TEMP%\.") do set "HU_TEMPBASE=%%~fD"
:HU_TEMP_RETRY
set "HU_WORK=!HU_TEMPBASE!\WindowsHostsUtility_!RANDOM!_!RANDOM!"
if exist "!HU_WORK!" goto HU_TEMP_RETRY
md "!HU_WORK!" >nul 2>&1
if errorlevel 1 goto HU_TEMP_FAILED

:HU_MENU
call :HU_SCREEN
echo.
echo !HU_MSG_MENU1!
echo !HU_MSG_MENU2!
echo !HU_MSG_MENU3!
echo !HU_MSG_MENU4!
echo !HU_MSG_MENU0!
set "HU_CHOICE="
set /p "HU_CHOICE=!HU_MSG_SELECT! "
if not defined HU_CHOICE goto HU_DONE
if "!HU_CHOICE!"=="1" goto HU_ADD
if "!HU_CHOICE!"=="2" goto HU_VIEW
if "!HU_CHOICE!"=="3" goto HU_REMOVE
if "!HU_CHOICE!"=="4" goto HU_HELP
if "!HU_CHOICE!"=="0" goto HU_DONE
goto HU_MENU

:HU_SCREEN
cls
echo === Windows Hosts Utility ===
echo !HU_MSG_TARGET! !HU_TARGET!
exit /b

:HU_SNAPSHOT
copy /b /y "!HU_TARGET!" "!HU_WORK!\original.tmp" >nul 2>&1
if errorlevel 1 exit /b 1
set "HU_FILE_CP=!HU_UI_CP!"
call :HU_REBUILD_TEXT
fc /b "!HU_WORK!\original.tmp" "!HU_WORK!\roundtrip.tmp" >nul 2>&1
if not errorlevel 1 exit /b 0
if "!HU_FILE_CP!"=="65001" exit /b 0
chcp 65001 >nul 2>&1
if errorlevel 1 exit /b 0
set "HU_FILE_CP=65001"
call :HU_REBUILD_TEXT
chcp !HU_UI_CP! >nul 2>&1
exit /b 0

:HU_REBUILD_TEXT
chcp !HU_FILE_CP! >nul 2>&1
set "HU_COUNT=0"
set "HU_FOUND=0"
type nul >"!HU_WORK!\roundtrip.tmp"
type nul >"!HU_WORK!\stage.tmp"
type nul >"!HU_WORK!\entries.tmp"
del /f /q "!HU_WORK!\note_*.tmp" >nul 2>&1
setlocal DisableDelayedExpansion
for /f "usebackq delims=" %%L in (`findstr /n "^" "%HU_WORK%\original.tmp"`) do (
    set "HU_RAW=%%L"
    call :HU_PROCESS_LINE
)
endlocal & set "HU_COUNT=%HU_COUNT%" & set "HU_FOUND=%HU_FOUND%"
chcp !HU_UI_CP! >nul 2>&1
exit /b 0

:HU_PROCESS_LINE
setlocal EnableDelayedExpansion
set "HU_LINE=!HU_RAW:*:=!"
>>"!HU_WORK!\roundtrip.tmp" echo(!HU_LINE!
if not defined HU_LINE (
    >>"!HU_WORK!\stage.tmp" echo.
    goto HU_LINE_RETURN
)
set "HU_CODE=!HU_LINE!"
set "HU_COMMENT="
set /a HU_POS=0
:HU_SPLIT_COMMENT
set "HU_CHAR=!HU_LINE:~%HU_POS%,1!"
if not defined HU_CHAR goto HU_NOTE_INIT
if "!HU_CHAR!"=="#" (
    set "HU_CODE=!HU_LINE:~0,%HU_POS%!"
    set "HU_COMMENT=!HU_LINE:~%HU_POS%!"
    goto HU_NOTE_INIT
)
set /a HU_POS+=1
goto HU_SPLIT_COMMENT

:HU_NOTE_INIT
set "HU_NOTE_TEXT="
if defined HU_COMMENT set "HU_NOTE_TEXT=!HU_COMMENT:~1!"
:HU_NOTE_TRIM
if not defined HU_NOTE_TEXT goto HU_TOKEN_INIT
if "!HU_NOTE_TEXT:~0,1!"==" " goto HU_NOTE_SKIP
if "!HU_NOTE_TEXT:~0,1!"=="!HU_TAB!" goto HU_NOTE_SKIP
goto HU_TOKEN_INIT
:HU_NOTE_SKIP
set "HU_NOTE_TEXT=!HU_NOTE_TEXT:~1!"
goto HU_NOTE_TRIM

:HU_TOKEN_INIT
set /a HU_SCAN=0,HU_TOKENS=0,HU_REMOVE_START=-1,HU_REMOVE_END=-1,HU_IP_START=0
if not defined HU_CODE goto HU_EMIT_LINE
:HU_SKIP_SPACE
set "HU_CHAR=!HU_CODE:~%HU_SCAN%,1!"
if not defined HU_CHAR goto HU_EMIT_LINE
if "!HU_CHAR!"==" " goto HU_NEXT_SPACE
if "!HU_CHAR!"=="!HU_TAB!" goto HU_NEXT_SPACE
set "HU_TOKEN_START=!HU_SCAN!"
goto HU_READ_TOKEN
:HU_NEXT_SPACE
set /a HU_SCAN+=1
goto HU_SKIP_SPACE
:HU_READ_TOKEN
set "HU_CHAR=!HU_CODE:~%HU_SCAN%,1!"
if not defined HU_CHAR goto HU_TOKEN_READY
if "!HU_CHAR!"==" " goto HU_TOKEN_READY
if "!HU_CHAR!"=="!HU_TAB!" goto HU_TOKEN_READY
set /a HU_SCAN+=1
goto HU_READ_TOKEN
:HU_TOKEN_READY
set /a HU_TOKEN_LEN=HU_SCAN-HU_TOKEN_START,HU_TOKENS+=1
set "HU_TOKEN=!HU_CODE:~%HU_TOKEN_START%,%HU_TOKEN_LEN%!"
if "!HU_TOKENS!"=="1" (
    set "HU_IP=!HU_TOKEN!"
    set "HU_IP_START=!HU_TOKEN_START!"
    set "HU_INPUT=!HU_IP!"
    call :HU_VALIDATE_IP
    if errorlevel 1 goto HU_EMIT_LINE
) else (
    set "HU_INPUT=!HU_TOKEN!"
    call :HU_VALIDATE_HOST
    if not errorlevel 1 (
        set /a HU_COUNT+=1
        >>"!HU_WORK!\entries.tmp" echo(!HU_COUNT!^|!HU_IP!^|!HU_TOKEN!
        >"!HU_WORK!\note_!HU_COUNT!.tmp" echo(!HU_NOTE_TEXT!
        if "!HU_ACTION!"=="REMOVE" if "!HU_COUNT!"=="!HU_SELECTED!" (
            set "HU_REMOVE_START=!HU_TOKEN_START!"
            set "HU_REMOVE_END=!HU_SCAN!"
            set "HU_FOUND=1"
        )
    )
)
goto HU_SKIP_SPACE

:HU_EMIT_LINE
if !HU_REMOVE_START! LSS 0 goto HU_EMIT_UNCHANGED
if "!HU_TOKENS!"=="2" (
    if defined HU_COMMENT (
        set "HU_LINE=!HU_LINE:~0,%HU_IP_START%!!HU_COMMENT!"
        >>"!HU_WORK!\stage.tmp" echo(!HU_LINE!
    )
    goto HU_LINE_RETURN
)
:HU_REMOVE_SPACE
if !HU_REMOVE_START! LEQ 0 goto HU_REMOVE_BUILD
set /a HU_BEFORE=HU_REMOVE_START-1
set "HU_CHAR=!HU_CODE:~%HU_BEFORE%,1!"
if "!HU_CHAR!"==" " goto HU_REMOVE_ONE_SPACE
if "!HU_CHAR!"=="!HU_TAB!" goto HU_REMOVE_ONE_SPACE
goto HU_REMOVE_BUILD
:HU_REMOVE_ONE_SPACE
set /a HU_REMOVE_START-=1
goto HU_REMOVE_SPACE
:HU_REMOVE_BUILD
set "HU_LINE=!HU_CODE:~0,%HU_REMOVE_START%!!HU_CODE:~%HU_REMOVE_END%!!HU_COMMENT!"
:HU_EMIT_UNCHANGED
>>"!HU_WORK!\stage.tmp" echo(!HU_LINE!
:HU_LINE_RETURN
endlocal & set "HU_COUNT=%HU_COUNT%" & set "HU_FOUND=%HU_FOUND%"
exit /b

:HU_VALIDATE_HOST
setlocal EnableDelayedExpansion
if not defined HU_INPUT goto HU_BAD_VALUE
if not "!HU_INPUT:~253!"=="" goto HU_BAD_VALUE
>"!HU_WORK!\input.tmp" echo(!HU_INPUT!
findstr /r /x /c:"[A-Za-z0-9][A-Za-z0-9.-]*" "!HU_WORK!\input.tmp" >nul
if errorlevel 1 goto HU_BAD_VALUE
if not "!HU_INPUT:..=!"=="!HU_INPUT!" goto HU_BAD_VALUE
if "!HU_INPUT:~-1!"=="." goto HU_BAD_VALUE
set "HU_LABELS=!HU_INPUT:.= !"
for %%S in (!HU_LABELS!) do (
    set "HU_LABEL=%%S"
    if "!HU_LABEL:~0,1!"=="-" goto HU_BAD_VALUE
    if "!HU_LABEL:~-1!"=="-" goto HU_BAD_VALUE
    if not "!HU_LABEL:~63!"=="" goto HU_BAD_VALUE
)
endlocal & exit /b 0

:HU_VALIDATE_IP
setlocal EnableDelayedExpansion
if not defined HU_INPUT goto HU_BAD_VALUE
>"!HU_WORK!\input.tmp" echo(!HU_INPUT!
findstr /r /x /c:"[0-9][0-9.]*" "!HU_WORK!\input.tmp" >nul
if errorlevel 1 goto HU_IPV6
if not "!HU_INPUT:..=!"=="!HU_INPUT!" goto HU_BAD_VALUE
if "!HU_INPUT:~-1!"=="." goto HU_BAD_VALUE
set /a HU_OCTETS=0
set "HU_OCTET_LIST=!HU_INPUT:.= !"
for %%O in (!HU_OCTET_LIST!) do (
    set "HU_OCTET=%%O"
    if not "!HU_OCTET:~3!"=="" goto HU_BAD_VALUE
    if not "!HU_OCTET:~1!"=="" if "!HU_OCTET:~0,1!"=="0" goto HU_BAD_VALUE
    set "HU_BASE=10"
    if not "!HU_OCTET:~1!"=="" set "HU_BASE=100"
    if not "!HU_OCTET:~2!"=="" set "HU_BASE=1000"
    set /a HU_NUMBER=1!HU_OCTET!-HU_BASE,HU_OCTETS+=1
    if !HU_NUMBER! GTR 255 goto HU_BAD_VALUE
)
if not "!HU_OCTETS!"=="4" goto HU_BAD_VALUE
endlocal & exit /b 0
:HU_IPV6
findstr /r /x /c:"[0-9A-Fa-f:][0-9A-Fa-f:]*" "!HU_WORK!\input.tmp" >nul
if errorlevel 1 goto HU_BAD_VALUE
if "!HU_INPUT::=!"=="!HU_INPUT!" goto HU_BAD_VALUE
if "!HU_INPUT:~0,1!"==":" if not "!HU_INPUT:~1,1!"==":" goto HU_BAD_VALUE
if "!HU_INPUT:~-1!"==":" if not "!HU_INPUT:~-2,1!"==":" goto HU_BAD_VALUE
set /a HU_INDEX=0,HU_DOUBLES=0,HU_RUN=0,HU_GROUPS=0
:HU_IPV6_CHAR
set "HU_C=!HU_INPUT:~%HU_INDEX%,1!"
if not defined HU_C goto HU_IPV6_GROUPS
if "!HU_C!"==":" (
    set /a HU_RUN+=1
    if !HU_RUN! GTR 2 goto HU_BAD_VALUE
    if !HU_RUN! EQU 2 set /a HU_DOUBLES+=1
) else (
    set "HU_RUN=0"
)
set /a HU_INDEX+=1
goto HU_IPV6_CHAR
:HU_IPV6_GROUPS
if !HU_DOUBLES! GTR 1 goto HU_BAD_VALUE
set "HU_GROUP_LIST=!HU_INPUT::= !"
for %%G in (!HU_GROUP_LIST!) do (
    set "HU_GROUP=%%G"
    if not "!HU_GROUP:~4!"=="" goto HU_BAD_VALUE
    set /a HU_GROUPS+=1
)
if "!HU_DOUBLES!"=="0" if not "!HU_GROUPS!"=="8" goto HU_BAD_VALUE
if "!HU_DOUBLES!"=="1" if !HU_GROUPS! GEQ 8 goto HU_BAD_VALUE
endlocal & exit /b 0
:HU_BAD_VALUE
endlocal & exit /b 1

:HU_TABLE
echo.
echo !HU_MSG_TABLE!
if "!HU_COUNT!"=="0" echo !HU_MSG_EMPTY!
for /f "usebackq tokens=1-3 delims=|" %%A in ("!HU_WORK!\entries.tmp") do (
    echo [%%A] %%C
    echo   !HU_MSG_IP_FIELD! %%B
    set "HU_NOTE_INDEX=%%A"
    call :HU_LOAD_NOTE
    echo.
)
exit /b

:HU_LOAD_NOTE
chcp !HU_FILE_CP! >nul 2>&1
setlocal DisableDelayedExpansion
for /f "usebackq delims=" %%D in (`findstr /n "^" "%HU_WORK%\note_%HU_NOTE_INDEX%.tmp"`) do (
    set "HU_NOTE_RAW=%%D"
    call :HU_PRINT_NOTE
)
endlocal
chcp !HU_UI_CP! >nul 2>&1
exit /b

:HU_PRINT_NOTE
setlocal EnableDelayedExpansion
set "HU_NOTE_SHOW=!HU_NOTE_RAW:*:=!"
if not defined HU_NOTE_SHOW set "HU_NOTE_SHOW=!HU_MSG_NO_NOTE!"
chcp !HU_UI_CP! >nul 2>&1
echo   !HU_MSG_NOTE_FIELD! !HU_NOTE_SHOW!
chcp !HU_FILE_CP! >nul 2>&1
endlocal
exit /b

:HU_VIEW
call :HU_SCREEN
set "HU_ACTION=VIEW"
call :HU_SNAPSHOT
if errorlevel 1 goto HU_READ_FAILED
call :HU_TABLE
goto HU_AFTER_ACTION

:HU_ADD
call :HU_SCREEN
set "HU_ACTION=ADD"
call :HU_SNAPSHOT
if errorlevel 1 goto HU_READ_FAILED
call :HU_CAN_EDIT
if errorlevel 1 goto HU_UNSUPPORTED
:HU_GET_NAME
set "HU_NAME="
set /p "HU_NAME=!HU_MSG_NAME! "
if not defined HU_NAME goto HU_CANCEL
set "HU_INPUT=!HU_NAME!"
call :HU_VALIDATE_HOST
if errorlevel 1 (
    echo !HU_MSG_BAD_HOST!
    goto HU_GET_NAME
)
:HU_GET_IP
set "HU_NEW_IP="
set /p "HU_NEW_IP=!HU_MSG_IP! "
if not defined HU_NEW_IP set "HU_NEW_IP=127.0.0.1"
set "HU_INPUT=!HU_NEW_IP!"
call :HU_VALIDATE_IP
if errorlevel 1 (
    echo !HU_MSG_BAD_IP!
    goto HU_GET_IP
)
set "HU_SAME=0"
set "HU_CONFLICT=0"
for /f "usebackq tokens=1-3 delims=|" %%A in ("!HU_WORK!\entries.tmp") do (
    if /i "%%C"=="!HU_NAME!" (
        if /i "%%B"=="!HU_NEW_IP!" (set "HU_SAME=1") else (set "HU_CONFLICT=1")
    )
)
if "!HU_CONFLICT!"=="1" goto HU_CONFLICT
if "!HU_SAME!"=="1" goto HU_DUPLICATE
set "HU_NEW_NOTE="
set /p "HU_NEW_NOTE=!HU_MSG_NOTE_INPUT! "
echo.
echo !HU_MSG_PREVIEW_ADD! !HU_NEW_IP! !HU_NAME!
if defined HU_NEW_NOTE (echo !HU_MSG_NOTE_FIELD! !HU_NEW_NOTE!) else (echo !HU_MSG_NOTE_FIELD! !HU_MSG_NO_NOTE!)
set "HU_LOCAL_HINT=0"
if "!HU_NEW_IP:~0,4!"=="127." set "HU_LOCAL_HINT=1"
set "HU_IP_WITHOUT_ZERO=!HU_NEW_IP:0=!"
set "HU_IP_REMAINDER=!HU_IP_WITHOUT_ZERO::=!"
if not "!HU_NEW_IP::=!"=="!HU_NEW_IP!" if "!HU_NEW_IP:~-1!"=="1" if "!HU_IP_REMAINDER!"=="1" set "HU_LOCAL_HINT=1"
if "!HU_LOCAL_HINT!"=="1" (echo !HU_MSG_LOOPBACK_HINT!) else (echo !HU_MSG_SERVER_HINT!)
set "HU_CONFIRM="
set /p "HU_CONFIRM=!HU_MSG_CONFIRM! "
if not "!HU_CONFIRM!"=="1" goto HU_CANCEL
chcp !HU_FILE_CP! >nul 2>&1
if defined HU_NEW_NOTE (
    >>"!HU_WORK!\stage.tmp" echo(!HU_NEW_IP! !HU_NAME! # !HU_NEW_NOTE!
) else (
    >>"!HU_WORK!\stage.tmp" echo(!HU_NEW_IP! !HU_NAME!
)
chcp !HU_UI_CP! >nul 2>&1
goto HU_COMMIT

:HU_REMOVE
call :HU_SCREEN
set "HU_ACTION=VIEW"
call :HU_SNAPSHOT
if errorlevel 1 goto HU_READ_FAILED
call :HU_TABLE
if "!HU_COUNT!"=="0" goto HU_AFTER_ACTION
call :HU_CAN_EDIT
if errorlevel 1 goto HU_UNSUPPORTED
:HU_GET_NUMBER
set "HU_SELECTED="
set /p "HU_SELECTED=!HU_MSG_REMOVE_NUMBER! "
if not defined HU_SELECTED goto HU_CANCEL
if "!HU_SELECTED!"=="0" goto HU_CANCEL
>"!HU_WORK!\input.tmp" echo(!HU_SELECTED!
findstr /r /x /c:"[1-9][0-9]*" "!HU_WORK!\input.tmp" >nul
if errorlevel 1 goto HU_GET_NUMBER
if not "!HU_SELECTED:~9!"=="" goto HU_GET_NUMBER
if !HU_SELECTED! GTR !HU_COUNT! goto HU_GET_NUMBER
call :HU_SCREEN
for /f "usebackq tokens=1-3 delims=|" %%A in ("!HU_WORK!\entries.tmp") do if "%%A"=="!HU_SELECTED!" echo !HU_MSG_PREVIEW_REMOVE! [%%A] %%B %%C
set "HU_NOTE_INDEX=!HU_SELECTED!"
call :HU_LOAD_NOTE
echo !HU_MSG_REMOVE_SCOPE!
set "HU_CONFIRM="
set /p "HU_CONFIRM=!HU_MSG_REMOVE_CONFIRM! "
if not "!HU_CONFIRM!"=="1" goto HU_CANCEL
set "HU_ACTION=REMOVE"
call :HU_REBUILD_TEXT
if not "!HU_FOUND!"=="1" goto HU_READ_FAILED
call :HU_CAN_EDIT
if errorlevel 1 goto HU_UNSUPPORTED
goto HU_COMMIT

:HU_CAN_EDIT
fc /b "!HU_WORK!\original.tmp" "!HU_WORK!\roundtrip.tmp" >nul 2>&1
if errorlevel 1 exit /b 1
exit /b 0

:HU_COMMIT
fc /b "!HU_WORK!\original.tmp" "!HU_TARGET!" >nul 2>&1
if errorlevel 1 goto HU_CHANGED
for %%F in ("!HU_TARGET!") do set "HU_ATTRIBUTES=%%~aF"
if not "!HU_ATTRIBUTES:r=!"=="!HU_ATTRIBUTES!" goto HU_READ_ONLY
copy /b /y "!HU_WORK!\stage.tmp" "!HU_TARGET!" >nul 2>&1
if errorlevel 1 goto HU_WRITE_FAILED
fc /b "!HU_WORK!\stage.tmp" "!HU_TARGET!" >nul 2>&1
if errorlevel 1 goto HU_WRITE_FAILED
echo !HU_MSG_SUCCESS!
echo !HU_MSG_TARGET! !HU_TARGET!
ipconfig /flushdns >nul 2>&1
if errorlevel 1 (echo !HU_MSG_CACHE_FAIL!) else (echo !HU_MSG_CACHE_OK!)
echo !HU_MSG_RESTART!
goto HU_AFTER_ACTION

:HU_HELP
call :HU_SCREEN
echo Usage
echo hosts maps a hostname to an IP address on this PC.
echo Example: 127.0.0.1 app.test # local development
echo Separate the IP address and hostname with spaces or tabs.
echo Text after # is a comment. Default comments and examples are not active entries.
echo 127.0.0.1 and ::1 point to this PC; a local server must be running to connect.
echo.
echo Add: enter a hostname, IP address and optional comment, then confirm.
echo View: display numbered entries with IP addresses and descriptions.
echo Remove: select an entry number. Other entries and comments are kept.
echo Enter a hostname such as app.test, without https://, a path or a port.
goto HU_AFTER_ACTION
:HU_DUPLICATE
echo !HU_MSG_DUPLICATE!
goto HU_AFTER_ACTION
:HU_CONFLICT
echo !HU_MSG_CONFLICT!
goto HU_AFTER_ACTION
:HU_CHANGED
echo !HU_MSG_CHANGED!
goto HU_AFTER_ACTION
:HU_READ_ONLY
echo !HU_MSG_READ_ONLY!
goto HU_AFTER_ACTION
:HU_UNSUPPORTED
echo !HU_MSG_UNSUPPORTED!
goto HU_AFTER_ACTION
:HU_WRITE_FAILED
echo !HU_MSG_WRITE_FAILED!
echo !HU_MSG_ADMIN!
goto HU_AFTER_ACTION
:HU_READ_FAILED
echo !HU_MSG_READ_FAILED!
goto HU_AFTER_ACTION
:HU_CANCEL
echo !HU_MSG_CANCEL!
:HU_AFTER_ACTION
echo.
set "HU_NEXT="
set /p "HU_NEXT=!HU_MSG_AGAIN! "
if "!HU_NEXT!"=="1" goto HU_MENU
goto HU_DONE

:HU_MISSING
echo !HU_MSG_MISSING!
goto HU_DONE
:HU_ADMIN_REQUIRED
cls
echo === Windows Hosts Utility ===
echo !HU_MSG_ADMIN!
goto HU_DONE
:HU_TEMP_FAILED
echo !HU_MSG_TEMP_FAILED!
goto HU_DONE
:HU_DONE
if defined HU_WORK if exist "!HU_WORK!" (
    del /f /q "!HU_WORK!\original.tmp" "!HU_WORK!\roundtrip.tmp" "!HU_WORK!\stage.tmp" "!HU_WORK!\entries.tmp" "!HU_WORK!\input.tmp" "!HU_WORK!\note_*.tmp" >nul 2>&1
    rd "!HU_WORK!" >nul 2>&1
)
echo.
echo !HU_MSG_EXIT!
set "HU_CLOSE="
set /p "HU_CLOSE="

endlocal
exit /b
