KB5037765 fails on Windows Server 2019 without en-US language pack.

KB article can be found [here](https://support.microsoft.com/en-us/topic/may-14-2024-kb5037765-os-build-17763-5820-82d1aefb-093c-4e4a-a729-cd4a829750ad)

This script installs the language pack and the update from a network share. 
* Download the files from

  https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2024/05/windows10.0-kb5037765-x64_3ca0b737e301d4e398a38f1d67966f1c82507fa8.msu

  https://software-static.download.prss.microsoft.com/pr/download/17763.1.180914-1434.rs5_release_SERVERLANGPACKDVD_OEM_MULTI.iso

* Place the .msu file in your network share
* Mount/Extract the ISO and copy the file Microsoft-Windows-Server-Language-Pack_x64_en-us.cab to your share
* Run the script on your servers. Specify share path with `-SharePath \\your-server\share` and add `-NoReboot` if you don't want the server to automatically reboot.
* Check the log at `C:\KB5037765-<timestamp>.txt`

Example log output

```
2024-05-16 07:09:56 - Script startet at 20240516T070956
2024-05-16 07:09:56 - Checking if en-US language pack is installed
2024-05-16 07:09:57 - Installed language packs:
2024-05-16 07:09:57 - de-DE
2024-05-16 07:09:57 - en-US language pack is not installed, trying to install.
2024-05-16 07:09:57 - Searching for language pack
2024-05-16 07:09:57 - Language pack found at \\s1\share\Microsoft-Windows-Server-Language-Pack_x64_en-us.cab
2024-05-16 07:09:57 - Installing en-US language pack from \\s1\share.

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
     26       2      340        656       0,02   7876   3 lpksetup
2024-05-16 07:14:02 - Finished installing language pack.




TimeCreated  : 16.05.2024 07:14:01
ProviderName : Microsoft-Windows-Servicing
Id           : 2
Message      : Der Status des Pakets SP1 Language Pack wurde erfolgreich in "Installiert" geändert.



2024-05-16 07:14:02 - Checking if language pack has installed successfully
2024-05-16 07:14:02 - Installed language packs:
2024-05-16 07:14:02 - de-DE en-US
2024-05-16 07:14:02 - Language pack installed successfully.
2024-05-16 07:14:02 - Searching for update file
2024-05-16 07:14:02 - Update file found at \\s1\share\windows10.0-kb5037765-x64_3ca0b737e301d4e398a38f1d67966f1c82507fa8.msu
2024-05-16 07:14:02 - Installing update file from \\s1\share.
2024-05-16 07:21:45 - Finished installing update file.


TimeCreated  : 16.05.2024 07:19:44
ProviderName : Microsoft-Windows-WUSA
Id           : 4
Message      : Das Windows-Update Sicherheitsupdate für Windows (KB5037765) erfordert einen Neustart des Computers, um
               die Installation abzuschließen. (Befehlszeile: ""C:\Windows\system32\wusa.exe"
               \\s1\share\windows10.0-kb5037765-x64_3ca0b737e301d4e398a38f1d67966f1c82507fa8.msu /quiet /norestart ")



2024-05-16 07:21:45 - Update installed successfully. Reboot required.
2024-05-16 07:21:45 - Parameter 'noreboot' specified. Skipping reboot.
```
