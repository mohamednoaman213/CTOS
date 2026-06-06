using CTOS.Web.Services;
using Microsoft.AspNetCore.Mvc;

namespace CTOS.Web.Controllers
{ 
     [ApiController]
    [Route("api/[controller]")]

    public class NotificationController(NotificationService notificationService) : ControllerBase
{
        // GET api/notification/user/{userId}
        [HttpGet("User/{userId}")]
        public async Task<IActionResult> GetUserNotifications(int userId)
        {
            var notifications = await notificationService.GetUserNotificationsAsync(userId);
            return Ok(notifications.Select(n => new
            {
                n.Id,
                n.Title,
                n.Body,
                n.IsRead,
                n.EventId,
                n.CreatedAt
            }));
        }

        // PUT api/notification/{id}/read
        [HttpPut("{id}/Read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var result = await notificationService.MarkAsReadAsync(id);
            if (!result) return NotFound($"Notification with Id:{id} not found.");
            return Ok("Marked as read.");
        }






    }
}
