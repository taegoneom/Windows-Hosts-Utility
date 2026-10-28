@echo off
if /i "%~1"=="--hu-run" goto HU_MAIN
"%ComSpec%" /d /a /c ""%~f0" --hu-run %*"
exit /b

:HU_MAIN
setlocal EnableExtensions EnableDelayedExpansion
set "HU_WORK="
for /f "tokens=2 delims=:" %%C in ('chcp') do for %%N in (%%C) do set "HU_OLD_CP=%%N"
chcp 949 >nul 2>&1
if errorlevel 1 (
    echo Cannot display Korean. Please use whu_eng.bat.
    echo Press Enter to close.
    set /p "HU_CLOSE="
    endlocal
    exit /b
)
title Windows Hosts Utility
set "HU_MSG_TARGET=대상 hosts:"
set "HU_MSG_MENU1=1. 신규 추가"
set "HU_MSG_MENU2=2. 현재 내용 조회"
set "HU_MSG_MENU3=3. 특정 항목 제거 - 번호 선택"
set "HU_MSG_MENU4=4. 사용 설명"
set "HU_MSG_MENU0=0. 종료"
set "HU_MSG_SELECT=선택 [1/2/3/4/0]:"
set "HU_MSG_TABLE=--- 등록된 항목 ---"
set "HU_MSG_EMPTY=등록된 항목이 없습니다. 주소 조회에는 IPv4 어댑터 또는 공유기에 설정된 DNS 서버를 사용합니다."
set "HU_MSG_IP_FIELD=IP:"
set "HU_MSG_NOTE_FIELD=설명:"
set "HU_MSG_NO_NOTE=설명이 입력되지 않은 항목입니다."
set "HU_MSG_NOTE_INPUT=주석 달기 (선택, Enter: 생략):"
set "HU_MSG_NAME=영문 호스트 이름, 예: app.test [Enter: 취소]:"
set "HU_MSG_IP=연결할 IP 주소 [Enter: 127.0.0.1]:"
set "HU_MSG_BAD_HOST=영문, 숫자, 점, 하이픈으로 호스트 이름을 입력하세요. 예: app.test"
set "HU_MSG_BAD_IP=올바른 IP 주소를 입력하세요."
set "HU_MSG_PREVIEW_ADD=추가 예정:"
set "HU_MSG_LOOPBACK_HINT=해당 주소와 포트에 로컬 서버가 없으면 접속할 수 없습니다."
set "HU_MSG_SERVER_HINT=입력한 IP가 연결하려는 서버의 주소인지 확인하세요."
set "HU_MSG_PREVIEW_REMOVE=제거 예정:"
set "HU_MSG_REMOVE_SCOPE=선택한 호스트 이름만 삭제합니다. 같은 줄의 다른 이름과 설명은 유지됩니다."
set "HU_MSG_REMOVE_CONFIRM=위 내용이 삭제하려는 항목인지 확인하세요. [1: 삭제 / 그 외: 취소]:"
set "HU_MSG_CONFIRM=이 작업을 실행할까요? [1: 실행 / 그 외: 취소]:"
set "HU_MSG_REMOVE_NUMBER=제거할 항목 번호 [0: 취소]:"
set "HU_MSG_SUCCESS=완료했습니다."
set "HU_MSG_CACHE_OK=DNS 캐시를 갱신했습니다. 새 주소 조회부터 적용됩니다."
set "HU_MSG_CACHE_FAIL=설정은 저장했지만 DNS 캐시를 갱신하지 못했습니다."
set "HU_MSG_RESTART=2번 조회에서 확인하세요. 반영되지 않으면 프로그램을 다시 실행하거나 재부팅하세요."
set "HU_MSG_DUPLICATE=이미 등록된 항목입니다."
set "HU_MSG_CONFLICT=같은 호스트 이름에 다른 IP가 등록되어 있습니다. 현재 내용을 확인하세요."
set "HU_MSG_CHANGED=파일 내용이 변경되었습니다. 다시 조회하세요."
set "HU_MSG_READ_ONLY=읽기 전용 파일이라 수정할 수 없습니다."
set "HU_MSG_UNSUPPORTED=이 파일 형식은 편집할 수 없습니다. 조회는 가능합니다."
set "HU_MSG_WRITE_FAILED=저장하지 못했습니다. 다른 프로그램에서 파일을 사용 중인지 확인하세요."
set "HU_MSG_ADMIN=관리자 권한으로 다시 실행하세요."
set "HU_MSG_READ_FAILED=hosts 파일을 읽지 못했습니다."
set "HU_MSG_CANCEL=취소했습니다."
set "HU_MSG_AGAIN=[1: 처음 메뉴 / Enter: 종료]:"
set "HU_MSG_MISSING=hosts 파일을 찾지 못했습니다."
set "HU_MSG_TEMP_FAILED=작업을 시작하지 못했습니다. 다시 실행하세요."
set "HU_MSG_EXIT=Enter를 누르면 창을 닫습니다."
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
echo 사용 설명
echo hosts는 이 PC에서 호스트 이름을 IP 주소로 연결하는 파일입니다.
echo 예시: 127.0.0.1 app.test # 로컬 개발용
echo IP와 호스트 이름은 공백이나 탭으로 구분합니다.
echo # 뒤는 설명 주석입니다. 기본 파일의 주석과 예시는 실제 등록 항목이 아닙니다.
echo 127.0.0.1과 ::1은 내 PC를 가리킵니다. 접속하려면 로컬 서버가 실행 중이어야 합니다.
echo.
echo 신규 추가: 호스트 이름, IP와 선택 설명을 입력하고 확인 후 등록합니다.
echo 조회: 번호가 붙은 등록 항목의 IP와 설명을 확인합니다.
echo 제거: 항목 번호를 선택합니다. 다른 항목과 주석은 유지됩니다.
echo 호스트 이름만 입력하세요. 예: app.test - https://, 경로, 포트는 제외합니다.
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
if defined HU_OLD_CP chcp !HU_OLD_CP! >nul 2>&1
endlocal
exit /b
