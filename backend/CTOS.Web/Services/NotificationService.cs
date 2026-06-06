
using CTOS.Web.Entities;
using CTOS.Web.Repositroies;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;


namespace CTOS.Web.Services
{
    public class NotificationService(NotificationRepo notificationRepo)
    {
        // ── Initialize Firebase once ─────────────────
        static NotificationService()
        {
            if (FirebaseApp.DefaultInstance == null)
            {
                FirebaseApp.Create(new AppOptions
                {
                    Credential = GoogleCredential.FromJson(FirebaseJson)
                });
            }
        }

        // ── Send + Save to DB ────────────────────────
        public async Task SendAndSaveAsync(int userId, string title, string body, string? deviceToken, int? eventId = null)
        {
            // Save to DB
            var notification = new Entities.Notification
            {
                Title = title,
                Body = body,
                UserId = userId,
                EventId = eventId,
                IsRead = false,
                CreatedAt = DateTime.UtcNow
            };
            await notificationRepo.AddAsync(notification);
            await notificationRepo.SaveChangesAsync();

            // Send push notification if device token exists
            if (!string.IsNullOrEmpty(deviceToken))
            {
                try
                {
                    var message = new Message
                    {
                        Token = deviceToken,
                        Notification = new FirebaseAdmin.Messaging.Notification
                        {
                            Title = title,
                            Body = body
                        }
                    };
                    await FirebaseMessaging.DefaultInstance.SendAsync(message);
                }
                catch { /* ignore push errors */ }
            }
        }

        // ── Send to multiple users ───────────────────
        public async Task SendToMultipleAsync(List<(int UserId, string? DeviceToken)> users, string title, string body, int? eventId = null)
        {
            foreach (var user in users)
            {
                await SendAndSaveAsync(user.UserId, title, body, user.DeviceToken, eventId);
            }
        }

        // ── Get notifications for user ───────────────
        public async Task<IEnumerable<Entities.Notification>> GetUserNotificationsAsync(int userId)
            => await notificationRepo.GetByUserIdAsync(userId);

        // ── Mark as read ─────────────────────────────
        public async Task<bool> MarkAsReadAsync(int notificationId)
        {
            var notification = await notificationRepo.GetByIdAsync(notificationId);
            if (notification is null) return false;

            notification.IsRead = true;
            notificationRepo.Update(notification);
            await notificationRepo.SaveChangesAsync();
            return true;
        }

        // ── Firebase credentials ─────────────────────
        private const string FirebaseJson = """
        {
          "type": "service_account",
          "project_id": "ctos-not",
          "private_key_id": "8d4b004a82aeca4d8687393e35d83ce8ab43cd99",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDZtoqO6uK7wPW+\nwI/fPU/McMQVwOOC0jkT0eWDC2HjGcwdisVZ0e1L1fVh2ZEmVRFnq9Vmob2PNX4x\ndlaylBvBWwaXhFb0VYGzms54TGFMS/TPNnlqH9GhEFSLfeSRVVOYL/U5e2mNurfW\nqT1FEQvSQ4Q5chhQAIMDk8t3OoZ7YNtw9oYtbTtRFCn5ZcyWX1lv0npEYYimlVIh\nkAVUupeoysgdvo8mx4y97q37NigoPpuxlcO1GM5VrxfmjinCKXIrHiFeH4TFIEIN\nQ97GmN3LHrrzrgAlMqIxJ6XXq9YNSjlSu66m0qYZC6r9d2/lN4IkGMBy8KnSLgoe\nuYBKGjNbAgMBAAECggEARknLURnfSrug+01DBdFPHpN3kwhby4QgflghL54wo7fT\n8OO5FGcUpAu3Nbiexo/nVx+gfYqRXxdnnwN0OSJdFZ9UMP2+bxLeFYTQzQDn1tCd\nAHs3Vr5gGQ5jJUfnT86K9xLgqobADMxwBuNLzy0SMneuzDccR1Pq+HAyW9Nu0Izb\nyoTHE4S8u8QIgRpzBQwYHMTgc+dIMQ1Dt3QgR9znr8F7d+G4Wc1JRrI057hYUZ/8\n0eGRXmngaKtB172URajXq4iZRQcq3vQl6+O4/3hElOkEVKsc7FnVvZ2JreAbE5NS\nSCfoJr4dFnCdxkHzAkuwY2edomopBY7Kua17+5wEaQKBgQDt0a12Ia5Mzs6ZNWKJ\nSU/mM7FUVULxqjoMRVKWoFKHq94Rdx+cTYMpiWNTLj2wB9fl04VGVJoeTbQsYb4v\nmmKFvc4w/8EZQtyPkSRjOoqDEffi0gCoHZFOlraXg/F7qZGI9jQiZu7U95wCdeQk\n5ViSJ6v9SuZtal4HoK7R2K2JCQKBgQDqW187tUmaZT+p9FfoN/bO6vsG8E1oBNOT\n3fKmmM5aqweL9F+0GipUvzmfqGjy1inC92Opkb9gvq50A/UUPovYbbhq46LATFs+\nYYJXEmVVqFhFv2cEM4RJmQ8XceAmxCvNUKPIl6E5p5Iss8n9cm3np5Xkl5ECXPxt\nqTcMDZgmQwKBgBk0me/lTfXyDU+Lqu/mB0PcwrSvfLLkWdanGkPApj6e5qBvQbht\nNrOWTiKoyfz4N9ex/XQgz1za23fAvEmLUVnfbhUfZjXpMjs9JOAnejq+EsnFfDBV\nQetUafHRGC0FIdmkTo4+3p1PyQcxu4Z1kFedQMtNvvJlzaV9UEoJbwsRAoGBAKTt\nIqsZXK/8Ov53B3pUECv0MC7k5ASlCOTR2FcnyGkEXa4/jy5nD41OedYDJcBnuUIM\n6aVG/aCu8ISS2GGj1rS8GoGWq02bLsdKxfhS6N+MNnr3RR8uxhUpUvaT3ERL3+uA\nqZKcKwkxBWzSJf9oDTJuvMz/YTyBheACqsufsYiTAoGBAL0Ne9FeF9CLKXZi1DVx\noHpRy+iX3XPgKz9LHW5Grso/6uf5PFYD/VGR7ak1AGBSTa1wHXlRQ/5OCB+ApgMK\n8ebYfsUdsAX9ipm/4MpCIFbnlnPXFyHJAtFXfZmHxRTaiq0SeFMYsnor/tYkAagP\ndVxS/y9EdzNsQiSjP2PX5CRY\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-fbsvc@ctos-not.iam.gserviceaccount.com",
          "client_id": "102685628110452247644",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40ctos-not.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
        """;
    }
}
