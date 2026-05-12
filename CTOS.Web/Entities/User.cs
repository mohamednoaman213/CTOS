namespace CTOS.Web.Entities
{
    public class User
    {
        public int Id { get; set; }

        public string UserId { get; set; } = null!;

        public string FullName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string PasswordHash { get; set; } = null!;

        public string NationalId { get; set; } = null!;

        public bool IsVerified { get; set; } = false;

        public bool IsDeleted { get; set; } = false;

        public ICollection<Event> Events { get; set; } = new List<Event>();

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
