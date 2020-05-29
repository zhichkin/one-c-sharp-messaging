USE [one-c-sharp-queuing]
GO
/****** Object:  StoredProcedure [dbo].[sp_create_queue]    Script Date: 30.05.2020 1:49:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_create_queue]
	@name   nvarchar(128),
	@fifo   bit = 0x01,
	@strict bit = 0x01
AS
BEGIN
	SET NOCOUNT ON;

	IF (@name IS NULL OR @name = '') THROW 50001, N'Bad queue name format.', 1;

	DECLARE @test_name bit = CASE WHEN (@name NOT LIKE '%[^a-zа-я0-9_]%') THEN 0x01 ELSE 0x00 END;
	
	IF (@test_name = 0x00) THROW 50001, N'Bad queue name format.', 1;

	SET XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		INSERT [dbo].[queues] ([name]) SELECT @name;

		EXEC(N'CREATE TABLE [dbo].[' + @name + N']
		(
			consume_order bigint NOT NULL IDENTITY(0,1),
			payload varbinary(max) NOT NULL
		);
		CREATE UNIQUE CLUSTERED INDEX [cux_' + @name + N'] ON [' + @name + N'] (consume_order);');

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH

	RETURN 0;
END;
GO