DECLARE @handle uniqueidentifier;
DECLARE @message nvarchar(max) = N'test message';

SET @handle = CAST('9A5B7E3C-5A9B-EA11-9C67-408D5C93CC8E' AS uniqueidentifier);

SEND ON CONVERSATION @handle MESSAGE TYPE [DEFAULT] (CAST(@message AS varbinary(max)));

