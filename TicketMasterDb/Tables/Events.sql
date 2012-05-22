CREATE TABLE [dbo].[Events](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Date] [datetime] NOT NULL,
	[TotalTicketCount] [int] NOT NULL,
	[Price] [decimal](19, 4) NOT NULL,
	PRIMARY KEY CLUSTERED (Id)
) ON [PRIMARY]