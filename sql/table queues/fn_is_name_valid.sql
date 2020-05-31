USE [one-c-sharp-queuing]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_is_name_valid]    Script Date: 31.05.2020 14:43:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_is_name_valid]
(
	@name nvarchar(128)
)
RETURNS bit
AS
BEGIN
	IF (@name IS NULL OR @name = '') RETURN 0x00; -- false

	DECLARE @has_invalid_characters bit = CASE WHEN (@name NOT LIKE '%[^a-zа-я0-9_]%') THEN 0x00 ELSE 0x01 END;
	
	IF (@has_invalid_characters = 0x01) RETURN 0x00; -- false

	RETURN 0x01; -- true
END

--SELECT [dbo].[fn_is_name_valid] ('asdf_5');