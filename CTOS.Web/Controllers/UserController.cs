using CTOS.Web.Entities;
using CTOS.Web.Services;
using Microsoft.AspNetCore.Mvc;

namespace CTOS.Web.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController(UserService userService) : ControllerBase
    {
        // POST api/user/register
        [HttpPost]
        [Route("Register")]
        public async Task<IActionResult> Register(User user)
        {
            var id = await userService.RegisterAsync(user);
            if (id == 0) return BadRequest("Registration failed.");
            return Ok(new { UserId = id });
        }

        // POST api/user/login
        // Body: { "email": "...", "password": "..." }
        [HttpPost]
        [Route("Login")]
        public async Task<IActionResult> Login([FromBody] User user)
        {
            var result = await userService.LoginAsync(user.Email, user.PasswordHash);
            if (result is null) return Unauthorized("Invalid email or password.");
            return Ok(new { result.UserId, result.FullName, result.Email });
        }

        // GET api/user/profile/{id}
        [HttpGet]
        [Route("Profile/{id}")]
        public async Task<IActionResult> GetProfile(int id)
        {
            var user = await userService.GetProfileAsync(id);
            if (user is null) return NotFound($"User with Id:{id} not found.");
            return Ok(new
            {
                user.UserId,
                user.FullName,
                user.Email,
                user.NationalId,
                user.IsVerified,
                user.CreatedAt
            });
        }

        // PUT api/user/profile/{id}
        [HttpPut]
        [Route("Profile/{id}")]
        public async Task<IActionResult> UpdateProfile(int id, User user)
        {
            var result = await userService.UpdateProfileAsync(id, user);
            if (result == 0) return NotFound($"User with Id:{id} not found.");
            return Ok(new { UpdatedId = result });
        }

        // DELETE api/user/delete/{id}
        [HttpDelete]
        [Route("Delete/{id}")]
        public async Task<IActionResult> DeleteAccount(int id)
        {
            var result = await userService.DeleteAccountAsync(id);
            if (!result) return NotFound($"User with Id:{id} not found.");
            return Ok("Account deleted successfully.");
        }
    }
}
