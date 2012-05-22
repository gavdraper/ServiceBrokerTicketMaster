CREATE PROCEDURE [dbo].[BrokerPaymentMessageProcessed]
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
			ProcessPaymentInitiatorQueue
			), TIMEOUT 1000
		IF(@@ROWCOUNT=0)
			BEGIN
				ROLLBACK TRANSACTION 
				RETURN
			END
		SELECT @MessageType
		IF @MessageType = 'ProcessPaymentResponse'
			BEGIN
			--Parse the Message and update tables based on contents
			DECLARE @PaymentStatus INT = @MessageBody.value('/Payment[1]/PaymentStatus[1]','INT')
			DECLARE @BookingId INT = @MessageBody.value('/Payment[1]/BookingId[1]','INT')
			UPDATE Bookings SET Bookings.PaymentStatus = @PaymentStatus WHERE Id = @BookingId
			--Close the conversation on the Payment Service
			END CONVERSATION @ConversationHandle				
			--Start a new conversation on the print service
			BEGIN DIALOG CONVERSATION @ConversationHandle
				FROM SERVICE [PrintInitiatorService]
				TO SERVICE 'PrintTargetService'
				ON CONTRACT [PrintContract]
				WITH ENCRYPTION = OFF
			DECLARE @Msg NVARCHAR(MAX) = '<BookingId>' +  CAST(@BookingId AS NVARCHAR(10)) +  '</BookingId>';
			SELECT @ConversationHandle;
			SEND ON CONVERSATION @ConversationHandle MESSAGE TYPE [PrintRequest](@Msg)						
			END
		COMMIT
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
