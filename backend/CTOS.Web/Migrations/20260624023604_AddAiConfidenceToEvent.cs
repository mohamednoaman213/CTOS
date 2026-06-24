using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CTOS.Web.Migrations
{
    /// <inheritdoc />
    public partial class AddAiConfidenceToEvent : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "AiConfidence",
                table: "Events",
                type: "float",
                nullable: false,
                defaultValue: 0.0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AiConfidence",
                table: "Events");
        }
    }
}
