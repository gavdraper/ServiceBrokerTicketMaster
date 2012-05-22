CREATE PROCEDURE [dbo].[CreateBooking]
(
 @EventId INT,
 @Quantity INT,
 @CreditCard VARCHAR(20)
)
AS

BEGIN TRANSACTION
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
DECLARE @TicketsTaken INT
SELECT @TicketsTaken = ISNULL(SUM(Quantity),0) FROM Bookings WHERE EventId = @EventId AND Cancelled = 0 
DECLARE @TicketsRemaining INT
SELECT @TicketsRemaining = TotalTicketCount - @TicketsTaken
FROM Events WHERE Id = @EventId

BEGIN TRY
	IF @TicketsRemaining >= @Quantity
		BEGIN
		DECLARE @BillAmount DECIMAL(19,4)
		SELECT @BillAmount = Price FROM Events WHERE Id = @EventId
		SELECT @BillAmount = @BillAmount * @Quantity

		INSERT INTO Bookings(EventId,Quantity,CreditCard, BillAmount)
		VALUES(@EventId,@Quantity,@CreditCard, @BillAmount)

		DECLARE @BookingId INT = SCOPE_IDENTITY()

		--Send messagge for payment process
		DECLARE @ConversationHandle UNIQUEIDENTIFIER
			BEGIN DIALOG CONVERSATION @ConversationHandle
				FROM SERVICE [ProcessPaymentInitiatorService]
				TO SERVICE 'ProcessPaymentTargetService'
				ON CONTRACT [ProcessPaymentContract]
				WITH ENCRYPTION = OFF
			DECLARE @Msg NVARCHAR(MAX) = '<Payment><BookingId>' + CAST(@BookingId AS NVARCHAR(10)) + '</BookingId><BillAmount>' + CAST(@BillAmount AS NVARCHAR(15)) + '</BillAmount><CreditCard>' + @CreditCard + '</CreditCard></Payment>';
			SEND ON CONVERSATION @ConversationHandle MESSAGE TYPE [ProcessPaymentRequest](@Msg)
		END
	ELSE
		BEGIN
		RAISERROR('Booking Failed : Not enough remaining tickets!',1,1)
		ROLLBACK
		RETURN
		END
	COMMIT
END TRY
BEGIN CATCH
	RAISERROR('Booking Failed',1,1)
	ROLLBACK
	RETURN
END CATCH
