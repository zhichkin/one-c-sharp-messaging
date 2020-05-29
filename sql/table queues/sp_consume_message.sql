SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_consume_message]
	@queue_name nvarchar(128),
	@number_of_messages int = 1
AS
BEGIN
	SET NOCOUNT ON;

    WITH [cte] AS
    (
        SELECT TOP (@number_of_messages)
            [message_body]
        FROM
            [queue_name] WITH (rowlock) -- +readpast if order is not strict
        ORDER BY
            [consume_order] ASC
    )
    DELETE [cte] OUTPUT deleted.[message_body];
END;
GO
