using CTOS.Web.Database.AppDbContext;
using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;

namespace CTOS.Web.Repositroies
{
    public class UserRepo(CtosDbContext context)
    {
        // ── Generic ──────────────────────────────────────
        public async Task<User?> GetByIdAsync(int id)
            => await context.Set<User>().FindAsync(id);

        public async Task<User?> GetByEmailAsync(string email)
            => await context.Set<User>()
                            .FirstOrDefaultAsync(u => u.Email == email);

        public async Task<IEnumerable<User>> GetAllAsync()
            => await context.Set<User>().ToListAsync();

        // ── Citizen ──────────────────────────────────────
        public async Task<IEnumerable<Citizen>> GetAllCitizensAsync()
            => await context.Set<Citizen>().ToListAsync();

        // ── Official ─────────────────────────────────────
        public async Task<IEnumerable<Official>> GetAllOfficialsAsync()
            => await context.Set<Official>().ToListAsync();

        public async Task<Official?> GetOfficialByBadgeAsync(string badgeId)
            => await context.Set<Official>()
                            .FirstOrDefaultAsync(o => o.BadgeId == badgeId);

        // ── CRUD ─────────────────────────────────────────
        public async Task AddAsync(User entity)
            => await context.AddAsync(entity);

        public void UpdateAsync(User entity)
            => context.Update(entity);

        public void DeleteAsync(User entity)
            => context.Remove(entity);

        public async Task SaveChangesAsync()
            => await context.SaveChangesAsync();
    }
}
