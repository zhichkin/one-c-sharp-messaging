USE [one-c-sharp-messaging];
IF NOT EXISTS(SELECT 1 FROM sys.routes WHERE name = 'RouteFromSourceToTarget')
BEGIN
	CREATE ROUTE [RouteFromSourceToTarget] WITH
		SERVICE_NAME = '7d027278-6734-48c3-814e-180f0892dd00/Service/TargetQueue',
		ADDRESS = 'TCP://ZHICHKIN\SQLEXPRESS:4321';
END
IF NOT EXISTS(SELECT 1 FROM sys.remote_service_bindings WHERE name = 'RouteFromSourceToTarget')
BEGIN
	CREATE REMOTE SERVICE BINDING [RouteFromSourceToTarget]
		TO SERVICE '7d027278-6734-48c3-814e-180f0892dd00/Service/TargetQueue'
		WITH
			USER = [7d027278-6734-48c3-814e-180f0892dd00/User],
			ANONYMOUS = ON;
END
DECLARE @handle UNIQUEIDENTIFIER = NULL;
SELECT @handle = handle FROM [dbo].[channels] WHERE name = N'RouteFromSourceToTarget';
IF (@handle IS NULL)
BEGIN
	SET XACT_ABORT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

			BEGIN DIALOG @handle
			FROM SERVICE [2677a8fb-b2ca-4d9b-a51d-3699bbc89e1a/Service/SourceQueue]
			TO SERVICE '7d027278-6734-48c3-814e-180f0892dd00/Service/TargetQueue', '7d027278-6734-48c3-814e-180f0892dd00'
			ON CONTRACT [DEFAULT]
			WITH ENCRYPTION = OFF;

			INSERT [dbo].[channels] (name, handle)
			VALUES (N'RouteFromSourceToTarget', @handle);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END