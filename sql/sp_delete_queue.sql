USE [one-c-sharp-service-broker]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_delete_queue](@name nvarchar(80))
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @queue_name nvarchar(128) = [dbo].[fn_create_queue_name](@name);
	DECLARE @service_name nvarchar(128) = [dbo].[fn_create_service_name](@name);
	DECLARE @default_service_name nvarchar(128) = [dbo].[fn_default_service_name]();

	IF (@default_service_name = @queue_name) THROW 50001, N'The default queue can not be droped!', 1;
	
	IF EXISTS(SELECT 1 FROM sys.services WHERE name = @service_name)
	BEGIN
		EXEC(N'DROP SERVICE [' + @service_name + N'];');
	END;

	IF EXISTS(SELECT 1 FROM sys.service_queues WHERE name = @queue_name)
	BEGIN
		EXEC(N'DROP QUEUE [dbo].[' + @queue_name + N'];');
	END;

	-- ==============================================
	-- Receive error message for default local dialog
	-- ==============================================
	-- http://schemas.microsoft.com/SQL/ServiceBroker/Error
	-- 'Remote service has been dropped.' message !
END;
GO