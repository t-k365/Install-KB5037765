KB5037765 fails on Windows Server 2019 without en-US language pack.

Microsoft has not yet put a statement on this online. It is not listed as known issue on their KB article which can be found [here](https://support.microsoft.com/en-us/topic/may-14-2024-kb5037765-os-build-17763-5820-82d1aefb-093c-4e4a-a729-cd4a829750ad)

This script installs the language pack and the update from a network share. 
* Download the files from

  https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2024/05/windows10.0-kb5037765-x64_3ca0b737e301d4e398a38f1d67966f1c82507fa8.msu

  https://software-static.download.prss.microsoft.com/pr/download/17763.1.180914-1434.rs5_release_SERVERLANGPACKDVD_OEM_MULTI.iso

* Place the .msu file in your network share
* Mount/Extract the ISO and copy the file Microsoft-Windows-Server-Language-Pack_x64_en-us.cab to your share
* Run the script on your servers. Specify share path with `-SharePath \\your-server\share` and add `-NoReboot` if you don't want the server to automatically reboot.
* Check the log at `C:\KB5037765-<timestamp>.txt`
