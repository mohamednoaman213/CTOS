

// Operations to be done on Event Entity

using CTOS.Web.Entities;
using CTOS.Web.Repositroies;
using Microsoft.Extensions.Logging;

namespace CTOS.Web.Services {
    public class EventService(EventRepo eventRepo, UserRepo userRepo, NotificationService notificationService)
    {

        public async Task<Event?> GetEventByIdAsync(int id)
        {
            var result = await eventRepo.GetByIdAsync(id);
            if (result is null)
                throw new Exception($"Event with Id:{id} is not found");
            return result;
        }

        public async Task<IEnumerable<Event>> GetAllEventsAsync()
            => await eventRepo.GetAllAsync();

        public async Task<int> CreateEventAsync(Event evenT)
        {
            evenT.Id = 0;
            evenT.Status = "UnderProcessing";
            evenT.CreatedAt = DateTime.UtcNow;

            await eventRepo.AddAsync(evenT);
            await eventRepo.SaveChangesAsync();

            // Notify the citizen who submitted
            var citizen = await userRepo.GetByIdAsync(evenT.UserId);
            if (citizen != null)
            {
                await notificationService.SendAndSaveAsync(
                    citizen.Id,
                    "Report Submitted ✅",
                    $"Your report '{evenT.EventName}' has been received and is under processing.",
                    citizen.DeviceToken,
                    evenT.Id
                );
            }

            // Notify officials in the same department
            var officials = await userRepo.GetOfficialsByDepartmentAsync(evenT.Category);
            var officialList = officials
                .Select(o => (o.Id, o.DeviceToken))
                .ToList();

            if (officialList.Count > 0)
            {
                await notificationService.SendToMultipleAsync(
                    officialList,
                    $"New {evenT.Category} Report 🚨",
                    $"{evenT.EventName} - {evenT.Location}",
                    evenT.Id
                );
            }

            return evenT.Id;
        }

        public async Task<int> UpdateEventAsync(int id, Event sentEvent)
        {
            if (id <= 0) return 0;
            var existingEvent = await eventRepo.GetByIdAsync(id);
            if (existingEvent == null) return 0;

            existingEvent.EventName = sentEvent.EventName;
            existingEvent.Location = sentEvent.Location;
            existingEvent.Priority = sentEvent.Priority;
            existingEvent.Description = sentEvent.Description;

            // If status changed → notify citizen
            if (!string.IsNullOrEmpty(sentEvent.Status) && sentEvent.Status != existingEvent.Status)
            {
                existingEvent.Status = sentEvent.Status;

                var citizen = await userRepo.GetByIdAsync(existingEvent.UserId);
                if (citizen != null)
                {
                    await notificationService.SendAndSaveAsync(
                        citizen.Id,
                        "Report Status Updated 🔔",
                        $"Your report '{existingEvent.EventName}' is now: {sentEvent.Status}",
                        citizen.DeviceToken,
                        existingEvent.Id
                    );
                }
            }

            eventRepo.UpdateAsync(existingEvent);
            await eventRepo.SaveChangesAsync();
            return existingEvent.Id;
        }

        public async Task<bool> DeletedEventAsync(int id)
        {
            var existingEvent = await eventRepo.GetByIdAsync(id);
            if (existingEvent == null) return false;
            eventRepo.DeleteAsync(existingEvent);
            await eventRepo.SaveChangesAsync();
            return true;
        }
    }

}


