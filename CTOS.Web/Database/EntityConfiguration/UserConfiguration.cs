using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CTOS.Web.Database.EntityConfiguration
{
    public class UserConfiguration : IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            // ── Primary Key ──────────────────────────────
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).ValueGeneratedOnAdd();

            // ── TPH Discriminator ────────────────────────
            builder.HasDiscriminator<string>("UserType")
                   .HasValue<Citizen>("Citizen")
                   .HasValue<Official>("Official");

            builder.Property(x => x.UserType)
                   .IsRequired()
                   .HasMaxLength(50);

            // ── Shared Fields ────────────────────────────
            builder.Property(x => x.UserId)
                   .IsRequired()
                   .HasMaxLength(64);
            builder.HasIndex(x => x.UserId).IsUnique();

            builder.Property(x => x.FullName)
                   .IsRequired()
                   .HasMaxLength(256);

            builder.Property(x => x.Email)
                   .IsRequired()
                   .HasMaxLength(256);
            builder.HasIndex(x => x.Email).IsUnique();

            builder.Property(x => x.PasswordHash)
                   .IsRequired()
                   .HasMaxLength(512);

            builder.Property(x => x.NationalId)
                   .IsRequired()
                   .HasMaxLength(14)
                   .IsUnicode(false);
            builder.HasIndex(x => x.NationalId).IsUnique();

            builder.Property(x => x.NationalIdFrontImageUrl).HasMaxLength(1024);
            builder.Property(x => x.NationalIdBackImageUrl).HasMaxLength(1024);
            builder.Property(x => x.ProfileImageUrl).HasMaxLength(1024);

            builder.Property(x => x.IsVerified).HasDefaultValue(false);
            builder.Property(x => x.IsDeleted).HasDefaultValue(false);

            builder.Property(x => x.CreatedAt)
                   .IsRequired()
                   .HasDefaultValueSql("GETUTCDATE()");

            //notification token for push notifications
            builder.Property(x => x.DeviceToken).HasMaxLength(512);
            // ── Relationship with Events ─────────────────
            builder.HasMany(x => x.Events)
                   .WithOne(e => e.User)
                   .HasForeignKey(e => e.UserId)
                   .OnDelete(DeleteBehavior.Restrict);

            // ── Citizen Fields ───────────────────────────
            builder.Property<string?>("JobTitle").HasMaxLength(256);
            builder.Property<string?>("HomeAddress").HasMaxLength(512);
            builder.Property<string?>("AiSensitivity").HasMaxLength(50);
            builder.Property<int>("AiSensitivityLevel").HasDefaultValue(1);
            builder.Property<double>("AiScore").HasDefaultValue(0.0);
            builder.Property<string?>("ImpactGrade").HasMaxLength(10);

            // ── Official Fields ──────────────────────────
            builder.Property<string?>("BadgeId").HasMaxLength(64);
            builder.Property<string?>("Rank").HasMaxLength(128);
            builder.Property<string?>("Department").HasMaxLength(100);
            builder.Property<string?>("OfficialHomeAddress").HasMaxLength(512);
            builder.Property<double>("MapProximityKm").HasDefaultValue(2.5);
            builder.Property<double>("Rating").HasDefaultValue(0.0);
            builder.Property<string?>("OfficialImpactGrade").HasMaxLength(10);
        }
    }
}
