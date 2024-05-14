using Healthtrackr.Api.EndpointHandlers;

namespace Healthtrackr.Api.Extensions
{
    public static class EndpointRouteBuilderExtensions
    {
        public static void RegisterWeightEndpoints(this IEndpointRouteBuilder endpoints)
        {
            endpoints.MapGet("api/weight", WeightHandlers.GetWeights)
                .WithName("GetWeights");
        }
    }
}
