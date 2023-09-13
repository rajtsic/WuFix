# Windows Optimization Script

Welcome to the Windows Optimization Script! This script is designed to simplify and streamline various optimization tasks on your Windows system using native Windows commands. It covers a wide range of tasks to enhance your system's performance and stability. Please read this readme carefully before using the script.

## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
  - [Option 1: Double-Click to Run](#option-1-double-click-to-run)
  - [Option 2: Command Prompt](#option-2-command-prompt)
- [Script Variants](#script-variants)
  - [onlyWufix](#onlywufix)
  - [Normal](#normal)
- [Important Notes](#important-notes)
- [Runtime](#runtime)
- [Support and Feedback](#support-and-feedback)
- [Acknowledgments](#Acknowledgments)

## Introduction

This script simplifies a variety of optimization tasks for your Windows system. It includes tasks like enabling system restore, configuring service startup types, disabling Cortana, stopping Xbox-related services, adjusting power settings for better performance, cleaning temporary files, and resetting Windows Update policies.

## Usage

### Option 1: Ease of with Command Prompt(CMD)

Most ease of use, copy the following command, open cmd, copy the following command and paste it into cmd and press enter - et voilà!:

```shell
curl https://raw.githubusercontent.com/rajtsic/WuFix/main/WuFix-main.CMD > ./Downloads/WuFix-main.CMD | start .\Downloads\Wufix-Main.CMD
```

### Option 2: Double-Click to Run

The script is designed to automatically request and acquire administrative rights at the beginning. To run the script, simply follow these steps:

1. **Download the Script:** Download the script file to your computer.

2. **Double-Click to Run:** Locate the downloaded script file and double-click on it. The script will automatically request and acquire administrative rights and proceed with optimization tasks.



## Script Variants

The script comes in two variants: "onlyWufix" and "Normal," each serving different purposes.

### onlyWufix

The "onlyWufix" variant mainly performs the following tasks:

- Checks for admin rights and elevates permissions if necessary.
- Creates a system restore point.
- Deletes temporary files.
- Resets BITS (Background Intelligent Transfer Service).
- Runs DISM (Deployment Imaging Service and Management Tool) scan.
- Executes SFC (System File Checker) scan.
- Reboots the system.
- Runs a chkdsk scan.

This script is effective in resolving Windows update issues and serves as a general system maintenance tool.

### Normal

The "Normal" variant does more for system performance and is targeted towards business and enterprise end-user computers but can be used by any Windows user. In addition to the tasks performed by "onlyWufix," the "Normal" script also:

- Stops and disables startup Xbox-related services.
- Disables Cortana (End of Life).
- Enables the use of the Print Screen button to open the Snipping Tool.
- Enables Storage Sense and configures basic settings.
- Customizes visual effects for enhanced performance.
- Enables Processor Performance Boost mode (if compatible hardware is present).
- Sets minimum and maximum processor states to 100% when plugged in.

## Important Notes

This script makes significant changes to your system settings, services, and configurations. Only use it if you are confident in its effects.

## Runtime

The script may take some time to complete, depending on your system's hardware and the tasks being performed. On average, it takes about 20-30 minutes to run within CMD. 
The script will prompt you to reboot, and after that, the chkdsk scan can take an additional 20-30 minutes or even longer.

## Support and Feedback

For any questions, issues, or feedback related to this script, please visit the [GitHub Discussions page](https://github.com/rajtsic/WuFix/discussions). Your feedback is valuable in improving this script for the community.

Enjoy an optimized Windows experience! 🚀

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

* [NicoKnowsTech and the NKT_tool project](https://github.com/NicoKnowsTech/NicoKnowsTech)
* [bmrf and the Tron project](https://github.com/bmrf/tron)
