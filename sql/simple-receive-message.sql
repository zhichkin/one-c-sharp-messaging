DECLARE @handle uniqueidentifier;
DECLARE @message_type nvarchar(256);
DECLARE @message_body NVARCHAR(max) = N'';
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN TRANSACTION;
	WAITFOR (RECEIVE TOP (1)
		@handle = conversation_handle,
		@message_type = message_type_name,
		@message_body = CAST(message_body AS nvarchar(max))
	FROM [7d027278-6734-48c3-814e-180f0892dd00/Queue/TargetQueue]
	), TIMEOUT 1000;
	IF (@@ROWCOUNT = 0)
	BEGIN
		ROLLBACK TRANSACTION;
		RETURN;
	END
	ELSE IF (@message_type = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error' OR
			 @message_type = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
	BEGIN
		END CONVERSATION @handle;
	END
	SELECT @message_body;
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
	THROW;
END CATCH
