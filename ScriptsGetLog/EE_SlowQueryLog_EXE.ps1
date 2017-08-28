cls
$error.Clear()
$CurrentFolder = Split-Path $MyInvocation.MyCommand.Definition -Parent
$PsExtEventOn = ".\EE_SlowQueryLog_ON.ps1"
$PsExtEventOff = ".\EE_SlowQueryLog_OFF.ps1"
$PsShowLog = "..\ScriptsAnalyzeLog\EE_SlowQueryLog_SHOW.ps1"

Write-Host "Extended Events diagnostic to get the Slow Query !!" -ForegroundColor Cyan


#region SERVER MANAGEMENT
$MachineName = $env:computername
$FullServerName = Read-Host "Server name\Instance name (empty to auto-discover)"
Write-Host 
if ($FullServerName -eq "")
{
    Write-Host "Gathering instance data.." -ForegroundColor Yellow

    # default instance name (the first in the registry key)
    $InstanceName = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances | Select-Object -first 1

    if ($InstanceName -ne "MSSQLSERVER")
    {
        $serverName = $MachineName + "\"+ $InstanceName
    } 
    else
    {
        $serverName = $MachineName
    }
} else 
{
    $serverName = $FullServerName
}

if ($serverName.StartsWith("."))
{
    $serverName = $serverName -replace "\.", $MachineName
}

Write-Host "Instance name set to '$serverName'" -ForegroundColor Gray
Write-Host 
#endregion

#region Log Folder
do 
{
    $LogFolder = Read-Host "Log Folder (empty to set 'C:\_DbLogTest')"
    if ($LogFolder -eq "")
    {
        $LogFolder = "C:\_DbLogTest"
    } 

    if (!(Test-Path $LogFolder))
    {
        New-Item -ItemType Directory -Path $LogFolder | Out-Null 
    } 
} 
until (Test-Path $LogFolder -pathType container)
Write-Host "Log Folder set to '$LogFolder'" -ForegroundColor Gray
Write-Host 
#endregion

#region Activate the Extended Events script

Push-Location $CurrentFolder
Invoke-Expression "$PsExtEventOn -serverName '$serverName' -LogFolder '$LogFolder'"
Pop-Location

#endregion

#region Open Show Log in another windows

$Command = $PsShowLog + " ""$serverName"" ""$LogFolder"""

Push-Location $CurrentFolder
invoke-expression 'cmd /c start powershell -NoProfile -ExecutionPolicy unrestricted -Command $Command'
Pop-Location

#endregion


#region Show group result data from file
$Count = 0
$continue = $true
while($continue)
{

    if ([console]::KeyAvailable)
    {
        $x = [System.Console]::ReadKey() 

        switch ( $x.key)
        {
            F12 { $continue = $false }
            q { $continue = $false }
            Q { $continue = $false }

        }
    } 
    else
    {
        cls
        Write-Host "Program is running... (Press F12 or Q to STOP)"
        Write-Host $Count

        #list of files
        Get-ChildItem "$LogFolder" -Filter EE_SlowQueryLog_*.xel | sort-Object -property name | 
        Foreach-Object {

            Write-Host $_.FullName
            Write-Host $_.length

        }

        $Count++

        # wait for 1 second
        Start-Sleep -m 1000
    }    
}
#endregion

    
#region De-Activate the Extended Events script

Push-Location $CurrentFolder
Invoke-Expression "$PsExtEventOff -serverName '$serverName'"
Pop-Location

#endregion

#region Open Folder

#explorer $LogFolder

#endregion

#Write-Host "Press ENTER to close.." -ForegroundColor Cyan
#Read-Host



