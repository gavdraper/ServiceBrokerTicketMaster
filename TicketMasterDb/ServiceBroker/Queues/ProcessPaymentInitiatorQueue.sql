CREATE QUEUE ProcessPaymentInitiatorQueue WITH ACTIVATION
(
	STATUS = ON,
	PROCEDURE_NAME = [BrokerPaymentMessageProcessed],
	MAX_QUEUE_READERS = 4,
	EXECUTE AS SELF
)