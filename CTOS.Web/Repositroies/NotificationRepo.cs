using CTOS.Web.Database.AppDbContext;
using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;


namespace CTOS.Web.Repositroies
{
    public class NotificationRepo(CtosDbContext context)
    {
        public async Task<IEnumerable<Notification>> GetByUserIdAsync(int userId)
            => await context.Set<Notification>()
                            .Where(n => n.UserId == userId)
                            .OrderByDescending(n => n.CreatedAt)
                            .ToListAsync();

        public async Task<Notification?> GetByIdAsync(int id)
            => await context.Set<Notification>().FindAsync(id);

        public async Task AddAsync(Notification notification)
            => await context.AddAsync(notification);

        public void Update(Notification notification)
            => context.Update(notification);

        public async Task SaveChangesAsync()
            => await context.SaveChangesAsync();
    }
}
