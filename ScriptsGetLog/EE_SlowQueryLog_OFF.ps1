$error.Clear()
$CurrentFolder = Split-Path $MyInvocation.MyCommand.Definition -Parent
$DatabaseScript = Join-Path  -Path $CurrentFolder -ChildPath "EE_SlowQueryLog_OFF.sql"
#Parameters: $serverName

Write-Host "DE-ACTIVATE the Extended Events to get the Slow Query !!" -ForegroundColor Cyan

#region SCRIPT EXECUTION
Write-Host
Write-Host "Loading and executing setup scripts.." -ForegroundColor Yellow
Write-Host -NoNewline "Executing "$DatabaseScript" setup script.." -ForegroundColor Gray
Write-Host 
Invoke-Sqlcmd -inputfile $DatabaseScript -serverinstance $serverName

if ($error.Count -eq 0) 
{
    Write-Host "Script executed  successfully!" -ForegroundColor Green
} else {
    Write-Host "Error on script executing!" -ForegroundColor Red
}
#endregion