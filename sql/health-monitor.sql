SELECT * FROM sys.symmetric_keys;
SELECT * FROM sys.certificates;
SELECT * FROM sys.service_broker_endpoints;
SELECT * FROM sys.tcp_endpoints AS i
INNER JOIN sys.service_broker_endpoints AS e
ON i.endpoint_id = e.endpoint_id;

SELECT * FROM sys.database_principals;

SELECT * FROM sys.routes;
SELECT * FROM sys.remote_service_bindings;
SELECT * FROM sys.transmission_queue;
SELECT * FROM sys.conversation_endpoints;

--SELECT * FROM [dbo].[7d027278-6734-48c3-814e-180f0892dd00/Queue/TargetQueue]
--SELECT service_name, CAST(message_body AS nvarchar(max)) FROM [dbo].[7d027278-6734-48c3-814e-180f0892dd00/Queue/TargetQueue]
