
// : IEntityTypeConfiguration<Location>

// Configurations -> set the attribute types and relationships for each table to be created
// After each new change (related to database) ---> Add Migrations!
// Use "Package Manager Console" to add migrations then update database
// {Add-Migration "MigrationName"} command then {Update-Database} command

using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CTOS.Web.Database.EntityConfiguration {
    public class EventConfiguration : IEntityTypeConfiguration<Event> {
        public void Configure(EntityTypeBuilder<Event> builder) {

            //  Primary Key
            builder.HasKey(x => x.Id);

            builder.Property(x => x.Id)
                .ValueGeneratedOnAdd();

            // Public EventId
            builder.Property(x => x.EventId)
                .IsRequired()
                .HasMaxLength(64);

            // Event Name
            builder.Property(x => x.EventName)
                .IsRequired()
                .HasMaxLength(256);

            // Description
            builder.Property(x => x.Description)
                .IsRequired()
                .HasMaxLength(1000);

            // Location
            builder.Property(x => x.Location)
                .IsRequired()
                .HasMaxLength(512);

            // Category (Police / Fire / etc.)
            builder.Property(x => x.Category)
                .IsRequired()
                .HasMaxLength(100);

            // Priority (High / Mid / Low)
            builder.Property(x => x.Priority)
                .IsRequired()
                .HasMaxLength(50);

            // Status (UnderProcessing / Resolved / NotResolved)
            builder.Property(x => x.Status)
                .IsRequired()
                .HasMaxLength(50)
                .HasDefaultValue("UnderProcessing");

            // CreatedAt
            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            #region Relationship with User
            //builder.HasOne(x => x.User)
            //    .WithMany() 
            //    .HasForeignKey(x => x.UserId)
            //    .OnDelete(DeleteBehavior.Cascade);
            #endregion

            #region Relationships if present
            // Ex:

            /* 
            builder.HasOne(p => p.Company)
                .WithMany(c => c.Products)
                .HasForeignKey(p => p.CompanyId)
                .OnDelete(DeleteBehavior.Cascade);
            */
            #endregion
        }


    }
}
