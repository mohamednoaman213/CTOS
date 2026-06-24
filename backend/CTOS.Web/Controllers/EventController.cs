


// Controllers are functions that call the functions implemented in service (EventService)
// They are the links created to execute the functions

using CTOS.Web.Entities;
using CTOS.Web.Services;
using Microsoft.AspNetCore.Mvc;

namespace CTOS.Web.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventController(EventService eventService, Cloudinaryservice cloudinaryService, AiService aiService) : ControllerBase
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
        [HttpPost("Create")]
        public async Task<IActionResult> CreateEvent([FromForm] CreateEventRequest request)
        {
            // 1. Run AI analysis to get annotated image + priority
            var aiResult = await aiService.AnalyzeAsync(request.Image);

            // 2. Upload annotated image to Cloudinary (fallback to original if AI failed)
            string? imageUrl;
            if (!string.IsNullOrEmpty(aiResult.AnnotatedImage))
            {
                var annotatedBytes = Convert.FromBase64String(aiResult.AnnotatedImage);
                imageUrl = await cloudinaryService.UploadBytesAsync(annotatedBytes, request.Image.FileName, "ctos-events");
            }
            else
            {
                imageUrl = await cloudinaryService.UploadImageAsync(request.Image, "ctos-events");
            }

            if (imageUrl is null)
                return BadRequest("Image upload failed.");

            // 3. Build the Event object
            var newEvent = new Event
            {
                EventId = Guid.NewGuid().ToString(),
                EventName = request.EventName,
                Description = request.Description,
                Location = request.Location,
                Category = request.Category,
                UserId = request.UserId,
                ImageUrl = imageUrl,
                Status = "UnderProcessing",
                Priority = aiResult.Priority,
                CreatedAt = DateTime.UtcNow
            };

            // 4. Save to DB
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

        // ── PATCH api/event/{id}/status ─────────────
        [HttpPatch("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateStatusDto dto)
        {
            var result = await eventService.UpdateStatusAsync(id, dto.Status);
            if (result == 0) return NotFound($"Event with Id:{id} not found.");
            return Ok(new { UpdatedId = result });
        }

        // ── POST api/event/analyze ───────────────────
        [HttpPost("Analyze")]
        public async Task<IActionResult> AnalyzeImage([FromForm] AnalyzeImageRequest request)
        {
            var result = await aiService.AnalyzeAsync(request.Image);
            return Ok(new
            {
                threatLevel = result.ThreatLevel,
                priority = result.Priority,
                labels = result.Labels,
                recommendedAction = result.RecommendedAction,
                annotatedImage = result.AnnotatedImage
            });
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

    // ── DTOs ─────────────────────────────────────────
    public class UpdateStatusDto
    {
        public string Status { get; set; } = null!;
    }

    public class AnalyzeImageRequest
    {
        public IFormFile Image { get; set; } = null!;
    }

    public class CreateEventRequest
    {
        public string EventName { get; set; } = null!;
        public string Description { get; set; } = null!;
        public string Location { get; set; } = null!;
        public string Category { get; set; } = null!;
        public int UserId { get; set; }
        public IFormFile Image { get; set; } = null!;
    }
}
