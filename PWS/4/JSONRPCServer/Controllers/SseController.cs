// Controllers/SseController.cs
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/sse")]
public class SseController : ControllerBase
{
    private readonly SseService _sseService;
    private readonly ILogger<SseController> _logger;

    public SseController(SseService sseService, ILogger<SseController> logger)
    {
        _sseService = sseService;
        _logger = logger;
    }

    [HttpGet]
    public async Task Get()
    {
        await _sseService.AddClientAsync(HttpContext);
    }
}