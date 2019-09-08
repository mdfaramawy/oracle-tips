SETLOCAL
set DOMAIN_NAME=sitksa
set USERDOMAIN_HOME=D:\Oracle\Middleware\user_projects\domains\sitksa
set SERVER_NAME=WLS_NodeManager
set WL_HOME=D:\Oracle\Middleware\wlserver
set PRODUCTION_MODE=true
cd %USERDOMAIN_HOME%
call %USERDOMAIN_HOME%\bin\startNodeManager.cmd
call "%WL_HOME%\server\bin\installSvc.cmd"
ENDLOCAL