namespace BSTU.Results.Authenticate
{
    public interface IAuthenticateService
    {
        string Authenticate(string login, string password);
    }
}