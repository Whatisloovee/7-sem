namespace BSTU.Results.Authenticate;

public interface IAuthenticateService
{
    string? SignIn(LoginModel model);
}