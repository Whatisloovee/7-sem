using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace BSTU.Results.Authenticate;

public class AuthenticateService : IAuthenticateService
{
    // Хардкод пользователей для примера. В реальности - из БД с хэшами.
    private readonly Dictionary<string, (string Password, string Role)> _users = new()
    {
        { "reader", ("pass1", "READER") },
        { "writer", ("pass2", "WRITER") }
    };

    private readonly string _secretKey; // В реальности - из конфига
    private readonly string _issuer = "yourissuer";
    private readonly string _audience = "youraudience";

    public AuthenticateService(string secretKey)
    {
        _secretKey = secretKey;
    }

    public string? SignIn(LoginModel model)
    {
        if (_users.TryGetValue(model.Login, out var user) && user.Password == model.Password)
        {
            var claims = new[]
            {
                new Claim(ClaimTypes.Name, model.Login),
                new Claim(ClaimTypes.Role, user.Role)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _issuer,
                audience: _audience,
                claims: claims,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
        return null;
    }
}