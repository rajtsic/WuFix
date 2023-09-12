

This script is designed to automate various optimization tasks on a Windows system using built-in Windows commands. 
It performs tasks such as enabling system restore, setting service startup types, disabling Cortana, stopping Xbox services, modifying power settings for more power, cleaning temporary files, resetting Windows Update policies. 

Double-Click to Run: Thanks to NicoKnowsTech - https://github.com/NicoKnowsTech - The script will automatically request and acquire administrative rights at the beginning.
Then let the script run. 

Or for ease of use, paste one of the following script row into a command promt to run the said script
what it does; the scripts download the github raw into ~/Downloads and start it.

curl https://raw.githubusercontent.com/rajtsic/WuFix/main/WuFix-main.CMD > ./Downloads/WuFix-main.CMD | start .\Downloads\Wufix-Main.CMD


### Normal VS onlyWufix ####

If onlyWufix script mainly does; 
*check for admin - if not, make the script admin
*restore point
*delete temp files
*reset bits
*run DISM scan
*run SFC scan
*reboot 
*run chkdsk scan
This can result in fixing windows update issues if you have that, otherwise it just a good script to run.

Main does more for "performance".
The script is target for business and enterprise end-user computer.
But can be used by any windows user.
As of writing this readeMe.txt, Main script does what "onlyWuFix.cmd" script plus:
*Stop and disable startup xbox services
*Disable cortana (EOL anyway)
*Enable - use printscreen button to open snipping tool
*Enable storage sense and set basic config.
*Setting a visual effect to costum for more "performance" 
*Enable Processor performance boost mode - if you got the hardware.
*Setting minimum & maximum processor state to 100% when plugged in.


Important Notes:
This script involves making significant changes to your system settings, services, and configurations. 
Use it only if you are confident in its effects.

Runtime: The script may take some time to complete, depending on your system's specifications and the tasks being performed.
Takes about 20-30min run it within CMD (depending on hardware)
Script ask to reboot.
After that the chkdsk scan take about 20-30min.(depending on hardware)

Support and Feedback
For any questions, issues, or feedback related to this script, please reach out to https://github.com/rajtsic/WuFix/discussions


