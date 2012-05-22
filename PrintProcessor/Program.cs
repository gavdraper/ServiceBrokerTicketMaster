using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;

namespace PrintProcessor
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
            Console.WriteLine(":: PRINT PROCESSOR ::");
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
            var broker = new Broker();
            while (!stopping)
            {
                string message;
                string messageType;
                Guid dialogHandle;
                Guid serviceInstance;
                broker.tran = broker.cnn.BeginTransaction();
                broker.Receive("PrintTargetQueue", out messageType, out message, out serviceInstance, out dialogHandle);
                if (message != null)
                {
                    switch (messageType)
                    {
                        case "PrintRequest":
                            {
                                var xml = new XmlDocument();
                                xml.LoadXml(message);
                                int BookingId = int.Parse(xml.DocumentElement.InnerText);                               
                                Console.Write(string.Format("Printing Tickets For Order : {0}... ", BookingId));
                                Thread.Sleep(3000); /******CODE TO PRINT WOULD GO HERE*****/
                                Console.Write("Printed\n");
                                broker.Send(dialogHandle, "<Print><BookingId>" + BookingId + "</BookingId><PrintStatus>2</PrintStatus></Print>", "PrintResponse");
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
