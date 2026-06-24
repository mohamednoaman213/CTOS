using System.Text.Json;

namespace CTOS.Web.Services
{
    public class AiDetectionResult
    {
        public string Priority { get; set; } = "Low";
        public string ThreatLevel { get; set; } = "NO THREAT DETECTED";
        public string RecommendedAction { get; set; } = "No action required";
        public List<string> Labels { get; set; } = [];
        public string? AnnotatedImage { get; set; }
        public double AverageConfidence { get; set; } = 0;
    }

    public class AiService(HttpClient httpClient, IConfiguration configuration)
    {
        private readonly string _aiApiUrl = configuration["AiApi:BaseUrl"] ?? "http://localhost:8001";

        public async Task<AiDetectionResult> AnalyzeAsync(IFormFile image)
        {
            try
            {
                // Copy to bytes first — avoids stream disposal and ContentType null issues
                using var ms = new MemoryStream();
                await image.CopyToAsync(ms);
                var imageBytes = ms.ToArray();

                var fileContent = new ByteArrayContent(imageBytes);
                var contentType = string.IsNullOrWhiteSpace(image.ContentType) ? "image/jpeg" : image.ContentType;
                fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(contentType);

                var fileName = string.IsNullOrWhiteSpace(image.FileName) ? "upload.jpg" : image.FileName;
                if (string.IsNullOrEmpty(Path.GetExtension(fileName))) fileName += ".jpg";

                using var content = new MultipartFormDataContent();
                content.Add(fileContent, "file", fileName);

                var response = await httpClient.PostAsync($"{_aiApiUrl}/detect", content);
                if (!response.IsSuccessStatusCode)
                {
                    var err = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"[AiService] Python API returned {response.StatusCode}: {err}");
                    return new AiDetectionResult();
                }

                var json = await response.Content.ReadAsStringAsync();
                var root = JsonDocument.Parse(json).RootElement;

                var threatLevel = root.GetProperty("threat_level").GetString() ?? "NO THREAT DETECTED";
                var recommendedAction = root.GetProperty("recommended_action").GetString() ?? "No action required";

                var labels = new List<string>();
                var confidences = new List<double>();
                if (root.TryGetProperty("detections", out var detectionsEl))
                    foreach (var d in detectionsEl.EnumerateArray())
                    {
                        if (d.TryGetProperty("label", out var lbl))
                            labels.Add(lbl.GetString() ?? "");
                        if (d.TryGetProperty("confidence", out var conf))
                            confidences.Add(conf.GetDouble() * 100);
                    }
                var avgConfidence = confidences.Count > 0
                    ? Math.Round(confidences.Average(), 1)
                    : 0;

                string? annotatedImage = null;
                if (root.TryGetProperty("annotated_image", out var imgEl))
                    annotatedImage = imgEl.GetString();

                return new AiDetectionResult
                {
                    Priority = threatLevel switch
                    {
                        "CRITICAL" => "Critical",
                        "HIGH"     => "High",
                        _          => "Low"
                    },
                    ThreatLevel = threatLevel,
                    RecommendedAction = recommendedAction,
                    Labels = labels,
                    AnnotatedImage = annotatedImage,
                    AverageConfidence = avgConfidence
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] ERROR: {ex.GetType().Name}: {ex.Message}");
                return new AiDetectionResult();
            }
        }

        public async Task<string> DetectThreatAsync(IFormFile image)
        {
            var result = await AnalyzeAsync(image);
            return result.Priority;
        }
    }
}
