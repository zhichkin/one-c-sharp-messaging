USE [one-c-sharp-messaging]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_dialog_handle]    Script Date: 26.05.2020 0:34:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_dialog_handle]
	@service nvarchar(128),          -- service name {service_broker_guid}/Service/{queue_name}
	@handle  uniqueidentifier OUTPUT -- dialog handle to send message[s] on
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @broker uniqueidentifier; -- target service broker guid
	DECLARE @database_id int;         -- target database id
	
	BEGIN TRY
		SET @broker = CAST(SUBSTRING(@service, 1, 36) AS uniqueidentifier);
	END TRY
	BEGIN CATCH
		RETURN 1; -- Invalid 'queue' parameter error
	END CATCH

	SELECT @database_id = database_id FROM sys.databases WHERE is_broker_enabled = 0x01 AND service_broker_guid = @broker;

	IF (@database_id IS NULL) -- remote database queue
	BEGIN
		-- remote queue
		IF NOT EXISTS(SELECT 1 FROM sys.routes WHERE remote_service_name = @service) RETURN 2; -- Route not found error
		IF NOT EXISTS(SELECT 1 FROM sys.remote_service_bindings WHERE remote_service_name = @service) RETURN 3; -- Remote service binding not found error
		SELECT TOP (1)
			@handle = dialogs.conversation_handle
		  FROM (SELECT TOP (2) conversation_handle FROM sys.conversation_endpoints
				 WHERE far_service = @service
				   AND far_broker_instance = @broker
				   AND state IN ('CO', 'SO')
			  ORDER BY is_initiator DESC) AS dialogs;
	END
	ELSE IF (@database_id = DB_ID()) -- same database queue
	BEGIN
		SELECT @handle = conversation_handle FROM sys.conversation_endpoints
		 WHERE far_service = @service
		   AND far_broker_instance = @broker
		   AND state IN ('CO', 'SO');
	END
	ELSE -- neighboring database queue (user without login but certificate must be present)
	BEGIN
		SELECT @handle = conversation_handle FROM sys.conversation_endpoints
		 WHERE far_service = @service
		   AND far_broker_instance = @broker
		   AND state IN ('CO', 'SO');
	END

	IF (@handle IS NULL) RETURN 4; -- Dialog handle not found error

    RETURN 0;
END
