<#
.Synopsis
    ASP-Delete.ps1 script Run from your local system to a remote system or your choice
    if PCI network copy and run from one of the pci jump boxes. 
  
 
.DESCRIPTION
    The script Will assure c:\temp\empty exist, then do a robocopy to delete remote files 
    "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files" from the serverlist.txt file. 
 
 
.NOTES  
    Name: asp-delete
    Author: William King
    Version: 1.0
    DateCreated: 11-29-2021
    DateUpdated: 
 
.How it works
    Create your c:\temp\serverlist.txt file with the servers you want cleaned up
    Run the command below to cleanup all ASP.NET temp files on that remote system.
    NOTE: will only work on PCI systems from a PCI jump box. 
 
 
.EXAMPLE
    >.\ASP-Delete.ps1
       
#>

#Get the server list
$Computerlist = get-content "C:\temp\serverlist.txt" 

#Run the commands for each server in the list
foreach ($computername in $computerlist) { 

write-output "Server to delete ASP.NET Temp files on" $computername

Enter-PSSession $computername

$path = "C:\temp\empty" 
if(!(test-path $path))
{ 
	New-Item -ItemType Directory -Force -Path $path
}

robocopy "C:\temp\empty" "\\$computername\C$\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files" /s /mir

Stop-Service -Name "cryptsvc"

Start-Sleep -s 3

Start-Service -Name "cryptsvc"
}