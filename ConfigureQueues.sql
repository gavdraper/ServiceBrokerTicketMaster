/* Remove SSB Objects**************************
DROP SERVICE PrintInitiatorService
DROP SERVICE PrintTargetService
DROP SERVICE ProcessPaymentInitiatorService 
DROP SERVICE ProcessPaymentTargetService
DROP QUEUE ProcessPaymentInitiatorQueue 
DROP QUEUE PrintInitiatorQueue 
DROP QUEUE ProcessPaymentTargetQueue 
DROP QUEUE PrintTargetQueue
DROP CONTRACT PrintContract
DROP CONTRACT ProcessPaymentContract
DROP MESSAGE TYPE ProcessPaymentRequest
DROP MESSAGE TYPE ProcessPaymentResponse 
DROP MESSAGE TYPE PrintRequest
DROP MESSAGE TYPE PrintResponse
*********************************************/

CREATE MESSAGE TYPE [ProcessPaymentRequest]  VALIDATION = WELL_FORMED_XML
CREATE MESSAGE TYPE [ProcessPaymentResponse] VALIDATION = WELL_FORMED_XML
CREATE MESSAGE TYPE [PrintRequest] VALIDATION = WELL_FORMED_XML
CREATE MESSAGE TYPE [PrintResponse] VALIDATION = WELL_FORMED_XML

CREATE CONTRACT [ProcessPaymentContract]
(
	[ProcessPaymentResponse] SENT BY TARGET,
	[ProcessPaymentRequest] SENT BY INITIATOR
)

CREATE CONTRACT [PrintContract]
(
	[PrintRequest] SENT BY INITIATOR,
	[PrintResponse] SENT BY TARGET
)

CREATE QUEUE ProcessPaymentInitiatorQueue WITH STATUS = ON
CREATE QUEUE PrintInitiatorQueue WITH STATUS = ON
CREATE QUEUE ProcessPaymentTargetQueue WITH STATUS = ON
CREATE QUEUE PrintTargetQueue WITH STATUS = ON

CREATE SERVICE PrintInitiatorService ON QUEUE PrintInitiatorQueue(PrintContract) 
GO
CREATE SERVICE PrintTargetService ON QUEUE PrintTargetQueue(PrintContract) 
GO
CREATE SERVICE ProcessPaymentInitiatorService ON QUEUE ProcessPaymentInitiatorQueue(ProcessPaymentContract)
GO
CREATE SERVICE ProcessPaymentTargetService ON QUEUE ProcessPaymentTargetQueue(ProcessPaymentContract)
GO

ALTER QUEUE ProcessPaymentInitiatorQueue WITH ACTIVATION
(
	STATUS = ON,
	PROCEDURE_NAME = [BrokerPaymentMessageProcessed],
	MAX_QUEUE_READERS = 4,
	EXECUTE AS SELF
)

ALTER QUEUE PrintInitiatorQueue WITH ACTIVATION
(
	STATUS = ON,
	PROCEDURE_NAME = [BrokerPrintMessageProcessed],
	MAX_QUEUE_READERS = 4,
	EXECUTE AS SELF
)



/*Debuging
SELECT * FROM sys.transmission_queue
SELECT * FROM sys.conversation_endpoints
SELECT * FROM ProcessPaymentTargetQueue
SELECT * FROM ProcessPaymentInitiatorQueue
SELECT * FROM PrintTargetQueue
SELECT * FROM PrintInitiatorQueue
*/