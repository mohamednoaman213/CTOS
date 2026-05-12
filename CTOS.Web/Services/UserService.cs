using CTOS.Web.Entities;
using CTOS.Web.Repositroies;
using System.Security.Cryptography;
using System.Text;

namespace CTOS.Web.Services
{
    public class UserService (UserRepo userRepo)
    {
        //  Register
        // ────────────────────────────────────────────
        public async Task<int> RegisterAsync(User user)
        {
            user.Id = 0;
            user.UserId = Guid.NewGuid().ToString();
            user.PasswordHash = HashPassword(user.PasswordHash);
            user.CreatedAt = DateTime.UtcNow;
            user.IsVerified = false;
            user.IsDeleted = false;

            await userRepo.AddAsync(user);
            await userRepo.SaveChangesAsync();
            return user.Id;
        }

        // ────────────────────────────────────────────
        //  Login
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
        //  Update Profile
        // ────────────────────────────────────────────
        public async Task<int> UpdateProfileAsync(int id, User sentUser)
        {
            if (id <= 0) return 0;

            var existingUser = await userRepo.GetByIdAsync(id);
            if (existingUser is null || existingUser.IsDeleted) return 0;

            if (!string.IsNullOrEmpty(sentUser.FullName))
                existingUser.FullName = sentUser.FullName;

            if (!string.IsNullOrEmpty(sentUser.Email))
                existingUser.Email = sentUser.Email;

            if (!string.IsNullOrEmpty(sentUser.PasswordHash))
                existingUser.PasswordHash = HashPassword(sentUser.PasswordHash);

            userRepo.UpdateAsync(existingUser);
            await userRepo.SaveChangesAsync();
            return existingUser.Id;
        }

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
