using CTOS.Web.Database.AppDbContext;
using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;

namespace CTOS.Web.Repositroies
{
    public class UserRepo(CtosDbContext context)
    {
        public async Task<User?> GetByIdAsync(int id)
        {

            return await context.Set<User>().FindAsync(id);
        }

        public async Task<IEnumerable<User>> GetAllAsync()
        {

            return await context.Set<User>().ToListAsync();
        }

        public async Task AddAsync(User entity)
        {
            await context.AddAsync(entity);
        }

        public void UpdateAsync(User entity)
        {
            context.Update(entity);
        }

        public void DeleteAsync(User entity)
        {
            context.Remove(entity);
        }

        public async Task SaveChangesAsync()
        {
            await context.SaveChangesAsync();


        }
}
}
