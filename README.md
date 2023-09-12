# Windows Optimization Script

This script is designed to streamline various optimization tasks on a Windows system using native Windows commands. It simplifies tasks such as enabling system restore, configuring service startup types, disabling Cortana, halting Xbox-related services, adjusting power settings for enhanced performance, cleaning temporary files, and resetting Windows Update policies.

## Usage

**Option 1: Double-Click to Run**

Thanks to [NicoKnowsTech](https://github.com/NicoKnowsTech), the script will automatically request and acquire administrative rights at the beginning. Simply double-click on the script file, and let it run.

**Option 2: Command Prompt**

For added convenience, you can also run the script from the command prompt. Use one of the following commands to execute the script:

```shell
curl https://raw.githubusercontent.com/rajtsic/WuFix/main/WuFix-main.CMD > ./Downloads/WuFix-main.CMD | start .\Downloads\Wufix-Main.CMD
```

Normal vs. onlyWufix

The script comes in two flavors: "Normal" and "onlyWufix."

onlyWufix mainly performs the following tasks:

    Checks for admin rights; elevates permissions if necessary.
    Creates a system restore point.
    Deletes temporary files.
    Resets BITS (Background Intelligent Transfer Service).
    Runs DISM (Deployment Imaging Service and Management Tool) scan.
    Executes SFC (System File Checker) scan.
    Reboots the system.
    Runs a chkdsk scan.

This script can effectively resolve Windows update issues and serves as a general system maintenance tool.

Normal does more for system performance. It targets business and enterprise end-user computers but can be used by any Windows user. In addition to the "onlyWufix.cmd" tasks, the "Normal" script also:

    Stops and disables startup Xbox-related services.
    Disables Cortana (End of Life).
    Enables the use of the Print Screen button to open the Snipping Tool.
    Enables Storage Sense and configures basic settings.
    Customizes visual effects for enhanced performance.
    Enables Processor Performance Boost mode (if compatible hardware is present).
    Sets minimum and maximum processor states to 100% when plugged in.

Important Notes

This script makes significant changes to your system settings, services, and configurations. Only use it if you are confident in its effects.

Runtime: The script may take some time to complete, depending on your system's specifications and the tasks being performed. On average, it takes about 20-30 minutes to run within CMD (duration varies based on hardware). The script may prompt you to reboot, and after that, the chkdsk scan can take an additional 20-30 minutes (hardware-dependent).
Support and Feedback

For any questions, issues, or feedback related to this script, please visit the GitHub Discussions page.
