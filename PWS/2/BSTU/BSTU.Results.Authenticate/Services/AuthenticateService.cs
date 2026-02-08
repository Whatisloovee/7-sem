using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace BSTU.Results.Authenticate
{
    public class AuthenticateService : IAuthenticateService
    {
        private readonly string _jwtKey;
        private readonly string _jwtIssuer;
        private readonly string _jwtAudience;

        private readonly Dictionary<string, (string Password, string Role)> _users = new()
        {
            { "reader", ("reader123", "READER") },
            { "writer", ("writer123", "WRITER") },
            { "admin", ("admin123", "READER,WRITER") }
        };

        public AuthenticateService(string jwtKey, string jwtIssuer, string jwtAudience)
        {
            _jwtKey = jwtKey;
            _jwtIssuer = jwtIssuer;
            _jwtAudience = jwtAudience;
        }

        public string Authenticate(string login, string password)
        {
            if (_users.TryGetValue(login, out var user) && user.Password == password)
            {
                return GenerateJwtToken(login, user.Role);
            }
            return null;
        }

        private string GenerateJwtToken(string username, string role)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_jwtKey);
            
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, username)
            };

            var roles = role.Split(',');
            foreach (var r in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, r.Trim()));
            }

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddHours(1),
                Issuer = _jwtIssuer,
                Audience = _jwtAudience,
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}