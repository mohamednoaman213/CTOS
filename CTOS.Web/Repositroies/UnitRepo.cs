using CTOS.Web.Database.AppDbContext;
using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace CTOS.Web.Repositroies
{
    public class UnitRepo(CtosDbContext context)
    {
        public async Task<Unit?> GetByIdAsync(int id)
           => await context.Set<Unit>()
                           .Include(u => u.Members)
                           .FirstOrDefaultAsync(u => u.Id == id);

        public async Task<IEnumerable<Unit>> GetByDispatcherAsync(int dispatcherId)
            => await context.Set<Unit>()
                            .Include(u => u.Members)
                            .Where(u => u.DispatcherId == dispatcherId)
                            .ToListAsync();

        public async Task<IEnumerable<Unit>> GetAllAsync()
            => await context.Set<Unit>()
                            .Include(u => u.Members)
                            .ToListAsync();

        public async Task AddAsync(Unit unit)
            => await context.AddAsync(unit);

        public void Update(Unit unit)
            => context.Update(unit);

        public void Delete(Unit unit)
            => context.Remove(unit);

        public async Task SaveChangesAsync()
            => await context.SaveChangesAsync();


        public async Task<IEnumerable<Unit>> GetAvailableUnitsAsync()
    => await context.Set<Unit>()
                    .Include(u => u.Members)
                    .Where(u => u.Status == "Available")
                    .ToListAsync();
    }
}
