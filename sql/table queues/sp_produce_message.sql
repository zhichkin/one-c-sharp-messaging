USE [one-c-sharp-queuing]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_produce_message]
	@queue_name   nvarchar(128),
	@message_body nvarchar(max), -- use varchar(max) for BASE64 to reduce memory space !!!
	@message_type nvarchar(128) = N'',
	@consume_time datetime = '2020-01-01'
AS
BEGIN
	SET NOCOUNT ON;

	IF ([dbo].[fn_is_name_valid](@queue_name) = 0x00) THROW 50001, N'Bad queue name format.', 1;

	IF (@message_body IS NULL OR @message_body = '') THROW 50002, N'Invalid parameter value: @message_body.', 1;

	IF (@message_type IS NULL) SET @message_type = N'';

	IF (@consume_time IS NULL) SET @consume_time = '2020-01-01';

	DECLARE @type char(4);
	DECLARE @mode char(1);
	SELECT @type = [type], @mode = [mode] FROM [dbo].[queues] WHERE [name] = @queue_name;

	IF (@type IS NULL) THROW 50003, N'Queue is not found.', 1;

	DECLARE @sql nvarchar(1024);
	DECLARE @message_body_value varbinary(max) = CAST(@message_body AS varbinary(max));

	IF (@type = 'TIME')
	BEGIN
		SET @sql = N'INSERT [dbo].[' + @queue_name + N']
				([consume_time], [message_type], [message_body])
			VALUES
				(@consume_time, @message_type, @message_body);';
		EXECUTE sp_executesql @sql, N'@consume_time datetime, @message_type nvarchar(128), @message_body varbinary(max)',
				@consume_time = @consume_time, @message_type = @message_type, @message_body = @message_body_value;
	END;
	ELSE
	BEGIN
		SET @sql = N'INSERT [dbo].[' + @queue_name + N'] ([message_type], [message_body]) VALUES (@message_type, @message_body);';
		EXECUTE sp_executesql @sql, N'@message_type nvarchar(128), @message_body varbinary(max)',
				@message_type = @message_type, @message_body = @message_body_value;
	END;

	RETURN 0;
END;
