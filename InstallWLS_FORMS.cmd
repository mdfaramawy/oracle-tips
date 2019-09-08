SETLOCAL
set DOMAIN_NAME=sitksa
set USERDOMAIN_HOME=D:\Oracle\Middleware\user_projects\domains\sitksa
set SERVER_NAME=WLS_FORMS
set WL_HOME=D:\Oracle\Middleware\wlserver
set PRODUCTION_MODE=true
set ADMIN_URL=http://localhost:9001
cd %USERDOMAIN_HOME%
call %USERDOMAIN_HOME%\bin\setDomainEnv.cmd
rem *** call "C:\Oracle\Middleware\wlserver_10.3\server\bin\installSvc.cmd"
call "%WL_HOME%\server\bin\installSvc.cmd"
ENDLOCAL
