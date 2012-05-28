using System;
using System.Collections.Generic;
using System.Threading;
using System.Xml;
using System.Configuration;
using BrokerLib;

namespace PaymentProcessor
{
    class Program
    {
        const int max_threads = 1;
        static bool stopping = false;

        static void Main(string[] args)        
        {
            var threads = new List<Thread>();
            for (int i = 0; i < max_threads; i++)
            {
                threads.Add(new Thread(monitorPaymentQueue));
                threads[i].Start();
            }
            Console.WriteLine(":: PAYMENT PROCESSOR ::");
            Console.ReadLine();
            Console.WriteLine("Stopping Threads.....");
            stopping = true;
            foreach (var t in threads)
            {
                t.Join();
            }
        }

        static void monitorPaymentQueue()
        {
            var broker = new Broker(ConfigurationManager.AppSettings["connectionString"]);
            while (!stopping)
            {
                string message;
                string messageType;
                Guid dialogHandle;
                Guid serviceInstance;
                broker.tran = broker.cnn.BeginTransaction();
                broker.Receive("ProcessPaymentTargetQueue", out messageType, out message, out serviceInstance, out dialogHandle);
                if (message != null)
                {
                    switch (messageType)
                    {
                        case "ProcessPaymentRequest":
                            {
                                var xml = new XmlDocument();
                                xml.LoadXml(message);
                                int BookingId = int.Parse(xml.DocumentElement["BookingId"].InnerText);
                                string CreditCard = xml.DocumentElement["CreditCard"].InnerText;
                                decimal BillAmount = decimal.Parse(xml.DocumentElement["BillAmount"].InnerText);
                                Console.Write(string.Format("Processing Order : {0} For £{1} Card : {2}... ",BookingId,BillAmount,CreditCard));
                                Thread.Sleep(3000); /******CODE TO PROCESS PAYMENT WOULD GO HERE*****/
                                Console.Write("Processed\n");                                
                                broker.Send(dialogHandle, "<Payment><BookingId>" + BookingId +"</BookingId><PaymentStatus>2</PaymentStatus></Payment>","ProcessPaymentResponse");
                                broker.EndDialog(dialogHandle);
                                break;
                            }                      
                    }
                }
                broker.tran.Commit();
            }
        }

    }
}
