using CTOS.Web.Entities;
using CTOS.Web.Repositroies;

namespace CTOS.Web.Services
{
    public class UnitService(UnitRepo unitRepo, UserRepo userRepo)
    {
        // ────────────────────────────────────────────
        //  Create Unit
        // ────────────────────────────────────────────
        public async Task<int> CreateUnitAsync(Unit unit)
        {
            unit.Id = 0;
            unit.Status = "Available";
            unit.CreatedAt = DateTime.UtcNow;

            await unitRepo.AddAsync(unit);
            await unitRepo.SaveChangesAsync();
            return unit.Id;
        }

        // ────────────────────────────────────────────
        //  Get Units by Dispatcher
        // ────────────────────────────────────────────
        public async Task<IEnumerable<Unit>> GetUnitsByDispatcherAsync(int dispatcherId)
            => await unitRepo.GetByDispatcherAsync(dispatcherId);

        // ────────────────────────────────────────────
        //  Get Unit by Id
        // ────────────────────────────────────────────
        public async Task<Unit?> GetUnitByIdAsync(int id)
            => await unitRepo.GetByIdAsync(id);

        // ────────────────────────────────────────────
        //  Update Status (Available / Occupied)
        // ────────────────────────────────────────────
        public async Task<bool> UpdateStatusAsync(int unitId, string status)
        {
            var unit = await unitRepo.GetByIdAsync(unitId);
            if (unit is null) return false;

            unit.Status = status;
            unitRepo.Update(unit);
            await unitRepo.SaveChangesAsync();
            return true;
        }

        // ────────────────────────────────────────────
        //  Add Official to Unit
        // ────────────────────────────────────────────
        public async Task<bool> AddMemberAsync(int unitId, int officialId)
        {
            var unit = await unitRepo.GetByIdAsync(unitId);
            if (unit is null) return false;

            var user = await userRepo.GetByIdAsync(officialId);
            if (user is not Official official) return false;

            // Official already in a unit
            if (official.UnitId is not null) return false;

            official.UnitId = unitId;
            userRepo.UpdateAsync(official);
            await userRepo.SaveChangesAsync();
            return true;
        }

        // ────────────────────────────────────────────
        //  Remove Official from Unit
        // ────────────────────────────────────────────
        public async Task<bool> RemoveMemberAsync(int officialId)
        {
            var user = await userRepo.GetByIdAsync(officialId);
            if (user is not Official official) return false;

            official.UnitId = null;
            userRepo.UpdateAsync(official);
            await userRepo.SaveChangesAsync();
            return true;
        }

        // ────────────────────────────────────────────
        //  Delete Unit
        // ────────────────────────────────────────────
        public async Task<bool> DeleteUnitAsync(int id)
        {
            var unit = await unitRepo.GetByIdAsync(id);
            if (unit is null) return false;

            unitRepo.Delete(unit);
            await unitRepo.SaveChangesAsync();
            return true;

        }
        public async Task<IEnumerable<Unit>> GetAvailableUnitsAsync()
       => await unitRepo.GetAvailableUnitsAsync();
    }
}