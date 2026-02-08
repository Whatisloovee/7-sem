public interface IRpcService
{
    JsonRpcResponse ProcessRequest(JsonRpcRequest request);
    List<JsonRpcResponse> ProcessBatch(List<JsonRpcRequest> requests);
}