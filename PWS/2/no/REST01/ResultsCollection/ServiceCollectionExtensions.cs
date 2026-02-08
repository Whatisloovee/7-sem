using Microsoft.Extensions.DependencyInjection;

namespace BSTU.Results.Collection;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddResultsService(this IServiceCollection services, string filePath = "results.json")
    {
        services.AddTransient<IResultsService>(sp => new ResultsService(filePath));
        return services;
    }
}