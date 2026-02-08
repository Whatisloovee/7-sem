using System.Text.Json;

public class RpcService : IRpcService
{
    // Правильные коды ошибок JSON-RPC 2.0
    private const int ERROR_DIVISION_BY_ZERO = -32001;
    private const int ERROR_FACTORIAL_OVERFLOW = -32002;
    private const int ERROR_INVALID_FACTORIAL = -32003;

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
                "SUM" => CalculateSum(request.Params),
                "SUB" => CalculateSub(request.Params),
                "MUL" => CalculateMul(request.Params),
                "DIV" => CalculateDiv(request.Params),
                "FACT" => CalculateFact(request.Params),
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

    private double CalculateSum(object parameters)
    {
        var (x, y) = ParseParameters(parameters);
        return x + y;
    }

    private double CalculateSub(object parameters)
    {
        var (x, y) = ParseParameters(parameters);
        return x - y;
    }

    private double CalculateMul(object parameters)
    {
        var (x, y) = ParseParameters(parameters);
        return x * y;
    }

    private double CalculateDiv(object parameters)
    {
        var (x, y) = ParseParameters(parameters);
        
        if (y == 0)
        {
            throw new JsonRpcException(ERROR_DIVISION_BY_ZERO, "Division by zero");
        }
        
        return x / y;
    }

    private int CalculateFact(object parameters)
    {
        try
        {
            if (parameters is JsonElement element)
            {
                if (element.ValueKind == JsonValueKind.Array && element.GetArrayLength() == 1)
                {
                    var x = element[0].GetInt32();
                    return CalculateFactorial(x);
                }
                else if (element.ValueKind == JsonValueKind.Object)
                {
                    var x = element.GetProperty("x").GetInt32();
                    return CalculateFactorial(x);
                }
            }
            
            throw new JsonRpcException(-32602, "Invalid parameters for FACT");
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

// Добавьте этот класс в тот же файл или в отдельный файл
public class JsonRpcException : Exception
{
    public int Code { get; }

    public JsonRpcException(int code, string message) : base(message)
    {
        Code = code;
    }
}