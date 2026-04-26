

// Entities folder is the location where the base classes exist (The same structure as database tables)


using CTOS.Web.Entities;

namespace CTOS.Web.Entities {
    public class Event {

        // Primary Key (Database)
        public int Id { get; set; }

        // Public ID (shown to user)
        public string EventId { get; set; } = null!;

        public string EventName { get; set; } = null!;

        public string Description { get; set; } = null!;

        public string Location { get; set; } = null!;

        // Police / Fire / Hospital / Infrastructure
        public string Category { get; set; } = null!;

        // High / Mid / Low (AI decides)
        public string Priority { get; set; } = null!;

        // UnderProcessing / Resolved / NotResolved
        public string Status { get; set; } = "UnderProcessing";

        #region Relation with User
        //public int UserId { get; set; }
        //public User User { get; set; } = null!;
        #endregion
        // Meta
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    }
    #region Navigational properties and relationships

    //public int LocationId { get; set; } // fk
    //public Location location { get; set; } // navigation

    //    public class Location {

    //        public int Id { get; set; }

    //        public string address { get; set; }

    //    }

    #endregion

}


