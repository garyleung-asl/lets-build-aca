using Healthtrackr.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Healthtrackr.Web.Pages
{
    public class EditModel : PageModel
    {
        private readonly IHttpClientFactory _httpClientFactory;

        [BindProperty]
        public Weight Weight { get; set; }

        public EditModel(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        public async Task<IActionResult> OnGet(Guid? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            // direct svc to svc http request
            var httpClient = _httpClientFactory.CreateClient("BackendApi");
            Weight = await httpClient.GetFromJsonAsync<Weight>($"api/weight/{id}");

            if (Weight == null)
            {
                return NotFound();
            }

            return Page();
        }
    }
}
