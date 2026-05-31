


// Controllers are functions that call the functions implemented in service (EventService)
// They are the links created to execute the functions

using CTOS.Web.Entities;
using CTOS.Web.Services;
using Microsoft.AspNetCore.Mvc;

namespace CTOS.Web.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventController(EventService eventService, Cloudinaryservice cloudinaryService) : ControllerBase
    {
        // ── GET api/event/get-all ────────────────────
        [HttpGet("Get-All")]
        public async Task<IActionResult> GetAllEvents()
        {
            var result = await eventService.GetAllEventsAsync();
            return Ok(result);
        }

        // ── GET api/event/{id} ───────────────────────
        [HttpGet("Event/{id}")]
        public async Task<IActionResult> GetEventById(int id)
        {
            var result = await eventService.GetEventByIdAsync(id);
            if (result is null) return NotFound($"Event with Id:{id} not found.");
            return Ok(result);
        }

        // ── POST api/event/create ────────────────────
        // Citizen sends: image + event data as multipart/form-data
        [HttpPost("Create")]
        [Consumes("multipart/form-data")]
        
        public async Task<IActionResult> CreateEvent(
            [FromForm] string eventName,
            [FromForm] string description,
            [FromForm] string location,
            [FromForm] string category,
            [FromForm] int userId,
            [FromForm] IFormFile image)
        {
            // 1. Upload image to Cloudinary
            var imageUrl = await cloudinaryService.UploadImageAsync(image, "ctos-events");
            if (imageUrl is null)
                return BadRequest("Image upload failed.");

            // 2. Build the Event object
            var newEvent = new Event
            {
                EventId = Guid.NewGuid().ToString(),
                EventName = eventName,
                Description = description,
                Location = location,
                Category = category,
                UserId = userId,
                ImageUrl = imageUrl,
                Status = "UnderProcessing",
                Priority = "Pending",  // AI will update this later
                CreatedAt = DateTime.UtcNow
            };

            // 3. Save to DB
            var id = await eventService.CreateEventAsync(newEvent);
            return Ok(new { Id = id, ImageUrl = imageUrl });
        }

        // ── PUT api/event/{id} ───────────────────────
        [HttpPut("Event/{id}")]
        public async Task<IActionResult> UpdateEvent(int id, Event @event)
        {
            var result = await eventService.UpdateEventAsync(id, @event);
            if (result == 0) return NotFound($"Event with Id:{id} not found.");
            return Ok(new { UpdatedId = result });
        }

        // ── DELETE api/event/{id} ────────────────────
        [HttpDelete("Event/{id}")]
        public async Task<IActionResult> DeleteEvent(int id)
        {
            var result = await eventService.DeletedEventAsync(id);
            if (!result) return NotFound($"Event with Id:{id} not found.");
            return Ok("Event deleted.");
        }
    }
}