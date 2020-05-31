SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_delete_queue]
	@name nvarchar(128)
AS
BEGIN
	SET NOCOUNT ON;

	IF ([dbo].[fn_is_name_valid](@name) = 0x00) THROW 50001, N'Bad queue name format.', 1;

	SET XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		DELETE [dbo].[queues] WHERE [name] = @name;

		IF OBJECT_ID(N'dbo.' + @name, 'U') IS NOT NULL
		BEGIN
			EXEC(N'DROP TABLE [dbo].[' + @name + N'];');
		END;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH

	RETURN 0;
END
GO
