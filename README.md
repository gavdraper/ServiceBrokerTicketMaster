#Using Service Broker With ASP.Net MVC

This is a demo/sample project to show the use of SQL Service broker from within an ASP.Net MVC site.

It's a ticketing site that when a booking is made sends asynchronus messages to Service Broker services to process the payment and print the tickets. 
This sample shows how you could run the payment processor and the ticket printer applications on different machines away from your SQL Server and have them receive/process messages. It also gives an example of multithreading the queue receivers.

##Installation
* Once you have opened the solution in Visual Studio publish the TicketMasterDb database project to your SQL server to create the database.
* In the BrokerTicketingExample project change the connection string in Web.Config to point to the database you published.
* Do the same for the app.config files in the PrintProcessor/PaymentProcessor console apps.
* You can then run the BrokerTicketingExample MVC app and create bookings. 
* It's best if you are running the PaymentProcessor/PrintProcessor at the same time as the MVC app as then you can watch the messages go through.
