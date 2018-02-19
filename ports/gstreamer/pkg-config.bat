@echo off

set prefix=@CURRENT_INSTALLED_DIR@

if "%1"=="--version" (
    echo 0.1
    exit /b 0
)

call :check %1 %2 glib-2.0
call :check %1 %2 gobject-2.0
call :check %1 %2 gmodule-2.0
call :check %1 %2 gio-2.0

exit /b 1

:check

if "%1"=="%3" (
    if "%2"=="--libs" (
        echo -L%prefix%/lib -l%3
	exit
    )
)

if "%2"=="%3" (
    if "%1"=="--modversion" (
        echo 999.0
	exit
    )
    if "%1"=="--cflags" (
        echo -I%prefix%/include
	exit
    )
)

exit /b
