@echo off
REM --> ::: sources :::
REM --> how it started -> https://answers.microsoft.com/en-us/windows/forum/all/windows-update-error/1b2ed12d-7758-43f7-9238-412c915fd317
REM --> https://github.com/NicoKnowsTech/NicoKnowsTech/blob/main/NKT_TOOL.bat
REM --> https://github.com/bmrf/tron/blob/master/resources/stage_4_repair/disable_windows_telemetry/purge_windows_10_telemetry.bat
REM --> https://answers.microsoft.com/en-us/windows/forum/all/preparing-windows7-for-windows10-upgrade/eeaab542-a96c-419d-a498-e391344ea9d5
REM --> https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/repair-a-windows-image?view=windows-11
REM --> https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder?view=windows-11


REM --> Check for permissions and gain admin privileges
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
REM -------------------- from this point we are admin -------------------->


echo DISCLAIMER: This open-source script automates common IT tasks using built-in Windows commands. 
echo It does not rely on third-party applications or tools. 
echo By using this tool, you accept sole responsibility for any potential damage. 
echo If you do not agree, please close this window. 


:userInput
set /p user_input=Are you sure you want to Proceed at your own risk? (y/n)
if /i "%user_input%"=="y" (
    echo You chose to continue.
) else if /i "%user_input%"=="n" (
    echo You chose not to continue.
    pause >nul
	exit
) else (
    echo Invalid input, try again.
    goto userInput
)


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


REM --> Stop specified services
echo Stopping services...
echo Stopping Background Intelligent Transfer Service (BITS)...
echo y|net stop bits

echo Stopping Windows Update Service...
echo y|net stop wuauserv

echo Stopping Windows Installer Service...
echo y|net stop msiserver

echo Stopping Cryptographic Services...
echo y|net stop cryptsvc

echo Stopping Application Identity Service...
echo y|net stop appidsvc
echo Services stopped successfully.

REM --> Reset Winsock configuration to default settings
echo Resetting Winsock configuration to default settings...
netsh winsock reset
netsh winsock reset proxy
echo Winsock configuration has been reset to default settings.


REM --> Set the startup type as automatic for the services: trustedinstaller, wuauserv,bits and cryptsvc
echo Setting the startup type of services as automatic...
set "services=trustedinstaller wuauserv bits cryptsvc"

REM --> Check and set startup type for each service
for %%s in (%services%) do (
    sc qc %%s | findstr "START_TYPE" | findstr /i "AUTO" > nul
    if errorlevel 1 (
        sc config %%s start= auto
        echo Startup type for %%s service set to automatic.
    ) else (
        echo Startup type for %%s service is already set to automatic.
    )
)
echo Startup type set as automatic for the services.

REM ---> try to update office if possible
"C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" /update user

REM ---> Check if New Microsoft Teams is running
:checkNewTeams
tasklist /fi "imagename eq ms-teams.exe" 2>NUL | find /i /n "ms-teams.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo New Microsoft Teams is running.
    echo Exiting New Microsoft Teams.
    REM ---> Terminate New Microsoft Teams
    taskkill /f /im "ms-teams.exe"
    goto checkNewTeams
)
echo Microsoft New eams is not running.

REM ---> Check if Old Microsoft Teams is running
:checkOldTeams
tasklist /fi "imagename eq Teams.exe" 2>NUL | find /i /n "Teams.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Old Microsoft Teams is running.
    echo Exiting Old Microsoft Teams.
    REM ---> Terminate Old Microsoft Teams
    taskkill /f /im "Teams.exe"
    goto checkOldTeams
)
echo Microsoft Old Teams is not running.


REM ---> Deleting Teams cache
echo Delting Teams cache
del /s /f /q %appdata%\Microsoft\Teams\*.* 2> nul
rmdir /s /q %appdata%\Microsoft\Teams 2> nul
echo Teams cache deleted...


REM ---> Deleting Outlook cache
echo Delting Outlook cache
del /s /f /q %localappdata%\Microsoft\Outlook\RoamCache*.* 2> nul
rmdir /s /q %localappdata%\Microsoft\Outlook\RoamCache 2> nul
echo Outlook cache deleted...

