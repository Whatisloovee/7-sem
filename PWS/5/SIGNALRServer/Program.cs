using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using SIGNALRServer.Hubs;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSignalR();
builder.Services.AddControllers();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

var app = builder.Build();

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseCors("AllowAll");
app.UseRouting();

app.MapHub<CalculatorHub>("/calculatorHub");
app.MapControllers();

app.Run();