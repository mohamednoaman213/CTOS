


// CtosDbContext represnt that database in C#
// Every Dbset represents a new table to be created

using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;
using System.Reflection;

namespace CTOS.Web.Database.AppDbContext {
    public class CtosDbContext : DbContext {

        #region Ignore
        public CtosDbContext(DbContextOptions<CtosDbContext> options) : base(options) {

        }

        protected override void OnModelCreating(ModelBuilder modelBuilder) {
            modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

            base.OnModelCreating(modelBuilder);
        }
        #endregion


        // Create Table (DbSet) for each Entity
        public DbSet<Event> Events { get; set; }

        public DbSet<User> Users { get; set; }
        //public DbSet<Location> Locations { get; set; }
    }
}
