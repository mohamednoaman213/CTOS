using CTOS.Web.Entities;
using CTOS.Web.Repositroies;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;

namespace CTOS.Web.Services
{
    public class UserService (UserRepo userRepo)
    {
        //  Register Citizen
        // ────────────────────────────────────────────
        public async Task<int> RegisterCitizenAsync(Citizen citizen)
        {
            if (await userRepo.ExistsByNationalIdAsync(citizen.NationalId))
                throw new Exception("This National ID is already registered.");

            citizen.Id = 0;
            citizen.UserId = Guid.NewGuid().ToString();
            citizen.PasswordHash = HashPassword(citizen.PasswordHash);
            citizen.CreatedAt = DateTime.UtcNow;
            citizen.IsVerified = false;
            citizen.IsDeleted = false;
            citizen.AiScore = 0;
            citizen.AiSensitivityLevel = 1;

            await userRepo.AddAsync(citizen);
            await userRepo.SaveChangesAsync();
            return citizen.Id;
        }

        // ────────────────────────────────────────────
        //  Register Official
        // ────────────────────────────────────────────
        public async Task<int> RegisterOfficialAsync(Official official)
        {
            if (await userRepo.ExistsByNationalIdAsync(official.NationalId))
                throw new Exception("This National ID is already registered.");

            official.Id = 0;
            official.UserId = Guid.NewGuid().ToString();
            official.PasswordHash = HashPassword(official.PasswordHash);
            official.CreatedAt = DateTime.UtcNow;
            official.IsVerified = false;
            official.IsDeleted = false;
            official.Rating = 0;

            await userRepo.AddAsync(official);
            await userRepo.SaveChangesAsync();
            return official.Id;
        }

        // ────────────────────────────────────────────
        //  Login (Citizen & Official)
        // ────────────────────────────────────────────
        public async Task<User?> LoginAsync(string email, string password)
        {
            var user = await userRepo.GetByEmailAsync(email);
            if (user is null || user.IsDeleted) return null;
            if (user.PasswordHash != HashPassword(password)) return null;
            return user;
        }

        // ────────────────────────────────────────────
        //  Get Profile
        // ────────────────────────────────────────────
        public async Task<User?> GetProfileAsync(int id)
        {
            var user = await userRepo.GetByIdAsync(id);
            if (user is null || user.IsDeleted) return null;
            return user;
        }

        // ────────────────────────────────────────────
        //  Update Citizen
        // ────────────────────────────────────────────
        public async Task<int> UpdateCitizenAsync(int id, Citizen sentData)
        {
            var user = await userRepo.GetByIdAsync(id);
            if (user is not Citizen citizen || citizen.IsDeleted) return 0;

            if (!string.IsNullOrEmpty(sentData.FullName))
                citizen.FullName = sentData.FullName;
            if (!string.IsNullOrEmpty(sentData.Email))
                citizen.Email = sentData.Email;
            if (!string.IsNullOrEmpty(sentData.PasswordHash))
                citizen.PasswordHash = HashPassword(sentData.PasswordHash);
            if (!string.IsNullOrEmpty(sentData.ProfileImageUrl))
                citizen.ProfileImageUrl = sentData.ProfileImageUrl;
            if (!string.IsNullOrEmpty(sentData.JobTitle))
                citizen.JobTitle = sentData.JobTitle;
            if (!string.IsNullOrEmpty(sentData.HomeAddress))
                citizen.HomeAddress = sentData.HomeAddress;
            if (!string.IsNullOrEmpty(sentData.AiSensitivity))
                citizen.AiSensitivity = sentData.AiSensitivity;

            userRepo.UpdateAsync(citizen);
            await userRepo.SaveChangesAsync();
            return citizen.Id;
        }

        // ────────────────────────────────────────────
        //  Update Official
        // ────────────────────────────────────────────
        public async Task<int> UpdateOfficialAsync(int id, Official sentData)
        {
            var user = await userRepo.GetByIdAsync(id);
            if (user is not Official official || official.IsDeleted) return 0;

            if (!string.IsNullOrEmpty(sentData.FullName))
                official.FullName = sentData.FullName;
            if (!string.IsNullOrEmpty(sentData.Email))
                official.Email = sentData.Email;
            if (!string.IsNullOrEmpty(sentData.PasswordHash))
                official.PasswordHash = HashPassword(sentData.PasswordHash);
            if (!string.IsNullOrEmpty(sentData.ProfileImageUrl))
                official.ProfileImageUrl = sentData.ProfileImageUrl;
            if (!string.IsNullOrEmpty(sentData.HomeAddress))
                official.HomeAddress = sentData.HomeAddress;
            if (!string.IsNullOrEmpty(sentData.Rank))
                official.Rank = sentData.Rank;
            if (sentData.MapProximityKm > 0)
                official.MapProximityKm = sentData.MapProximityKm;

            userRepo.UpdateAsync(official);
            await userRepo.SaveChangesAsync();
            return official.Id;
        }

        // ────────────────────────────────────────────
        //  Get All Officials
        // ────────────────────────────────────────────
        public async Task<IEnumerable<Official>> GetAllOfficialsAsync()
            => await userRepo.GetAllOfficialsAsync();

        // ────────────────────────────────────────────
        //  Delete Account (Soft Delete)
        // ────────────────────────────────────────────
        public async Task<bool> DeleteAccountAsync(int id)
        {
            var user = await userRepo.GetByIdAsync(id);
            if (user is null || user.IsDeleted) return false;

            user.IsDeleted = true;
            userRepo.UpdateAsync(user);
            await userRepo.SaveChangesAsync();
            return true;
        }

        // ────────────────────────────────────────────
        //  Private Helper
        // ────────────────────────────────────────────
        private static string HashPassword(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToHexString(bytes);
        }

    }
}
