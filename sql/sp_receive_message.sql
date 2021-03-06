USE [one-c-sharp-messaging]
GO
/****** Object:  StoredProcedure [dbo].[sp_receive_message]    Script Date: 26.05.2020 0:55:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_receive_message]
	@queue   nvarchar(128),
	@timeout int = 1000,
	@handle  uniqueidentifier OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @broker uniqueidentifier = CAST(SUBSTRING(@queue, 1, 36) AS uniqueidentifier);
	END TRY
	BEGIN CATCH
		SET @handle = CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier);
		SELECT N'' AS [message_body], N'' AS [message_type];
		RETURN 1;
	END CATCH

	DECLARE @message_type nvarchar(128);
	DECLARE @message_body nvarchar(max);

	DECLARE @sql nvarchar(1024) = N'WAITFOR (RECEIVE TOP (1)
		@handle_out = conversation_handle,
		@message_type_out = message_type_name,
		@message_body_out = CAST(message_body AS nvarchar(max))
		FROM [dbo].[{queue}]
	), TIMEOUT @timeout;';
	SET @sql = REPLACE(@sql, N'{queue}', @queue);

	EXECUTE sp_executesql
		@sql,
		N'@handle_out uniqueidentifier OUTPUT, @message_type_out nvarchar(128) OUTPUT,
		  @message_body_out nvarchar(max) OUTPUT, @timeout int',
		  @handle_out = @handle OUTPUT,
		  @message_type_out = @message_type OUTPUT,
		  @message_body_out = @message_body OUTPUT,
		  @timeout = @timeout;

	IF (@@ROWCOUNT = 0)
	BEGIN
		SET @handle = CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier);
		SELECT N'' AS [message_body], N'' AS [message_type];
		RETURN 0;
	END

	IF (@message_type = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error' OR
        @message_type = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
	BEGIN
		END CONVERSATION @handle;
	END

	SELECT @message_body AS [message_body], @message_type AS [message_type];

	RETURN 0;
END
GO