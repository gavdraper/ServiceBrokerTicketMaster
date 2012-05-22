BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @ConversationHandle UNIQUEIDENTIFIER
	DECLARE @Message NVARCHAR(MAX)

	BEGIN DIALOG CONVERSATION @ConversationHandle
		FROM SERVICE [ProcessPaymentInitiatorService]
		TO SERVICE 'ProcessPaymentTargetService'
		ON CONTRACT [ProcessPaymentContract] 
		
		SET @Message = '<Payment><CreditCard>4565 9458 4855</CreditCard></payment>'

		;SEND ON CONVERSATION @ConversationHandle MESSAGE TYPE [ProcessPaymentRequest](@Message);
		PRINT 'Sent'
		COMMIT
END TRY
BEGIN CATCH
	PRINT 'RolllBack'
	ROLLBACK
END CATCH



SELECT * FROM ProcessPaymentTargetQueue
SELECT * FROM ProcessPAymentInitiatorQueue