// Controllers/JsonRpcController.cs
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/jsonrpc")]
public class JsonRpcController : ControllerBase
{
    private readonly IRpcService _rpcService;
    private readonly ILogger<JsonRpcController> _logger;

    public JsonRpcController(IRpcService rpcService, ILogger<JsonRpcController> logger)
    {
        _rpcService = rpcService;
        _logger = logger;
    }

    [HttpPost]
    public IActionResult HandleRequest([FromBody] object request)
    {
        try
        {
            _logger.LogInformation("Received JSON-RPC request: {Request}", 
                JsonSerializer.Serialize(request));

            if (request is JsonElement element && element.ValueKind == JsonValueKind.Array)
            {
                // Пакетная обработка
                var batchRequests = JsonSerializer.Deserialize<List<JsonRpcRequest>>(element.GetRawText());
                var responses = _rpcService.ProcessBatch(batchRequests);
                return Ok(responses);
            }
            else
            {
                // Одиночный запрос
                var singleRequest = JsonSerializer.Deserialize<JsonRpcRequest>(
                    JsonSerializer.Serialize(request));
                var response = _rpcService.ProcessRequest(singleRequest);
                return Ok(response);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing JSON-RPC request");
            return Ok(new JsonRpcResponse
            {
                Error = new JsonRpcError
                {
                    Code = -32603,
                    Message = "Internal error"
                },
                Id = null
            });
        }
    }
}