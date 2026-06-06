


// Repositroy reprents the layer between database and service
// The basic operations made on the database like Getting, updating, deleting, saving on the database after changes


using CTOS.Web.Database.AppDbContext;
using CTOS.Web.Entities;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace CTOS.Web.Repositroies {
    public class EventRepo(CtosDbContext context) {

        public async Task<Event?> GetByIdAsync(int id) {

            return await context.Set<Event>().FindAsync(id);
        }
       
        public async Task<IEnumerable<Event>> GetAllAsync() {

            return await context.Set<Event>().ToListAsync();
        }

        public async Task AddAsync(Event entity) {
            await context.AddAsync(entity);
        }

        public void UpdateAsync(Event entity) {
            context.Update(entity);
        }

        public void DeleteAsync(Event entity) {
            context.Remove(entity);
        }

        public async Task SaveChangesAsync() {
            await context.SaveChangesAsync();
        }

    }
}
