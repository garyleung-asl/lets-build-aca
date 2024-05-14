using Bogus;
using Healthtrackr.Api.Models;

namespace Healthtrackr.Api.Services
{
    public class FakeWeightManager : IWeightManager
    {
        private List<Weight> _weightList = new List<Weight>();

        public FakeWeightManager()
        {
            GenerateFakeWeights();
        }

        public Task<List<Weight>> GetWeights()
        {
            return Task.FromResult(_weightList);
        }

        private void GenerateFakeWeights()
        {
            for (int i = 0; i < 10; i++)
            {
                var weight = new Faker<Weight>()
                    .RuleFor(w => w.WeightId, f => Guid.NewGuid())
                    .RuleFor(w => w.MeasurementDate, f => f.Date.Past())
                    .RuleFor(w => w.BMI, f => f.Random.Double(10, 50))
                    .RuleFor(w => w.Fat, f => f.Random.Double(10, 50))
                    .RuleFor(w => w.MeasurementSource, f => f.Lorem.Word())
                    .RuleFor(w => w.Time, f => f.Date.Past())
                    .RuleFor(w => w.WeightInKG, f => f.Random.Double(50, 150))
                    .Generate();

                _weightList.Add(weight);
            }
        }
    }
}
