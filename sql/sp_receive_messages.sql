USE [one-c-sharp-messaging]
GO
/****** Object:  StoredProcedure [dbo].[sp_receive_messages]    Script Date: 26.05.2020 1:20:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_receive_messages]
	@queue nvarchar(128),
	@timeout int = 1000,
	@number_of_messages int = 10
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @broker uniqueidentifier = CAST(SUBSTRING(@queue, 1, 36) AS uniqueidentifier);
	END TRY
	BEGIN CATCH
		SELECT CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS [dialog_handle],
			N'' AS [message_body], N'' AS [message_type];
		RETURN 1;
	END CATCH

	DECLARE @sql nvarchar(1024) = N'WAITFOR (RECEIVE TOP (@number_of_messages)
		conversation_handle                 AS [dialog_handle],
		message_type_name                   AS [message_type],
		CAST(message_body AS nvarchar(max)) AS [message_body]
		FROM [dbo].[{queue}]
	), TIMEOUT @timeout;';
	SET @sql = REPLACE(@sql, N'{queue}', @queue);

	EXECUTE sp_executesql @sql,
		N'@number_of_messages int, @timeout int',
		  @number_of_messages = @number_of_messages, @timeout = @timeout;

	RETURN 0;
END
