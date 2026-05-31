
using CTOS.Web.Database.AppDbContext;
using CTOS.Web.Repositroies;
using CTOS.Web.Services;
using Microsoft.EntityFrameworkCore;

namespace CTOS.Web
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();


            #region Add Services (Dependency injection)

            builder.Services.AddScoped<EventRepo>();
            builder.Services.AddScoped<EventService>();
            builder.Services.AddScoped<UserRepo>();
            builder.Services.AddScoped<UserService>();
            builder.Services.AddScoped<UnitRepo>();
            builder.Services.AddScoped<UnitService>();
            builder.Services.AddScoped<Cloudinaryservice>();
            #endregion


            builder.Services.AddDbContext<CtosDbContext>(options => {
                options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
            });
            
            
            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}
