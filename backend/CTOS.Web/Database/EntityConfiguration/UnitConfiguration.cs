using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CTOS.Web.Database.EntityConfiguration

{
    public class UnitConfiguration : IEntityTypeConfiguration<Unit>
    {
        public void Configure(EntityTypeBuilder<Unit> builder)
        {
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).ValueGeneratedOnAdd();

            builder.Property(x => x.UnitName)
                   .IsRequired()
                   .HasMaxLength(100);

            builder.Property(x => x.Status)
                   .IsRequired()
                   .HasMaxLength(50)
                   .HasDefaultValue("Available");

            builder.Property(x => x.CreatedAt)
                   .IsRequired()
                   .HasDefaultValueSql("GETUTCDATE()");

            // Dispatcher → Units
            builder.HasOne(x => x.Dispatcher)
                   .WithMany()
                   .HasForeignKey(x => x.DispatcherId)
                   .OnDelete(DeleteBehavior.Restrict);

            // Unit → Officials (one unit, many officials)
            builder.HasMany(x => x.Members)
                   .WithOne(o => o.Unit)
                   .HasForeignKey(o => o.UnitId)
                   .OnDelete(DeleteBehavior.SetNull);
        }
    }
}
