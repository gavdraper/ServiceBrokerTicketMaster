#Using Service Broker With ASP.Net MVC

This is a demo/sample project to show the use of SQL Service broker from within an ASP.Net MVC site.

It's a ticketing site that when a booking is made sends asynchronus messages to Service Broker services to process the payment and print the tickets. 
This sample shows how you could run the payment processor and the ticket printer applications on different machines away from your SQL Server and have them receive/process messages. It also gives an example of multithreading the queue receivers.
