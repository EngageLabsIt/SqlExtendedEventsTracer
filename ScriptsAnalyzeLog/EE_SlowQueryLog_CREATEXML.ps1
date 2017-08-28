#Parameters:
#            $serverName
#            $LogFolder
#            $DatabaseName
#            $ProcName

#---------------
#Debug
#Write-Host "Debug EE_SlowQueryLog_CREATEXML.ps1"
#Write-Host "Parameters: "
#Write-Host $serverName
#Write-Host $LogFolder
#Write-Host $DatabaseName
#Write-Host $ProcName
#Read-Host "Enter to continue debug "
#---------------

$error.Clear()
$CurrentFolder = Split-Path $MyInvocation.MyCommand.Definition -Parent
#$SqlScriptReadFile = ".\RUN_proc_EE_ListSlowestExecutions.sql"

#region Create Folder
#Cartella di destinazione dei log
$LogProcFolder = Join-Path $LogFolder $ProcName

Write-Host "The plan will be stored in the folder '$LogProcFolder'" -ForegroundColor Gray
if (!(Test-Path $LogProcFolder))
{
    New-Item -ItemType Directory -Path $LogProcFolder | Out-Null 
}

#endregion


#region Run procedure and create xml file

Push-Location $CurrentFolder

$query = "EXECUTE [_DBATools].[Troubleshooting].[proc_Plans_ListSlowestCommands] @DataBaseName = '$DatabaseName', @ProcName = '$ProcName'"

$connection = new-object system.data.sqlclient.sqlconnection( "Data Source=" + $serverName + ";Integrated Security=SSPI;") 

$adapter = new-object system.data.sqlclient.sqldataadapter ($query, $connection)
$table = new-object system.data.datatable
$adapter.Fill($table) | out-null
$arrayPlan = @($table | select -ExpandProperty query_plan)
$i = 0
foreach($object in $arrayPlan){
    #Debug
    #Write-Host "$i. $($object)"

    $i += 1
    $fileName = "ExecutionPlan" + $i + ".sqlplan"
    $planPath = Join-Path $LogProcFolder $fileName

    #Debug
    #Write-Host $planPath 

    New-Item $planPath -type file -force -value $($object)
}


Pop-Location
#endregion

#region Open Folder

explorer $LogProcFolder

#endregion

#Write-Host
#Read-Host "Enter to close "


