using Healthtrackr.Api.Models;

namespace Healthtrackr.Api.Services
{
    public interface IWeightManager
    {
        Task<List<Weight>> GetWeights();
    }
}
