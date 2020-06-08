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

SELECT service_name,
CAST(message_body AS varchar(max)) AS [UTF-8],
CAST(message_body AS nvarchar(max)) AS [UTF-16],
DATALENGTH(message_body) AS [size]
FROM [dbo].[06000E2A-06AA-43B8-AE6E-0DDF3F718997/queue/test];

SELECT * FROM sys.services
SELECT * FROM sys.service_queues
SELECT * FROM sys.service_queue_usages
SELECT * FROM sys.conversation_endpoints