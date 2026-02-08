// Services/SseService.cs
using System.Text;
using System.Collections.Concurrent;

public class SseService
{
    private readonly ConcurrentDictionary<string, SseClient> _clients = new();
    private readonly ILogger<SseService> _logger;

    public SseService(ILogger<SseService> logger)
    {
        _logger = logger;
    }

    public async Task AddClientAsync(HttpContext context)
    {
        var clientId = Guid.NewGuid().ToString();
        var response = context.Response;
        
        response.ContentType = "text/event-stream";
        response.Headers.CacheControl = "no-cache";
        response.Headers.Connection = "keep-alive";
        response.Headers.AccessControlAllowOrigin = "*";

        var client = new SseClient(clientId, response.Body);
        
        if (_clients.TryAdd(clientId, client))
        {
            _logger.LogInformation("SSE client connected. Total clients: {Count}", _clients.Count);

            try
            {
                await SendMessageToClient(clientId, "connected", new { message = "SSE connection established", clientId = clientId });

                var cancellationToken = context.RequestAborted;
                while (!cancellationToken.IsCancellationRequested)
                {
                    await Task.Delay(5000, cancellationToken);
                    
                    await SendMessageToClient(clientId, "ping", new { timestamp = DateTime.Now });
                }
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("SSE client {ClientId} disconnected (operation canceled)", clientId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in SSE connection for client {ClientId}", clientId);
            }
            finally
            {
                RemoveClient(clientId);
                _logger.LogInformation("SSE client disconnected. Total clients: {Count}", _clients.Count);
            }
        }
    }

    public async Task BroadcastEventAsync(string eventName, object data)
    {
        _logger.LogInformation("Broadcasting event '{Event}' to {Count} clients", eventName, _clients.Count);

        var tasks = _clients.Keys.Select(clientId => SendMessageToClient(clientId, eventName, data));
        await Task.WhenAll(tasks);
    }

    private async Task SendMessageToClient(string clientId, string eventName, object data)
    {
        if (_clients.TryGetValue(clientId, out var client))
        {
            try
            {
                var jsonData = System.Text.Json.JsonSerializer.Serialize(data);
                var message = $"event: {eventName}\ndata: {jsonData}\n\n";
                
                var bytes = Encoding.UTF8.GetBytes(message);
                await client.Stream.WriteAsync(bytes);
                await client.Stream.FlushAsync();
                
                _logger.LogDebug("Sent event '{Event}' to client {ClientId}", eventName, clientId);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to send message to SSE client {ClientId}", clientId);
                RemoveClient(clientId);
            }
        }
    }

    private void RemoveClient(string clientId)
    {
        if (_clients.TryRemove(clientId, out var client))
        {
            _logger.LogDebug("Removed SSE client {ClientId}", clientId);
        }
    }

    private class SseClient
    {
        public string ClientId { get; }
        public Stream Stream { get; }

        public SseClient(string clientId, Stream stream)
        {
            ClientId = clientId;
            Stream = stream;
        }
    }
}