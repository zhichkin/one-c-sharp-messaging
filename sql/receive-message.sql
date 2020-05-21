DECLARE @handle UNIQUEIDENTIFIER;
DECLARE @message_body NVARCHAR(max) = N'';
DECLARE @message_type nvarchar(256); -- sysname

SET XACT_ABORT ON;
BEGIN TRY
	BEGIN TRANSACTION;

    WAITFOR
    (RECEIVE TOP (1)
        @handle = conversation_handle,
        @message_body = message_body,
        @message_type = message_type_name
      FROM [dbo].[7d027278-6734-48c3-814e-180f0892dd00/Queue/TargetQueue]
	  --[dbo].[2677a8fb-b2ca-4d9b-a51d-3699bbc89e1a/Queue/SourceQueue]
    ), TIMEOUT 1000; -- 1 second

    IF (@@ROWCOUNT = 0)
    BEGIN
      ROLLBACK TRANSACTION;
	  -- SELECT @message_body; !?
    END
    ELSE IF (@message_type = N'DEFAULT')
    BEGIN
		SELECT CAST(@message_body AS nvarchar(max));
		--SEND ON CONVERSATION @handle MESSAGE TYPE [DEFAULT] (N'success');
    END
    ELSE IF (@message_type = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
    BEGIN
       END CONVERSATION @handle;
    END
    ELSE IF (@message_type = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
    BEGIN
       END CONVERSATION @handle; -- WITH CLEANUP; !?
    END
      
    COMMIT TRANSACTION; -- ?!
END TRY
BEGIN CATCH
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
	THROW;
END CATCH