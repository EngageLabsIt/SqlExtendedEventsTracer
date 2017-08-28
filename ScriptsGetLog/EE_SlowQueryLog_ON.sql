:setvar DatabaseName
:setvar DurationMicroSeconds
:setvar LogFolder

/*  THIS QUERY NEEDS TO BE RUN IN SQLCMD MODE                          */
/*  To enable SQLCMD mode in SSMS use the Query Menu and select SQLCMD */

/* DatabaseName				= ALL */
/* DurationMicroSeconds		= 200000 = 200 millisecondi in microseconds */
/* LogFolder				= C:\_DbLogTest = Destination log folder  C:\_DbLogTest */


USE MASTER;
GO

/* Conditionally drop the session if it already exists */
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'EE_SlowQueryLog')
    DROP EVENT SESSION EE_SlowQueryLog ON SERVER;
 GO  


/*
Devo fare due CREATE EVENT SESSION diversi perchè quel maledetto di SQL non prende la condizione 
  AND (sqlserver.database_name = N'$(DatabaseName)' OR N'$(DatabaseName)' = N'ALL')
*/
IF N'$(DatabaseName)' = N'ALL'
BEGIN
	/* Create the session */
	CREATE EVENT SESSION EE_SlowQueryLog ON SERVER
	ADD EVENT sqlserver.rpc_completed
	(
		ACTION
		(
		  sqlserver.client_app_name
		, sqlserver.client_hostname
		, sqlserver.database_name
		, sqlserver.plan_handle
		, sqlserver.sql_text
		, sqlserver.username
		)
		WHERE 
			duration > $(DurationMicroSeconds) /* 200 milliseconds in microseconds */ 
	)
	ADD TARGET package0.asynchronous_file_target(SET FILENAME = N'$(LogFolder)\EE_SlowQueryLog.xel')
	--WITH (
	--		MAX_DISPATCH_LATENCY = 1 seconds -- da eliminare e lasciare il default di 30 secondi
	--	)
		;
END
ELSE
BEGIN
	/* Create the session */
	CREATE EVENT SESSION EE_SlowQueryLog ON SERVER
	ADD EVENT sqlserver.rpc_completed
	(
		ACTION
		(
		  sqlserver.client_app_name
		, sqlserver.client_hostname
		, sqlserver.database_name
		, sqlserver.plan_handle
		, sqlserver.sql_text
		, sqlserver.username
		)
		WHERE 
			duration > $(DurationMicroSeconds) /* 200 milliseconds in microseconds */ 
		AND sqlserver.database_name = N'$(DatabaseName)'
	)
	ADD TARGET package0.asynchronous_file_target(SET FILENAME = N'$(LogFolder)\EE_SlowQueryLog.xel')
	--WITH (
	--		MAX_DISPATCH_LATENCY = 1 seconds -- da eliminare e lasciare il default di 30 secondi
	--	)
		;
END
GO


/* Start Session */
ALTER EVENT SESSION EE_SlowQueryLog ON SERVER STATE = START;
GO 
