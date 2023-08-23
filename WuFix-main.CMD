@echo off
REM --> sources
REM --> ttps://github.com/NicoKnowsTech/NicoKnowsTech/blob/main/NKT_TOOL.bat


REM --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
REM -----------------------------------> 


REM --> Check if restore is enabled and enable it if not
echo Checking if restore is enabled
wmic.exe /Namespace:\\root\default Path SystemRestore Get DisableSR, EnableStatus | findstr /i "Disabled" | findstr /i "No"
if %errorlevel% neq 0 (
    echo System restore is disabled. Enabling...
    wmic.exe /Namespace:\\root\default Path SystemRestore Call Enable "C:\"
) else (
    echo System restore is already enabled.
)

REM --> Start a restore point using PowerShell with admin privileges
echo Starting a restore point...
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -NoExit -Command ""Checkpoint-Computer -Description \""PreWufix\"" -RestorePointType \""MODIFY_SETTINGS\""; Start-Sleep -Seconds 2; Exit""' -Verb RunAs}"



REM --> Set the startup type as automatic for services
echo Setting the startup type of services as automatic...
sc config trustedinstaller start= auto
sc config wuauserv start= auto
sc config bits start= auto
sc config cryptsvc start= auto
echo Startup type set as automatic for the services.

REM --> Wait for the restore point to be completed
setlocal enabledelayedexpansion
REM --> SET time default to 30sec, 
REM --> However it could take longer so set it higher if you think you need it. 
set "remainingTime=30"
echo Timer for the restore point to be completed...
:wait
timeout /t 1 >nul
set /a "remainingTime-=1"
echo Remaining time: !remainingTime! seconds
if !remainingTime! gtr 0 (
    goto wait
) else (
    echo Restore may be completed. Proceeding with the script
)


REM --> Add registry values to see minimum and maximum processor states
echo Adding registry values for minimum and maximum processor states...

REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\893dee8e-2bef-41e0-89c6-b55d0929964c /v Attributes /t REG_DWORD /d 2 /f

REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\bc5038f7-23e0-4960-96da-33abaf5935ec /v Attributes /t REG_DWORD /d 2 /f


REM --> Set the current power scheme to the minimum processor state to 100% (plugged in)
powercfg.exe -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100

REM --> Set the current power scheme to the maximum processor state to 100% (plugged in)
powercfg.exe -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100

Powercfg -setactive SCHEME_CURRENT
echo Registry values added and current power scheme updated.



REM --> Stop specified services
echo Stopping services...

echo Stopping Background Intelligent Transfer Service (BITS)...
net stop bits

echo Stopping Windows Update Service...
net stop wuauserv

echo Stopping Windows Installer Service...
net stop msiserver

echo Stopping Cryptographic Services...
net stop cryptsvc

echo Stopping Application Identity Service...
net stop appidsvc

echo Services stopped.

REM --> Reset Winsock configuration to default settings
echo Resetting Winsock configuration to default settings...
netsh winsock reset
netsh winsock reset proxy
echo Winsock configuration has been reset to default settings.


REM --> Remove Temporary Files
REM --> Deletes temporary files from the Windows system directories
REM --> Cleans up the Windows temp folder, prefetch files, and user temp folder
del /s /f /q c:\windows\temp\*.* 2> nul
rd /s /q c:\windows\temp 2> nul
md c:\windows\temp 2> nul
del /s /f /q C:\WINDOWS\Prefetch 2> nul
del /s /f /q %temp%\*.* 2> nul
rd /s /q %temp% 2> nul
md %temp% 2> nul
rd /s /q c:\windows\tempor~1 2> nul
del /f /q c:\windows\tempor~1 2> nul
rd /s /q c:\windows\temp 2> nul
del /f /q c:\windows\temp 2> nul
rd /s /q c:\windows\tmp 2> nul
del /f /q c:\windows\tmp 2> nul
rd /s /q c:\windows\ff*.tmp 2> nul
del /f /q c:\windows\ff*.tmp 2> nul
rd /s /q c:\windows\history 2> nul
del /f /q c:\windows\history 2> nul
rd /s /q c:\windows\cookies 2> nul
del /f /q c:\windows\cookies 2> nul
rd /s /q c:\windows\recent 2> nul
del /f /q c:\windows\recent 2> nul
rd /s /q c:\windows\spool\printers 2> nul
del /f /q c:\windows\spool\printers 2> nul
del c:\WIN386.SWP 2> nul
echo Temporary files removed.


REM --> Delete and reset Windows Update policies
echo Deleting and resetting Windows Update policies...

reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" /f

echo Windows Update policies have been deleted and reset.


 
 
REM --> Delete BITS cache
echo Deleting BITS cache...
del /s /q /f "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat" 
del /s /q /f "%ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat"
echo BITS cache has been deleted.


