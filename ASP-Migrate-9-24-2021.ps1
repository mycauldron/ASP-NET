<#
    .SYNOPSIS
        Performs a migration of ASP.NET Temporary files from C: drive to L: drive

        1. Add 8gb Lun to the system in VMWare 
        2. In Win Disk Manager Create the 8gb L: drive. 
        3. Create new directories for the ASP.NET temporary files.  
        4. Set permissions on the folder just created. 

    .EXAMPLE, what the script will do

        PS> Change-ASP.net.ps1
    
        Replaces the String <compilation> in the web.config file with: 
          
            <compilation tempDirectory="L:\Microsoft.NET\Framework64\Temporary ASP.NET Files">

        Creates the folder "L:\Microsoft.NET\Framework64\Temporary ASP.NET Files"

        Sets ICACLS permissions on the folder
                 
        Baseline ICSCLS for the folder "Temporary ASP.NET Files"
        
            NT AUTHORITY\SYSTEM:(F)
            CREATOR OWNER:(OI)(CI)(IO)(F)
            NT AUTHORITY\SYSTEM:(OI)(CI)(F)
            BUILTIN\Administrators:(OI)(CI)(F)
            BUILTIN\IIS_IUSRS:(OI)(CI)(M,DC)
            BUILTIN\Users:(RX)
            BUILTIN\Users:(OI)(CI)(IO)(GR,GE)
            "ALL APPLICATION PACKAGES:(RX)"
            "ALL APPLICATION PACKAGES:(OI)(CI)(IO)(GR,GE)"

    .PARAMETER FilePath
        "c:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\web.config" 

    .PARAMETER Find
        <compilation>

    .PARAMETER Replace
        <compilation tempDirectory="L:\Microsoft.NET\Framework64\Temporary ASP.NET Files">

    .EXAMPLE stop and start IIS services
        NET STOP WAS /Y && NET START W3SVC
        or
        iisreset 
    #>

# Create the Folder on the L: drive

    MKDIR "L:\Microsoft.NET\Framework64\Temporary ASP.NET Files"

# Set Permissions on the new folder root

    icacls "L:\Microsoft.NET" /inheritance:d
    icacls "L:\Microsoft.NET" /grant:r "CREATOR OWNER:(OI)(CI)(IO)(F)"
    icacls "L:\Microsoft.NET" /grant:r "NT AUTHORITY\SYSTEM:(OI)(CI)(F)"
    icacls "L:\Microsoft.NET" /grant:r "BUILTIN\Administrators:(OI)(CI)(F)"
    icacls "L:\Microsoft.NET" /grant:r "BUILTIN\IIS_IUSRS:(OI)(CI)(M,WDAC,DC)"
    icacls "L:\Microsoft.NET" /grant:r "BUILTIN\Users:(OI)(CI)(RX)"
    icacls "L:\Microsoft.NET" /grant:r "NT SERVICE\TrustedInstaller:(CI)(F)"
    icacls "L:\Microsoft.NET" /grant:r "ALL APPLICATION PACKAGES:(RX)"
    icacls "L:\Microsoft.NET" /grant:r "ALL APPLICATION PACKAGES:(OI)(CI)(IO)(GR,GE)"

# Check folder permissions

    icacls "L:\Microsoft.NET\Framework64\Temporary ASP.NET Files"

# Copy a backup of current web.config file as web.config.old and to c:\temp

    copy "c:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\web.config" "c:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\web.config.old"
    copy "c:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\web.config" c:\temp\web.config

# Change the string in the web.config file to point files to new location

    $content = Get-Content -Path 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\web.config'
    $newContent = $content -replace '<compilation>', '<compilation tempDirectory="L:\Microsoft.NET\Framework64\Temporary ASP.NET Files">'
    $newContent | Set-Content -Path 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\web.config'

# Check type web.config file and find string <compilation Should read as below
# <compilation tempDirectory="L:\Microsoft.NET\Framework64\Temporary ASP.NET Files"> 

    type "c:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\web.config" |findstr "<compilation"

# Testing https://paz1ehswtw2v/HSWeb_EXAM_920-7/


# At the command prompt, type net stop WAS and press ENTER; type Y and then press ENTER to stop W3SVC as well.


    NET STOP WAS /Y && NET START W3SVC
 
