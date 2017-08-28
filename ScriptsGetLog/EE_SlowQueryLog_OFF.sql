 /* Stop the Extended Events session */
ALTER EVENT SESSION EE_SlowQueryLog ON SERVER STATE = STOP;

/* Remove the session from the server. */
DROP EVENT SESSION EE_SlowQueryLog ON SERVER;
