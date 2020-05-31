
DECLARE @count int;
DECLARE @name nvarchar(128) = 'test';
DECLARE @message_body nvarchar(max) = 'test тест';

--EXEC [dbo].[sp_create_queue] @name;
--EXEC [dbo].[sp_delete_queue] @name;

--EXEC [dbo].[sp_produce_message] @name, @message_body;

BEGIN TRANSACTION;
EXEC @count = [dbo].[sp_consume_message] @name, 2;
SELECT @count;

--ROLLBACK TRANSACTION;
--COMMIT TRANSACTION;

SELECT TOP (1000) [consume_order]
      ,CASE WHEN [message_type] IS NULL THEN 'null' ELSE 'empty' END
      ,CAST([message_body] AS nvarchar(max))
  FROM [one-c-sharp-queuing].[dbo].[test] WITH (NOLOCK);

SELECT TOP (1000) [name],[type],[mode] FROM [one-c-sharp-queuing].[dbo].[queues];