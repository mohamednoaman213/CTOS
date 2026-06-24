using CTOS.Web.Entities;
using CTOS.Web.Services;
using Microsoft.AspNetCore.Mvc;

namespace CTOS.Web.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UnitController(UnitService unitService, NotificationService notificationService, UserService userService) : ControllerBase
    {
        // GET api/unit/dispatcher/{dispatcherId}
        [HttpGet("Dispatcher/{dispatcherId}")]
        public async Task<IActionResult> GetUnitsByDispatcher(int dispatcherId)
        {
            var units = await unitService.GetUnitsByDispatcherAsync(dispatcherId);
            return Ok(units.Select(u => new
            {
                u.Id,
                u.UnitName,
                u.Status,
                MemberCount = u.Members.Count,
                Members = u.Members.Select(m => new
                {
                    m.Id,
                    m.FullName,
                    m.BadgeId,
                    m.Rank,
                    m.ProfileImageUrl
                })
            }));
        }

        // GET api/unit/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUnit(int id)
        {
            var unit = await unitService.GetUnitByIdAsync(id);
            if (unit is null) return NotFound($"Unit with Id:{id} not found.");
            return Ok(new
            {
                unit.Id,
                unit.UnitName,
                unit.Status,
                unit.DispatcherId,
                unit.CreatedAt,
                Members = unit.Members.Select(m => new
                {
                    m.Id,
                    m.FullName,
                    m.BadgeId,
                    m.Rank,
                    m.ProfileImageUrl
                })
            });
        }

        // POST api/unit/create
        [HttpPost("Create")]
        public async Task<IActionResult> CreateUnit(Unit unit)
        {
            var id = await unitService.CreateUnitAsync(unit);
            if (id == 0) return BadRequest("Failed to create unit.");
            return Ok(new { Id = id });
        }

        // PUT api/unit/{unitId}/status
        // Body: "Available" or "Occupied"
        [HttpPut("{unitId}/Status")]
        public async Task<IActionResult> UpdateStatus(int unitId, [FromBody] string status)
        {
            if (status != "Available" && status != "Occupied")
                return BadRequest("Status must be 'Available' or 'Occupied'.");

            var result = await unitService.UpdateStatusAsync(unitId, status);
            if (!result) return NotFound($"Unit with Id:{unitId} not found.");
            return Ok("Status updated.");
        }

        // POST api/unit/{unitId}/members/{officialId}
        [HttpPost("{unitId}/Members/{officialId}")]
        public async Task<IActionResult> AddMember(int unitId, int officialId)
        {
            var result = await unitService.AddMemberAsync(unitId, officialId);
            if (!result) return BadRequest("Official already in a unit or not found.");
            return Ok("Member added.");
        }

        // DELETE api/unit/members/{officialId}
        [HttpDelete("Members/{officialId}")]
        public async Task<IActionResult> RemoveMember(int officialId)
        {
            var result = await unitService.RemoveMemberAsync(officialId);
            if (!result) return NotFound("Official not found.");
            return Ok("Member removed.");
        }

        // DELETE api/unit/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUnit(int id)
        {
            var result = await unitService.DeleteUnitAsync(id);
            if (!result) return NotFound($"Unit with Id:{id} not found.");
            return Ok("Unit deleted.");
        }

        // POST api/unit/{unitId}/request-backup
        [HttpPost("{unitId}/RequestBackup")]
        public async Task<IActionResult> RequestBackup(int unitId, [FromBody] RequestBackupDto dto)
        {
            var unit = await unitService.GetUnitByIdAsync(unitId);
            if (unit is null) return NotFound($"Unit with Id:{unitId} not found.");

            var officials = await userService.GetAllOfficialsAsync();
            var recipients = officials
                .Where(o => !o.IsDeleted && o.Id != dto.RequestingOfficerId)
                .Select(o => (o.Id, o.DeviceToken))
                .ToList();

            await notificationService.SendToMultipleAsync(
                recipients,
                "Backup Requested",
                $"{unit.UnitName} is requesting backup!",
                null
            );

            return Ok("Backup request sent.");
        }


        [HttpGet("Available")]
        public async Task<IActionResult> GetAvailableUnits()
        {
            var units = await unitService.GetAvailableUnitsAsync();
            return Ok(units.Select(u => new
            {
                u.Id,
                u.UnitName,
                u.Status,
                MemberCount = u.Members.Count,
                Members = u.Members.Select(m => new
                {
                    m.Id,
                    m.FullName,
                    m.BadgeId,
                    m.Rank,
                    m.ProfileImageUrl
                })
            }));
        }

    }

    public class RequestBackupDto
    {
        public int RequestingOfficerId { get; set; }
    }
    }