REM --> Clear Windows Update cache by renaming files and folders
echo Clearing Windows Update cache...
ren %SYSTEMROOT%\winsxs\pending.xml pending.xml.bak
ren %Systemroot%\SoftwareDistribution SoftwareDistribution.bak
ren %Systemroot%\SoftwareDistribution\DataStore DataStore.bak
ren %Systemroot%\SoftwareDistribution\Download Download.bak
ren %Systemroot%\System32\catroot2 catroot2.bak
ren %SYSTEMROOT%\WindowsUpdate.log WindowsUpdate.log.bak 
echo Windows Update cache has been cleared.


REM --> Reset the BITS service and the Windows Update service to the default security descriptor
echo Resetting the BITS service and the Windows Update service to the default security descriptor...
sc.exe sdset bits D:(A;CI;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)
sc.exe sdset wuauserv D:(A;;CCLCSWRPLORC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)
echo BITS service and Windows Update service have been reset to the default security descriptor.

REM --> Register DLL files
echo Registering DLL files...
regsvr32.exe /s %windir%\system32\atl.dll 
regsvr32.exe /s %windir%\system32\urlmon.dll 
regsvr32.exe /s %windir%\system32\mshtml.dll 
regsvr32.exe /s %windir%\system32\shdocvw.dll 
regsvr32.exe /s %windir%\system32\browseui.dll 
regsvr32.exe /s %windir%\system32\jscript.dll 
regsvr32.exe /s %windir%\system32\vbscript.dll 
regsvr32.exe /s %windir%\system32\scrrun.dll 
regsvr32.exe /s %windir%\system32\msxml.dll 
regsvr32.exe /s %windir%\system32\msxml3.dll 
regsvr32.exe /s %windir%\system32\msxml6.dll 
regsvr32.exe /s %windir%\system32\actxprxy.dll 
regsvr32.exe /s %windir%\system32\softpub.dll 
regsvr32.exe /s %windir%\system32\wintrust.dll 
regsvr32.exe /s %windir%\system32\dssenh.dll 
regsvr32.exe /s %windir%\system32\rsaenh.dll 
regsvr32.exe /s %windir%\system32\gpkcsp.dll 
regsvr32.exe /s %windir%\system32\sccbase.dll 
regsvr32.exe /s %windir%\system32\slbcsp.dll 
regsvr32.exe /s %windir%\system32\cryptdlg.dll 
regsvr32.exe /s %windir%\system32\oleaut32.dll 
regsvr32.exe /s %windir%\system32\ole32.dll 
regsvr32.exe /s %windir%\system32\shell32.dll 
regsvr32.exe /s %windir%\system32\initpki.dll 
regsvr32.exe /s %windir%\system32\wuapi.dll 
regsvr32.exe /s %windir%\system32\wuaueng.dll 
regsvr32.exe /s %windir%\system32\wuaueng1.dll 
regsvr32.exe /s %windir%\system32\wucltui.dll 
regsvr32.exe /s %windir%\system32\wups.dll 
regsvr32.exe /s %windir%\system32\wups2.dll 
regsvr32.exe /s %windir%\system32\wuweb.dll 
regsvr32.exe /s %windir%\system32\qmgr.dll 
regsvr32.exe /s %windir%\system32\qmgrprxy.dll 
regsvr32.exe /s %windir%\system32\wucltux.dll 
regsvr32.exe /s %windir%\system32\muweb.dll 
regsvr32.exe /s %windir%\system32\wuwebv.dll
regsvr32.exe /s %windir%\system32\wudriver.dll
echo DLL files have been registered successfully.

REM --> Update Windows Update policy
echo Updating Windows Update policy...
echo If stuck on "Updating policy..." for more than 10 minutes, press Ctrl + C once to keep it going.
echo n|gpupdate /force
echo Windows Update policy has been updated.


REM --> Perform system cleanup and health checks
echo Performing system cleanup and health checks...

echo Cleaning up unused drivers...
rundll32.exe pnpclean.dll,RunDLL_PnpClean /DRIVERS /MAXCLEAN

echo Scanning the system image for health issues...
dism /Online /Cleanup-image /ScanHealth
dism /Online /Cleanup-image /CheckHealth

echo Restoring the system image to a healthy state...
dism /Online /Cleanup-image /RestoreHealth

echo Starting component cleanup...
dism /Online /Cleanup-image /StartComponentCleanup

echo Scanning system files for integrity violations...
Sfc /ScanNow
echo System cleanup and health checks have been completed.

REM --> Start chkdsk utility and confirm with "yes"
echo Initiating disk check (CHKDSK) and confirming with "yes"...
echo y|chkdsk /r
echo Disk check (CHKDSK) has been initiated.

REM --> Start specified services
echo Starting services...
net start bits
net start wuauserv
net start msiserver
net start cryptsvc
net start appidsvc

REM --> Restarts computer
echo Task completed successfully! - Press any key to reboot
pause >nul
shutdown /r /t 00 
