// Models/JsonRpcRequest.cs
using System.Text.Json.Serialization;

public class JsonRpcRequest
{
    [JsonPropertyName("jsonrpc")]
    public string JsonRpc { get; set; } = "2.0";
    
    [JsonPropertyName("method")]
    public string Method { get; set; } = string.Empty;
    
    [JsonPropertyName("params")]
    public object Params { get; set; } = new object();
    
    [JsonPropertyName("id")]
    public object Id { get; set; }
}

