using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CTOS.Web.Database.EntityConfiguration
{
    public class UserConfiguration : IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            builder.HasKey(x => x.Id);

            builder.Property(x => x.Id)
                .ValueGeneratedOnAdd();

            
            builder.Property(x => x.UserId)
                .IsRequired()
                .HasMaxLength(64);

           
            builder.Property(x => x.FullName)
                .IsRequired()
                .HasMaxLength(256);

           
            builder.Property(x => x.Email)
                .IsRequired()
                .HasMaxLength(256);

            builder.HasIndex(x => x.Email)
                .IsUnique();

            
            builder.Property(x => x.PasswordHash)
                .IsRequired()
                .HasMaxLength(512);

           
            builder.Property(x => x.NationalId)
                .IsRequired()
                .HasMaxLength(14)
                .IsUnicode(false);

            builder.HasIndex(x => x.NationalId)
                .IsUnique();

            
            builder.Property(x => x.IsVerified)
                .IsRequired()
                .HasDefaultValue(false);

            
            builder.Property(x => x.IsDeleted)
                .IsRequired()
                .HasDefaultValue(false);

            
            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            //  Relationship with Events
            builder.HasMany(x => x.Events)
                .WithOne(e => e.User)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
