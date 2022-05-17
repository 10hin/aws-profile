@echo off

setlocal enabledelayedexpansion

IF x%1x == xlsx (
    GOTO list-profile
)
IF x%1x == xx (
    GOTO get-profile
)
REM ELSE
GOTO set-profile


:list-profile
FOR /F "delims=" %%i IN ('findstr "^\[.*\]$" %USERPROFILE%\.aws\config') DO (
    set ent=%%i
    set ent=!ent:[=!
    set ent=!ent:profile =!
    set profile=!ent:]=!

    IF x!profile!x == x%AWS_PROFILE%x (
        set prefix=^*
    ) else (
        set prefix=^ 
    )
    echo !prefix! !profile!
)

GOTO end


:get-profile
IF x%AWS_PROFILE%x == xx (
    echo.
) ELSE (
    echo %AWS_PROFILE%
)

GOTO end


:set-profile
endlocal
set AWS_PROFILE=%1

GOTO end

:end
