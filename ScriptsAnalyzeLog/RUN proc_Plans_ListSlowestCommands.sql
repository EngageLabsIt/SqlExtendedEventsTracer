USE [_DBATools]
GO

DECLARE @RC int
DECLARE @DataBaseName varchar(50)
DECLARE @ProcName varchar(50)

SELECT
   @DataBaseName = 'Accounts_Dev'
  ,@ProcName = 'proc_Clients_CheckUsername'

EXECUTE @RC = [Troubleshooting].[proc_Plans_ListSlowestCommands] 
   @DataBaseName
  ,@ProcName
GO


