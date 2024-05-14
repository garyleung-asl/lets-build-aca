using Healthtrackr.Api.Models;
using Healthtrackr.Api.Services;
using Microsoft.AspNetCore.Http.HttpResults;

namespace Healthtrackr.Api.EndpointHandlers
{
    public static class WeightHandlers
    {
        public static async Task<Ok<List<Weight>>> GetWeights(
            IWeightManager weightManager)
        {
            return TypedResults.Ok(await weightManager.GetWeights());
        }
    }
}