REM --> Stop Xbox services and set their startup type to "demand"
echo Stopping Xbox services and setting startup type...
sc qc XblAuthManager | findstr "STATE" | findstr "RUNNING" && sc stop XblAuthManager
sc qc XblGameSave | findstr "STATE" | findstr "RUNNING" && sc stop XblGameSave
sc qc XboxNetApiSvc | findstr "STATE" | findstr "RUNNING" && sc stop XboxNetApiSvc
sc qc XboxGipSvc | findstr "STATE" | findstr "RUNNING" && sc stop XboxGipSvc
sc qc xbgm | findstr "STATE" | findstr "RUNNING" && sc stop xbgm
echo Stop Xbox services - Done...

REM --> Set the startup type as automatic for the services: XblAuthManager, XblGameSave, XboxNetApiSvc, XboxGipSvc and xbgm
echo Setting the startup type of services as demand...
set "services=XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc xbgm"

REM --> Check and set startup type for each service
for %%s in (%services%) do (
    sc qc %%s | findstr "START_TYPE" | findstr /i "DEMAND" > nul
    if errorlevel 1 (
        sc config %%s start= demand
        echo Startup type for %%s service set to demand.
    ) else (
        echo Startup type for %%s service is already set to demand.
    )
)
echo Startup type set as demand for the services.


REM -->	Disable Cortana globally
echo Disabling Cortana globally...
REM --> Disable Cortana
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f

REM --> Disable Cortana above lock screen
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f

REM --> Disable search using location
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f
echo Cortana has been disabled globally.


REM --> Enable, use printscreen to open snipping tool
reg add "HKCU\Control Panel\Keyboard" /v "PrintScreenKeyForSnippingEnabled" /t REG_DWORD /d 1 /f


REM --> Add DWORD value 01 to enable Storage Sense
echo Enabling Storage Sense
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 1 /f

REM --> Add DWORD value 1024 to run Storage Sense
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 1024 /t REG_DWORD /d 1 /f

echo Run storage sense every week
REM --> Add DWORD value 2048 to run Storage Sense every week
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 2048 /t REG_DWORD /d 7 /f

echo Set storage sense never delete downloads
REM --> Add DWORD value 32 to never delete downloads
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 32 /t REG_DWORD /d 0 /f

REM --> Add DWORD value 512 to never delete downloads
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 512 /t REG_DWORD /d 0 /f

echo Set storagesense to empty recycle bin every 60days
REM --> Add DWORD value 256 to empty recycle bin every 60 days
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 256 /t REG_DWORD /d 0x3c /f
echo Registry values added


REM -->  set visual effect to custom
echo Setting visual effects to Custom
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 3 /f

REM --> wanna set syste propterties performance options to optimal
REM --> however, it doesnt i disable the following
REM --> Animation windows when minimising/maximising
REM --> Animate taskbar 
REm --> Enable peak. 
echo making performance changes to visual effects
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9032078010000000 /f
echo Registry values changed. 


REM --> Add registry values to enable Processor Performance Boost Mode
echo Adding registry values enable Processor Performance Boost Mode...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v "BoostState" /t REG_DWORD /d 1 /f 

REM --> Add registry values to see minimum and maximum processor states
echo Adding registry values for minimum and maximum processor states...

reg add HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\893dee8e-2bef-41e0-89c6-b55d0929964c /v Attributes /t REG_DWORD /d 2 /f
reg add HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\bc5038f7-23e0-4960-96da-33abaf5935ec /v Attributes /t REG_DWORD /d 2 /f

REM --> Set the current power scheme to the minimum processor state to 100% (plugged in)
powercfg.exe -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100

REM --> Set the current power scheme to the maximum processor state to 100% (plugged in)
powercfg.exe -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100

Powercfg -setactive SCHEME_CURRENT
echo Registry values added and current power scheme updated.


REM --> Remove Temporary Files
REM --> Deletes temporary files from the Windows system directories
REM --> Cleans up the Windows temp folder, prefetch files, and user temp folder
echo Starting to clean Temporary file from Windws system directories...
echo.
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
echo.
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
Dism /Online /Cleanup-Image /ScanHealth
Dism /Online /Cleanup-Image /CheckHealth

echo Restoring the system image to a healthy state...
Dism /Online /Cleanup-Image /RestoreHealth

echo Starting component cleanup...
Dism /online /Cleanup-Image /StartComponentCleanup

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
