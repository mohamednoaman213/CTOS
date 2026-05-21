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

        // National ID card images (front & back) — uploaded at registration
        public string? NationalIdFrontImageUrl { get; set; }
        public string? NationalIdBackImageUrl { get; set; }

        public string? ProfileImageUrl { get; set; }

        // "Citizen" or "Official" — managed by EF Core TPH discriminator
        public string UserType { get; set; } = null!;

        public bool IsVerified { get; set; } = false;
        public bool IsDeleted { get; set; } = false;

        public ICollection<Event> Events { get; set; } = new List<Event>();
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
    public class Citizen : User
    {
        // "Operations Manager at Concentrix"
        public string? JobTitle { get; set; }

        // "4 El Manar St, Sidi Beshr Qebly, Alexandria"
        public string? HomeAddress { get; set; }

        // AI Sensitivity level — "HIGH" / "MEDIUM" / "LOW"
        public string? AiSensitivity { get; set; }

        // Analysis level shown in UI — e.g. 4
        public int AiSensitivityLevel { get; set; } = 1;

        // AI Score shown in profile — e.g. 98.2
        public double AiScore { get; set; } = 0;

        // Impact grade shown in profile — e.g. "A+"
        public string? ImpactGrade { get; set; }
    }
    public class Official : User
    {
        // "3021-SN-22X"
        public string BadgeId { get; set; } = null!;

        // "DISPATCHER LVL 4"
        public string Rank { get; set; } = null!;

        // Police / Fire / Hospital / Infrastructure
        public string Department { get; set; } = null!;

        // "4 El Manar St, Sidi Beshr Qebly, Alexandria"
        public string? HomeAddress { get; set; }

        // Map proximity radius in KM — e.g. 2.5
        public double MapProximityKm { get; set; } = 2.5;

        // Rating shown in profile — e.g. 98.2
        public double Rating { get; set; } = 0;

        // Impact grade shown in profile — e.g. "B-"
        public string? ImpactGrade { get; set; }
    }




}
