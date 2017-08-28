#cls
#$error.Clear()
$CurrentFolder = Split-Path $MyInvocation.MyCommand.Definition -Parent
$DatabaseScript = Join-Path  -Path $CurrentFolder -ChildPath "EE_SlowQueryLog_ON.sql"
#Parameters: $serverName

Write-Host "ACTIVATE the Extended Events to get the Slow Query !!" -ForegroundColor Cyan

#region DATABASE MANAGEMENT
$DatabaseName = Read-Host "Database name (empty to check all databases)"
if ($DatabaseName -ne "")
{
    Write-Host "Check Database exists.." -ForegroundColor Yellow
    #flag for checking whether databases are installed or not
   $DatabaseExists = Invoke-Sqlcmd -Query "DECLARE @v int; SELECT @v=DB_ID('$DatabaseName'); SELECT @v AS DBExists;" -serverinstance $serverName 

    if ([string]::IsNullOrEmpty($DatabaseExists.DBExists)) 
    {
	    Write-Host "The database '$DatabaseName' does not exist." -ForegroundColor red    
        break
    } 
} else {
    $DatabaseName = "ALL"
}
Write-Host "Database name set to '$DatabaseName'" -ForegroundColor Gray
Write-Host 
#endregion


#region Duration
$inputOK = $false
do 
{
    try
    {    
        [int]$DurationMilliSeconds = Read-Host "Duration milliseconds (empty to set 200) (the minimum allowed is 200)"
        if ($DurationMilliSeconds -eq "")
        {
           $DurationMilliSeconds = 200
        } 
        $inputOK = $true
    }
    catch
    {
        Write-Host "INVALID INPUT!  Please enter a numeric value." -ForegroundColor red 
    } 

    if ($DurationMilliSeconds -lt 200)
    {
        Write-Host "The minimum allowed is 200 !!!!" -ForegroundColor red 
        $inputOK = $false
    } 

} 
until ($inputOK)
Write-Host "Duration milliseconds set to '$DurationMilliSeconds'" -ForegroundColor Gray
$DurationMicroSeconds = $DurationMilliSeconds * 1000
Write-Host "Duration microseconds set to '$DurationMicroSeconds'" -ForegroundColor Gray
Write-Host 
#endregion

#region SCRIPT EXECUTION
Write-Host
Write-Host "Loading and executing setup scripts.." -ForegroundColor Yellow
Write-Host -NoNewline "Executing "$DatabaseScript" setup script.." -ForegroundColor Gray
Write-Host 
Invoke-Sqlcmd -inputfile $DatabaseScript -serverinstance $serverName -Variable DatabaseName="$DatabaseName", DurationMicroSeconds="$DurationMicroSeconds", LogFolder="$LogFolder" 

if ($error.Count -eq 0) 
{
    Write-Host "Script executed  successfully!" -ForegroundColor Green
} else {
    Write-Host "Error on script executing!" -ForegroundColor Red
}
#endregion