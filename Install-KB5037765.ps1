<#
.SYNOPSIS
    Installs update KB5037765 and en-US language pack if needed, reboots if successful.

.DESCRIPTION
    This script checks if the en-US language pack is installed on the system. If not, it attempts to install it from a specified share location.
    It then checks if the update file (KB5037765) is available on the share. If found, it installs the update.
    If the `-NoReboot` parameter is not specified, it performs the required reboot. The transcript of the installation process is saved to a log file.

.PARAMETER SharePath
    Specifies the network share path where the update file and language pack are located.

.PARAMETER NoReboot
    Specifies whether to skip the automatic reboot after installing the update. By default, the script will perform a reboot if required. If this parameter is specified, no reboot will be performed.

.EXAMPLE
    .\Install-Update.ps1 -SharePath "\\server\share"
    Runs the script with the specified share path, allowing automatic reboot.

.EXAMPLE
    .\Install-Update.ps1 -SharePath "\\server\share" -NoReboot
    Runs the script with the specified share path and the `-NoReboot` parameter, skipping automatic reboot.

.NOTES
    Author: Thomas Klemenc | License: MIT
#>

param(
    [string]$SharePath, # Specifies the network share path
    [switch]$NoReboot    # Specify this switch to skip automatic reboot after update installation
)

$updateFilename = "windows10.0-kb5037765-x64_3ca0b737e301d4e398a38f1d67966f1c82507fa8.msu"
$languagePackFilename = "Microsoft-Windows-Server-Language-Pack_x64_en-us.cab"

function New-LogMessage {
    param(
        [string]$message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage
}

function Stop-Install {
    param(
        [string]$errorMessage
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $errorMessage"
    Write-Error $logMessage
    Stop-Transcript
    exit
}


$timestamp = Get-Date -Format "yyyyMMddTHHmmss"
Start-Transcript "C:\KB5037765-$timestamp.txt"

New-LogMessage "Script startet at $timestamp"

if (-not $SharePath) {
    Stop-Install "SharePath parameter is mandatory. Please specify the network share path where the update file and language pack are located."
    exit 1
}

$updateFullPath = Join-Path $SharePath $updateFilename
$languagePackFullPath = Join-Path $SharePath $languagePackFilename

New-LogMessage "Checking if en-US language pack is installed"
$OSInfo = Get-WmiObject -Class Win32_OperatingSystem
$languagePacks = $OSInfo.MUILanguages
New-LogMessage "Installed language packs:"
New-LogMessage $languagePacks

if (-Not ($languagePacks.Contains("en-US"))) {
    New-LogMessage "en-US language pack is not installed, trying to install."
    New-LogMessage "Searching for language pack"

    If (-Not (Test-Path $languagePackFullPath)) {
        Stop-Install "Language pack could not be found in $SharePath. Aborting."
    }

    New-LogMessage "Language pack found at $languagePackFullPath"
    New-LogMessage "Installing en-US language pack from $SharePath."

    Start-Process -FilePath "lpksetup.exe" -ArgumentList "/i en-US /r /s /p $SharePath" -Wait -PassThru -NoNewWindow

    New-LogMessage "Finished installing language pack."

    $events = Get-WinEvent -LogName Setup -MaxEvents 1
    $events | Format-List

    New-LogMessage "Checking if language pack has installed successfully"
    $OSInfo = Get-WmiObject -Class Win32_OperatingSystem
    $languagePacks = $OSInfo.MUILanguages
    New-LogMessage "Installed language packs:"
    New-LogMessage $languagePacks
    if (-Not ($languagePacks.Contains("en-US"))) {
        Stop-Install "Language pack installation seems to have failed, aborting."
    }

    New-LogMessage "Language pack installed successfully."
}

New-LogMessage "Searching for update file"
If (-Not (Test-Path $updateFullPath)) {
    Stop-Install "Update file could not be found in $SharePath. Aborting."
}
New-LogMessage "Update file found at $updateFullPath"
New-LogMessage "Installing update file from $SharePath."

$process = Start-Process -FilePath "wusa.exe" -ArgumentList "$updateFullPath /quiet /norestart" -Wait -PassThru -NoNewWindow

New-LogMessage "Finished installing update file."
$events = Get-WinEvent -LogName Setup -MaxEvents 1
$events | Format-List

if (-Not ($process.ExitCode -eq 3010)) {
    Stop-Install "Unknown exitcode: $($process.ExitCode) (0x$("{0:X}" -f $process.ExitCode)). Please check log if update installed successfully."
    # Failure codes: http://inetexplorer.mvps.org/archive/windows_update_codes.htm
}
else {
    New-LogMessage "Update installed successfully. Reboot required."
}

if ($NoReboot) {
    New-LogMessage "Parameter 'noreboot' specified. Skipping reboot."
}
else {
    New-LogMessage "Rebooting now."
    Restart-Computer -Force
}

Stop-Transcript
