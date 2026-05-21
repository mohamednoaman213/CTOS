using CTOS.Web.Entities;
using CTOS.Web.Services;
using Microsoft.AspNetCore.Mvc;

namespace CTOS.Web.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController(UserService userService) : ControllerBase
    {
        // ── POST api/user/register/citizen ───────────────
        [HttpPost("Register/Citizen")]
        public async Task<IActionResult> RegisterCitizen(Citizen citizen)
        {
            var id = await userService.RegisterCitizenAsync(citizen);
            if (id == 0) return BadRequest("Registration failed.");
            return Ok(new { Id = id });
        }

        // ── POST api/user/register/official ─────────────
        [HttpPost("Register/Official")]
        public async Task<IActionResult> RegisterOfficial(Official official)
        {
            var id = await userService.RegisterOfficialAsync(official);
            if (id == 0) return BadRequest("Registration failed.");
            return Ok(new { Id = id });
        }

        // ── POST api/user/login ──────────────────────────
        // Body: { "email": "...", "passwordHash": "..." }
        [HttpPost("Login")]
        public async Task<IActionResult> Login([FromBody] User user)
        {
            var result = await userService.LoginAsync(user.Email, user.PasswordHash);
            if (result is null) return Unauthorized("Invalid email or password.");

            if (result is Official official)
                return Ok(new
                {
                    official.UserId,
                    official.FullName,
                    official.Email,
                    official.UserType,
                    official.BadgeId,
                    official.Rank,
                    official.Department,
                    official.IsVerified
                });

            if (result is Citizen citizen)
                return Ok(new
                {
                    citizen.UserId,
                    citizen.FullName,
                    citizen.Email,
                    citizen.UserType,
                    citizen.IsVerified
                });

            return Ok(result);
        }

        // ── GET api/user/profile/{id} ────────────────────
        [HttpGet("Profile/{id}")]
        public async Task<IActionResult> GetProfile(int id)
        {
            var user = await userService.GetProfileAsync(id);
            if (user is null) return NotFound($"User with Id:{id} not found.");

            if (user is Official official)
                return Ok(new
                {
                    official.UserId,
                    official.FullName,
                    official.Email,
                    official.NationalId,
                    official.ProfileImageUrl,
                    official.IsVerified,
                    official.BadgeId,
                    official.Rank,
                    official.Department,
                    official.HomeAddress,
                    official.MapProximityKm,
                    official.Rating,
                    official.ImpactGrade,
                    official.CreatedAt,
                    TotalReports = official.Events.Count
                });

            if (user is Citizen citizen)
                return Ok(new
                {
                    citizen.UserId,
                    citizen.FullName,
                    citizen.Email,
                    citizen.NationalId,
                    citizen.ProfileImageUrl,
                    citizen.IsVerified,
                    citizen.JobTitle,
                    citizen.HomeAddress,
                    citizen.AiSensitivity,
                    citizen.AiSensitivityLevel,
                    citizen.AiScore,
                    citizen.ImpactGrade,
                    citizen.CreatedAt,
                    TotalReports = citizen.Events.Count
                });

            return Ok(user);
        }

        // ── PUT api/user/profile/citizen/{id} ───────────
        [HttpPut("Profile/Citizen/{id}")]
        public async Task<IActionResult> UpdateCitizen(int id, Citizen citizen)
        {
            var result = await userService.UpdateCitizenAsync(id, citizen);
            if (result == 0) return NotFound($"Citizen with Id:{id} not found.");
            return Ok(new { UpdatedId = result });
        }

        // ── PUT api/user/profile/official/{id} ──────────
        [HttpPut("Profile/Official/{id}")]
        public async Task<IActionResult> UpdateOfficial(int id, Official official)
        {
            var result = await userService.UpdateOfficialAsync(id, official);
            if (result == 0) return NotFound($"Official with Id:{id} not found.");
            return Ok(new { UpdatedId = result });
        }

        // ── DELETE api/user/delete/{id} ──────────────────
        [HttpDelete("Delete/{id}")]
        public async Task<IActionResult> DeleteAccount(int id)
        {
            var result = await userService.DeleteAccountAsync(id);
            if (!result) return NotFound($"User with Id:{id} not found.");
            return Ok("Account deleted successfully.");
        }
    }
}
