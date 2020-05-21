USE [one-c-sharp-messaging]
GO

DECLARE @handle UNIQUEIDENTIFIER = NULL;
SELECT @handle = handle FROM [dbo].[channels] WHERE name = N'routeName';
SELECT @handle;

IF (@handle IS NULL)
BEGIN

	SET XACT_ABORT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		BEGIN DIALOG @handle
		FROM SERVICE [{sourceServiceName}]
		TO SERVICE '{targetServiceName}', '{targetBroker}'
		ON CONTRACT [DEFAULT]
		WITH ENCRYPTION = OFF;

		INSERT [dbo].[channels] (name, handle)
		VALUES (N'{routeName}', @handle);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END