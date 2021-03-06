USE [one-c-sharp-messaging]
GO
/****** Object:  StoredProcedure [dbo].[sp_send_message]    Script Date: 26.05.2020 0:35:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_send_message]
	@dialog_handle uniqueidentifier,
	@message_body nvarchar(max),
	@message_type nvarchar(128) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF (@message_type IS NULL)
	BEGIN
		SET @message_type = N'DEFAULT';
	END;

	SEND ON CONVERSATION @dialog_handle MESSAGE TYPE @message_type (CAST(@message_body AS varbinary(max)));

    RETURN 0;
END
