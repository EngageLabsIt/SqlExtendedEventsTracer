cls
$error.Clear()
$CurrentFolder = Split-Path $MyInvocation.MyCommand.Definition -Parent
#Variables
$PsCreaXml = ".\EE_SlowQueryLog_CREATEXML.ps1"

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
#Write-Host "Log Folder set to '$LogFolder'" -ForegroundColor Gray
Write-Host 
#endregion

#region DatabaseName

$DatabaseName = Read-Host "DatabaseName "
Write-Host 

#endregion

#region ProcName

$ProcName = Read-Host "ProcName "
Write-Host 


#endregion

#region Call show Log script

Push-Location $CurrentFolder
Invoke-Expression "$PsCreaXml -serverName '$serverName' -LogFolder '$LogFolder' -DatabaseName '$DatabaseName' -ProcName '$ProcName'"
Pop-Location

#endregion







