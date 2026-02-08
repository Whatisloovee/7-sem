using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR.Client;

class Program
{
    static async Task Main(string[] args)
    {
        var connection = new HubConnectionBuilder()
            .WithUrl("http://localhost:5000/calculatorHub")
            .Build();

        connection.On<string>(
            "ReceiveBroadcast",
            (message) =>
            {
                Console.WriteLine($"BROADCAST {DateTime.Now:HH:mm:ss} » {message}");
            }
        );

        try
        {
            await connection.StartAsync();
            // Тестовые вызовы
            double x = 10,
                y = 5;

            await TestOperation(connection, "SUM", x, y);
            await TestOperation(connection, "SUB", x, y);
            await TestOperation(connection, "MUL", x, y);

            // DIV - нормальный случай
            await TestOperation(connection, "DIV", x, y);

            // FACT - нормальный случай
            await TestOperation(connection, "FACT", 5, 0);

            // DIV - ошибка деления на ноль
            await TestOperation(connection, "DIV", x, 0);
            
            // FACT - переполнение
            await TestOperation(connection, "FACT", 100, 0);
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Connection Error: {ex.Message}");
            Console.ResetColor();
        }
        finally
        {
            await connection.StopAsync();
        }

        Console.WriteLine("Press any key to exit...");
        Console.ReadKey();
    }

    static async Task TestOperation(HubConnection connection, string operation, double x, double y)
    {
        try
        {
            object result;
            if (operation == "FACT")
                result = await connection.InvokeAsync<int>(operation, (int)x);
            else
                result = await connection.InvokeAsync<double>(operation, x, y);

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"RESULT {operation}({x}{(operation == "FACT" ? "" : $", {y}")}): {result}");
            Console.ResetColor();
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"ERROR {operation}({x}{(operation == "FACT" ? "" : $", {y}")}): {ex.Message}");
            Console.ResetColor();
        }
    }
}
