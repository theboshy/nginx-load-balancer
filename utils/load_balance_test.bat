@echo off

:: [-  = incio de comentario
:: ]- = fin comentario

set serv=%1

%SystemRoot%\system32\ping.exe -n 1 %serv% >nul
if errorlevel 1 goto NoServer
start  http://%serv%:8080
goto :EOF

:NoServer
::[- echo x=msgbox(%serv% "No esta disponible" ,0, "Fallo la conexion") >> msgbox.vbs
::start msgbox.vbs ]-
msg "%username%" no hubo respuesta del servidor %serv%
::echo %serv% no disponible.
goto :EOF

::echo %DOCKER_HOST% : variable de entorno para la amquina virtual de docker
