USE [_DBATools]
GO

DECLARE @RC int
DECLARE @Folder varchar(100)
DECLARE @FilenameWithOutExtenxsion varchar(50)

-- TODO: Set parameter values here.

EXECUTE @RC = [Troubleshooting].[proc_EE_ListSlowestExecutions] 
   @Folder = DEFAULT
  ,@FilenameWithOutExtenxsion = DEFAULT



