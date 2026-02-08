// Services/RpcService.cs
using System.Text.Json;

public class RpcService : IRpcService
{
    private readonly SseService _sseService;
    private readonly ILogger<RpcService> _logger;

    // Правильные коды ошибок JSON-RPC 2.0
    private const int ERROR_DIVISION_BY_ZERO = -32001;
    private const int ERROR_FACTORIAL_OVERFLOW = -32002;
    private const int ERROR_INVALID_FACTORIAL = -32003;

    public RpcService(SseService sseService, ILogger<RpcService> logger)
    {
        _sseService = sseService;
        _logger = logger;
    }

    public JsonRpcResponse ProcessRequest(JsonRpcRequest request)
    {
        try
        {
            if (request.Method == null)
            {
                return CreateErrorResponse(-32600, "Invalid Request", request.Id);
            }

            object result = request.Method.ToUpper() switch
            {
                "SUM" => ProcessSum(request),
                "SUB" => ProcessSub(request),
                "MUL" => ProcessMul(request),
                "DIV" => ProcessDiv(request),
                "FACT" => ProcessFact(request),
                _ => throw new JsonRpcException(-32601, "Method not found")
            };

            return CreateSuccessResponse(result, request.Id);
        }
        catch (JsonRpcException ex)
        {
            return CreateErrorResponse(ex.Code, ex.Message, request.Id);
        }
        catch (Exception ex)
        {
            return CreateErrorResponse(-32603, $"Internal error: {ex.Message}", request.Id);
        }
    }

    public List<JsonRpcResponse> ProcessBatch(List<JsonRpcRequest> requests)
    {
        var responses = new List<JsonRpcResponse>();
        
        foreach (var request in requests)
        {
            responses.Add(ProcessRequest(request));
        }
        
        return responses;
    }

    private double ProcessSum(JsonRpcRequest request)
    {
        var (x, y) = ParseParameters(request.Params);
        var result = x + y;
        
        // Отправляем SSE событие
        _ = _sseService.BroadcastEventAsync("SUM", new { result = result });
        
        return result;
    }

    private double ProcessSub(JsonRpcRequest request)
    {
        var (x, y) = ParseParameters(request.Params);
        var result = x - y;
        
        // Отправляем SSE событие
        _ = _sseService.BroadcastEventAsync("SUB", new { result = result });
        
        return result;
    }

    private double ProcessMul(JsonRpcRequest request)
    {
        var (x, y) = ParseParameters(request.Params);
        var result = x * y;
        
        // Отправляем SSE событие
        _ = _sseService.BroadcastEventAsync("MUL", new { result = result });
        
        return result;
    }

    private double ProcessDiv(JsonRpcRequest request)
    {
        var (x, y) = ParseParameters(request.Params);
        
        if (y == 0)
        {
            // Отправляем SSE событие об ошибке
            _ = _sseService.BroadcastEventAsync("DIV", new { error = "y = 0" });
            throw new JsonRpcException(ERROR_DIVISION_BY_ZERO, "Division by zero");
        }
        
        var result = x / y;
        
        // Отправляем SSE событие об успехе
        _ = _sseService.BroadcastEventAsync("DIV", new { result = result });
        
        return result;
    }

    private int ProcessFact(JsonRpcRequest request)
    {
        try
        {
            int n;
            if (request.Params is JsonElement element)
            {
                if (element.ValueKind == JsonValueKind.Array && element.GetArrayLength() == 1)
                {
                    n = element[0].GetInt32();
                }
                else if (element.ValueKind == JsonValueKind.Object)
                {
                    n = element.GetProperty("x").GetInt32();
                }
                else
                {
                    throw new JsonRpcException(-32602, "Invalid parameters for FACT");
                }
            }
            else
            {
                throw new JsonRpcException(-32602, "Invalid parameters for FACT");
            }

            var result = CalculateFactorial(n);
            
            // Отправляем SSE событие об успехе
            _ = _sseService.BroadcastEventAsync("FACT", new { result = result });
            
            return result;
        }
        catch (JsonRpcException ex) when (ex.Code == ERROR_FACTORIAL_OVERFLOW)
        {
            // Отправляем SSE событие о переполнении
            _ = _sseService.BroadcastEventAsync("FACT", new { error = "overflow" });
            throw;
        }
        catch (KeyNotFoundException)
        {
            throw new JsonRpcException(-32602, "Missing parameter 'x' for FACT");
        }
        catch (FormatException)
        {
            throw new JsonRpcException(-32602, "Invalid parameter format for FACT");
        }
    }

    private int CalculateFactorial(int n)
    {
        if (n < 0) 
            throw new JsonRpcException(ERROR_INVALID_FACTORIAL, "Factorial is not defined for negative numbers");
        
        if (n > 12) 
            throw new JsonRpcException(ERROR_FACTORIAL_OVERFLOW, "Factorial result exceeds int capacity");
        
        int result = 1;
        for (int i = 2; i <= n; i++)
        {
            checked { result *= i; } // Проверка переполнения во время выполнения
        }
        return result;
    }

    private (double x, double y) ParseParameters(object parameters)
    {
        try
        {
            if (parameters is JsonElement element)
            {
                if (element.ValueKind == JsonValueKind.Array && element.GetArrayLength() == 2)
                {
                    // Позиционные параметры
                    var x = element[0].GetDouble();
                    var y = element[1].GetDouble();
                    return (x, y);
                }
                else if (element.ValueKind == JsonValueKind.Object)
                {
                    // Именованные параметры
                    var x = element.GetProperty("x").GetDouble();
                    var y = element.GetProperty("y").GetDouble();
                    return (x, y);
                }
            }
            
            throw new JsonRpcException(-32602, "Invalid parameters");
        }
        catch (KeyNotFoundException)
        {
            throw new JsonRpcException(-32602, "Missing required parameters");
        }
        catch (FormatException)
        {
            throw new JsonRpcException(-32602, "Invalid parameter format");
        }
        catch (InvalidOperationException)
        {
            throw new JsonRpcException(-32602, "Invalid parameter type");
        }
    }

    private JsonRpcResponse CreateSuccessResponse(object result, object id)
    {
        return new JsonRpcResponse
        {
            Result = result,
            Id = id
        };
    }

    private JsonRpcResponse CreateErrorResponse(int code, string message, object id)
    {
        return new JsonRpcResponse
        {
            Error = new JsonRpcError
            {
                Code = code,
                Message = message
            },
            Id = id
        };
    }
}
