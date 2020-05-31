USE [one-c-sharp-queuing]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[queues]
(
	[name] nvarchar(128) NOT NULL,
	[type] char(4)       NOT NULL, -- 'FIFO', 'LIFO', 'HEAP', 'TIME', 'FILE'
	[mode] char(1)       NOT NULL, -- 'S', 'M' concurrency access mode (single or multiple consumers)
);
GO
CREATE UNIQUE CLUSTERED INDEX [cux_queues_name] ON [dbo].[queues] ([name] ASC);
GO