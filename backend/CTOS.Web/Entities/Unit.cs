namespace CTOS.Web.Entities
{
    public class Unit
    {
        public int Id { get; set; }

        // "UNIT 14" / "UNIT 23"
        public string UnitName { get; set; } = null!;

        // Available / Occupied
        public string Status { get; set; } = "Available";

        // The Dispatcher who owns this unit
        public int DispatcherId { get; set; }
        public Official Dispatcher { get; set; } = null!;

        // Members — each Official belongs to one Unit
        public ICollection<Official> Members { get; set; } = new List<Official>();

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
