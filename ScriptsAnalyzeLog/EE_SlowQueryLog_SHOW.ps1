param ($serverName, $LogFolder) 

#Parameters:
#            $serverName
#            $LogFolder
#---------------
#Debug
#Write-Host "Debug EE_SlowQueryLog_SHOW.ps1"
#Write-Host "Parameters: "
#Write-Host $serverName
#Write-Host $LogFolder
#Read-Host "Enter to continue debug "
#---------------


$error.Clear()
$CurrentFolder = Split-Path $MyInvocation.MyCommand.Definition -Parent
#$SqlScriptReadFile = ".\RUN_proc_EE_ListSlowestExecutions.sql"
$PsCreaXml = ".\EE_SlowQueryLog_CREATEXML.ps1"


#Read-Host "Current folder: " + $CurrentFolder

#region Read from file and show the output

Push-Location $CurrentFolder

do 
{
    cls


    $query = "EXECUTE [_DBATools].[Troubleshooting].[proc_EE_ListSlowestExecutions] @Folder = DEFAULT, @FilenameWithOutExtenxsion = DEFAULT"

    $connection = new-object system.data.sqlclient.sqlconnection( "Data Source=" + $serverName + ";Integrated Security=SSPI;") 

    #$adapter = new-object system.data.sqlclient.sqldataadapter ($query, $connection)
    #$table = new-object system.data.datatable
    #$adapter.Fill($table) | out-null
    #$arrayDatabaseNames = @($table | select -ExpandProperty database_name)
    #foreach($object in $arrayDatabaseNames){
    #    Write-Host "$i. $($object)"
    #}

    $connection.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $connection
    $Command.CommandText = $query
    $Reader = $Command.ExecuteReader()
    $myArrayProc = New-Object System.Collections.ArrayList
    while ($Reader.Read()) {
         #$object = $Reader.GetValue($1)
         #Write-Host "$($object)"
         #Write-Host $Reader.GetValue(0).PadRight(15) + $Reader.GetValue(1).PadRight(15) + $Reader.GetValue(2).PadLeft(15)
         #Write-Host ($Reader.GetValue(0)).PadRight(30) ($Reader.GetValue(1)).PadRight(30) ($Reader.GetValue(2)).PadLeft(10)
         #Write-Host 
         "{0,2} {1,-30} {2,-40} {3,8}" -f $myArrayProc.Add(($Reader.GetValue(0), $Reader.GetValue(1))) , $Reader.GetValue(0), $Reader.GetValue(1), $Reader.GetValue(2)
         

    }
    $connection.Close()

    
    #Write-Host
    #Invoke-Sqlcmd -inputfile $SqlScriptReadFile -serverinstance $serverName 

    if ($error.Count -eq 0) 
    {
        Write-Host
        $ReadContinue = Read-Host "Enter 'q' to quit; Enter to refresh; The number of the procedure to analyze: "
        Write-Host

    } else {
        Write-Host "Error on script executing!" -ForegroundColor Red
        $ReadContinue = "q"
    }

    [int]$ProcSelection = -1
    if ($ReadContinue -match "[0-9]") {
        $ProcSelection = $ReadContinue
    }


} 
until (($ReadContinue -eq "q") -or ($ProcSelection -gt -1 -and $ProcSelection -lt $myArrayProc.Count))

if ($ReadContinue -ne "q") {

    $DatabaseName = $myArrayProc[$ProcSelection][0] #Database
    $ProcName = $myArrayProc[$ProcSelection][1] #Procedure

    #Eseguo lo script per creare i piani di esecuzione
    Push-Location $CurrentFolder
    Invoke-Expression "$PsCreaXml -serverName '$serverName' -LogFolder '$LogFolder' -DatabaseName '$DatabaseName' -ProcName '$ProcName'"
    Pop-Location

}



Pop-Location


#endregion






