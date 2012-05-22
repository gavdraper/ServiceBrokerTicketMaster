CREATE TABLE [dbo].[Bookings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EventId] [int] NOT NULL,
	[CreditCard] [varchar](20) NOT NULL,
	[BillAmount] [decimal](19, 4) NOT NULL,
	[Quantity] [int] NOT NULL,
	[Cancelled] [bit] NOT NULL DEFAULT 0,
	[PaymentStatus] [int] NOT NULL DEFAULT 1,
	[PrintStatus] [int] NOT NULL DEFAULT 1,
	PRIMARY KEY CLUSTERED (Id),
	FOREIGN KEY(PaymentStatus) REFERENCES PaymentStatus(Id),
	FOREIGN KEY(PrintStatus) REFERENCES PrintStatus(Id),
	FOREIGN KEY(EventId) REFERENCES Events(Id)
	
) 