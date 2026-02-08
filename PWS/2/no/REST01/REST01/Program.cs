using BSTU.Results.Collection;
using BSTU.Results.Authenticate;
using Microsoft.AspNetCore.Authentication.JwtBearer;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Добавьте секретный ключ в appsettings.json или здесь
var secretKey = "your_super_secret_key_at_least_32_chars"; // Минимум 16 символов, лучше 32+

// Внедрение сервисов
builder.Services.AddResultsService("results.json"); // Transient
builder.Services.AddAuthenticateService(secretKey); // Scoped + Auth

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("ReaderPolicy", policy => policy.RequireRole("READER", "WRITER")); // READER может читать, WRITER тоже
    options.AddPolicy("WriterPolicy", policy => policy.RequireRole("WRITER"));
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();