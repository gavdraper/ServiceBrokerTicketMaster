CREATE TABLE [dbo].[PaymentStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Status] [nvarchar](30) NOT NULL,
	PRIMARY KEY CLUSTERED (Id)
)