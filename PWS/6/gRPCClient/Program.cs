using Grpc.Core;
using Grpc.Net.Client; 
using GRPCServer.Protos;

class Program
{
    static async Task Main(string[] args)
    {
        using var channel = GrpcChannel.ForAddress("http://localhost:5028");
        var client = new Calculator.CalculatorClient(channel);

        double x = 10, y = 5;

        try
        {
            // SUM
            var sumResponse = await client.SumAsync(new CalcRequest { X = x, Y = y });
            Console.WriteLine($"SUM({x}, {y}) = {sumResponse.Result}");

            // SUB
            var subResponse = await client.SubAsync(new CalcRequest { X = x, Y = y });
            Console.WriteLine($"SUB({x}, {y}) = {subResponse.Result}");

            // MUL
            var mulResponse = await client.MulAsync(new CalcRequest { X = x, Y = y });
            Console.WriteLine($"MUL({x}, {y}) = {mulResponse.Result}");

            // DIV
            try
            {
                var divResponse = await client.DivAsync(new CalcRequest { X = x, Y = y });
                Console.WriteLine($"DIV({x}, {y}) = {divResponse.Result}");
            }
            catch (RpcException ex)
            {
                Console.WriteLine($"DIV Error: {ex.Status.Detail}");
            }

            // DIV by zero
            try
            {
                var divZeroResponse = await client.DivAsync(new CalcRequest { X = x, Y = 0 });
                Console.WriteLine($"DIV({x}, 0) = {divZeroResponse.Result}");
            }
            catch (RpcException ex)
            {
                Console.WriteLine($"DIV Error: {ex.Status.Detail}");
            }

            // FACT
            try
            {
                var factResponse = await client.FactAsync(new FactRequest { X = 5 });
                Console.WriteLine($"FACT(5) = {factResponse.Result}");
            }
            catch (RpcException ex)
            {
                Console.WriteLine($"FACT Error: {ex.Status.Detail}");
            }

            // FACT overflow
            try
            {
                var factOverflowResponse = await client.FactAsync(new FactRequest { X = 100 });
                Console.WriteLine($"FACT(100) = {factOverflowResponse.Result}");
            }
            catch (RpcException ex)
            {
                Console.WriteLine($"FACT Error: {ex.Status.Detail}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Unexpected error: {ex.Message}");
        }

        Console.WriteLine("Press any key to exit...");
        Console.ReadKey();
    }
}