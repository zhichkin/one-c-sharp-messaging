SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_queue_exists]
(
	@name nvarchar(128)
)
RETURNS bit
AS
BEGIN
	IF ([dbo].[fn_is_name_valid](@name) = 0x00) RETURN 0x00; -- false

	IF (OBJECT_ID(N'dbo.' + @name, 'U') IS NULL) RETURN 0x00; -- false

	IF NOT EXISTS(SELECT 1 FROM [dbo].[queues] WHERE [name] = @name) RETURN 0x00; -- false

	RETURN 0x01; -- true
END
GO

-- EXEC [dbo].[sp_create_queue] N'test_queue';
-- EXEC [dbo].[sp_delete_queue] N'test_queue';
-- SELECT [dbo].[fn_queue_exists]('test_queue');