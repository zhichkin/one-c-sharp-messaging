SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_produce_message]
	@queue_name nvarchar(128),
	@message_body nvarchar(max),
	@message_type nvarchar(128) = N''
AS
BEGIN
	SET NOCOUNT ON;

	--EXEC(

	INSERT [dbo].[queue] (@message_body) VALUES (@message_body);
    
END;
GO
