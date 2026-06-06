
using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;




namespace CTOS.Web.Database.EntityConfiguration
{
    public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
    {
        public void Configure(EntityTypeBuilder<Notification> builder)
        {
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).ValueGeneratedOnAdd();

            builder.Property(x => x.Title)
                   .IsRequired()
                   .HasMaxLength(256);

            builder.Property(x => x.Body)
                   .IsRequired()
                   .HasMaxLength(1024);

            builder.Property(x => x.IsRead)
                   .HasDefaultValue(false);

            builder.Property(x => x.CreatedAt)
                   .IsRequired()
                   .HasDefaultValueSql("GETUTCDATE()");

            // Relationship with User
            builder.HasOne(x => x.User)
                   .WithMany()
                   .HasForeignKey(x => x.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            // Relationship with Event (optional)
            builder.HasOne(x => x.Event)
                   .WithMany()
                   .HasForeignKey(x => x.EventId)
                   .OnDelete(DeleteBehavior.NoAction);
        }
    }
}
