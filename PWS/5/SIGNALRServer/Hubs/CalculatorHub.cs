using Microsoft.AspNetCore.SignalR;

namespace SIGNALRServer.Hubs
{
    public class CalculatorHub : Hub
    {
        public double SUM(double x, double y)
        {
            var result = x + y;
            BroadcastToAll($"SUM({x}, {y}) = {result}");
            return result;
        }

        public double SUB(double x, double y)
        {
            var result = x - y;
            BroadcastToAll($"SUB({x}, {y}) = {result}");
            return result;
        }

        public double MUL(double x, double y)
        {
            var result = x * y;
            BroadcastToAll($"MUL({x}, {y}) = {result}");
            return result;
        }

        public double DIV(double x, double y)
        {
            if (y == 0)
            {
                BroadcastToAll("Division by zero attempted");
                throw new HubException("Division by zero is not allowed.");
            }
            var result = x / y;
            BroadcastToAll($"DIV({x}, {y}) = {result}");
            return result;
        }

        public int FACT(int x)
        {
            if (x < 0)
            {
                BroadcastToAll("Factorial of negative number attempted");
                throw new HubException("Factorial is not defined for negative numbers.");
            }
            try
            {
                checked
                {
                    int result = 1;
                    for (int i = 2; i <= x; i++)
                    {
                        result *= i;
                    }
                    BroadcastToAll($"FACT({x}) = {result}");
                    return result;
                }
            }
            catch (OverflowException)
            {
                BroadcastToAll("Factorial overflow attempted");
                throw new HubException("Factorial result exceeds int limit.");
            }
        }

        public async Task BroadcastToAll(string message)
        {
            await Clients.All.SendAsync("ReceiveBroadcast", $"[{DateTime.Now:HH:mm:ss}] {message}");
        }
    }
}