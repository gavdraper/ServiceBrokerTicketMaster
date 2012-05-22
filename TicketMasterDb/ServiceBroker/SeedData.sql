/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
ALTER DATABASE  [$(DatabaseName)] SET ENABLE_BROKER
GO

INSERT INTO PaymentStatus(Status)
SELECT 'Pending' 
UNION ALL
SELECT 'Complete'
UNION ALL 
SELECT 'Failed'

INSERT INTO PrintStatus(Status)
SELECT 'Pending'
UNION ALL 
SELECT 'Printed'

INSERT INTO Events(Name,Price,TotalTicketCount,Date)
SELECT 'T4 on the beach',80,4000,'20120615'
UNION ALL
SELECT 'Swedish House Mafia',60,1000,'20120615'
UNION ALL
SELECT 'V Festival',120,10000,'20120615'
UNION ALL
SELECT 'Ultravox',40,400,'20120615'
UNION ALL
SELECT 'The Guns N Roses Experience',30,500,'20120615'
UNION ALL
SELECT 'Brit Floyd',30,250,'20120615'
UNION ALL
SELECT 'Ultimate 80s',50,1000,'20120615'
UNION ALL
SELECT 'The Pigeon Detecties',70,720,'20120615'
UNION ALL
SELECT 'The Zombies',25.99,120,'20120615'