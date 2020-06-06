SELECT * FROM sys.symmetric_keys;
SELECT * FROM sys.certificates;
SELECT * FROM sys.service_broker_endpoints;

SELECT * FROM sys.tcp_endpoints AS i
INNER JOIN sys.service_broker_endpoints AS e
ON i.endpoint_id = e.endpoint_id;

SELECT * FROM sys.service_message_types;

SELECT * FROM sys.database_principals;

SELECT * FROM sys.routes;
SELECT * FROM sys.remote_service_bindings;
SELECT * FROM sys.transmission_queue;
SELECT * FROM sys.conversation_endpoints;

--SELECT * FROM [dbo].[7437A48F-E4B0-4107-BDE4-BE1B47B3CA5F/queue/default];
--SELECT service_name, CAST(message_body AS nvarchar(max)) FROM [dbo].[7437A48F-E4B0-4107-BDE4-BE1B47B3CA5F/queue/default];

SELECT * FROM sys.services
SELECT * FROM sys.service_queues
SELECT * FROM sys.service_queue_usages
SELECT * FROM sys.conversation_endpoints