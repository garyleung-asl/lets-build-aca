using Healthtrackr.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http;

namespace Healthtrackr.Web.Pages
{
    public class IndexModel : PageModel
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public List<Weight?> WeightList { get; set; }

        public IndexModel(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        public async Task<IActionResult> OnGet()
        {
            var httpClient = _httpClientFactory.CreateClient("BackendApi");
            WeightList = await httpClient.GetFromJsonAsync<List<Weight>>($"api/weight");
            return Page();
        }
    }
}
