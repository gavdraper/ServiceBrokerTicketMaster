CREATE PROCEDURE [dbo].[BrokerPrintMessageProcessed]
AS
DECLARE @ConversationHandle UNIQUEIDENTIFIER
DECLARE @MessageType NVARCHAR(256)
DECLARE @MessageBody XML
DECLARE @ResponseMessage XML

WHILE(1=1)
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		WAITFOR(RECEIVE TOP(1)
			@ConversationHandle = conversation_handle,
			@MessageType = message_type_name,
			@MessageBody = CAST(message_body AS XML)
		FROM
			PrintInitiatorQueue
			), TIMEOUT 1000
		IF(@@ROWCOUNT=0)
			BEGIN
				ROLLBACK TRANSACTION 
				RETURN
			END
		SELECT @MessageType
		IF @MessageType = 'PrintResponse'
			BEGIN
			--Parse the Message and update tables based on contents
			DECLARE @PrintStatus INT = @MessageBody.value('/Print[1]/PrintStatus[1]','INT')
			DECLARE @BookingId INT = @MessageBody.value('/Print[1]/BookingId[1]','INT')
			UPDATE Bookings SET Bookings.PrintStatus = @PrintStatus WHERE Id = @BookingId
			--Close the conversation on the Payment Service
			END CONVERSATION @ConversationHandle												
			END
		COMMIT
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
