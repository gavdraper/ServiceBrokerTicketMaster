CREATE PROCEDURE [dbo].[GetEvents]
AS
SELECT
	Events.Id, 
	Events.Name,
	Events.Date,
	Events.TotalTicketCount,
	TotalTicketCount-ISNULL(SUM(Bookings.Quantity),0) AS Remaining,
	Events.Price
FROM
	Events
	LEFT JOIN Bookings ON Bookings.EventId = Events.Id
GROUP BY
	Events.Id,Events.Name,Events.Date, Events.TotalTicketCount, Events.Price
