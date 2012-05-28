using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using BrokerTicketingExample.Models;

namespace BrokerTicketingExample.Controllers
{
    public class EventsController : Controller
    {
        //
        // GET: /Events/

        public ActionResult Index()
        {
            var ctx = new TicketMasterEntities();

            var events = ctx.GetEvents();

            return View(events);
        }

        public ActionResult Booking(int Id)
        {
            Booking booking = new Booking() { EventId = Id };
            return View(booking);
        }

        [HttpPost]
        public ActionResult Booking(Booking booking)
        {
            var ctx = new TicketMasterEntities();
            try
            {
                if (ctx.CreateBooking(booking.EventId, booking.Quantity, booking.CreditCard) < 1)
                {
                    ViewBag.Error = "Unable to save booking, no may be no tickets left";
                    return View();
                }
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                ViewBag["Error"] = ex.Message;
                return View(booking);
            }
            
        }

  

    } 
}
