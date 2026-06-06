namespace CTOS.Web.Entities
{
    public class Notification
    {
        public int Id { get; set; }

        public string Title { get; set; } = null!;

        public string Body { get; set; } = null!;

        // Linked to which event
        public int? EventId { get; set; }
        public Event? Event { get; set; }

        // Who received it
        public int UserId { get; set; }
        public User User { get; set; } = null!;

        // Is it read?
        public bool IsRead { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
