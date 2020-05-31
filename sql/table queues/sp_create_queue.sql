USE [one-c-sharp-queuing]
GO
/****** Object:  StoredProcedure [dbo].[sp_create_queue]    Script Date: 01.06.2020 0:29:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_create_queue]
	@name nvarchar(128),
	@type char(4) = 'FIFO', -- queue type
	@mode char(1) = 'S' -- concurrency access mode (single or multiple consumers)
AS
BEGIN
	SET NOCOUNT ON;

	IF ([dbo].[fn_is_name_valid](@name) = 0x00) THROW 50001, N'Bad queue name format.', 1;

	IF (NOT @type IN ('FIFO', 'LIFO', 'HEAP', 'TIME', 'FILE')) THROW 50002, N'Invalid queue type.', 1;

	IF (NOT @mode IN ('S', 'M')) THROW 50003, N'Invalid concurrency access mode.', 1;

	SET XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		INSERT [dbo].[queues] ([name], [type], [mode]) SELECT @name, @type, @mode;

		IF (@type IN ('FIFO', 'LIFO'))
		BEGIN
			EXEC(N'CREATE TABLE [dbo].[' + @name + N']
			(
				[consume_order] bigint         NOT NULL IDENTITY(0,1),
				[message_type]  nvarchar(128)  NOT NULL,
				[message_body]  varbinary(max) NOT NULL
			);
			CREATE UNIQUE CLUSTERED INDEX [cux_' + @name + N'] ON [dbo].[' + @name + N'] (consume_order ASC);');
		END;
		ELSE IF (@type = 'HEAP')
		BEGIN
			EXEC(N'CREATE TABLE [dbo].[' + @name + N']
			(
				[message_type] nvarchar(128)  NOT NULL,
				[message_body] varbinary(max) NOT NULL
			);');
		END;
		ELSE IF (@type = 'TIME')
		BEGIN
			EXEC(N'CREATE TABLE [dbo].[' + @name + N']
			(
				[consume_time] datetime       NOT NULL,
				[message_type] nvarchar(128)  NOT NULL,
				[message_body] varbinary(max) NOT NULL
			);
			CREATE CLUSTERED INDEX [cux_' + @name + N'] ON [dbo].[' + @name + N'] (consume_time ASC);');
		END;
		ELSE IF (@type = 'FILE')
		BEGIN
			EXEC(N'CREATE TABLE [dbo].[' + @name + N']
			(
				[file_name] nvarchar(256)  NOT NULL,
				[file_type] nvarchar(128)  NOT NULL,
				[file_body] varbinary(max) NOT NULL
			);
			CREATE UNIQUE CLUSTERED INDEX [cux_' + @name + N'] ON [dbo].[' + @name + N'] (file_name ASC);');
		END;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH

	RETURN 0;
END;
