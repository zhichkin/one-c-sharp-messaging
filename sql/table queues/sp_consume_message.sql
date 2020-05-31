USE [one-c-sharp-queuing]
GO
/****** Object:  StoredProcedure [dbo].[sp_consume_message]    Script Date: 01.06.2020 0:54:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_consume_message]
	@queue_name nvarchar(128),
	@number_of_messages int = 1
AS
BEGIN
	SET NOCOUNT ON;

	IF ([dbo].[fn_is_name_valid](@queue_name) = 0x00) THROW 50001, N'Bad queue name format.', 1;

	IF (@number_of_messages <= 0) THROW 50002, N'Invalid parameter value: @number_of_messages.', 1;

	DECLARE @type char(4);
	DECLARE @mode char(1);
	SELECT @type = [type], @mode = [mode] FROM [dbo].[queues] WHERE [name] = @queue_name;

	IF (@type IS NULL) THROW 50003, N'Queue is not found.', 1;

	DECLARE @sql nvarchar(1024);

	IF (@type IN ('FIFO', 'LIFO'))
	BEGIN
		SET @sql = N'WITH [cte] AS
			(
				SELECT TOP (@number_of_messages)
					[consume_order],
					[message_type],
					[message_body]
				FROM
					[dbo].[' + @queue_name + N'] WITH (rowlock' + IIF(@mode = 'S', N'', N', readpast') + N')
				ORDER BY
					[consume_order] ' + IIF(@type = 'FIFO', N'ASC', N'DESC') + N'
			)
			DELETE [cte] OUTPUT
				deleted.[message_type]                        AS [message_type],
				CAST(deleted.[message_body] AS nvarchar(max)) AS [message_body];';
	END;
	ELSE IF (@type = 'HEAP')
	BEGIN
		SET @sql = N'DELETE TOP (@number_of_messages)
				[dbo].[' + @queue_name + N'] WITH (rowlock, readpast)
			OUTPUT
				deleted.[message_type]                        AS [message_type],
				CAST(deleted.[message_body] AS nvarchar(max)) AS [message_body];';
	END;
	ELSE IF (@type = 'TIME')
	BEGIN
		SET @sql = N'WITH [cte] AS
			(
				SELECT TOP (@number_of_messages)
					[consume_time],
					[message_type],
					[message_body]
				FROM
					[dbo].[' + @queue_name + N'] WITH (rowlock' + IIF(@mode = 'S', N'', ', readpast') + N')
				WHERE
					[consume_time] < GETUTCDATE()
				ORDER BY
					[consume_time] ASC
			)
			DELETE [cte] OUTPUT
				deleted.[message_type]                        AS [message_type],
				CAST(deleted.[message_body] AS nvarchar(max)) AS [message_body];';
	END; 

	EXECUTE sp_executesql @sql, N'@number_of_messages int', @number_of_messages = @number_of_messages;

    RETURN @@ROWCOUNT;
END;
